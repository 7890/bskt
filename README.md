bskt - basket
=============

bskt is the bootstrap script to create a new empty 'data basket'.

a basket is one file that can contain a collection of files and a set 
of standard methods to manipulate the basket.

any basket can create new empty baskets or a compressed bootstrapping version 
of itself.

dependencies
------------

bskt will check on startup if all these tools are available on your system:
xmlstarlet, md5sum, base64, gzip, sed, split, du, file, rev, cat, cut, head, chmod, touch

quick start
-----------

```
 bskt stuff              #create an empty basket from minified bskt script
                         #(bskt assumed to be in $PATH)
 ./stuff add my.xml      #add file
 cat a.png | ./stuff add - my.png    #add from stdin
 ./stuff list            #show contents
 ./stuff dumpat 1        #dump first file to stdout
 ./stuff saveat 1 /tmp   #save first file to /tmp
 ./stuff delete a.xml    #delete from basket
 ./stuff strip bunch     #create a new empty basket named bunch
 ./bunch --help          #please see help for a full list
```

quick install
-------------

```
 wget https://github.com/7890/bskt/raw/master/dist/bskt
 chmod 755 bskt
 #mv bskt ~/bin                   #example place to store
 #sudo mv bskt /usr/local/bin     #alternative place
```

bskt is experimental. use at your own risk.

help
----

```
 ./abasket --help

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  _         _    _    
 | |__  ___| | _| |_   v0.1 written by Thomas Brand
 | '_ \/ __| |/ / __|  http://github.com/7890/bskt
 | |_) \__ \   <| |_   free software (LGPL/GPL)
 |_.__/|___/_|\_\___|  without any warranty

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

syntax: bskt <name of your basket>
  create an empty basket from the bskt bootstrap

syntax: <name of your basket> <command> (<command argument>)*
  operate on the basket

commands:

list
   show basket contents
add <file> (name)
   add a file to the basket, use different name optionally
add - (<name>)
   add file from stdin (with temporary name if no filename given)
dump <file>
   write file contents (original) to stdout
dumpat <index>
   write file contents (original) to stdout
dumpraw <file>
   write raw (base64,gzipped) file contents to stdout
dumprawat <index>
   write raw (base64,gzipped) file contents to stdout
dumpxml
   write all files (base64,gzipped) in xml structure to stdout
   any xml operation can then be applied to the basket contents with |
dumpxml <file>
   write xml to stdout for specific file
dumpxmlat <index>
   write xml to stdout for specific index
save <file> (<out path>) (<out filename>)
   write file to current or given path. if path given, optional filename.
saveat <index> (<out path>) (<out filename>)
   write file to to current or given path. if path given, optional filename
delete <file>
   remove file from basket
deleteat <index>
   remove file from basket
strip
   write the bskt script to stdout (strip off all data)
strip <out file>
   same as strip, to given file
bootstrap <out file>
   write the bskt script (compressed) to given file
clone <out file>
   copy the basket (with data) to given new basket

example: create basket, add two files:
./bskt bunch; ./bunch add a.txt; ./bunch add z.png;

example: show contents, clone, dump file:
./bunch list; ./bunch clone another; ./another dump a.txt

example: add content from stdin, delete at index 0:
cat myfile | ./another add -; ./another deleteat 0

example: create bskt bootstrap file from any basket:
./another bootstrap mybootstrap

```
