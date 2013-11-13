#!/bin/bash

#if no parameter given, mainMethod() will be called

#application specific notes (mainMethod)
##########################################
#
#
#
#
#

#generic bskt
##########################################

#file: basket.sh
#part of bskt. see http://github.com/7890/bskt
#//tb/130604//131113

VERSION=0.2
PROJECT_URL=http://github.com/7890/bskt

#to create boostrap block:
#cat <this script> | gzip -9 - | base64 -

#need to support wildcards for add / dump

##########################################
mainMethod()
{
	#default action: none
	echo -e "no parameters given and mainMethod not customized."
	echo -e "see mainMethod in $0"
	exit 0
}
##########################################

checkAvail()
{
	which "$1" >/dev/null 2>&1
	ret=$?
	if [ $ret -ne 0 ]
	then
		echo -e "tool \"$1\" not found. please install"
		exit 1
	fi
}

printHelp()
{
	echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
	echo "  _         _    _    "
	echo " | |__  ___| | _| |_   v"$VERSION written by Thomas Brand
	echo " | '_ \/ __| |/ / __|  $PROJECT_URL"
	echo " | |_) \__ \   <| |_   free software (LGPL/GPL)" 
	echo " |_.__/|___/_|\_\\___|  without any warranty" 
	echo ''
	echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
	echo ''
	echo 'syntax: bskt <name of your basket>'
	echo '  create an empty basket from the bskt bootstrap'
	echo ''
	echo 'syntax: <name of your basket> <command> (<command argument>)*'
	echo '  operate on the basket'
	echo ''
	echo 'commands:'
	echo ''
	echo 'list'
	echo '   show basket contents'
	echo 'add <file> (name)'
	echo '   add a file to the basket, use different name optionally'
	echo 'add - (<name>)'
	echo '   add file from stdin (with temporary name if no filename given)'
	echo 'dump <file>'
	echo '   write file contents (original) to stdout'
	echo 'dumpat <index>'
	echo '   write file contents (original) to stdout'
	echo 'dumpraw <file>'
	echo '   write raw (base64,gzipped) file contents to stdout'
	echo 'dumprawat <index>'
	echo '   write raw (base64,gzipped) file contents to stdout'
	echo 'dumpxml'
	echo '   write all files (base64,gzipped) in xml structure to stdout'
	echo '   any xml operation can then be applied to the basket contents with |'
	echo 'dumpxml <file>'
	echo '   write xml to stdout for specific file'
	echo 'dumpxmlat <index>'
	echo '   write xml to stdout for specific index'
	echo 'save <file> (<out path>) (<out filename>)'
	echo '   write file to current or given path. if path given, optional filename.'
	echo 'saveat <index> (<out path>) (<out filename>)'
	echo '   write file to to current or given path. if path given, optional filename'
	echo 'delete <file>'
	echo '   remove file from basket'
	echo 'deleteat <index>'
	echo '   remove file from basket'
	echo 'strip'
	echo '   write the bskt script to stdout (strip off all data)'
	echo 'strip <out file>'
	echo '   same as strip, to given file'
	echo 'bootstrap <out file>'
	echo '   write the bskt script (compressed) to given file'
	echo 'clone <out file>'
	echo '   copy the basket (with data) to given new basket'
	echo ''
	echo 'example: create basket, add two files:'
	echo './bskt bunch; ./bunch add a.txt; ./bunch add z.png;'
	echo ''
	echo 'example: show contents, clone, dump file:'
	echo './bunch list; ./bunch clone another; ./another dump a.txt'
	echo ''
	echo 'example: add content from stdin, delete at index 0:'
	echo 'cat myfile | ./another add -; ./another deleteat 0'
	echo ''
	echo 'example: create bskt bootstrap file from any basket:'
	echo './another bootstrap mybootstrap'
	echo ''

	exit 0

	#future methods
	#echo 'replace <file>'
	#echo 'tarall <out tar file>'
	#echo 'showlog'
	#echo 'log <manual entry>'
	#echo 'cleanlog'
	#echo 'showplug'
	#echo 'addplug <file>'
	#echo 'plug <plug name> (<plug options> ...)'
}

for tool in {xmlstarlet,md5sum,base64,gzip,sed,split,du,file,rev,cat,cut,head,chmod,touch}; \
	do checkAvail "$tool"; done

SCRIPTNAME=`echo "$0" | rev | cut -d"/" -f1 | rev`

#find out in which directory this script is in, following symlinks
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

#absolute uri of this script
S="$DIR/$SCRIPTNAME"
#echo "$S"

DELIM="__delim__"

#create helper script, prepend/enclose in stream
ENCLOSE=`mktemp`
echo "IyEvYmluL2Jhc2gKZWNobyAtZW4gIjwkQD4iCmNhdCAtCmVjaG8gLWVuICI8LyRAPiIK" | base64 -d - > "$ENCLOSE"
chmod 755 "$ENCLOSE"
#needs to be deleted on exit
trap "rm -f $ENCLOSE" EXIT

