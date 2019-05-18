# papers.sh
DESCRIPTION

 papers.sh is a script for looking for articles and storing them.
 It uses two search engines: scholar.google.com and google.com
 to look for articles. ATTENTION! You need program googler to be installed.
 For more information follow https://github.com/jarun/googler#installation

 The program has two functions: find articles, browse loaded articles.
 You can store your founded articles only in home directory in some existing
 or not existing directories.
 
SYNOPSIS

papers.sh [-f] [NUMBER] keys
papers.sh [-r]

OPTIONS

         -f, --find [NUMBER] [KEYS]...
                With that option you can look for new papers.
                After -f keywords must be added. You can also choose, how many
                papers will be downloaded, by adding a number [1-50] between -f an keys.
                Every time you call the program with that option, it
                would ask you, where to save new articles. It must be an existing directory
                in your home directory, or a name for a new directory, that will be created.
                Example:
                         ./papers.sh -f nilpotent matrices
                         ./papers.sh -f 13 unix shell function

         -r, --read
                Will gice you a list of directories, where your articles
                are stored. After choosing a directory, the list of articles will be
                shown. After entering a number of article, the document will be opened
                in your default pdf viewer. (changing of default viewer will be added later)

                If some directories were removed, program identifies
                changes only after choosing non existing directory in this -r option.
                After that the directory will be removed from the list.
                
         -h, --help
 
 
