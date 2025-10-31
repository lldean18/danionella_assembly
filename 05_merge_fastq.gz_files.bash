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

## combine fastq.gz files into one for fish A
#cat simplex_SUP_calls_ic_207.fastq.gz \
#	simplex_SUP_calls_ic_208.fastq.gz > FishA_ALL_simplex.fastq.gz

# combine simplex fastq.gz files into one for fish B
cat simplex_SUP_calls_ic_206.fastq.gz \
	duplex_SUP_calls_duplex_simplex.fastq.gz \
	duplex_SUP_calls_duplex2_simplex.fastq.gz > FishB_ALL_simplex.fastq.gz


cat duplex_SUP_calls_duplex_duplex.fastq.gz \
	duplex_SUP_calls_duplex2_duplex.fastq.gz > FishB_ALL_duplex_duplex.fastq.gz




