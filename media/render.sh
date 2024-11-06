#!/bin/bash
# This script is used to render the svg
# file to a png file.
# --export-type="png"
# https://wiki.inkscape.org/wiki/Using_the_Command_Line
set -x
mkdir -p tmp
for svg in *.svg; do
    # open -a Inkscape.app $svg --args -z -e tmp/${svg%.*}.png
    /Applications/Inkscape.app/Contents/MacOS/inkscape $svg -o tmp/${svg%.*}.png
done
