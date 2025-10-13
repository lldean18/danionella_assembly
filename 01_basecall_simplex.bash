#!/bin/bash
# Laura Dean
# file written for running on the UoN HPC Ada
# 13/10/25

#SBATCH --partition=ampereq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --gres=gpu:1
#SBATCH --mem=256g
#SBATCH --time=100:00:00
#SBATCH --job-name=danio_basecall
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out

# set variables
wkdir=/gpfs01/home/mbzlld/data/danionella


# then make a directory for the basecalled files (only if it does not already exist)
mkdir -p $wkdir/basecalls
cd $wkdir/basecalls


# make a list of the pod5 files
find /share/deepseq/matt/danionella -type f -name "*.pod5*" > ~/data/danionella/pod5_list.txt
# make a list from this with only the simplex files
sed '/duplex/d' ~/data/danionella/pod5_list.txt > ~/data/danionella/pod5_simplex_list.txt


# load cuda module
module load cuda-12.2.2


# basecall the simplex reads
xargs -a ~/data/danionella/pod5_simplex_list.txt \
	bash -c 'dorado basecaller sup@latest,5mCG_5hmCG "$@" > simplex_SUPlatest_calls.bam'











