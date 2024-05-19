#!/bin/bash
echo -e "seqTech\tcapDesign\tsizeFrac\tsampleRep\tcategory\tcount\tpercent" > technology.polyA.stats.tsv

while read lab cap tmp sample
do
    reads="${lab}_${cap}_${tmp}_${sample}.bam"
    polyA="../../data/polya/polyAfilter/${lab}_${cap}_${tmp}_${sample}.polyAreads.list"
    mapped=$(samtools view -F4 $reads | cut -f1 | sort -u | wc -l)
    polyAcount=$(cat $polyA | wc -l)
    echo -e "$lab\t$cap\t$tmp\t$sample\t$mapped\t$polyAcount" | awk '{{print $0"\t"$6/$5}}' > ${lab}_${cap}_${tmp}_${sample}.polyacount
    cat ${lab}_${cap}_${tmp}_${sample}.polyacount | awk '{{print $1"\\t"$2"\\t"$3"\\t"$4"\\tnonPolyA\\t"$5-$6"\\t"($5-$6)/$5"\\n"$1"\\t"$2"\\t"$3"\\t"$4"\\tpolyA\\t"$6"\\t"$6/$5}}' | sort >> technology.polyA.stats.tsv
done  < ../../Figure3/samples.benchmark.technologies.tsv
