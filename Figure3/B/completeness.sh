while read lab cap tmp sample
do
    polya="../../data/polya/${lab}_${cap}_${tmp}_${sample}.polyAsites.bed.gz"
    polyafilt="../../data/polya/polyafilter/${lab}_${cap}_${tmp}_${sample}.polyAreads.list"
        
    zgrep -Ff $polyafilt $polya > ${lab}_${cap}_${tmp}_${sample}.polyAreads.refined.list
    original="../../data/bed/${lab}_${cap}_${tmp}_${sample}.bed.gz"        
    zegrep -w "SIRVome_isoforms|ERCC" $original > ${lab}_${cap}_${tmp}_${sample}.sirvs.bed

    cage="../../data/human_CAGE_peaks.bed"
    zcat $original | awk -F"\t" -v OFS="\t" '{ if( $6 == "+" ) print $1, $2-50, $2+50, $4, "0", $6; else print $1, $3-50, $3+50, $4, "0", $6 }' | awk -F"\t" -v OFS="\t" '{ if( $2 < 0 ) print $1, "0", $3, $4, $5, $6; else print $0 }' > ${lab}_${cap}_${tmp}_${sample}.starts.bed
    bedtools intersect -u -s -a ${lab}_${cap}_${tmp}_${sample}.starts.bed -b $cage > ${lab}_${cap}_${tmp}_${sample}.crossCAGE.bed

    echo "$(wc -l ${lab}_${cap}_${tmp}_${sample}.sirvs.bed | cut -c1 )"
    if [ $(wc -l ${lab}_${cap}_${tmp}_${sample}.sirvs.bed | cut -c1 ) -eq 0 ]; then
        rm ${lab}_${cap}_${tmp}_${sample}.sirvs.bed
    fi
    Rscript ../../Figure1/D/completeness_collate.R $original ${lab}_${cap}_${tmp}_${sample}.crossCAGE.bed ${lab}_${cap}_${tmp}_${sample}.polyAreads.refined.list ${lab}_${cap}_${tmp}_${sample}.sirvs.bed

done < ../samples.benchmark.technologies.human.tsv

while read lab cap tmp sample
do
    cat ${lab}_${cap}_${tmp}_${sample}.count.tsv
done < ../samples.benchmark.technologies.tsv > technology.support.stats.tsv
