#!/bin/sh
# Run a complete suite of sysbench performance benchmarks

NUM_THREADS=8

run_sysbench() {
	local threads="$1"
	for test in cpu memory mutex; do 
		echo "----- Running sysbench for $test -----"
		sysbench --test="$test" run
	done

	for mode in seqwr seqrewr seqrd rndrd rndwr rndrw; do
		echo "----- Running sysbench for fileio, mode=$mode -----"
		sysbench --test=fileio --file-test-mode="$mode" prepare
		sysbench --test=fileio --file-test-mode="$mode" run
	done

	echo "----- Running sysbench for threads -----"
	sysbench --test=threads --num-threads="$threads" run

    if [ -n "$(which mysql)" ]; then
        echo "----- Running sysbench for oltp -----"
        mysql -u root -e 'drop database if exists sbtest; create database sbtest'
        if sysbench --test=oltp prepare --db-driver=mysql --mysql-user=root; then
            sysbench --test=oltp run --db-driver=mysql --mysql-user=root
        fi
    else
        echo "----- No mysql detected, skipping oltp -----"
    fi
}

capture_env() {
    local os
    os="$(uname -a | tr '[:upper:]' '[:lower:]')"

    echo "current working directory (sysbench creates files here): '$(pwd)' -----"
    echo "uname: '$(uname))'
    echo "----- environment details -----"
    uname
    case "$os" in
		darwin)
		    system_profiler 2>/dev/null | grep -iE 'Model Name|Model Identifier|Processor Name|Processor Speed|Number of Processors|Total Number of Cores|L[23] Cache|Memory:|Boot ROM|Serial Number|Hardware UUID'
            ;;
		linux)
			cat /proc/cpuinfo && \
			cat /proc/interrupts && \
			cat /proc/meminfo && \
			cat /proc/diskstats
		    ;;
		*)
		    echo "WARNING: Unrecognized OS, skipping extra diagnostic output"
		    ;;
	esac


}

storagetype=${1?Enter a storage type: disk or ssd}
# Thanks Stack Overflow https://stackoverflow.com/a/7216394
ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
hostname=$(hostname)
logfile=sysbench-"$hostname-$storagetype-$ts".txt
rm -f "$logfile"
( 
    time capture_env && \
	time run_sysbench "$NUM_THREADS" 
) >> "$logfile" 2>&1
echo "----- see '$logfile' for benchmark output -----"
