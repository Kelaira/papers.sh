# papers.sh
DESCRIPTION
        
    papers.sh is a script for searching for articles in PDF and storing them.
    It uses two search engines, scholar.google.com and google.com
    to search for articles. ATTENTION! You need program googler to be installed.
    For more information follow:
   https://github.com/jarun/googler#installation
                
    The program has two functions: find articles, browse loaded articles.
    Found articles can be stored in existing or non-existing directories
    of your home directory.
 
 
SYNOPSIS

    papers.sh [-f] [NUMBER] keys
    papers.sh [-r]

OPTIONS

         -f, --find [NUMBER] [KEYS]...
                With this option you can search for new papers. After -f keywords
                must be added. You can also choose how many papers will be downloaded 
                by adding a number [1-50] between -f and keywords.
                
                Every time you call the program with this option, it will ask you,
                where to save new articles. It must be an existing directory
                in your home directory, or a name for a new directory, that will be created.
                
                Example:
                         ./papers.sh -f nilpotent matrices
                         ./papers.sh -f 13 unix shell function

         -r, --read
                Will give you a list of directories, where your articles are stored. 
                After choosing a directory, the list of articles will beshown. After 
                entering a number of article, the document will be opened in your default 
                pdf viewer. Changing of default viewer will be added later.

                If some directories were removed, program identifies changes only after 
                choosing non-existing directory from the directory list. After that the directory 
                will be removed from the list.
                
         -h, --help
 
 
