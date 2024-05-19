echo -e "seqTech\\tcapDesign\\tsizeFrac\\tsampleRep\\tgene_id\\treadCount" > human.GeneReadCoverage.stats.tsv

while read lab cap tmp sample
do
    counts="../../data/coverage/${lab}_${cap}_${tmp}_${sample}.gencode.coverage.tsv"
    cat $counts | cut -f1-4,8,9 >> human.GeneReadCoverage.stats.tsv
done  < ../../Figure1/samples.benchmark.human.tsv
