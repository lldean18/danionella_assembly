#!/bin/bash
# Laura Dean
# file written for running on the UoN HPC Ada
# 14/10/25

#SBATCH --partition=ampereq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --gres=gpu:1
#SBATCH --mem=256g
#SBATCH --time=100:00:00
#SBATCH --job-name=danio_duplex_basecall
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out
#SBATCH --array=1-2


# set variables
wkdir=/gpfs01/home/mbzlld/data/danionella
config=/gpfs01/home/mbzlld/code_and_scripts/config_files/danionella_duplex_basecalling_array_config.txt


## make the config file (beforehand so its not overwritten with every array item)
#echo "1 /share/deepseq/matt/danionella/danionella_duplex
#2 /share/deepseq/matt/danionella/danionella_duplex2" > $config


# then make a directory for the basecalled files (only if it does not already exist)
mkdir -p $wkdir/basecalls
cd $wkdir/basecalls


# extract the directories from the config file
pod5_dir=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $config)


# load cuda module
module load cuda-12.2.2


# basecall the duplex reads
dorado duplex \
	sup@latest,5mCG_5hmCG \
	--recursive \
       	$pod5_dir > duplex_SUP_calls_${SLURM_ARRAY_TASK_ID}.bam



# unload module
module unload cuda-12.2.2

