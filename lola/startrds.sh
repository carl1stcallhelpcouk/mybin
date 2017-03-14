nohup xinit /usr/bin/ssh -Y carl@pi /etc/X11/Xsession -- :1 vt8 > ~/log/pi.log 2>&1 &
nohup xinit /usr/bin/ssh -Y carl@dell-server startkde -- :2 vt9 > ~/log/dell-server.log 2>&1 &
