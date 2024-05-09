# sample script used to fetch raw publicly-available rna-seq reads for reanalysis
# BioProject:	PRJNA690227
# SRA Study:	SRP300739
# GEO Accession: GSE164372 (https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE164372)
# Citation:  Buchou C, Laud-Duval K, van der Ent W, Grossetête S et al. 
#            Upregulation of the Mevalonate Pathway through EWSR1-FLI1/EGR2 
#            Regulatory Axis Confers Ewing Cells Exquisite Sensitivity to Statins. 
#            Cancers (Basel) 2022 May 8;14(9). PMID: 35565457

## make a new “master folder” called anything, i’m calling this one “GSE164372” for convenience
mkdir GSE164372
cd GSE164372

## setup
workdir=$(pwd)
cd $workdir

module load stack/2022.2-base_arch # See https://uiowa.atlassian.net/wiki/spaces/hpcdocs/pages/76513504/2022.2+stack for the list of modules loaded
module load sra-tools/3.0.3_gcc-9.5.0

# select SRR files of interest
for (( i = 43; i <= 60; i++ ))
  do
  prefetch SRR133761$i
done

# convert SRR files to fastq.gz and download
for (( i = 43; i <= 60; i++ ))
  do
  parallel-fastq-dump --sra-id SRR133761$i --threads 8 --outdir out/ --split-files --gzip 
done
