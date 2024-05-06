## setup
workdir=$(pwd)
cd $workdir
module load stack/2021.1-base_arch   # See https://uiowa.atlassian.net/wiki/spaces/hpcdocs/pages/76515023/2021.1+Stack for the list of modules loaded

## download fastq.gz files
mkdir fastq  # this makes a new folder called "fastq" where we will download our files
wget -P $workdir/fastq -r -l 2 -nH -nd -np --ignore-case -A '*fastq.gz' [insert link]  # this command will recursively download all files ending with ".fastq.gz" from the specified URL (http://example.edu/results/), up to two levels deep, ignoring case and saving them in the current directory without creating a directory structure mirroring the server.

## quality checking fastq.gz files
mkdir fastq/qc # this makes a new folder called "qc" inside the "fastq" folder to output fastqc files into
fastqc -o $workdir/fastq/qc -t 6 *fastq.gz  # this command will execute FastQC on all FASTQ files ending with ".fastq.gz" in the current directory, using up to 6 CPU threads for analysis, and save the resulting reports to the directory specified
multiqc $workdir/fastq/qc  # multiqc compiles all individual fastqc files into one report

## STAR alignment
mkdir star
cd fastq

staridx=$workdir/hs_index_100/hs_genome

module load stack/2022.2-base_arch

for i in *_R1_001.fastq.gz; do 
  STAR --runMode alignReads \
  --genomeLoad NoSharedMemory \
  --readFilesCommand zcat \
  --outSAMtype BAM SortedByCoordinate \
  --genomeDir $staridx \
  --readFilesIn $i ${i%_R1_001.fastq.gz}_R2_001.fastq.gz \
  --runThreadN 6  \
  --outSAMattributes NM  \
  --outFileNamePrefix $workdir/STAR/${i%_R1_001.fastq.gz}; done

## generate read counts
cd $workdir
mkdir counts
#module load stack/2022.2-base_arch

featureCounts -T 4 -s 2 -p -t exon -g gene_id -a $workdir/hs_index_100/gencode.v29.annotation.gtf -o $workdir/counts/counts.txt *.bam

multiqc $workdir/counts/counts.txt.summary

## tidy data in R
Rscript $workdir/scripts/tidy_counts.R
