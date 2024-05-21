#!/bin/bash
output="benchmark.polyasites.tsv"
echo -e "seqTech\tcapDesign\tsizeFrac\tsampleRep\tbiotype\treadOverlapsCount\treadOverlapsPercent" > $output

while read lab cap tmp sample
do
    sortbed ../../data/bed/${lab}_${cap}_${tmp}_${sample}.bed | bedtools slop -s -l 5 -r 5 -i stdin -g chromInfo_length_hg38.txt | bedtools intersect -u -s -a stdin -b hg38.polyAsignals.bed > ${lab}_${cap}_${tmp}_${sample}.vspolyAsignals.bed
    cut -f4 ${lab}_${cap}_${tmp}_${sample}.vspolyAsignals.bed | sed 's/,/\n/g' | sort -u > ${lab}_${cap}_${tmp}_${sample}.polyA.readID
    fzgrep -f ../../data/polyA/polya_filter/${lab}_${cap}_${tmp}_${sample}.polyAreads.list ${lab}_${cap}_${tmp}_${sample}.polyA.readID > ${lab}_${cap}_${tmp}_${sample}.polyAsites+polyAreads.all.readID
    
    common=`cat ${lab}_${cap}_${tmp}_${sample}.polyAsites+polyAreads.all.readID | fgrep -f ${lab}_${cap}_${tmp}_${sample}.all.readID - | wc -l`
    polyAread=`fgrep -vf ${lab}_${cap}_${tmp}_${sample}.polyAsites+polyAreads.all.readID ../../data/polyA/polya_filter/${lab}_${cap}_${tmp}_${sample}.polyAreads.list | fgrep -f ${lab}_${cap}_${tmp}_${sample}.all.readID - | wc -l`
    polyAsites=`fgrep -vf ${lab}_${cap}_${tmp}_${sample}.polyAsites+polyAreads.all.readID ${lab}_${cap}_${tmp}_${sample}.polyA.readID | fgrep -f ${lab}_${cap}_${tmp}_${sample}.all.readID - | wc -l`
    
    echo -e "$name\t$polyAread\tpolyAread\n$name\t$common\tcommon\n$name\t$polyAsites\tpolyAsites"
done < ../human.samples.benchmark.supplementary.tsv > captrap.polyAsites+polyAreads.stats.all.tmp.tsv

cat captrap.polyAsites+polyAreads.stats.tmp.tsv | while read name count typ
do
    platform=`echo ${lab}_${cap}_${tmp}_${sample} | awk -F "-" '{print $1}'`
    seq=`echo ${lab}_${cap}_${tmp}_${sample} | awk -F "_" '{print $1}'`
    label=`echo ${lab}_${cap}_${tmp}_${sample} | awk -F "-" '{print $2"-"$3}' | awk -F "_" '{print $1}'`
    sampl=`echo ${lab}_${cap}_${tmp}_${sample} | awk -F "_" '{print $4}'`
    echo -e "$seq\t$sampl\t$count\t$typ\t$platform\t$label\tAll"
done > captrap.polyAsites+polyAreads.stats.all.tsv


while read lab cap tmp sample
do
    cat ../../data/gff/${lab}_${cap}_${tmp}_${sample}.gff| awk '{print \$10}'| sed 's/\"//g'| sed 's/;//g'| sort | uniq -c | awk '\$1>1{print \$2}' > ${lab}_${cap}_${tmp}_${sample}.spliced.readID 
    fgrep -f ${lab}_${cap}_${tmp}_${sample}.spliced.readID ${lab}_${cap}_${tmp}_${sample}.polyAsites+polyAreads.all.readID > ${lab}_${cap}_${tmp}_${sample}.polyAsites+polyAreads.spilced.readID
    
    common=`cat ${lab}_${cap}_${tmp}_${sample}.polyAsites+polyAreads.spilced.readID | fgrep -f ${lab}_${cap}_${tmp}_${sample}.spliced.readID - | wc -l`
    polyAread=`fgrep -vf ${lab}_${cap}_${tmp}_${sample}.polyAsites+polyAreads.spilced.readID ../../data/polyA/polya_filter/${lab}_${cap}_${tmp}_${sample}.polyAreads.list | fgrep -f ${lab}_${cap}_${tmp}_${sample}.spliced.readID - | wc -l`
    polyAsites=`fgrep -vf ${lab}_${cap}_${tmp}_${sample}.polyAsites+polyAreads.spilced.readID ${lab}_${cap}_${tmp}_${sample}.polyA.readID | fgrep -f ${lab}_${cap}_${tmp}_${sample}.spliced.readID - | wc -l`
    
    echo -e "$name\t$polyAread\tpolyAread\n$name\t$common\tcommon\n$name\t$polyAsites\tpolyAsites"
done < ../human.samples.benchmark.supplementary.tsv > captrap.polyAsites+polyAreads.stats.spliced.tmp.tsv

cat captrap.polyAsites+polyAreads.stats.spliced.tmp.tsv | while read name count typ
do
    platform=`echo ${lab}_${cap}_${tmp}_${sample} | awk -F "-" '{print $1}'`
    seq=`echo ${lab}_${cap}_${tmp}_${sample} | awk -F "_" '{print $1}'`
    label=`echo ${lab}_${cap}_${tmp}_${sample} | awk -F "-" '{print $2"-"$3}'| awk -F "_" '{print $1}'`
    sampl=`echo ${lab}_${cap}_${tmp}_${sample} | awk -F "_" '{print $4}'`
    echo -e "$seq\t$sampl\t$count\t$typ\t$platform\t$label\tSpliced"
done > captrap.polyAsites+polyAreads.stats.spliced.tsv

cat captrap.polyAsites+polyAreads.stats.all.tsv captrap.polyAsites+polyAreads.stats.spliced.tsv > $output
