#!/bin/bash
#
xclip -selection clipboard -o >>t.txt
 /home/batan/.local/bin/edge-tts -f t.txt --write-media output.mp3
 /usr/bin/play output.mp3

 mv output.mp3 ~/Music/output.$(date +%H.%M).mp3
/usr/bin/rm t.txt
