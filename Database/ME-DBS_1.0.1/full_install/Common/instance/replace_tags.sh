##  **********************************************************************************************************
##  replace_tags.sh
##  Date: Sept 28th, 2005    
##  
##  Pass four parameters into this shell file:
##    1. First one is path of directory contains all sub-directories and files in which 
##	   strings need to be replaced. eg ($1)
##    2. Second parameter is the name of the config file with its path. eg ($2)
##
##  Note: None of the path names should include blanks characters in them.
##
##  Important:  
##  1. This shell file replaces the original files including sub-directories with the ones in which the tags
##     have been replaced.  If you need to preserve a copy of your original files, please
##     do so prior to running this batch file.
##  2. Path names passed as parameter must not contain blanks.
##  **********************************************************************************************************

echo +
	echo Replace the original file by tag values
echo +
      find $1 -type f -name '*.*' -print | while read i
      do
	sed -f $2  $i > $i.tmp && mv -f $i.tmp $i
      done

