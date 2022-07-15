#!/bin/bash

# Set directories
DIR="/path/to/your/directory/"
IN=${DIR}"BAM_hg19/" # if unique hybridization/lanes per sample
IN=${DIR}"BAM_mergeLib_hg19/" # if many hybridizations/lanes per sample

OUTDIR=${DIR}"BAM_RmDups_hg19/"

# Set output
qu=$OUTDIR"qu"
out=${OUTDIR}"out"

# Create directories
mkdir -p $OUTDIR
mkdir -p $qu
mkdir -p $out

# Reference

#REF
ASSEMBLY="/home/devel/marcmont/scratch/snpCalling_hg19/chimp/assembly/hg19.fa"

#Software
PICARDTOOLS="/apps/PICARD/1.95/"

sample=""

while read line;
do
	sample=`echo $line | awk '{print $1}'`
	
	bamFile=${IN}${sample}.sorted.bam # unique hybridizations/lanes per sample
	bamFile=${IN}${sample}_chr21.sorted.bam # many hybridizations/lanes per sample
	bamFileRmDup=${OUTDIR}${sample}_rmdups.bam
	bamFileRmDupStats=${OUTDIR}${sample}.rmdups.stats

	
	jobName=${qu}/rmdups.${sample}.sh
	
	echo "java -Xmx8g -Djava.io.tmpdir=\${TMPDIR} -jar ${PICARDTOOLS}/MarkDuplicates.jar \
		I=${bamFile} \
		O=${bamFileRmDup} \
		MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 METRICS_FILE=${bamFileRmDupStats} \
		REMOVE_DUPLICATES=true ASSUME_SORTED=true MAX_RECORDS_IN_RAM=1500000 \
		VALIDATION_STRINGENCY=SILENT CREATE_INDEX=true COMPRESSION_LEVEL=9" > ${jobName}
	chmod 755 $jobName
	python3 ~/submit.py -c $jobName -n rm.${sample} -o ${out}/rmdups.${sample}.out -e  ${out}/rmdups.${sample}.err -u 1 -w "4:59:00" 

done < MergeSamples # or Samples_chr21 if not merged samples 
