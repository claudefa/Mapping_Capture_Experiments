#!/bin/bash

#Set Directory
DIR="/path/to/your/directory/"
IN=${DIR}"BAM_hg19/"
OUTDIR=${DIR}"BAM_mergeLib_hg19/"

#Software
SAMTOOLS="/apps/SAMTOOLS/0.1.19/bin/samtools";
PICARDTOOLS="/apps/PICARD/1.95/"

#Ref Genome
FASTA_ASSEMBLY="/home/devel/marcmont/scratch/snpCalling_hg19/chimp/assembly/hg19.fa"

qu=${OUTDIR}"qu"
out=${OUTDIR}"out"

mkdir -p $OUTDIR
mkdir -p $qu
mkdir -p $out

sample=""
while read line;
do
	sample=`echo $line | awk '{print $1}'`
	pool1=`echo $line | awk '{print $2}'`
	pool2=`echo $line | awk '{print $3}'`
	lib1=${IN}${sample}_${pool1}_chr21.sorted.bam
	lib2=${IN}${sample}_${pool2}_chr21.sorted.bam
	
	jobName=${qu}/merge_hg19_${sample}.sh


	bamMerged=${OUTDIR}${sample}_chr21.merged.bam
	bamSorted=${OUTDIR}${sample}_chr21.sorted.bam	

	jobName=${qu}/mergeBam.${sample}.sh
	
	echo "java -Xmx8g -Djava.io.tmpdir=\${TMPDIR} -jar ${PICARDTOOLS}MergeSamFiles.jar  \
	      I=${pe} I=${se} O=${bamMerged}; \
	      ${SAMTOOLS} sort -T ${sample}.mg -o $bamSorted $bamMerged; \
	      ${SAMTOOLS} index $bamSorted ; \
	      rm $bamMerged" > ${jobName}

	chmod 755 $jobName
	python3 ~/submit.py -u 4 -c $jobName -n merg${sample} -o ${out}/merge_${sample}.out -e ${out}/merge_${sample}.err -w "8:00:00" 
done < MergeSamples
