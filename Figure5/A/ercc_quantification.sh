while read lab cap tmp sample
do
    platform=$(echo $lab | awk -F'-' '{print $1}')
    file=`echo ../../data/coverage/${lab}_${cap}_${tmp}_${sample}.gencode.coverage.tsv`  
    fgrep -f ../../data/sirvs_mapping/HS.erccSpikein.ids.list $file | while read text cap sf labx chr strt stp ID count 
    do 
        echo -e "$labx\t$platform\t$ID\t$count\tERCC\t$lab" 
    done >> $cap.spikein.read.count.$sample.tsv

    fgrep -f ../../data/sirvs_mapping/HS.notTargeted.erccSpikein.ids.list $file | while read text cap sf labx chr strt stp ID count 
    do 
        echo -e "$labx\t$platform\t$ID\t$count\tERCC\t$lab" 
    done >> $cap.spikein.read.count.$sample.tsv

done < samples.lrgasp.tsv

while read lab cap tmp sample
do
    cat $cap.spikein.read.count.$sample.tsv | while read sample platform ERCC count typ 
    do
        cat ../../data/sirvs_mapping/ERCC.concs | awk -v spike=$ERCC '$2==spike'| while read nb spikeIn subgroup conc1 conc2 FC sth 
        do 
             echo -e "$sample\t$platform\t$ERCC\t$count\t$conc1\t$typ\t$cap" 
        done         
    done > $cap.spikein.conc.read.count.updtd.$sample.tsv 
done < samples.lrgasp.tsv

for cap in MpreCap HpreCap
do
    for i in $cap.spikein.conc.read.count.updtd.*.tsv; do cat $i >> $cap.spikein.conc.read.count.updtd.all.tsv; done
done
