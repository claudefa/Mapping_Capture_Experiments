#!/bin/bash

DIR="/path/to/your/directory/"
IN=${DIR}"FASTQs/Demultiplex/"
OUTDIR=${DIR}"FASTQs/Trimmed/"

qu=$OUTDIR"qu"
out=${OUTDIR}"out"

mkdir -p $OUTDIR
mkdir -p $qu
mkdir -p $out

sample=""
while read line;
do
	sample=`echo $line | awk '{print $1}'`
	p1=${IN}${sample}_1.fastq.gz 
	p2=${IN}${sample}_2.fastq.gz
	p1o=${OUTDIR}${sample}_1.fastq.gz
	p1o2=${OUTDIR}${sample}_R1_bad.fastq.gz
        p2o=${OUTDIR}${sample}_2.fastq.gz
        p2o2=${OUTDIR}${sample}_R2_bad.fastq.gz
	
	jobName=${qu}/trimming_adaptors${sample}_chr21.sh
	
	echo "#!/bin/bash" > ${jobName} 
	echo "java -jar /apps/TRIMMOMATIC/0.36/trimmomatic-0.36.jar PE -phred33 $p1 $p2 $p1o $p1o2 $p2o $p2o2 ILLUMINACLIP:${DIR}/adapters.fa:2:30:10 SLIDINGWINDOW:5:20" > ${jobName}

	chmod 755 $jobName
	python3 ~/submit.py -u 1 -c $jobName -n tr${sample} -o ${out}/tr${sample}_shotgun.out -e  ${out}/tr${sample}_shotgun.err -w "3:00:00" 

done < Samples_hDNA
