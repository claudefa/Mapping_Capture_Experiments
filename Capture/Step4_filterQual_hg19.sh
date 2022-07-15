#!/bin/bash

# Set directories
DIR="/path/to/your/directory/"
IN=${DIR}"BAM_RmDups_hg19/"
OUTDIR=${DIR}"BAM_Filtered_hg19/"

mkdir -p $OUTDIR
# Set output
qu=${OUTDIR}"qu"
out=${OUTDIR}"out"

# Create directories

mkdir -p $qu
mkdir -p $out

# Reference

#REF
PICARDTOOLS="/apps/PICARD/1.95/"
ASSEMBLY="/home/devel/marcmont/scratch/snpCalling_hg19/chimp/assembly/hg19.fa"

sample=""

while read line;
do
	sample=`echo $line | awk '{print $1}'`

	bamFile=${IN}${sample}_rmdups.bam
	bamSorted=${OUTDIR}${sample}_rmdups.sorted.bam	
	bamFiltered=${OUTDIR}${sample}_rmdups.qual.bam

	jobName=${qu}/FilterBamHg19.${sample}.sh
	
	echo "samtools sort -T ${sample} -o $bamSorted $bamFile; \
	      samtools index $bamSorted;
	      samtools view -h -q 30 -F 256 -F 4 $bamSorted | samtools view -hb > $bamFiltered; \
	      samtools index $bamFiltered; 
	      rm $bamSorted " > ${jobName}
		

	chmod 755 $jobName
	python3 ~/submit.py  -c $jobName -n FilChr21${sample} -o ${out}/FilCh${sample}.out -e  ${out}/FilCh${sample}.err -u 1 -w "1:59:00" 

done < Samples_chr21 # or MergedSamples
