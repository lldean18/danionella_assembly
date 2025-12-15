#!/bin/bash
# Laura Dean
# 15/12/25
# script written for running on the UoN HPC Ada

# script to scaffold a genome assembly based on homology to another assembly

#SBATCH --job-name=ragtag_scaffold
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=30g
#SBATCH --time=12:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out

# set variables
reference=/gpfs01/home/mbzlld/data/danionella/GCF_049306965.1_GRCz12tu_genomic.fna
assembly=/gpfs01/home/mbzlld/data/danionella/fish_B/hifiasm_asm1/ONTasm.bp.p_ctg.fasta

# scaffold assembly with ragtag
source $HOME/.bash_profile
conda activate ragtag
ragtag.py scaffold -t 16 -o ${assembly%.*}_ragtag $reference $assembly
conda deactivate


# get rid of the ragtag suffixes
sed -i 's/_RagTag//' ${assembly%.*}_ragtag/ragtag.scaffold.fasta

# set the file containing chromosome names to keep
keep=/gpfs01/home/mbzlld/data/danionella/zebrafish_chrs.txt

# rename scaffolds and remove unplaced contigs
conda activate seqtk
seqtk subseq ${assembly%.*}_ragtag/ragtag.scaffold.fasta $keep > ${assembly%.*}_ragtag/ragtag.scaffolds_only.fasta
conda deactivate



