while read lab cap tmp sample
do
    file=`echo ../../data/coverage/${lab}_${cap}_${tmp}_${sample}.gencode.min2reads.coverage.tsv`
    platform=$(echo $lab | awk -F'-' '{print $1}')
        
    if [ -f $file ]; then
        fgrep -f ../../data/sirvs_mapping/HS.erccSpikein.ids.list $file | while read text cap sf labx chr strt stp ID count
        do
            echo -e "$sample\t$platform\t$ID\t$count\tERCC\t$lab\t$cap"
        done

        fgrep -f ../../data/sirvs_mapping/HS.notTargeted.erccSpikein.ids.list $file | while read text cap sf labx chr strt stp ID count
        do
            echo -e "$sample\t$platform\t$ID\t$count\tERCC\t$lab\t$cap"
        done
    fi
done < ../samples.benchmark.sirvs.tsv > human.spikein.read.count.tsv

cat human.spikein.read.count.tsv | while read sample platform ERCC count tmp lab cap 
do
    cat ../../data/sirvs_mapping/ERCC.concs | awk -v spike=$ERCC '$2==spike'| while read nb spikeIn subgroup conc1 conc2 FC sth
    do
       echo -e "$sample\t$platform\t$ERCC\t$count\t$conc1\tERCC\t$lab\t$cap"
    done
done > human.spikein.conc.read.count.updtd.tsv
