#!/bin/bash
# 22/7/26

# script to downsample reads to be processed together for popgen

#SBATCH --job-name=downsample_reads
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=50g
#SBATCH --time=60:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out

# setup env
source $HOME/.bash_profile
conda activate minimap2
mkdir -p /gpfs01/home/mbzlld/data/danionella/popgen/downsampling
cd /gpfs01/home/mbzlld/data/danionella/popgen/downsampling

reference=/share/deepseq/shenson/ds1664_Wilkinson/03_medaka/consensus.fasta

fastqs=(
/gpfs01/home/mbzlld/data/danionella/fish_c/basecalls/SUP_fish_c.fastq.gz
/gpfs01/home/mbzlld/data/danionella/basecalls/FishA_ALL_simplex.fastq.gz
/gpfs01/home/mbzlld/data/danionella/basecalls/FishB_ALL_simplex.fastq.gz
)

for fastq in ${fastqs[@]}
do

echo "running for $fastq
against the reference $reference
"

# start by mapping the larger read file to the reference
minimap2 \
-ax map-ont \
-t 16 \
$reference \
$fastq |
samtools sort --threads 16 -o $(basename ${fastq%.*.*})_TO_$(basename ${reference%.*}).bam
samtools index --threads 16 $(basename ${fastq%.*.*})_TO_$(basename ${reference%.*}).bam

# filter to retain only good mappings
samtools view \
-b \
-q 30 \
-F 260 \
$(basename ${fastq%.*.*})_TO_$(basename ${reference%.*}).bam |
samtools sort --threads 16 -o $(basename ${fastq%.*.*})_TO_$(basename ${reference%.*})_flt.bam
samtools index --threads 16 $(basename ${fastq%.*.*})_TO_$(basename ${reference%.*})_flt.bam

# compute the current coverage of the reference bam
echo "the initial depth of coverage of the well mapped reads is:"
samtools depth \
$(basename ${fastq%.*.*})_TO_$(basename ${reference%.*})_flt.bam |
awk '{sum+=$3} END {print sum/NR}'

done

# AGAINST concensus.fasta the depths were
# fish c: 136.855
# fish a: 14.4006
# fish b:

##############################

##  for fastq in ${fastqs[@]}
##  do
##  
##  echo "running for $fastq
##  against the reference $reference
##  "
##  
##  # randomly subsample to the desired coverage
##  rasusa aln \
##  --coverage 22 \
##  $(basename ${fastq%.*.*})_TO_$(basename ${reference%.*})_flt.bam |
##  samtools sort --threads 16 -o $(basename ${fastq%.*.*})_downsampled.bam
##  samtools index --threads 16 $(basename ${fastq%.*.*})_downsampled.bam
##  
##  # check final depth
##  echo "the final depth of the downsampled bam file is:"
##  samtools depth \
##  $(basename ${fastq%.*.*})_downsampled.bam \
##  | awk '{sum+=$3} END {print sum/NR}'
##  
##  done

# cleanup env
conda deactivate


