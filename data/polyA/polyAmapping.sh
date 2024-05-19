#!/bin/bash
script="https://raw.githubusercontent.com/guigolab/LyRic/d304504/utils/samToPolyA.pl"
wget "$script"
chmod +x samToPolyA.pl

reads="${lab}_${cap}_${tmp}_${sample}.sam"
genome="hg38.sorted.fa"
minAcontent=0.8
output="${lab}_${cap}_${tmp}_${sample}.polyAsites.bed.gz"
cat $reads | samToPolyA.pl --minClipped=10 --minAcontent=$minAcontent  --discardInternallyPrimed --minUpMisPrimeAlength=10 --genomeFasta=$genome - | sort -k1,1 -k2,2n -k3,3n | gzip > $output
