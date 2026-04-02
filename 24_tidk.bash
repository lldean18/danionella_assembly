#!/bin/bash
# Laura Dean
# 2/4/26

# script to assess telomere presence within as well as at the ends of contigs

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=20g
#SBATCH --time=10:00:00
#SBATCH --job-name=tidk
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


# create and load conda env
source $HOME/.bash_profile
#conda create --name tidk -c bioconda tidk
conda activate tidk

cd /gpfs01/home/mbzlld/data/danionella/fish_B/hifiasm_asm1
genome=ONTasm.bp.p_ctg_100kb.fasta


# run the telomere explorer
tidk explore \
--distance 0.5 \
--minimum 4 \
--maximum 12 \
$genome > ${genome%.*}_tidk.tsv

conda deactivate


