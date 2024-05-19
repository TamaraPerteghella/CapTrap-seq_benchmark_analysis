#!/bin/bash
script="https://raw.githubusercontent.com/guigolab/LyRic/d304504/utils/qualimapReportToTsv.pl"
wget "$script"
chmod +x qualimapReportToTsv.pl

echo -e "seqTech\tcapDesign\tsizeFrac\tsampleRep\terrorCategory\terrorRate" > human.sequencingError.stats.tsv

while read lab cap tmp sample
do
    reads="../../data/qc_results/${lab}_${cap}_${tmp}_${sample}.genome_results.txt"
    qualimapReportToTsv.pl $reads | cut -f2,3 | grep -v globalErrorRate | sed 's/PerMappedBase//' | awk -v t=$lab -v c=$cap -v si=$tmp -v b=$sample '{{print t"\t"c"\t"si"\t"b"\t"$1"\t"$2}}' > ${lab}_${cap}_${tmp}_${sample}.sequencingError.stats.tsv
    sort ${lab}_${cap}_${tmp}_${sample}.sequencingError.stats.tsv >> human.ntCoverageByGenomePartition.tsv
done  < ../../Figure1/samples.benchmark.human.tsv
