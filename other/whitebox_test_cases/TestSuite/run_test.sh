#!/bin/bash

# Number of iterations
NB_ITERATION=$1

for i in `seq 1 $NB_ITERATION`
do
	echo "Iteration $i"
	rm lwp_cookies.dat
	find . -name 'case*.*' -exec sed -i 's|<RunInfo.*||' {} ";"
	perl -w kddart_dal_test.pl 2 xml/add_data_no_vcol/test_order_all.txt
done
