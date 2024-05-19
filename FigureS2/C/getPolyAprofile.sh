#!/bin/bash

while read lab cap tmp sample
do
  cat ../../data/bed/${lab}_${cap}_${tmp}_${sample}.bed | sortbed | bedtools slop -s -l 5 -r 5 -i stdin -g chromLengthInfo_hg38.txt | bedtools intersect -u -s -a stdin -b hg38.polyAsignals.bed > ${lab}_${cap}_${tmp}_${sample}.vspolyAsignals.bed

  ...
  TO DO
