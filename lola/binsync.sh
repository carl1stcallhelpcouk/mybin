#!/bin/bash

#
# Syncronise home bin directory with server
#

unison -auto -batch -ignore="Path */log/*" -ignore="Path */tmp/*" -ignore="Path */flask/*" "${HOME}/bin/" "/shares/data/home/carl/bin/"
