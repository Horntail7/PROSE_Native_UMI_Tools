#!/bin/bash

input=$1
Foutput=$2
Routput=$3

umi_tools extract --extract-method=regex --bc-pattern=".*(?P<umi_1>.{4})CCTCATGA(?P<umi_2>.{4})(?P<discard_1>.+)TCAG(?P<umi_3>.{4})CCATG(?P<umi_4>.{4})(?P<discard_2>.+)CGGGTC(?P<umi_5>.{4,8})CACCGC(?P<discard_3>.+)GGTA(?P<umi_6>.{7})TCAC.*" -I $input -S $Foutput

umi_tools extract --extract-method=regex --bc-pattern=".*(?P<umi_1>.{7})TACC(?P<discard_1>.+)GCGGTG(?P<umi_2>.{4,8})GACCCG(?P<discard_2>.+)(?P<umi_3>.{4})CATGG(?P<umi_4>.{4})(?P<discard_2>.+)(?P<umi_5>.{4})(?P<discard_3>TCATGAGG{s<=1})(?P<umi_6>.{4}).*" -I $input -S $Routput
