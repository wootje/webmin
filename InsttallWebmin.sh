#!/bin/sh
apt install curl ntpdate nano -y
cd /opt
curl -o setup-repos.sh https://raw.githubusercontent.com/webmin/webmin/master/setup-repos.sh
sh setup-repos.sh
apt install --install-recommends webmin -y
chmod 775 /etc/init.d/webmin
/usr/sbin/update-rc.d webmin defaults
cat << 'EOF' > /etc/init.d/webmin
#!/bin/sh

### BEGIN INIT INFO
# Provides:          webmin
# Required-Start:
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Webmin service
# Description:       Administrator web-interface
### END INIT INFO


case "$1" in
    start)
        /etc/webmin/.start-init
    ;;
    stop)
        /etc/webmin/.stop-init    
    ;;
    restart)
        $0 stop
	pidfile=`grep "^pidfile=" /etc/webmin/miniserv.conf | sed -e 's/pidfile=//g'`
	pid=`cat $pidfile 2>/dev/null`
        if [ "$pid" = "" ]; then
            echo "Unable to stop, will not attempt to start"
            exit 1
        fi
        $0 start
    ;;
    status)
	pidfile=`grep "^pidfile=" /etc/webmin/miniserv.conf | sed -e 's/pidfile=//g'`
	pid=`cat $pidfile 2>/dev/null`
	if [ "$pid" = "" ]; then
	    echo "Webmin is not running"
	else
            echo "Running with PID = $pid"
        fi
    ;;
    *)
    echo "Usage: $0 {start|stop|restart|status}"
    exit 1
    ;;
esac
exit 0
EOF
reboot