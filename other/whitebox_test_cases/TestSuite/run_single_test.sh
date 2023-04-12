#!/bin/bash
set -e

# Number of iterations
NB_ITERATION=$1
TEST=$2

for i in `seq 1 $NB_ITERATION`
do
	echo "Iteration $i"
	rm -f lwp_cookies_*.dat
	time perl -w kddart_dal_test.pl 1 $TEST
	rm -f lwp_cookies_*.dat
  	rm -f write_token_*
  	rm -f *.csv_*
  	rm -f *.xml_*
  	rm -f *.json_*
	rm -f xml/add_data_no_vcol/*_p_*.xml

done
