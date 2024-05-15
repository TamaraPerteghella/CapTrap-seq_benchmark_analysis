#!/bin/bash
#Brain
bw="../../data/bw/technology_brain/*bw"
annotation="../../data/human.bed"
output="tech_brain.readProfileMatrix.tsv.gz"
out_plot="tech_brain.readProfileMatrix.density.png" 

echo "Compute Matrix..."
computeMatrix scale-regions -S ${bw[@]} -R $annotation -o $output --upstream 1000 --downstream 1000 --sortRegions ascend --missingDataAsZero --skipZeros --metagene -p 6 

echo "Plot Profile..."
plotProfile -m $output -o $out_plot --perGroup --plotType se --yAxisLabel "mean CPM" --regionsLabel '' --plotTitle "Brain"


#Heart
bw="../../data/bw/technology_heart/*bw"
output="tech_heart.readProfileMatrix.tsv.gz"
out_plot="tech_heart.readProfileMatrix.density.png" 

echo "Compute Matrix..."
computeMatrix scale-regions -S ${bw[@]} -R $annotation -o $output --upstream 1000 --downstream 1000 --sortRegions ascend --missingDataAsZero --skipZeros --metagene -p 6 

echo "Plot Profile..."
plotProfile -m $output -o $out_plot --perGroup --plotType se --yAxisLabel "mean CPM" --regionsLabel '' --plotTitle "Heart"
