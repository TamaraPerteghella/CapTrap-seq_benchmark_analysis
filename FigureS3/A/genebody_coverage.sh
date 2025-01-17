/#!/bin/bash
bw="../../data/bw/mouse/*bw"
annotation="../../data/mouse.bed"
output="mouse_brain.readProfileMatrix.tsv.gz"
out_plot="mouse_brain.readProfileMatrix.density.png" 

echo "Compute Matrix..."
computeMatrix scale-regions -S ${bw[@]} -R $annotation -o $output --upstream 1000 --downstream 1000 --sortRegions ascend --missingDataAsZero --skipZeros --metagene -p 6 

echo "Plot Profile..."
plotProfile -m $output -o $out_plot --perGroup --plotType se --yAxisLabel "mean CPM" --regionsLabel '' --plotTitle "Brain"
