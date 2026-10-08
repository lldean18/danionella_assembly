#!/bin/bash
# Laura Dean
# 8/10/26

# script to perform read trimming and filtering

#SBATCH --job-name=ReadTrim
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=15g
#SBATCH --time=2:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


# first concatenated the reads with:
#cat ds1756_2_S3_L001_R1_001.fastq.gz ds1756_2_S3_L002_R1_001.fastq.gz > /gpfs01/home/mbzlld/data/danionella/fish_d/fastqs/ds1756_2_S3_L001_and_L002_R1.fastq.gz
#cat ds1756_2_S3_L001_R2_001.fastq.gz ds1756_2_S3_L002_R2_001.fastq.gz > /gpfs01/home/mbzlld/data/danionella/fish_d/fastqs/ds1756_2_S3_L001_and_L002_R2.fastq.gz

# setup env
module load fastp-uoneasy/0.23.4-GCC-12.3.0
cd /gpfs01/home/mbzlld/data/danionella/fish_d/fastqs
mkdir -p trimmed_fastqs


# set the file names
fwd_reads=ds1756_2_S3_L001_and_L002_R1.fastq.gz
rev_reads=ds1756_2_S3_L001_and_L002_R2.fastq.gz

fastp \
-i $fwd_reads \
-I $rev_reads \
-o trimmed_fastqs/$fwd_reads \
-O trimmed_fastqs/$rev_reads \
--detect_adapter_for_pe \
--thread 8

# cleanup env
module unload fastp-uoneasy/0.23.4-GCC-12.3.0




