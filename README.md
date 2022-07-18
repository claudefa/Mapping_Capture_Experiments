# Mapping pipeline for target capture experiments 
***by Claudia Fontsere*** 
July 2022 - keep in mind that this will need to be updated 

## Endogenous or hDNA Quantification to prepare equi-endogenous pools for cature 

*Step 0* - Demultiplexing ##### Production reads #####
bash hDNA/Step0_demultiplex.sh # previousy you have to gather the barcode information per pool
bgzip *.fastq 
mv *gz FASTQ/Demultiplex/

*Step 1* - Trimming adapters  ##### 
bash Step1_trimmingAdaptors_hDNA.sh # Here I do not collapse reads since I am only interested on how many of reads map

*Step 2* - Mapping ##### Mapped reads #####
bash hDNA/Step2_mapping_hg19_hDNA.sh

*Step 3* - Remove Duplicates ##### Unique reads ####
bash hDNA/Step3_rmdupsPicard_hg19_hDNA.sh

*Step 4* - Filtering by quality, remove secondary aligmnets, unmapped ##### Reliable reads #####
bash hDNA/Step4_filterQual_hg19_hDNA.sh

*Step 5* - Count number of reads in each step, I count the FIRST in pair #####
zcat FASTQs/Demutliplex/${sample}_1.fastq.gz | wc -l # count production reads --> then divide by 4
bash hDNA/Step5_STATS_hDNA.sh

*Step 6* - Add all the previously collected information in an spread sheet hDNA=RR/PR #####

**Disclaimer: If number of production reads is very different between libraries, it might be wise to downsample to the same amount of reads/library**

## Processing of captured data

*Step 0* - Demultiplexing ##### Production reads #####
bash Capture/Step0_demultiplex.sh # previousy you have to gather the barcode information per pool

*Step 1* - Trimming adapters  ##### 
bash Capture/Step1_trimmingAdaptors_FastP.sh # If sequenced in 2x150bp and the insert size is small, collapse reads

*Step 2* - Mapping ##### Mapped reads #####
bash Capture/Step2_mapping_hg19_pe.sh # mapping pair end reads
bash Capture/Step2_mapping_hg19_se.sh # mapping single end reads

**Step 2.1** - Merging single end and paired end data #####
bash Capture/Step2.1_merge_pese.sh

**Step 2.2** - Merging - Optional, if same library has been captured in diff pools or sequenced in different lanes #####
bash Capture/Step2.2_mergeLib.sh

*Step 3* - Remove Duplicates ##### Unique reads ####
bash Capture/Step3_rmdupsPicard_hg19.sh

*Step 4* - Filtering by quality, remove secondary aligmnets, unmapped ##### Reliable reads #####
bash Capture/Step4_filterQual_hg19.sh

*Step 5* - Extract OnTarget Reads intersecting with BED file ##### OnTarget reads #####
bash Capture/Step5_Ontarget_hg19.sh

*Step 6* - Count number of reads in each step #####
zcat FASTQs/Demutliplex/${sample}_1.fastq.gz | wc -l # count production reads --> then divide by 4
bash Capture/Step6_STATS.sh # here one can decide to do stats per indvidiual hybridization (process everthing without
			    # merging the reads from multiple hyb) or total (after merging from different hyb)#########

*Step 7* - Add all the previously collected information in an spread sheet hDNA=RR/PR #####
