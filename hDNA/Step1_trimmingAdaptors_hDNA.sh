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
	
	jobName=${qu}/trimming_adaptors${sample}.sh
	
	echo "~/bin/fastp -i ${p1} -I ${p2} --out1 ${p1o} --out2 ${p2o} --unpaired1 ${p1o2} --unpaired2 ${p2o2} --detect_adapter_for_pe -p --adapter_sequence=AGATCGGAAGAGCACACGTCTGAACT
CCAGTCA --adapter_sequence_r2=AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT --trim_poly_g --poly_g_min_len 10 --length_required 30 --html ${OUTDIR}/${sample}.html" > ${jobName}
	chmod 755 $jobName
	python3 ~/submit.py -u 1 -c $jobName -n tr${sample} -o ${out}/tr${sample}_shotgun.out -e  ${out}/tr${sample}_shotgun.err -w "3:00:00" 

done < Samples_hDNA
