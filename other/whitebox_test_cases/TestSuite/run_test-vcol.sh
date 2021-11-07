#!/bin/bash

set -e

# Number of iterations
NB_ITERATION=$1

for i in `seq 1 $NB_ITERATION`
do
	echo "Iteration $i"
	rm -f lwp_cookies_*.dat
	time perl -w kddart_dal_test.pl 2 xml/add_data_vcol/test_case_order.txt
	rm -f lwp_cookies_*.dat
  	rm -f write_token_*
  	rm -f *.csv_*
  	rm -f *.xml_*
  	rm -f *.json_*
done
