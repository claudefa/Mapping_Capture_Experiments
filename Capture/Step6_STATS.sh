#!/bin/bash


#GET PROJECT TABLE
PROJECT_DIR=/path/to/your/directory/;
PATH_BWA=${PROJECT_DIR}/;
PATH_STATS=${PROJECT_DIR}STATS_hg19/;

PICARDTOOLS=/apps/PICARD/1.95/;
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

    	# Mapped
        jobName=${qu}/StatBam.${sample}.sh
    	bamFile=${PATH_BWA}/BAM_hg19/${sample}.sorted.bam
    	statsFile=${PATH_STATS}/BAM_hg19/${sample}_sorted.stats
	
	echo "java -Xmx4g -jar ${PICARDTOOLS}/CollectAlignmentSummaryMetrics.jar INPUT=${bamFile} METRIC_ACCUMULATION_LEVEL=SAMPLE \
		REFERENCE_SEQUENCE=$FASTA_ASSEMBLY OUTPUT=${statsFile} VALIDATION_STRINGENCY=SILENT"> $jobName

	chmod 755 $jobName
        python3 ~/submit.py -c $jobName -n statCHR${sample} -o ${out}/stat.${sample}.out -e  ${out}/stat.${sample}.err -u 1 -w "0:59:00"

        jobName=${qu}/StatBamRmDups.${sample}.sh

    	# Unique reads 
	jobName=${qu}/StatBamRmDups.${sample}.sh
    	bamFile=${PATH_BWA}/BAM_RmDups_hg19/${sample}_rmdups.bam
    	statsFile=${PATH_STATS}/BAM_RmDups_hg19/${sample}_rmdups.stats
	
	echo "java -Xmx4g -jar ${PICARDTOOLS}/CollectAlignmentSummaryMetrics.jar INPUT=${bamFile} METRIC_ACCUMULATION_LEVEL=SAMPLE \
		REFERENCE_SEQUENCE=$FASTA_ASSEMBLY OUTPUT=${statsFile} VALIDATION_STRINGENCY=SILENT">> $jobName

	chmod 755 $jobName
        python3 ~/submit.py -c $jobName -n statchr21${sample} -o ${out}/statrm.${sample}.out -e  ${out}/statrm.${sample}.err -u 1 -w "0:59:00"

	# Filtered reads
        jobName=${qu}/StatBamFilter.${sample}.sh
    	bamFile=${PATH_BWA}/BAM_Filtered_hg19/${sample}_rmdups.qual.bam
    	statsFile=${PATH_STATS}/BAM_Filtered_hg19/${sample}_rmdups.qual.stats
	
	echo "java -Xmx4g -jar ${PICARDTOOLS}/CollectAlignmentSummaryMetrics.jar INPUT=${bamFile} METRIC_ACCUMULATION_LEVEL=SAMPLE \
		REFERENCE_SEQUENCE=$FASTA_ASSEMBLY OUTPUT=${statsFile} VALIDATION_STRINGENCY=SILENT">> $jobName

	chmod 755 $jobName
        python3 ~/submit.py  -c $jobName -n statchr21${sample} -o ${out}/statFilter.${sample}.out -e  ${out}/statFilter.${sample}.err -u 1 -w "0:59:00"

        # OnTarget reads
        jobName=${qu}/StatBamOnTarget.${sample}.sh
        bamFile=${PATH_BWA}/BAM_OnTarget/${sample}_onTarget.bam
        statsFile=${PATH_STATS}/BAM_OnTarget/${sample}_onTarget.stats

        echo "java -Xmx4g -jar ${PICARDTOOLS}/CollectAlignmentSummaryMetrics.jar INPUT=${bamFile} METRIC_ACCUMULATION_LEVEL=SAMPLE \
                REFERENCE_SEQUENCE=$FASTA_ASSEMBLY OUTPUT=${statsFile} VALIDATION_STRINGENCY=SILENT">> $jobName

        chmod 755 $jobName
        python3 ~/submit.py  -c $jobName -n statchr21${sample} -o ${out}/statOnT.${sample}.out -e  ${out}/statOnT.${sample}.err -u 1 -w "0:59:00"

done < Samples_chr21
