#!/bin/bash
# Laura Dean
# 17/10/25
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
#SBATCH --array=1-4


# set variables
wkdir=/gpfs01/home/mbzlld/data/danionella/basecalls
cd $wkdir
config=/gpfs01/home/mbzlld/code_and_scripts/config_files/danionella_dorado_read_correct_array_config.txt

##### GENERATE THE ARRAY CONFIG FILE #####
## generate list of file paths for the array config
#find $wkdir -type f -name "*.fastq.gz" > $config
## for now I manually removed the files I didn't want to run from $config
## add array numbers to config file
#awk '{print NR,$0}' $config > ~/tmp && mv ~/tmp $config

# extract the fastq file paths and names from the config file
fastq=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $config)








##### ERROR CORRECT THE READS #####

# load cuda module
module load cuda-12.2.2

# write the name of the file being converted
echo "correcting reads from $fastq"

dorado correct \
	--device cuda:all \
	$fastq | gzip > ${fastq%.*.*}_corrected.fastq.gz


# unload modules
module unload cuda-12.2.2



