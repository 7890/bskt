Examples
========

atest
-----

A pure test. Includes Java source code. 
The automatically called mainMethod() in atest will compile the program 
using a local javac (if available) with varying options and 
run the program.


```
$ ./atest list #show contents
1;Test.java;4.0K;544fb77096b11f0a84731c6642c84a8e;1384508475;ASCII Java program text

$ ./atest dump Test.java #show Java source
//javac Test.java; java Test

import java.io.InputStream;
import java.io.DataInputStream;

class Test
{
        public static void main(String[] args) throws Exception
        {
                System.out.println("hello from java!");
                System.out.println("jre version: "+System.getProperty("java.version"));
                Test t=new Test();
                System.exit(0);
        }
        public Test() throws Exception
        {
                //read Test.class to determine version of bytecode

                //http://stackoverflow.com/questions/1707139/how-to-determine-the-java-byte-code-version-of-the-current-class-programatically
                InputStream in = getClass().getClassLoader().getResourceAsStream(
                        getClass().getName().replace('.', '/') + ".class");
                DataInputStream data = new DataInputStream(in);
                int magic = data.readInt();
                if (magic != 0xCAFEBABE) {
                        throw new Exception("Invalid Java class");
                }
                int minor = 0xFFFF & data.readShort();
                int major = 0xFFFF & data.readShort();
                System.out.println("bytecode major.minor: "+major + "." + minor);
                data.close();
                in.close();
        }
}

$ ./atest #run (mainMethod())
checking if all needed tools are available
creating temporary directory
saving embedded Test.java
versions:
java version "1.7.0_45"
Java(TM) SE Runtime Environment (build 1.7.0_45-b18)
Java HotSpot(TM) 64-Bit Server VM (build 24.45-b08, mixed mode)
javac 1.7.0_45
compiling Test.java (-source 1.6 -target 1.6)
running compiled java program. output:
-----------
hello from java!
jre version: 1.7.0_45
bytecode major.minor: 50.0
-----------
compiling Test.java (without -source, -target)
running compiled java program. output:
-----------
hello from java!
jre version: 1.7.0_45
bytecode major.minor: 51.0
-----------
cleaning up...done. bye

```

easylapse
---------

Rudimentary interactive tool to create a video out of single image files.
Includes easylapse.sh script and ffmpeg binaries for i386/i686 and x86_64 architectures.
Dumps/uses the right ffmpeg depending on architecture.

```
$ ./easylapse list #show contents
1;ffmpeg_x86_64;19M;a01616ddcf79ad2f77f853027f747612;1397064669;ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.26, BuildID[sha1]=0xe2d1d25c0927c21ba2b16ec8dc52b71e5c3293a9, stripped
2;easylapse.sh;4.0K;092eba2e95d46873d97c09dec0d0474e;1397067604;POSIX shell script, ASCII text executable
3;ffmpeg_i386;18M;2cc349d0f44349e4f1d685815e698d7b;1397068425;ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.26, BuildID[sha1]=0xda64cd3f77576404edf42e144ff31d58e9fc5593, stripped

$ ./easylapse dump easylapse.sh #show included script
#!/bin/sh
#//tb/140914

echo ""
echo "welcome to easylapse!"
echo ""
echo "please enter the absolute path to your images"
echo -n "path: "
read path

#if [ x"$path" = x ]
#then
#	path="."
#fi

echo ""
echo "please enter the extension of the images you want to process"
echo "examples: jpg, JPG, png, ..."
echo -n "extension: "
read extension

found=`ls -1 "$path"/*."$extension" | wc -l`

echo ""
echo "found $found images in directory $path"
echo -n "first is: "
ls -1 "$path"/*."$extension" | head -1
echo -n "last is:  "
ls -1 "$path"/*."$extension" | tail -1
echo ""
echo "continue? (press enter to continue, ctrl+c to abort)"
read a

echo -n "creating symlinks in tempdir "$tempdir"... "
tempdir=`mktemp -d`
x=0; for i in "$path"/*."$extension"; do counter=$(printf %05d $x); ln "$i" "$tempdir"/img"$counter".jpg; x=$(($x+1)); done
echo "done."

echo ""
echo "please enter a title (metadata) for the output video"
echo -n "title: "
read title

echo ""
echo "please enter path + filename for the output video"
echo "example: /tmp/a.mp4"
echo -n "uri: "
read outfile

echo ""
echo "now creating video, this may take a while."
echo ""

#the enclosing bskt dumped the i386 or x86_64 version of statically linked ffmpeg
echo 'ffmpeg -i '"$tempdir"'/img%05d.jpg -vcodec libx264 -vf scale=1920:-1 -r 25 -metadata title="'$title'" "'$outfile'"'
./ffmpeg -i "$tempdir"/img%05d.jpg -vcodec libx264 -vf scale=1920:-1 -r 25 -metadata title="$title" "$outfile"

echo ""
echo "done! please find the video here:"
echo "$outfile"
echo ""
echo "cleaning up"
rm -rf "$tempdir"

exit 0

$ ./easylapse #run
...
...

```
