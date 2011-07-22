#! /bin/sh
WORKPATH=`pwd`

NGINXDAEMON=nginx
REDISDAEMON=redis-server-script

QUEPIDFILE=$WORKPATH/quepid

start(  ) {
	$NGINXDAEMON start
	$REDISDAEMON start

	if [ -f $QUEPIDFILE ]; then
		QUEPID=`cat $QUEPIDFILE`
		kill -9 $QUEPID
	fi

	QUEUE=* bundle exec rake environment resque:work &
	echo $! > $QUEPIDFILE
}

stop(  ) {
	$NGINXDAEMON stop
	$REDISDAEMON stop

	if [ -f $QUEPIDFILE ]; then
		QUEPID=`cat $QUEPIDFILE`
		kill -9 $QUEPID
		rm $QUEPIDFILE
	fi
}

case "$1" in
	start)
		start
        ;;
	stop)
		stop
        ;;
	restart|force-reload)
		stop
		start
        ;;
	*)
		exit 1
		;;
esac

