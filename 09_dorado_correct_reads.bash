#!/bin/bash
# Laura Dean
# 30/10/25
# for running on the UoN HPC Ada

#SBATCH --partition=ampereq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --gres=gpu:1
#SBATCH --mem=256g
#SBATCH --time=100:00:00
#SBATCH --job-name=dorado_correct
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



##### ERROR CORRECT THE READS #####

# load cuda module
module load cuda-12.2.2

# write the name of the file being converted
echo "correcting reads from $fastq"

dorado correct \
	--device cuda:all \
	--model-path /gpfs01/home/mbzlld/data/dorado_models/dorado_models \
	$fastq | gzip > ${fastq%.*.*}_corrected.fastq.gz


# unload modules
module unload cuda-12.2.2



