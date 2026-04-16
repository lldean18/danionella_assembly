#!/bin/bash
# 15/4/26

# script to have a look at synteny between the two danionella assemblies

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=20g
#SBATCH --time=2:00:00
#SBATCH --job-name=danionella_synteny
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out

# setup env
source $HOME/.bash_profile
#conda create --name ntsynt -c bioconda -c conda-forge ntsynt
conda activate ntsynt
mkdir -p /gpfs01/home/mbzlld/data/danionella/ntsynt
cd /gpfs01/home/mbzlld/data/danionella/ntsynt

# estimate divergence between sequences


###  # calculate synteny between assemblies
###  ntSynt \
###    --divergence 0.5 \
###    /share/deepseq/shenson/ds1664_Wilkinson/03_medaka/consensus.fasta \
###    /gpfs01/home/mbzlld/data/danionella/fish_A/hifiasm_asm1/ONTasm.bp.p_ctg.fasta

# plot synteny between assemblies
ntsynt_viz.py \
--normalize \
--blocks ntSynt.k24.w1000.synteny_blocks.tsv \
--fais consensus.fasta.fai ONTasm.bp.p_ctg.fasta.fai \
--prefix ribbon_plot

# unload software
conda deactivate
