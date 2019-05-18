#!/bin/bash

########             DEKLARACE PROMENNYCH            ##########################

listofkeys=""   # seznam parametru vyhledavani
errorik="Something went wrong."
pnumber=10 # cislo hledanych clanku je defaultne 10

###############################################################################
###############################################################################
################      FUNKCE       ############################################

helpik()
{
                echo " HELP"
        echo ""
        echo " NAME"
        echo " $0"
        echo ""
        echo " SYNOPSIS"
        echo " $0 [-f] [NUMBER] keys"
	echo " $0 [-r]
        echo ""
        echo " DESCRIPTION"
        echo " papers.sh is a script for looking for articles and storing them."
        echo -e " It uses two search engines: scholar.google.com and google.com\n \
to look for articles. ATTENTION! You need program googler to be installed.\n \
For more information follow https://github.com/jarun/googler#installation"
        echo ""
        echo " The program has two functions: find articles, browse loaded articles."
        echo -e " You can store your founded articles only in home directory\n \
in some existing or not existing directories."
        echo ""
        echo " Script works with the following options:"
        echo ""
        echo -e " -f, --find [NUMBER] [KEYS]..."
        echo -e "\tWith that option you can look for new papers.\n \
\tAfter -f keywords must be added. You can also choose, how many\n \
\tpapers will be downloaded, by adding a number [1-50] between -f an keys."
        echo ""
        echo -e "\tEvery time you call the program with that option, it\n \
\twould ask you, where to save new articles. It must be an existing directory\n \
\tin your home directory, or a name for a new directory, that will be created."
        echo -e "\tExample:"
        echo -e "\t\t $0 -f nilpotent matrices\n \
\t\t $0 -f 13 unix shell function"
        echo ""
        echo -e " -r, --read"
        echo -e "\tWill give you a list of directories, where your articles\n \
\tare stored. After choosing a directory, the list of articles will be\n \
\tshown. After entering a number of article, the document will be opened\n \
\tin your default pdf viewer. (changing of default viewer will be added later)"
        echo ""
        echo -e "\tIf some directories were removed, program identifies\n \
\tchanges only after choosing non existing directory in this -r option.\n \
\tAfter that the directory will be removed from the list."
        echo ""
        echo " -h, --help"
        echo -e "\tWill show you this help."
        echo ""
        echo ""
}

chybik()
{
        # if there is something wrong, this would be shown to user
        echo "Error: $errorik"
        echo "Print $0 -h, or $0 --h to show help page"

        cleaner

        exit
}

pdfconf()
{
        conf=".pdfviewer.conf"
        if [ -f "$conf" ]; then
                echo "okular" > "$conf"
                echo "evince" >> "$conf"
                echo "zathura" >> "$conf"
                echo "xpdf" >> "$conf"
                echo "gv" >> "$conf"
                echo "mupdf" >> "$conf"
                echo "qpdfviewer" >> "$conf"
        fi
}

###############################################################################
########################     FIND      ########################################

