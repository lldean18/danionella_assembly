#!/bin/bash
# Laura Dean
# file written for running on the UoN HPC Ada
# 22/10/25

#SBATCH --partition=ampereq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --gres=gpu:1
#SBATCH --mem=256g
#SBATCH --time=100:00:00
#SBATCH --job-name=danio_basecall
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out
#SBATCH --array=1-3


# set variables
wkdir=/gpfs01/home/mbzlld/data/danionella
config=/gpfs01/home/mbzlld/code_and_scripts/config_files/danionella_simplex_basecalling_array_config.txt

## make a list of all the pod5 files
#find /share/deepseq/matt/danionella -type f -name "*.pod5*" > ~/data/danionella/pod5_list.txt
## make a list from this with only the simplex files
#sed '/duplex/d' ~/data/danionella/pod5_list.txt > ~/data/danionella/pod5_simplex_list.txt

## make the config file (beforehand so its not overwritten with every array item)
## make this by using the list of all simplex files above to see which dirs the pod5's are in
#echo "1 /share/deepseq/matt/danionella/ic_208 ic_208
#2 /share/deepseq/matt/danionella/ic_206 ic_206" > $config


## make the config file with the new downloaded pod5 files
#echo "1 /gpfs01/home/mbzlld/data/danionella/pod5s/fish_A/ic_207 ic_207
#2 /gpfs01/home/mbzlld/data/danionella/pod5s/fish_A/ic_208 ic_208
#3 /gpfs01/home/mbzlld/data/danionella/pod5s/fish_B/ic_206 ic_206" > $config


# then make a directory for the basecalled files (only if it does not already exist)
mkdir -p $wkdir/basecalls
cd $wkdir/basecalls



# extract the directories and the run names from the config file
pod5_dir=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $config)
run=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $3}' $config)


# load cuda module
module load cuda-12.2.2


# basecall the simplex reads
dorado basecaller \
	sup@latest,5mCG_5hmCG \
	--recursive \
       	$pod5_dir > simplex_SUP_calls_$run.bam



# unload module
module unload cuda-12.2.2

