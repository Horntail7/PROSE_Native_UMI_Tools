#!/usr/bin/bash

export PATH=$PATH:/home/prom/.local/bin

dir=`pwd`

if [ ! -d $dir/ERRORS ]
then
	mkdir $dir/ERRORS
fi	
cd $dir/ERRORS


for chip in `ls $dir/results | grep Chip`
do
    echo $chip
    
    echo "Barcode,nA,nG,nT,nC,nSkip,Rest,err,err,err,err,err,err" > $chip.csv
    
    for bar in `ls $dir/results/$chip/ | grep barcode`
    do

	awk '{if(NF>1){print $2}}' $dir/results/$chip/$bar/mistakes.tsv > sample
	nsample=`wc sample | awk '{print $1}'`
	
	if [ "$nsample" -gt "1000" ]
	then
	    
	    

	    
	    nA=0
	    nG=0
	    nT=0
	    nC=0
	    nS=0
	    nR=0
	    nA2=0
	    nG2=0
	    nT2=0
	    nC2=0
	    nS2=0
	    nR2=0
	    
	    for((i=0;i<10;i++))
	    do	
		shuf -n 100 sample > sub_sample
		
		nAt=`grep TTGAACA sub_sample | wc | awk '{print $1}'`
		nGt=`grep TTGGACA sub_sample | wc | awk '{print $1}'`
		nTt=`grep TTGTACA sub_sample | wc | awk '{print $1}'`
		nCt=`grep TTGCACA sub_sample | wc | awk '{print $1}'`
		nSt=`grep TTGACA sub_sample | wc | awk '{print $1}'`
		nRt=`grep -v TTGAACA sub_sample | grep -v TTGGACA | grep -v TTGTACA | grep -v TTGCACA | grep -v TTGACA | wc | awk '{print $1}'`
		
		
		nA=`echo $nA $nAt | awk '{print $1+$2}'`
		nA2=`echo $nA2 $nAt | awk '{print $1+$2*$2}'`
		nG=`echo $nG $nGt | awk '{print $1+$2}'`
		nG2=`echo $nG2 $nGt | awk '{print $1+$2*$2}'`
		nT=`echo $nT $nTt | awk '{print $1+$2}'`
                nT2=`echo $nT2 $nTt | awk '{print $1+$2*$2}'`
		nC=`echo $nC $nCt | awk '{print $1+$2}'`
                nC2=`echo $nC2 $nCt | awk '{print $1+$2*$2}'`
		nS=`echo $nS $nSt | awk '{print $1+$2}'`
                nS2=`echo $nS2 $nSt | awk '{print $1+$2*$2}'`
		nR=`echo $nR $nRt | awk '{print $1+$2}'`
                nR2=`echo $nR2 $nRt | awk '{print $1+$2*$2}'`

	    done
		
	    nA=`echo $nA | awk '{print $1/10}'`
	    nA2=`echo $nA $nA2 | awk '{print sqrt($2/10-$1*$1)}'`
	    nG=`echo $nG | awk '{print $1/10}'`
	    nG2=`echo $nG $nG2 | awk '{print sqrt($2/10-$1*$1)}'`
	    nT=`echo $nT | awk '{print $1/10}'`
	    nT2=`echo $nT $nT2 | awk '{print sqrt($2/10-$1*$1)}'`
	    nC=`echo $nC | awk '{print $1/10}'`
	    nC2=`echo $nC $nC2 | awk '{print sqrt($2/10-$1*$1)}'`
	    nS=`echo $nS | awk '{print $1/10}'`
	    nS2=`echo $nS $nS2 | awk '{print sqrt($2/10-$1*$1)}'`
	    nR=`echo $nR | awk '{print $1/10}'`
	    nR2=`echo $nR $nR2 | awk '{print sqrt($2/10-$1*$1)}'`
	    
	    echo $bar $nsample $nA $nG $nT $nC $nS $nR $nA2 $nG2 $nT2 $nC2 $nS2 $nR2
	    echo $bar $nA $nG $nT $nC $nS $nR $nA2 $nG2 $nT2 $nC2 $nS2 $nR2 | awk '{printf"%s,%6.2f,%6.2f,%6.2f,%6.2f,%6.2f,%6.2f,%6.2f,%6.2f,%6.2f,%6.2f,%6.2f,%6.2f\n", $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13}' >> $chip.csv
	    
	else
	    
	    echo $bar 0 0 0 0 0 0 0 0 0 0 0 0 | awk '{printf"%s,%6.2f,%6.2f,%6.2f,%6.2f,%6.2f,%6.2f,%6.2f,%6.2f,%6.2f,%6.2f,%6.2f,%6.2f\n", $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13}' >> $chip.csv
	    
	fi
	
    done
    
done
    
cd $dir