makefile()
{
        # vytvori adresar s nalezenymi clanky podle libovule uzivatele

        echo "Zadejte nazev slozky ve vasem domovskem adresari, kam si prejete \
clanky ulozit."
        read dirname

        # osetreni nazvu slozky
        # pokud nazev nezacina /, tak pridame adresu domu
        if [ -z $(echo "$dirname" | grep ^/ ) ]; then
                dirname="/home/$USER/$dirname"
        fi

        # vytvareni slozky pro papery
        if [ -d "$dirname" ]; then
                # nevytvarim slozku
                dirname="$dirname"
        else
                mkdir "$dirname"
        fi

        # pokud slozka s papery neexistuje, pak ji zalozime
        if [ -d "/home/$USER/papers" ]; then

                ## papers existuje
                cd "/home/$USER/papers"
                vypis=$( ls -1 )
                symname=$( echo "$dirname" | tr "/" ":" )

                # pokud symlink s nazvem slozky neexistuje vytvorime ho
                if [ -z $(echo "$vypis" | grep "$symname") ]; then

                        # odkaz neexistuje
                        touch "$symname"
                fi

                # premistime se do slozky, kam budeme stahovat papery
                cd "$dirname"
        else
                # zalozime papers
                mkdir "/home/$USER/papers"
                cd "/home/$USER/papers"
                vypis=$( ls -1 )
                symname=$( echo "$dirname" | tr "/" ":" )

                if [ -z $(echo "$vypis" | grep "$symname") ]; then
                        touch "$symname"
                fi

                cd "$dirname"
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

loadpage()
{

        curl -A 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) QtWebEngine/5.12.2 Chrome/69.0.3497.128 Safari/537.36' "https://scholar.google.cz/scholar?start=$s&q=$q&hl=cs&as_sdt=1,5&as_vis=1" 2> /dev/null > /tmp/hledej;


        # vyjmeme radky s h3
        grep -e =\"gs_r\ gs_or\ gs_scl\" /tmp/hledej | sed 's/<\/h3>/&\
        /g' > /tmp/odstavce
      
	j=1
        while read -r line; do
                
		if [ $j -le $i ]; then

                        if [ -n "$( echo "$line" | grep -e PDF )" ]; then

                                # vyjmeme odkaz
                                link=$( echo "$line" | sed 's/]/]\
                                /' | grep pdf | sed 's/.*.a href="//;
                                s/\(.pdf\)[^"]*".*/\1/g' | grep ^http )

                                # stahneme soubor
                                wget "$link" 2> /dev/null

                                # vyjmeme jmeno souboru
                                nameofloadfile="$( echo "$link" | sed 's/.*\///; s/%20/ /g' )"

                                # vyjmeme nazev clanku
                                nameoffile="$( echo "$line" | sed -e 's/.*\">\(.*.\)<\/a>.*/\1/' \
                                -e 's/<b>//' -e 's/<\/b>//').pdf"

                                mv "$nameofloadfile" "$nameoffile"
                                j=$(($j+1))
                        else

				# vyjmeme nazev clanku
                                nameoffile="$( echo "$line" | sed -e 's/.*\">\(.*.\)<\/a>.*/\1/' \
                                -e 's/<b>//' -e 's/<\/b>//')"
				# hledame pomoci googleru dany clanek v pdf formatu

				googler --json "$nameoffile filetype:pdf" > /tmp/googleni

				# stahovani
				link=$( cat /tmp/googleni | grep "\.pdf" | head -n1 | sed "s/.*http\(.*.\)\"/http\1/ " )
				
				if [ -n "$link" ]; then
					wget "$link" 2> /dev/null
				
					# vyjmeme jmeno souboru
                               		nameofloadfile="$( echo "$link" | sed 's/.*\///; s/%20/ /g' )"
					nameoffile="$nameoffile.pdf"
					if [ -z "$nameoffile" ]; then
						echo "some problems with loading file"
					else
						mv "$nameofloadfile" "$nameoffile" 2>/dev/null
					fi
					
					if [ $? -eq 0 ]; then	
						j=$(($j+1))
					else
						echo "some problems with loading file, may be it wouldnt have a good name"
					fi
				fi
					
                        fi
                else
                        break
                fi



        done < /tmp/odstavce
        if [ -n "$s" ]; then
                s=$(($s+10))
        else
                s=10
        fi
	j=$(($j-1))

}

findpapers()
{
        q=$( echo "$listofkeys" | tail -c +1 | tr ' ' '+')

        echo "parametry hledani: $q"


        s=""  # cislo stranky
        i=$pnumber  # cislo clanku
        while [ $i -ne 0 ]; do

                loadpage $i
                i=$(($i-$j))
        done

###############################################################################
#    stara verze - muze se hodit    #
# grep -e =\"gs_or_ggsm\" /tmp/hledej | sed 's/]/]\
#       /g' | grep pdf |sed 's/.*.a href="//; s/\(.pdf\)[^"]*".*/\1/' | grep ^http > /tmp/odkazy

#grep -e =\"gs_or_ggsm\" -e pdf /tmp/hledej | sed 's/<\/h3>/&\
#       /g' | grep -e PDF | sed -e 's/.*\">\(.*.\)<\/a>.*/\1/' -e 's/<b>//g' -e 's/<\/b>//g' \
#       > /tmp/nazvy

}

###############################################################################
#####################       READ        #######################################

choosedir()
{
        clear
	echo ""
        echo "Print the number of directory, you would like to open."
        echo "Or print 'q' for exit."

        # pokud slozka papers existuje
        if [ -d "/home/$USER/papers" ]; then

                if [ -z "$(ls -1 "/home/$USER/papers")" ]; then
                        echo "You have no papers yet."

                else

                        # vypise obsah slozky
                        ls -1 "/home/$USER/papers" | tr ":" "/" > /tmp/vypis
                        awk '{print " " NR " >\t" $s}' /tmp/vypis
                        # da se to udelat i pomoci cat -n, ale to se mi nelibi, jak to vypada
                        # zajimava je i moznost grep -n '^' , vzhled take neni tak pekny

                        # zpracovani volby uzivatele
                        read number
                        maxnumber=$(wc -l /tmp/vypis | sed -E 's/(^[1-9]+).*/\1/')
                        case "$number" in
                                q )
                                        exit;;
                                [1-9] | [1-9][0-9] | [1-9][0-9][0-9] )

                                        if [ $maxnumber -lt $number ]; then
                                                errorik="wrong line number"
                                                chybik

                                        else
                                                kam="$(sed "${number}q;d" /tmp/vypis)"

                                                if [ -d "$kam" ]; then
                                                        cd "$kam"
                                                        choosefile

                                                else
                                                        echo "we are sorry"
                                                        echo "direcctory does not exist"
                                                        rm "$( echo "$kam" | tr "/" ":" )"
                                                fi

                                        fi
                                        ;;
                                *)
                                        errorik="wrong input format"
                                        chybik;;
                        esac
                        choosedir
                fi

        # pokud papers neexistuje
        else
                echo "You have no papers yet."
                exit
        fi
}

