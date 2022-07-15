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

	pm=${OUTDIR}${sample}_merged.fastq.gz
	p1o=${OUTDIR}${sample}_1.fastq.gz
        p2o=${OUTDIR}${sample}_2.fastq.gz
        pup1=${OUTDIR}${sample}_unpaired1.fastq.gz
        pup2=${OUTDIR}${sample}_unpaired2.fastq.gz
	
	jobName=${qu}/FASTP${sample}.sh
	
	echo "#!/bin/bash" > ${jobName} 
	echo "~/bin/fastp -i ${p1} -I ${p2} --merge --merged_out ${pm} --out1 ${p1o} --out2 ${p2o} --unpaired1 ${pup1} --unpaired2 ${pup2} --overlap_len_require 11 --detect_adapter_for_pe -p --adapter_sequence=AGATCGGAAGAGCACACGTCTGAACTCCAGTCA --adapter_sequence_r2=AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT --trim_poly_g --poly_g_min_len 10 --length_required 30 --html ${OUTDIR}/${sample}.html" > ${jobName}

	chmod 755 $jobName
	python3 ~/submit.py -u 4 -c $jobName -n FastP${sample} -o ${out}/FASTP${sample}.out -e  ${out}/FASTP${sample}.err -w "8:00:00" 

done < Samples_chr21
