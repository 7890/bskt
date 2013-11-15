#!/bin/bash

#quick and dirty

echo "did you add newest bskt.template base64 encoded to basket.sh? ctrl+c to quit" 
read a

mkdir -p tmp
cd tmp
cp ../src/bskt.tmpl .
cp ../src/basket.sh .
cat basket.sh | gzip -9 | base64 - >> bskt.tmpl
echo "_EOF_" >> bskt.tmpl
echo "echo \"new basket created.\"" >> bskt.tmpl

rm basket.sh
mv bskt.tmpl bskt
chmod 755 bskt

echo "testing resulting bskt:"
./bskt --help
./bskt mynewbasket
echo "gugus" | ./mynewbasket add -
./mynewbasket list

echo ""
echo "if everyting looks fine, copy tmp/bskt to dist/bskt"
echo ""
