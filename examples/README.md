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
2;ffmpeg_i386;18M;2cc349d0f44349e4f1d685815e698d7b;1397068425;ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.26, BuildID[sha1]=0xda64cd3f77576404edf42e144ff31d58e9fc5593, stripped
3;easylapse.sh;4.0K;202342ad9f61c59301d8263dbe287b0b;1397091558;POSIX shell script, ASCII text executable

$ ./easylapse dump easylapse.sh #show included script
#!/bin/sh
#//tb/140409

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
echo "default: JPG (enter)"
echo -n "extension: "
read extension
if [ x"$extension" = x ]
then
	extension="JPG"
fi

found=`ls -1 "$path"/*."$extension" | wc -l`

if [ x"$found" = x0 ]
then
	echo "no images found."
	exit 1
fi

echo ""
echo "found $found images in directory $path"
echo -n "first is: "
ls -1 "$path"/*."$extension" | head -1
echo -n "last is:  "
ls -1 "$path"/*."$extension" | tail -1
echo ""
echo "continue? (press enter to continue, ctrl+c to abort)"
read a

echo -n "creating symlinks in tempdir ${tempdir}... "
tempdir=`mktemp -d`
x=0; for i in "$path"/*."$extension"; do counter=$(printf %05d $x); ln "$i" "$tempdir"/img"$counter".jpg; x=$(($x+1)); done
echo "done."

echo ""
echo "please enter the width:height in pixels for the output video"
echo ""
echo "for 4:3 images:"
echo "640:480, 800:600, 1024:768, 1152:864, 1280:960, 1400:1050, 1600:1200, 2048:1536, 3200:2400, 4000:3000, 6400:4800"
echo ""
echo "for 16:9 images:"
echo "640:360, 854:480, 960:540, 1024:576, 1280:720, 1366:768, 1600:900, 1920:1080, 2048:1152, 2560:1440, 2880:1620, 3840:2160 4096:2304"
echo ""
echo "default: 640:360 (enter)"
echo -n "width:height: "
read width_height
if [ x"$width_height" = x ]
then
	width_height="640:360"
fi

echo ""
echo "please enter the framerate (FPS) for the output video"
echo "examples: 24, 25, 30, 60"
echo "default: 25"
echo -n "fps: "
read fps
if [ x"$fps" = x ]
then
	fps=25
fi

cbr_cmd=""
echo ""
echo "do you want to set a constant bitrate (CBR) in kbps? leave blank for none"
echo "examples: 100, 400, 700, 1500, 2500, 4000"
echo "default: no CBR (enter)"
echo -n "cbr: "
read cbr
if [ x"$cbr" != x ]
then
	cbr_cmd="\-b ${cbr}k -minrate ${cbr}k -maxrate ${cbr}k"
fi


title_gen="Easylapse Video `date`"
echo ""
echo "please enter a title (metadata) for the output video"
echo "default: $title_gen (enter)"
echo -n "title: "
read title
if [ x"$title" = x ]
then
	title=title_gen
fi

echo ""
echo "please enter path + filename for the output video"
echo "example: /tmp/my.mp4"
echo "default: /tmp/out.mp4"
echo -n "uri: "
read outfile
if [ x"$outfile" = x ]
then
	outfile="/tmp/out.mp4"
fi


echo "=========================================="
echo "now creating video, this may take a while."
echo ""

#the enclosing bskt dumped the i386 or x86_64 version of statically linked ffmpeg
#scale='"$width"':-1
cmd="ffmpeg -r $fps -i $tempdir/img%05d.jpg -vcodec libx264 -vf scale=$width_height -r $fps $cbr_cmd -metadata title=\"$title\" \"$outfile\""
echo "$cmd"

echo "=========================================="

eval "$cmd"

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
