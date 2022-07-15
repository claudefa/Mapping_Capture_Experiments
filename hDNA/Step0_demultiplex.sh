#!/bin/bash

Dir="/path/to/your/directory/"

fastqDir=${Dir}"FASTQs/FASTQ/"

outDir=${Dir}"/FASTQs/Demultiplex/"
out=${outDir}"out/"
qu=${outDir}"qu/"

mkdir -p $outDir
mkdir -p $out
mkdir -p $qu

# Barcode File (inside folder barcode_files/)
# barcode1 barcode1_output_file1.fastq barcode1_output_file2.fastq
# barcode2 barcode2_output_file1.fastq barcode2_output_file2.fastq

while read line;
do
	pool=$(echo $line | awk '{print $1}')
	filepool=$(echo $line | awk '{print $2}')

	p1=${fastqDir}Pool_${pool}_1.fastq.gz
	p2=${fastqDir}Pool_${pool}_2.fastq.gz

	jobName=${qu}Demultiplex${pool}.sh
	
	echo "#!/bin/bash" > ${jobName}
	echo "/home/devel/cfontser/bin/sabre/sabre pe -m 2 -c -f $p1 -r $p2 -b ${Dir}/barcode_files/$filepool -u ${outDir}Pool_${pool}_unknown_R1.fastq -w  ${outDir}Pool_${pool}_unknown_R2.fastq;" > ${jobName}
	chmod 755 $jobName
	
	python3 ~/submit.py -u 1 -c $jobName -n h_$pool -o ${out}/Demultiplex${filepool}.out -e  ${out}/Demultiplex${filepool}.err -w "1:59:00"	

done < list_demultiplex.txt
