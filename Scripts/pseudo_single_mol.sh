#!/bin/bash

dir=`pwd`
scripts=$dir/Scripts

echo "Ind,F1,F2,F3,F4,class_id" > $dir/results/Chip2/pseudo_SM_old.csv
#echo "Ind,F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,F11,F12,F13,class_id" > $dir/results/Chip2/final_clusters.csv

count=0

for bar in `ls $dir/results/Chip2 | grep barcode`
do

    cd $dir/results/Chip2/$bar

    python3 $dir/score_copy.py --inp umis.tsv --ncol 3 --icol 3

    awk -v c=$count '{printf"%s%d\n", $0,c}' scores_pseudobulk.csv >> $dir/results/Chip2/pseudo_SM_old.csv
#    awk -v c=$count '{printf"%s,%d\n", $0,c}' scores_pseudobulk.csv >> $dir/results/Chip2/random_test.csv

    count=`echo $count | awk '{print $1+1}'`
    
    echo $bar done
    cd $dir
done
