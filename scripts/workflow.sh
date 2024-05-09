## make a new “master folder” called anything, i’m calling this one “proj” for convenience
mkdir proj
cd proj

## setup
workdir=$(pwd)
cd $workdir
module load stack/2021.1-base_arch

## download fastq.gz files
mkdir fastq  # this makes a new folder called "fastq" where we will download our files

wget -P $workdir/fastq -r -l 2 -nH -nd -np --ignore-case -A '*fastq.gz' [link to folder containing subfolders with paired-end reads for each sample]
## quality checking fastq.gz files
mkdir fastq/qc
mkdir fastq/multiqc
fastqc fastq/*.fastq.gz -o fastq/qc 
multiqc fastq/qc -o fastq/multiqc # multiqc compiles all individual fastqc files into one report

## STAR alignment
mkdir star
cd fastq

staridx=/Users/croushore/hs_index

module load stack/2022.2-base_arch

for i in *_R1_001.fastq.gz; do 
  STAR --runMode alignReads \
  --genomeLoad NoSharedMemory \
  --readFilesCommand zcat \
  --outSAMtype BAM SortedByCoordinate \
  --genomeDir $staridx/hs_genome \
  --readFilesIn $i ${i%_R1_001.fastq.gz}_R2_001.fastq.gz \
  --runThreadN 6  \
  --outSAMattributes NM  \
  --outFileNamePrefix $workdir/star/${i%_R1_001.fastq.gz}; done

## generate read counts
cd $workdir/star
mkdir $workdir/counts

featureCounts -T 4 -s 2 -p -t exon -g gene_id -a $staridx/gencode.v45.annotation.gtf -o $workdir/counts/counts.txt *.bam

multiqc $workdir/counts/counts.txt.summary

## open R and tidy data

module load stack/2022.1-base_arch
module load r/4.1.3_gcc-9.4.0
cd $workdir/counts

R

install.packages(c("tidyverse", "magrittr","stringr","dplyr"),repos = "http://cran.us.r-project.org")

library(tidyverse)
library(magrittr)
library(stringr)
library(dplyr)

## load counts.txt file for data tidying
counts <- read.delim("counts.txt", comment.char="#", header= TRUE, row.names = 1)

## removing ENSEMBL version numbers (e.g., ENG0898O.1 -> ENGENG0898O)
row.names(counts) %<>% str_remove("\\.[0-9]+$")

## removing Chr, Start, End, Strand, and Length columns (for easy iDEP analysis)
counts_tidy <- counts[,c(-(1:5))]

## tidying sample column names
names(counts_tidy) = gsub(pattern = "_.*", replacement = "", x = names(counts_tidy))

## writing as csv file (raw counts)
write.csv(counts_tidy, file = "counts_tidy.csv")
