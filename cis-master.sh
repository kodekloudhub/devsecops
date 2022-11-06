#!/bin/bash
#cis-master.sh

total_fail=$(kube-bench master  --version 1.15 --check 1.2.7,1.2.8,1.2.9 --json | jq .[].total_fail)

if [[ "$total_fail" -ne 0 ]];
        then
                echo "CIS Benchmark Failed MASTER while testing for 1.2.7, 1.2.8, 1.2.9"
                exit 1;
        else
                echo "CIS Benchmark Passed for MASTER - 1.2.7, 1.2.8, 1.2.9"
fi;