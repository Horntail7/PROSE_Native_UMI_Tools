#!/bin/bash

input=$1
output=$2

umi_tools extract --extract-method=regex --bc-pattern=".*(?P<umi_1>.{7})TACCAGCT(?P<discard_1>.+)GCGGTG(?P<umi_2>.{4,8})GACCCG(?P<discard_2>.+)(?P<umi_3>.{4})CATGG(?P<umi_4>.{4})(?P<discard_2>.+)(?P<umi_5>.{4})(?P<discard_3>TCATGAGG{s<=1})(?P<umi_6>.{4}).*" -I $input -S $output
