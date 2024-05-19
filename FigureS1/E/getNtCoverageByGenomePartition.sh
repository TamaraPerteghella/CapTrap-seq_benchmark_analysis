#!/bin/bash
script="https://raw.githubusercontent.com/guigolab/LyRic/d304504/utils/extractGffAttributeValue.pl"
wget "$script"
chmod +x /extractGffAttributeValue.pl

gencodePart="../../data/HpreCap.partition.gff"
echo -e "seqTech\\tcapDesign\\tsizeFrac\\tsampleRep\\tsplicingStatus\\tpartition\\tnt_coverage_count\\tnt_coverage_percent" > human.ntCoverageByGenomePartition.tsv

while read lab cap tmp sample
do
    reads="../../data/gff/${lab}_${cap}_${tmp}_${sample}.gff"
    zcat $reads | bedtools merge -i stdin > tmp.reads.bed
    bedtools coverage -a $gencodePart -b tmp.reads.bed  > tmp.reads.cov.bedtsv
    totalNts=$(cat tmp.reads.cov.bedtsv | awk '{{print $(NF-2)}}' | awk 'BEGIN { SUM=0 } { SUM += ($1);} END { print SUM }')

    for flag in `cat tmp.reads.cov.bedtsv | ./extractGffAttributeValue.pl region_flag | sort -u `;
    do
      nts=$(cat tmp.reads.cov.bedtsv | fgrep "region_flag \\"$flag\\";" | awk '{{print $(NF-2)}}' | awk 'BEGIN { SUM=0 } { SUM += ($1);} END { print SUM }')
      echo -e "${lab}\\t${cap}\\t${tmp}\\t${sample}\\tall\\t$flag\\t$nts" | awk -v t=$totalNts '{{print $0"\\t"$7/t}}';
    done > ${lab}_${cap}_${tmp}_${sample}.ntCoverageByGenomePartition.stats.tsv

    cat ${lab}_${cap}_${tmp}_${sample}.ntCoverageByGenomePartition.stats.tsv | sort >> human.ntCoverageByGenomePartition.tsv
done  < ../../Figure1/samples.benchmark.human.tsv
