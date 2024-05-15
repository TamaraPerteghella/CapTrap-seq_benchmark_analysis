while read lab cap tmp sample
do
    stats="../../data/coverage/${lab}_${cap}_${tmp}_${sample}.gencode.min2reads.coverage.tsv"
    grep -w "SIRVome_isoforms" $stats 
done < ../samples.benchmark.sirvs.tsv > human.spikeIns.sirvome.coverage.tsv
