#!/bin/bash
# Laura Dean
# 1/7/26

# script to filter the assembly to remove contigs

#SBATCH --job-name=filter_asm
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=10g
#SBATCH --time=2:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


# setup env
source $HOME/.bash_profile
conda activate seqkit
#cd /gpfs01/home/mbzlld/data/danionella/fish_c/hifiasm_1
cd /gpfs01/home/mbzlld/data/danionella/fish_c/hifiasm_2

asm=fish_c.bp.p_ctg.fasta
#asm=fish_c.bp.hap2.p_ctg.fasta


############ FILTER CONTIG LENGTH
seqtk seq \
-L 100000 $asm > ${asm%.*}_100kb.fasta


conda deactivate


