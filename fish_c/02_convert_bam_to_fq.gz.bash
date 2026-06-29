#!/bin/bash
# 29/6/26

# script to covert basecalled bam file to gzipped fastq format

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=10g
#SBATCH --time=12:00:00
#SBATCH --job-name=bam2fastq
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out

# setup env
cd /gpfs01/home/mbzlld/data/danionella/fish_c/basecalls
module load samtools-uoneasy/1.18-GCC-12.3.0


# convert the bam files to fastq format
# -O output quality tags if they exist
# -t output RG, BC and QT tags to the FASTQ header line
# then pipe to gzip to compress
samtools bam2fq \
-O \
-t \
--threads 23 \
SUP_fish_c.bam | gzip > SUP_fish_c.fastq.gz


# tidy up env
module unload samtools-uoneasy/1.18-GCC-12.3.0
echo "script ran to the end"