choosefile()
{
	clear
        echo ""
        echo "Files from $(pwd)"
        echo "Print the number of file, you would like to open."
        echo "Print 'r' to choose another directory or 'q' for exit."

        # vypis clanku
        ls -1 | grep pdf > /tmp/vypis
        awk '{print " " NR " >\t" $s}' /tmp/vypis

        # zpracovani volby uzivatele
        read char
        maxnumber=$(wc -l /tmp/vypis | sed -E 's/(^[1-9]+).*/\1/')
        case "$char" in
                r )
                        choosedir;;
                q )
                        exit ;;

                [1-9] | [1-9][0-9] | [1-9][0-9][0-9] )

                        if [ $char -gt $maxnumber ]; then

                                errorik="wrong line number"
                                chybik
                                exit

                        else
                                filename=$( sed "${char}q;d" /tmp/vypis)
                                if [ -z $viewer ]; then
                                        xdg-open "$filename"
                                else
					"$viewer" "$filename"
				fi
                        fi;;
                * )
                        errorik="wrong input format."
                        chybik;;

        esac
}



reading()
{
# zobrazi uzivateli slozky, kam kdy ulozil svoje papery
# uzivatel si slozku vybere a pak si muze v dane slozce vybrat

choosedir
choosefile

}

####################################################################
####################################################################
################         MAIN        ###############################


trap "chybik"  2 3 15
# cteni vstupu
case "$1" in

        # osetreni optionu -f

        -f | --find )
                if [ $# -eq 1 ]; then
                        chybik
                else

                # pokud druhy parametr je cislo
                case "$2" in
                        [0-9] | [0-9][0-9] )

                                pnumber=$2

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
