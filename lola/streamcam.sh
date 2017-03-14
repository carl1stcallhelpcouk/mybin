#!/bin/bash
#
#cvlc v4l2:// :v4l2-vdev="/dev/video0" --sout '#transcode{vcodec=x264{keyint=60,idrint=2},vcodec=h264,vb=400,width=368,heigh=208,acodec=mp4a,ab=32 ,channels=2,samplerate=22100}:duplicate{dst=std{access=http{mime=video/x-ms-wmv},mux=asf,dst=:8082/stream.wmv}}' --no-sout-audio &
#cvlc v4l2:// :v4l2-vdev="/dev/video0" -I dummy --sout-keep --sout '#transcode{vcodec=hevc,acodec=mpga,ab=128,channels=2,samplerate=44100}:http{dst=:8082/stream.mp4}' &
cvlc v4l2:///dev/video0 -I dummy --sout '#transcode{vcodec=theo,vb=800,acodec=vorb,ab=128,channels=2,samplerate=44100}:http{dst=:8082/cam2.ogg}' :sout-keep &