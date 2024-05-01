workdir=$(pwd)
cd $workdir
mkdir hs_index
mkdir hs_index/hs_genome

# download the "genome sequence, primary assembly (GRCh38)" fasta file
wget -P $workdir/hs_index ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_29/GRCh38.primary_assembly.genome.fa.gz

# download the annotations that correspond to it 
wget -P $workdir/hs_index ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_29/gencode.v29.annotation.gtf.gz

# unzip both files (temporarily since they are large)
gunzip $workdir/hs_index/GRCh38.primary_assembly.genome.fa.gz
gunzip $workdir/hs_index/gencode.v29.annotation.gtf.gz

module load stack/2022.2-base_arch # https://uiowa.atlassian.net/wiki/spaces/hpcdocs/pages/76513504/2022.2+stack
module load star/2.7.0e_gcc-8.4.0

STAR --runThreadN 8 \
--runMode genomeGenerate \
--genomeDir $workdir/hs_index/hs_genome \
--genomeFastaFiles $workdir/hs_index/GRCh38.primary_assembly.genome.fa \
--sjdbGTFfile $workdir/hs_index/gencode.v29.annotation.gtf \
--sjdbOverhang 100  \

# after genome generated
gzip $workdir/hs_index/GRCh38.primary_assembly.genome.fa