#########################################################
# call mainMethod when no params given
if [ x"$1" = "x" ]
then
        mainMethod
fi
#########################################################


if [ x"$1" = "xhelp" ]
then
	printHelp
fi
if [ x"$1" = "x-h" ]
then
	printHelp
fi
if [ x"$1" = "x--help" ]
then
	printHelp
fi
if [ x"$1" = "x-v" ]
then
	echo $VERSION
	exit 0
fi
if [ x"$1" = "x--version" ]
then
	echo $VERSION
	exit 0
fi

#=====================================

#find out line of delim inside this script
DELIM_LNO=`cat "$S" | grep -n "^${DELIM}$" | cut -d":" -f1`

#=====================================

if [ x"$1" = "xdelete" ]
then

	if [ x"$2" = "x" ]
	then
		echo -e "can not delete without parameter."
		exit 1
	fi

	NEW=`mktemp`

	cat "$S" | head -"$DELIM_LNO" > "$NEW"
	chmod 755 "$NEW"

	cat "$S" | sed "1,${DELIM_LNO}d" | bash "$ENCLOSE" "items" \
		| xmlstarlet sel -t -m "//item[@name!='${2}']" -c . -n >> "$NEW"
	
	#echo "$NEW"
	mv "$NEW" "$S"

	exit 0
fi

#=====================================

if [ x"$1" = "xdeleteat" ]
then
	if [ x"$2" = "x" ]
	then
		echo -e "can not delete without parameter."
		exit 1
	fi

	#check if integer
	if ! expr "$2" : '-\?[0-9]\+$' >/dev/null
	then
		echo -e "need index."
		exit 1
	fi

	NEW=`mktemp`

	cat "$S" | head -"$DELIM_LNO" > "$NEW"
	chmod 755 "$NEW"

	cat "$S" | sed "1,${DELIM_LNO}d" | bash "$ENCLOSE" "items" \
		| xmlstarlet sel -t -m "//item[position()!='${2}']" -c . -n >> "$NEW"
	
	#echo "$NEW"
	mv "$NEW" "$S"

	exit 0
fi

#=====================================

if [ x"$1" = "xstrip" ]
then
	touch "$2"

	#can read
        if [ -r "$2" ]
	then
		cat "$S" | head -"$DELIM_LNO" > "$2"
		chmod 755 "$2"

	else
		#strip head off and decode
		cat "$S" | head -"$DELIM_LNO" 
	fi

	exit 0
fi

#=====================================

if [ x"$1" = "xbootstrap" ]
then
	if [ x"$2" = "x" ]
	then
		echo -e "can not bootstrap without parameter."
		exit 1
	fi

	touch "$2"

	#can read
        if [ -r "$2" ]
	then

		#header of bootstrap script
		#cat bskt.tmpl | gzip -9 - | base64 -

		(cat | base64 -d - | gzip -d -> "$2") <<_EOF_
H4sIAJW2g1ICA51T227TQBB9znzF1IlIK61jpyUtbZMghIIAIYLC5YWgyLHH2VXXu5a9TlJK/51d
OyVBSAXhF+/lnJlzZmfaR8FSqGAZlRygnQpJV7gsb0zPZLmEdh4VBnXaHGFJhNyY/CoIVsLwatmL
dRZcPLsMAweAdhCYZdA/C8/DQWD//X7/zEbNhBLpLW4sBePI7OPjD1x9Fzn6l+jbtRVB50/RB/gy
mX18M30/Cnun8GE2fTt5+WnxefZu9FhyKLnevCaZH5/AHbQo5hp9wq4iStD6iDIyVPS6B1flrTLR
tjGMQ2deWZTzq2jj5NyQGR8QPFcAr3OgCO4BRIpfcet1+h6O0Nt6+A0MJwXQelBkI2yFwRBS8Qfc
X/8iNHk6O/OPkvw1FaXQ6n+4fE/6J4E+t4i/cGJO8c2LdSRkU/0NFzHHOsY4SGgdqEpKPB0/6UOr
IDPqPIdWnadjd+grwtAmaDUZ9vU2Wkuc2zBzD5U2mOpKJT3MJdlWQaFKE0npOYaTYmNbLfZFUl1g
TRUK77aZtLBCkmFZMiirjDV9xlzrsZISVuZSGJZUzHUAK2jNbJeyuDKMU5SwmGc6YUZXMb+/xjng
7ks07m1bry6jd22PFQHU8LoAu4Ieob9pCvLbizmXcaS6BjeFMGRlOxA8GHK1bTc3TTtiGRciNw63
EmtS6DRDLREvBoMm47Gbsv08JfV0NZPm1uMadYLDIS4m01cL+Anies9lBQQAAA==
_EOF_

		#compressed version of this script
		cat "$S" | head -"$DELIM_LNO" | gzip -9 - | base64 - >> "$2"
		echo '_EOF_' >> "$2"
		echo 'echo "new basket created."' >> "$2"
		chmod 755 "$2"
	fi

	exit 0
