#!/bin/bash

input=$1
output=$2

umi_tools extract --extract-method=regex --bc-pattern=".*(?P<umi_1>.{4})CCTCATGA(?P<umi_2>.{4})(?P<discard_1>.+)TCAG(?P<umi_3>.{4})CCATG(?P<umi_4>.{4})(?P<discard_2>.+)CGGGTC(?P<umi_5>.{4,8})CACCGC(?P<discard_3>.+)AGCTGGTA(?P<umi_6>.{7}).*" -I $input -S $output

