#!/bin/bash
# Laura Dean
# 13/11/25
# for running on the UoN HPC Ada

#SBATCH --partition=hmemq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=96
#SBATCH --mem=1495g
#SBATCH --time=168:00:00
#SBATCH --job-name=step1_dorado_correct
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


# set variables
wkdir=/gpfs01/home/mbzlld/data/danionella/basecalls
cd $wkdir

# specify the file of reads to be corrected
#fastq=FishA_ALL_simplex.fastq.gz
fastq=FishB_ALL_simplex.fastq.gz



# the whole thing fails because the models just won't download! Grr
# First need to download the models because that fails in the job
#dorado download --models all --models-directory /gpfs01/home/mbzlld/data/dorado_models



##### CREATE THE ALL VS ALL PAF FILE #####


# write the name of the file being converted
echo "correcting reads from $fastq"

# create the paf file
dorado correct \
	--to-paf \
	--model-path /gpfs01/home/mbzlld/data/dorado_models/dorado_models/herro-v1 \
	$fastq > ${fastq%.*.*}_overlaps.paf



