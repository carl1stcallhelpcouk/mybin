#!/bin/bash

#
# Syncronise home bin directory with server
#

unison -auto -batch -ignore="Path */log/*" -ignore="Path */tmp/*" -ignore="Path */flask/*" "${HOME}/mybin/" "/shares/data/home/carl/mybin/"
