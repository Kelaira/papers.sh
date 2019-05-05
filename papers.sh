#!/bin/bash

#deklarace promennych

listofkeys=""   # seznam parametru vyhledavani
errorik="Something went wrong."

# funkce

helpik()
{
        echo "----HELP----"
        echo ""
        echo "--NAME--"
        echo "$0"
        echo ""
        echo "--SYNOPSIS--"
        echo "$0 [OPTION] [PARAMETRS]"
        echo ""
        echo "--DESCRIPTION--"
        echo "papers.sh is a script for looking for and storing papers"
        echo "it looks for new titels through scholar.google and stores them whenever \
you want in your home directory"
        echo "Script works with the following options:"
        echo " -f, --find"
        echo "\t With that option you can look for new papers."
        echo "\t After option you should add \"key\" words of your dream titel."
        echo "\t With the number after -f you can choose, how many papers (up to 50) would you like to find."
        echo "\t Example:"
        echo "\t\t '$0 -f nilpotent matrices' will find papers with words 'nilpotent' and 'matrices' in it"
        echo "\t\t '$0 -f 13 unix shell function' will find 13 papers with words 'unix', 'shell', 'function'"
        echo "\t Every time you call script with that option, it would ask you, where to save new papers"
        echo "\t It must be an existing directory in your home directory, or a name for non existing directory, that would be created"
        echo ""
        echo " -r, --read"
        echo "\t With that option, you can open your later downloaded papers"
        echo ""
        echo " -h, --help"
        echo "\t Will show you this help page."
}

chybik()
{
# if there is something wrong, this would be shown to user
echo "Error: $errorik Print $0 -h, or $0 --h to show help page"

cleaner

exit
}

viewerconf()
{
        conf=".pdfviewer.conf"
        if [ -f "$conf" ]; then
                echo "okular" > "$conf"
                echo "evince" >> "$conf"
                echo "zathura" >> "$conf"
                echo "" >> "$conf"
                echo "" >> "$conf"
                echo "" >> "$conf"
                echo "" >> "$conf"
        fi
}
makefile()
{
# vytvori soubor s nalezenymi clanky podle libovule uzivatele

echo "Zadejte nazev slozky ve vasem domovskem adresari, kam si prejete \
clanky ulozit."
read dirname
# vytvoreni seznamu paperu v home dir
# pokud existuje seznam slozek s papery
if [ -f .papers ]; then
        # a je neprazdny
        if [ -n .papers ]; then
                echo "$dirname" >> .papers
        fi
else
        echo "$dirname" > .papers
fi

# premisteni do slozky, kam se budou ukladat papery
if [ -e "$dirname" ]; then
        cd /home/$USER/$dirname
else
        cd /home/$USER
        mkdir "$dirname"
        cd $dirname
fi
}

cleaner()
{
# az script skonci, smaze po sobe zbytecne veci
if [ -f /tmp/hledej ];then
        rm /tmp/hledej
fi
if [ -f /tmp/odkazy ]; then
        rm /tmp/odkazy
fi
if [ -f /tmp/nazvy ]; then
        rm /tmp/nazvy
fi

}

findpapers()
{

q=$( echo "$listofkeys" | tail -c +1 | tr ' ' '+')

echo "parametry hledani: $q"

curl -A 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) QtWebEngine/5.12.2 Chrome/69.0.3497.128 Safari/537.36' "https://scholar.google.cz/scholar?start=0&q=$q&hl=cs&as_sdt=1,5&as_vis=1" 2> /dev/null > /tmp/hledej;

grep -e =\"gs_or_ggsm\" /tmp/hledej | sed 's/]/]\
        /g' | grep pdf |sed 's/.*.a href="//; s/\(.pdf\)[^"]*".*/\1/' | grep ^http > /tmp/odkazy

grep -e =\"gs_or_ggsm\" -e pdf /tmp/hledej | sed 's/<\/h3>/&\
        /g' | grep -e PDF | sed -e 's/.*\">\(.*.\)<\/a>.*/\1/' -e 's/<b>//g' -e 's/<\/b>//g' \
        > /tmp/nazvy

i=0
while read -r line; do
        i=$(($i + 1))
        # stahne soubor
        wget "$line" 2> /dev/null
        # vyjme nazev stazeneho souboru
        nameofloadfile=$( echo "$line" | sed 's/.*\///; s/%20/ /g')
        nameoffile="$( head -n $i /tmp/nazvy | tail -n 1 ).pdf"
        # prejmenuje soubor podle nazvu clanku
        mv "$nameofloadfile" "$nameoffile"
        # prida clanek do seznamu clanku v slozce, soubor je "neviditelny"
        if [ -f ".$dirname" ]; then
                echo "$nameoffile" >> ".$dirname"
        else
                echo "$nameoffile" > ".$dirname"
        fi

done < /tmp/odkazy
}

choosedir()
{
echo "Print the number of directory, you would like to open."
echo "Or print 'q' for exit."
        awk '{print " " NR " >\t" $s}' .papers
        # da se to udelat i pomoci cat -n, ale to se mi nelibi, jak to vypada
        # zajimava je i moznost grep -n '^' , vzhled take neni tak pekny
        read number
        case "$number" in
                q )
                        exit;;
                [0-9] | [0-9][0-9] | [0-9][0-9][0-9] )

                        jmeno=$(sed "${number}q;d" .papers);;
                *)
                        errorik="wrong input format"
                        chybik;;
        esac
}

choosefile()
{
        echo "Files from $jmeno"
        echo "Print the number of file, you would like to open."
        echo "Or print 'r' to choose another directory"
        awk '{print " " NR " >\t" $s}' /home/$USER/$jmeno/".$jmeno"
        read char
        case "$char" in
                r )
                        choosedir;;

                [0-9] | [0-9][0-9] | [0-9][0-9][0-9] )
                        cd /home/$USER/$jmeno
                        filename=$(sed "${char}q;d" ".$jmeno")
                        openfile;;
                * )
                        errorik="wrong input format."
                        chybik;;

        esac
}

openfile()
{
echo "$filename"
# xdg-open "$filename"
}

reading()
{
# zobrazi uzivateli slozky, kam kdy ulozil svoje papery
# uzivatel si slozku vybere a pak si muze v dane slozce vybrat
if [ -f .papers ]; then
        choosedir
        choosefile

else
        echo "You have no papers yet."
fi
}


####################################################################
####################################################################
############################ MAIN ##################################


trap "chybik"  2 3 15
# cteni vstupu
case "$1" in

        # osetreni optionu -f

        -f | --find )
                if [ $# -eq 1 ]; then
                        chybik
                else
                # pokud druhy parametr neni cislo
                case "$2" in
                        [0-9] | [0-9][0-9] )

                # prectu zbytek

                                while [ -n "$3" ]; do
                                        if [ -n "$listofkeys" ]; then
                                                listofkeys="$listofkeys $3"
                                        else
                                                listofkeys="$3"
                                        fi
                                        shift
                                done;;
                        * )


                # prectu parametry vyhledavani

                                while [ -n "$2" ]; do
                                        if [ -n "$listofkeys" ]; then
                                                listofkeys="$listofkeys $2"
                                        else
                                                listofkeys="$2"
                                        fi
                                        shift
                                        echo "$listofkeys"
                                done;;
                esac

                makefile

                findpapers

                echo "soubory sis ulozil do $dirname"
                fi;;

        -r | --read )
                if [ $# -eq 1 ]; then
                        reading
                else
                        chybik
                fi;;

        -h | --help )
                if [ $# -eq 1 ]; then
                        helpik
                else
                        chybik
                fi;;
        * )
                chybik;;
esac
