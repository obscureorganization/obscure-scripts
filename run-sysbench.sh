#!/bin/sh
# Run a complete suite of sysbench performance benchmarks

NUM_THREADS=8

run_sysbench() {
	threads="$1"
	for test in cpu memory mutex; do 
		echo "----- Running sysbench for $test -----"
		sysbench --test="$test" run 2>&1
	done

	for mode in seqwr seqrewr seqrd rndrd rndwr rndrw; do
		echo "----- Running sysbench for fileio, mode=$mode -----"
		sysbench --test=fileio --file-test-mode="$mode" prepare 2>&1
		sysbench --test=fileio --file-test-mode="$mode" run 2>&1
	done

	echo "----- Running sysbench for threads -----"
	sysbench --test=threads --num-threads="$NUM_THREADS" run 2>&1

	echo "----- Running sysbench for oltp -----"
	mysql -u root -e 'drop database if exists sbtest; create database sbtest' 2>&1
	sysbench --test=oltp prepare --db-driver=mysql --mysql-user=root 2>&1
	sysbench --test=oltp run --db-driver=mysql --mysql-user=root 2>&1
}

hostname=$(hostname)
ts=$(date --rfc-3339=seconds | sed -e 's/[-:]//g;s/....$//;s/ /T/g')
hostname=$(hostname)
storagetype=ssd
logfile=sysbench-"$hostname-$storagetype-$ts".txt
rm -f "$logfile"
( 
	cat /proc/cpuinfo && \
	cat /proc/interrupts && \
	cat /proc/meminfo && \
	cat /proc/diskstats && \
	run_sysbench "$NUM_THREADS" 
) 2>&1 >> "$logfile"
echo "----- see $logfile for benchmark output -----"
