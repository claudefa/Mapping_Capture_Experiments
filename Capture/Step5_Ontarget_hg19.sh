#!/bin/bash

#GET PROJECT TABLE
DIR=/path/to/your/directory/;
PATH_BAM=${DIR}/BAM_Filtered_hg19/;
PATH_readsOnTarget=${DIR}/BAM_OnTarget/;
PATH_BED=${DIR}/Agilent_chr21_NR_chimptoHg19.bed;
BEDTOOLS=/apps/BEDTools/2.22.1/bin


# Set output
qu=${PATH_readsOnTarget}"qu"
out=${PATH_readsOnTarget}"out"

# Create directories
mkdir -p $PATH_readsOnTarget
mkdir -p $qu
mkdir -p $out


while read line;
do
        name=`echo $line | awk '{print $1}'`

	jobName=${qu}/StatBam.${name}.sh

    	bamFile=${PATH_BAM}${name}_rmdups.qual.bam 
	nameOut=${PATH_readsOnTarget}/${name}_onTarget.bam
 	
	echo "$BEDTOOLS/intersectBed -abam  $bamFile -b $PATH_BED > $nameOut" >> ${jobName}
	
	chmod 755 $jobName
        python3 ~/submit.py -c $jobName -n Tget${name} -o ${out}/Tget.${name}.out -e  ${out}/Tget.${name}.err -u 1 -w "0:59:00"

done < MergeSamples #or Samples_chr21 
