cvlc -I dummy test.mp4 'vlc://quit' --sout-keep --sout '#standard{access=http,mux=asf,p4,dst=:8080}' --stop-time 30
