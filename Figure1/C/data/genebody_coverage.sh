#!/bin/bash

annotation="/users/project/gencode_006070_no_backup/epalumbo/pilot/output/annotations/${cap}.bed"
output="${cap}_${sample}.readProfileMatrix.tsv.gz"

out_plot="${cap}_${sample}.readProfileMatrix.density.png" 
colors="colors.txt"

echo "Compute Matrix..."
computeMatrix scale-regions -S ${bw[@]} -R $annotation -o $output --upstream 1000 --downstream 1000 --sortRegions ascend --missingDataAsZero --skipZeros --metagene -p 6 --samplesLabel $(cat $libprep | perl -ne 'chomp; print')

echo "Plot Profile..."
plotProfile -m $output -o $out_plot --perGroup --plotType se --yAxisLabel "mean CPM" --regionsLabel '' --plotTitle "${sample}" --colors $(cat $colors | perl -ne 'chomp; print')