fi

#=====================================

if [ x"$1" = "xclone" ]
then
	if [ x"$2" = "x" ]
	then
		echo -e "can not clone without parameter."
		exit 1
	fi

	touch "$2"

	#can read
        if [ -r "$2" ]
	then
		cp "$S" "$2"
		chmod 755 "$2"
	else
		echo -e "can not clone to $2"
	fi

	exit 0
fi

#=====================================

if [ x"$1" = "xadd" ]
then
	#need to prevent to add files with the same name, files with same md5sum

	#if from stdin	
	if [ x"$2" = "x-" ]
	then
		IN=`mktemp`
		cat - > "$IN"

		#call myself
		"$S" add "$IN" "$3"

		rm -f "$IN"

		exit 0
	fi

	#can read
	if [ -r "$2" ]
	then

		if [ x"$3" = "x" ]
		then
			NAME=`echo "$2" | rev | cut -d"/" -f1 | rev`
		else
			NAME="$3"
		fi

		MD5=`md5sum "$2" | cut -d" " -f1`
		SIZE=`du -h "$2" | tr "\t" " " | cut -d" " -f1`
		TYPE=`file "$2" | cut -d" " -f2-`
		UTCS=`date --utc +%s`

		#enclose in item tag
		echo '<item name="'$NAME'" md5="'$MD5'" size="'$SIZE'" utc="'$UTCS'" type="'$TYPE'">' >> "$S"

		#create chunks in tmpdir and output as xml
		TMPDIR=`mktemp -d`
		gzip -9 "$2" --stdout | base64 - | split -a 10 --lines 500 - "$TMPDIR"/chunk.
		ls -1 "$TMPDIR"/chunk.* | while read line; do echo "<chunk>"; cat "$line"; echo "</chunk>"; done >> "$S"

		#clean up
		rm -rf "$TMPDIR"

		#gzip -9 "$2" --stdout | base64 - >> "$S"

		#close tag
		echo '</item>' >> "$S"
	else
		echo -e 'file: can not find/access/read '"$2"
		exit 1
	fi

	exit 0
fi

#=====================================

if [ x"$1" = "xlist" ]
then
	#strip head off and decode
	cat "$S" | sed "1,${DELIM_LNO}d" | bash "$ENCLOSE" "items" | xmlstarlet sel -t -m "//item" -v "position()" -o ";" -v "@name" -o ";" -v "@size" -o ";" -v "@md5" -o ";" -v "@utc" -o ";" -v "@type" -n \
		| grep -v "^$"

	exit 0
fi

#=====================================

if [ x"$1" = "xdumpxml" ]
then
	#if file name given
	if [ x"$2" != "x" ]
	then
		#strip head off and decode, take first if there are multiple with same name
		cat "$S" | sed "1,${DELIM_LNO}d" | bash "$ENCLOSE" "items" \
			| xmlstarlet sel -t -m "//item[@name='$2']" -c . \
			| bash "$ENCLOSE" "items" | xmlstarlet sel -t -m "//item[1]" -c .
	else
		#dump all
		#strip head off and decode
		cat "$S" | sed "1,${DELIM_LNO}d" | bash "$ENCLOSE" "items" | xmlstarlet fo
	fi

	exit 0
fi

#=====================================

if [ x"$1" = "xdumpxmlat" ]
then
	#if param given
	if [ x"$2" != "x" ]
	then
		#check if integer
		if ! expr "$2" : '-\?[0-9]\+$' >/dev/null
		then
			echo -e "need index."
			exit 1
		fi

		#strip head off and decode, take first if there are multiple with same name
		cat "$S" | sed "1,${DELIM_LNO}d" | bash "$ENCLOSE" "items" \
			| xmlstarlet sel -t -m "//item[position()='$2']" -c . \
			| bash "$ENCLOSE" "items" | xmlstarlet sel -t -m "//item[1]" -c .

	else
		echo -e "need paramter."
		exit 1
	fi

	exit 0
fi

#=====================================

if [ x"$1" = "xdumpraw" ]
then
	#if file name given
	if [ x"$2" != "x" ]
	then
		#strip head off and decode, take first if there are multiple with same name
		cat "$S" | sed "1,${DELIM_LNO}d" | bash "$ENCLOSE" "items" \
			| xmlstarlet sel -t -m "//item[@name='$2']" -c . \
			| bash "$ENCLOSE" "items" | xmlstarlet sel -t -m "//item[1]" \
			-v . 
	else
		echo -e "need paramter."
		exit 1
	fi

	exit 0
