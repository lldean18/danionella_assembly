#!/bin/bash
# Laura Dean
# 14/11/25
# for running on the UoN HPC Ada

#SBATCH --partition=ampereq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gres=gpu:2
#SBATCH --cpus-per-task=24
#SBATCH --mem=186g
#SBATCH --time=168:00:00
#SBATCH --job-name=step2_dorado_correct
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


# set variables
wkdir=/gpfs01/home/mbzlld/data/danionella/basecalls
cd $wkdir

# specify the file of reads to be corrected
#fastq=FishA_ALL_simplex.fastq.gz
fastq=FishB_ALL_simplex.fastq.gz



##### RUN THE ERROR CORRECTION FROM THE ALL VS ALL PAF FILE #####

# load cuda module
module load cuda-12.2.2

# write the name of the file being converted
echo "correcting reads from ${fastq%.*.*}_overlaps.paf"

# create the paf file
dorado correct \
	--model-path /gpfs01/home/mbzlld/data/dorado_models/dorado_models/herro-v1 \
	--from-paf \
	${fastq%.*.*}_overlaps.paf | gzip > ${fastq%.*.*}_corrected.fa.gz 


# unload cuda module
module unload cuda-12.2.2


