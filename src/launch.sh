#!/usr/bin/env bash

kill -9 $1;
rm -rf $2
curl https://thomasbarrett.github.io/Minima/minima.app.zip -o $2.zip 
unzip $2.zip -d $(dirname "$2.zip")
rm $2.zip
open $2