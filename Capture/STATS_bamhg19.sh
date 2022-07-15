#!/bin/bash

#Creates job for sort and merge BAMs

#GET PROJECT TABLE
PROJECT_DIR=/scratch/devel/cfontser/FecalSeq/;
PATH_BWA=${PROJECT_DIR}/BAM_hg19/;
PATH_STATS=${PROJECT_DIR}STATS_hg19/BAM/;

PICARDTOOLS=/apps/PICARD/1.95/;
SAMTOOLS=/apps/SAMTOOLS/0.1.19/bin/samtools;
SAMBAMBA=/apps/SAMBAMBA/0.4.7/bin/sambamba;
FASTA_ASSEMBLY=/home/devel/marcmont/scratch/snpCalling_hg19/chimp/assembly/hg19.fa;

# Set output
qu=${PATH_STATS}"qu"
out=${PATH_STATS}"out"

# Create directories
mkdir -p $PATH_STATS
mkdir -p $qu
mkdir -p $out


while read line;
do
        sample=`echo $line | awk '{print $1}'`

        jobName=${qu}/StatBam.${sample}.sh

    	# BAM FILE INPUT FILE AND DUPLICATES FILE GC STATS AND STATS FILE 
    	bamFile=${PATH_BWA}${sample}.sorted.bam
    	statsFile=${PATH_STATS}${sample}_merged.stats
	
	echo "java -Xmx4g -jar ${PICARDTOOLS}/CollectAlignmentSummaryMetrics.jar INPUT=${bamFile} METRIC_ACCUMULATION_LEVEL=SAMPLE \
		REFERENCE_SEQUENCE=$FASTA_ASSEMBLY OUTPUT=${statsFile} VALIDATION_STRINGENCY=SILENT"> $jobName

	 chmod 755 $jobName
        python3 ~/submit.py -c $jobName -n statCHR${sample} -o ${out}/stat.${sample}.out -e  ${out}/stat.${sample}.err -u 1 -w "0:59:00"

done < Samples
