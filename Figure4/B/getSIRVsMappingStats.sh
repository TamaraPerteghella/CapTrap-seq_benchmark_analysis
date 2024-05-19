#!/bin/bash
annot="../../data/sirvs_mapping/HpreCap.SIRVs.gff"
script="https://raw.githubusercontent.com/guigolab/LyRic/d304504/utils/fastq2tsv.pl"
wget "$script"
chmod +x fastq2tsv.pl

echo -e "seqTech\tcapDesign\tsizeFrac\tsampleRep\ttotalReads\tmappedReads\tpercentMappedReads" > human.sirvs.mapping.tsv
while read lab cap tmp sample
do
  bams="${lab}_${cap}_${tmp}_${sample}.bam",
  fastqs="${lab}_${cap}_${tmp}_${sample}.fastq.gz"
  basic="${lab}_${cap}_${tmp}_${sample}.mapping.tsv"
  
  totalReads=$(zcat ${fastqs} | fastq2tsv.pl | wc -l)
  mappedReads=$(samtools view  -F 4 ${bams} | cut -f1 | sort -u | wc -l)
  erccMappedReads=$(samtools view -F 4 ${bams} | cut -f3 | tgrep ERCC - | wc -l)
  sirvMappedReads=$(samtools view -F 4 ${bams} | cut -f3 | tgrep SIRV | wc -l)

  echo -e "${lab}\t${cap}\t${tmp}\t${sample}\t$totalReads\t$mappedReads" | awk '{{print $0"\t"$6/$5}}' > ${basic}
  sort $basic >> human.sirvs.mapping.tsv
done < ../samples.benchmark.sirvs.tsv
