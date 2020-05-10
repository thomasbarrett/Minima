#!/usr/bin/env bash

kill -9 $1;
rm -r $2
curl -o $2.zip https://thomasbarrett.github.io/Minima/minima.zip

echo $2.zip

unzip $2.zip
rm -f $2.zip
echo "Hello"