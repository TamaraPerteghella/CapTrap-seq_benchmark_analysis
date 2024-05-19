#Remove ERCC polyA
input="${lab}_${cap}_${tmp}_${sample}.polyAsites.bed.gz"
output="${lab}_${cap}_${tmp}_${sample}.polyAsitesNoErcc.tmp.bed"

zcat ${input} | fgrep -v ERCC > ${output}

#integrate Polya and SJ info
polyA="${lab}_${cap}_${tmp}_${sample}.polyAsitesNoErcc.tmp.bed"
SJs="${lab}_${cap}_${tmp}_${sample}.transcripts.tsv.gz"
wrongPolyAs="${lab}_${cap}_${tmp}_${sample}.wrongPolyAs.list"

zcat ${SJs} | skipcomments | cut -f 1,2 | awk '$2!="."' | sort > ${lab}_${cap}_${tmp}_${sample}.reads.SJ.strandInfo.tsv
cat ${polyA} | cut -f4,6 | awk '$2!="."'| sort > ${lab}_${cap}_${tmp}_${sample}.reads.polyA.strandInfo.tsv
join -a1 -a2 -e '.' -o '0,1.2,2.2' ${lab}_${cap}_${tmp}_${sample}.reads.SJ.strandInfo.tsv  ${lab}_${cap}_${tmp}_${sample}.reads.polyA.strandInfo.tsv > ${lab}_${cap}_${tmp}_${sample}.reads.SJ.polyA.strandInfo.tsv

#make list of reads with wrongly called polyA sites (i.e. their strand is different from the one inferred using SJs):
cat ${lab}_${cap}_${tmp}_${sample}.reads.SJ.polyA.strandInfo.tsv | perl -slane 'if($F[2] ne "." && $F[1] ne "." && $F[1] ne $F[2]){{print join ("\\t", $F[0])}}' | sort -u > ${lab}_${cap}_${tmp}_${sample}.wrongPolyAs

# Get list of right polyA reads without ERCCs
polyA="${lab}_${cap}_${tmp}_${sample}.polyAsitesNoErcc.tmp.bed",
wrongPolyAs="${lab}_${cap}_${tmp}_${sample}.wrongPolyAs.list"
output="${lab}_${cap}_${tmp}_${sample}.polyAsitesNoErcc.bed"

cat ${polyA} | fgrep -v -w -f ${wrongPolyAs} > ${output}

input="${lab}_${cap}_${tmp}_${sample}.polyAsitesNoErcc.bed" 
output="${lab}_${cap}_${tmp}_${sample}.polyAreads.list"
cat ${input} | cut -f4 | sort -u > $output
