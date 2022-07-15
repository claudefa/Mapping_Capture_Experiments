#!/bin/bash

#Set Directory
DIR="/path/to/your/directory/"
IN=${DIR}"FASTQs/Trimmed/"
OUTDIR=${DIR}"BAM_hg19/"

#Software
BWA="/apps/BWA/0.7.12/bin/bwa";
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
	p1=${IN}${sample}_merged.fastq.gz
	
	jobName=${qu}/bwa_hg19_${sample}.sh
	
        echo "$BWA mem -t 4 -M $FASTA_ASSEMBLY $p1 | $SAMTOOLS view -Sbh - | java -Djava.io.tmpdir=\${TMPDIR} -jar $PICARDTOOLS/AddOrReplaceReadGroups.jar I=/dev/stdin O=${OUTDIR}/${sample}_se.bam SORT_ORDER=coordinate QUIET=TRUE COMPRESSION_LEVEL=9 MAX_RECORDS_IN_RAM=150000 RGLB=${sample} RGPL=Illumina RGPU=${sample} RGSM=${sample} RGID=${sample} VALIDATION_STRINGENCY=SILENT"> ${jobName}
	chmod 755 $jobName
	python3 ~/submit.py -u 4 -c $jobName -n bwa${sample} -o ${out}/bwa_${sample}.out -e ${out}/bwa_${sample}.err -w "8:00:00" 

done < Samples_chr21 
