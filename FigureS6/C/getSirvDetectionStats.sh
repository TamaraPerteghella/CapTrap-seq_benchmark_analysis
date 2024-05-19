#!/bin/bash
annot="../../data/sirvs_mapping/HpreCap.SIRVs.gff"
script="https://raw.githubusercontent.com/guigolab/LyRic/d304504/utils/simplifyGffCompareClasses.pl"
wget "$script"
chmod +x simplifyGffCompareClasses.pl

while read lab cap tmp sample
do 
  input="../../data/gff/${lab}_${cap}_${tmp}_${sample}.gff.gz"
  zcat $input | awk '$1 ~ /SIRV/ ' > ${lab}_${cap}_${tmp}_${sample}.tmp
  gffcompare -o ${lab}_${cap}_${tmp}_${sample} -r $annot ${lab}_${cap}_${tmp}_${sample}.tmp
  cat ${lab}_${cap}_${tmp}_${sample}.tracking | simplifyGffCompareClasses.pl - > ../../data/sirvs_mapping/gffcompare/${lab}_${cap}_${tmp}_${sample}.reads.vs.SIRVs.simple.tsv
  mv ${lab}_${cap}_${tmp}_${sample}.refmap ${lab}_${cap}_${tmp}_${sample}.reads.vs.SIRVs.refmap
done  < ../samples.technology.sirvs.tsv


script="https://raw.githubusercontent.com/guigolab/LyRic/d304504/utils/sirvDetectionStats.pl"
wget "$script"
chmod +x sirvDetectionStats.pl

echo -e "seqTech\tcapDesign\tsizeFrac\tsampleRep\tSIRVid\tlength\tconcentration\tdetectionStatus" > technology.spikeIns.sirvome.tsv

while read lab cap tmp sample
do
  gffC="../../data/sirvs_mapping/gffcompare/${lab}_${cap}_${tmp}_${sample}.reads.vs.SIRVs.refmap"
  sirvDetectionStats.pl ../../data/sirvs_mapping/SIRV_Set1_Lot00141_info-170612a.tsv $gffC > ${lab}_${cap}_${tmp}_${sample}.tmp
  cat ${lab}_${cap}_${tmp}_${sample}.tmp | while read id l c ca; 
  do 
    echo -e "$lab\t$cap\t$tmp\t$sample\t$id\t$l\t$c\t$ca";
  done > ${lab}_${cap}_${tmp}_${sample}.out
  
 sort ${lab}_${cap}_${tmp}_${sample}.out >> technology.spikeIns.sirvome.tsv
  
done < ../samples.technology.sirvs.tsv
