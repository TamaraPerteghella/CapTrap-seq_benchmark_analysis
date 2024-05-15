for capture in HpreCap MpreCap
do
    while read lab cap tmp sample
    do
        path="data/${lab}_${cap}_${tmp}_${sample}.gff.gz"
        details=$(echo -e "$lab\t$cap\t$tmp\t$sample")
        if [ -f $path ]; then
            zcat $path | egrep -v "SIRVome_isoforms|ERCC" | awk -F"\t" -v OFS="\t" -v det="$details" '{ split($9, ids, "\""); print $5-$4, ids[2], det }'
        fi
    done < data/samples.benchmark.${capture}.tsv > benchmark.readlength.$capture.tsv
done

for capture in MpreCap HpreCap
do
    awk -F'\t' '{key = "\"" $2 "\"" "\t" $3 "\t" $4 "\t" $5 "\t" $6; sums[key]+=$1} END {for (key in sums) print key "\t" sums[key]}' benchmark.readlength.$capture.tsv > benchmark.readlength.$capture.finite.tsv
done
