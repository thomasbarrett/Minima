#!/usr/bin/env bash

kill -9 $1;
rm -rf $2
curl -H 'Cache-Control: no-cache' "https://s3.amazonaws.com/com.thomasbarrett.minima/minima.app.zip" -o $2.zip 
unzip $2.zip -d $(dirname "$2.zip")
rm $2.zip
open $2