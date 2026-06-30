#!/bin/bash
# 22/6/26

# script to SUP basecall danionella fish c runs

#SBATCH --partition=ampereq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --gres=gpu:A100-full:1
#SBATCH --mem=256g
#SBATCH --time=160:00:00
#SBATCH --job-name=danio_basecall
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


# setup env
module load cuda-12.2.2
mkdir -p ~/data/danionella/fish_c/basecalls
cd ~/data/danionella/fish_c/basecalls


# SUP basecall the reads
dorado basecaller \
	sup@latest \
        --modified-bases 5mCG_5hmCG \
	--recursive \
	--models-directory /gpfs01/home/mbzlld/data/dorado_models/dorado_models \
       	/share/deepseq/danionella/ds1749_1_P1 > SUP_fish_c.bam

#	--reference /share/deepseq/shenson/ds1664_Wilkinson/03_medaka/consensus.fasta \

# unload module
module unload cuda-12.2.2

