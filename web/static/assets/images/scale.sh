#!/bin/bash

basename=`echo $1 | sed 's/\..*//'`
for size in 36 48 72 96 144 192; do
  echo "convert $1 -resize $size $basename-$size.png"
  convert $1 -resize $size $basename-$size.png
done