fi

#=====================================

if [ x"$1" = "xdumprawat" ]
then
	#if param given
	if [ x"$2" != "x" ]
	then
		#check if integer
		if ! expr "$2" : '-\?[0-9]\+$' >/dev/null
		then
			echo -e "need index."
			exit 1
		fi

		#strip head off and decode, take first if there are multiple with same name
		cat "$S" | sed "1,${DELIM_LNO}d" | bash "$ENCLOSE" "items" \
			| xmlstarlet sel -t -m "//item[position()='$2']" -c . \
			| bash "$ENCLOSE" "items" | xmlstarlet sel -t -m "//item[1]" \
			-v . 
	else
		echo -e "need paramter."
		exit 1
	fi

	exit 0
fi

#=====================================

if [ x"$1" = "xsave" ]
then
	#if file name given
	if [ x"$2" != "x" ]
	then

		OUTPATH="."

		#path given
		if [ x"$3" != "x" ]
		then
			OUTPATH="$3"
		fi

		OUTFILE="$2"

		#file given
		if [ x"$4" != "x" ]
		then
			OUTFILE="$4"
		fi

		#strip head off and decode, take first if there are multiple with same name
		cat "$S" | sed "1,${DELIM_LNO}d" | bash "$ENCLOSE" "items" \
			| xmlstarlet sel -t -m "//item[@name='$2']" -c . \
			| bash "$ENCLOSE" "items" | xmlstarlet sel -t -m "//item[1]" \
			-v . | base64 -d - | gzip -d - > "$OUTPATH"/"$OUTFILE"

	else
		echo -e "need paramter."
		exit 1
	fi

	exit 0
fi

#=====================================

if [ x"$1" = "xsaveat" ]
then
	#if index given
	if [ x"$2" != "x" ]
	then

		#check if integer
		if ! expr "$2" : '-\?[0-9]\+$' >/dev/null
		then
			echo -e "need index."
			exit 1
		fi

		OUTPATH="."

		#path given
		if [ x"$3" != "x" ]
		then
			OUTPATH="$3"
		fi

		#get filename at index
		OUTFILE=`cat "$S" | sed "1,${DELIM_LNO}d" | bash "$ENCLOSE" "items" | xmlstarlet sel -t -m "//item[position()='$2']/@name" -v .`

		#file given
		if [ x"$4" != "x" ]
		then
			OUTFILE="$4"
		fi

		#strip head off and decode, take first if there are multiple with same name
		cat "$S" | sed "1,${DELIM_LNO}d" | bash "$ENCLOSE" "items" \
			| xmlstarlet sel -t -m "//item[position()='$2']" -c . \
			| bash "$ENCLOSE" "items" | xmlstarlet sel -t -m "//item[1]" \
			-v . | base64 -d - | gzip -d - > "$OUTPATH"/"$OUTFILE"

	else
		echo -e "need paramter."
		exit 1
	fi

	exit 0
fi


#=====================================

if [ x"$1" = "xdump" ]
then
	#if file name given
	if [ x"$2" != "x" ]
	then
		#strip head off and decode, take first if there are multiple with same name
		cat "$S" | sed "1,${DELIM_LNO}d" | bash "$ENCLOSE" "items" \
			| xmlstarlet sel -t -m "//item[@name='$2']" -c . \
			| bash "$ENCLOSE" "items" | xmlstarlet sel -t -m "//item[1]" \
			-v . | base64 -d - | gzip -d -
	else
		echo -e "need paramter."
		exit 1
	fi

	exit 0
fi

#=====================================

if [ x"$1" = "xdumpat" ]
then
	#if param given
	if [ x"$2" != "x" ]
	then
		#check if integer
		if ! expr "$2" : '-\?[0-9]\+$' >/dev/null
		then
			echo -e "need index."
			exit 1
		fi

		#strip head off and decode, take first if there are multiple with same name
		cat "$S" | sed "1,${DELIM_LNO}d" | bash "$ENCLOSE" "items" \
			| xmlstarlet sel -t -m "//item[position()='$2']" -c . \
			| bash "$ENCLOSE" "items" | xmlstarlet sel -t -m "//item[1]" \
			-v . | base64 -d - | gzip -d -
	else
		echo -e "need parameter."
		exit 1
	fi

	exit 0
fi

#=====================================

echo -e "wrong or no parameters given."
echo -e "type \"$SCRIPTNAME help\" for more information"

exit 0

#find out line of delim inside this script
#DELIM_LNO=`cat "$S" | grep -n "^${DELIM}$" | cut -d":" -f1`

#strip head off and decode
#cat "$S" | sed "1,${DELIM_LNO}d" | bash "$ENCLOSE" "items" | xmlstarlet sel -t -m "//item" -v . | base64 -d - | gzip -d -

__delim__
