#!/bin/bash
ann="../../data/HpreCap.gencode.collapsed.simplified_biotypes.gtf"
output="technology.readToBiotypeBreakdown.woSpikeIns.stats.tsv"
echo -e "seqTech\tcapDesign\tsizeFrac\tsampleRep\tbiotype\treadOverlapsCount\treadOverlapsPercent" > $output

while read lab cap tmp sample
do
    reads="${lab}_${cap}_${tmp}_${sample}.bam"
    bedtools intersect -split -wao -bed -a $reads -b $ann | grep -vP "^ERCC"  | grep -vP "^SIRV" | perl -lane '$line=$_; $gid="NA"; $gt="nonExonic"; if($line=~/gene_id \"(\S+)\";/){{$gid=$1}}; if ($line=~/gene_type \"(\S+)\";/){{$gt=$1}}; print "$F[3]\\t$gid\\t$gt\\t$F[-1]"' | cut -f1,3 | sort -u | gzip > ${lab}_${cap}_${tmp}_${sample}.reads2biotypes.woSpikeIns.tsv.gz
    totalPairs=$(zcat ${lab}_${cap}_${tmp}_${sample}.reads2biotypes.woSpikeIns.tsv.gz | wc -l)
    zcat ${lab}_${cap}_${tmp}_${sample}.reads2biotypes.woSpikeIns.tsv.gz | cut -f2 | sort | uniq -c | ssv2tsv | awk -v t=$lab -v c=$cap -v si=$tmp -v b=$sample -v tp=$totalPairs '{{print t\"\\t\"c\"\\t\"si\"\\t\"b\"\\t\"$2"\\t"$1"\\t"$1/tp}}' > ${lab}_${cap}_${tmp}_${sample}.readToBiotypeBreakdown.woSpikeIns.stats.tsv
    cat ${lab}_${cap}_${tmp}_${sample}.readToBiotypeBreakdown.woSpikeIns.stats.tsv | sort >> $output

done < ../../Figure3/samples.benchmark.technologies.tsv
