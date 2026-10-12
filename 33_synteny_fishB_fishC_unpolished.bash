#!/bin/bash
# 12/10/26

# script to have a look at synteny between two assemblies

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
mkdir -p /gpfs01/home/mbzlld/data/danionella/ntsynt_fishA_fishB
cd /gpfs01/home/mbzlld/data/danionella/ntsynt_fishA_fishB

# estimate divergence between sequences


# calculate synteny between assemblies
ntSynt \
  --divergence 0.5 \
  /gpfs01/home/mbzlld/data/danionella/fish_c/hifiasm_2/fish_c.bp.p_ctg.fasta \
  /gpfs01/home/mbzlld/data/danionella/fish_B/hifiasm_3/fish_b.bp.p_ctg.fasta
  

# plot synteny between assemblies
ntsynt_viz.py \
--normalize \
--blocks ntSynt.k24.w1000.synteny_blocks.tsv \
--fais fish_c.bp.p_ctg.fasta.fai fish_b.bp.p_ctg.fasta.fai \
--prefix ribbon_plot_fishB_fishC_unpolished \
--target-genome fish_c.bp.p_ctg.fasta \
--no-arrow \
--ribbon_adjust 0.15 \
--length 1000 \
--seq_length 1000



#--name_conversion name_conversion.tsv \

# unload software
conda deactivate
