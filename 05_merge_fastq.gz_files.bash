#!/bin/bash
# Laura Dean
# 16/10/25
# script written for running on the UoN HPC Ada

#SBATCH --job-name=merge_fastqs
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=50g
#SBATCH --time=2:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


# set working directory and move to it
wkdir=/gpfs01/home/mbzlld/data/danionella/basecalls
cd $wkdir

# combine fastq.gz files into one
cat simplex_SUP_calls_1.fastq.gz \
	simplex_SUP_calls_2.fastq.gz \
	duplex_SUP_calls_1_simplex.fastq.gz \
	duplex_SUP_calls_2_simplex.fastq.gz > ALL_simplex.fastq.gz


cat duplex_SUP_calls_1_duplex.fastq.gz \
	duplex_SUP_calls_2_duplex.fastq.gz > all_duplex_duplex.fastq.gz




