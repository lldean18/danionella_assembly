#!/bin/bash
# 17/4/26

# script to merge dorado bam files into one per fish

#SBATCH --job-name=merge_bams
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=20g
#SBATCH --time=3:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


# setup env
source $HOME/.bash_profile
conda activate samtools1.22
cd /gpfs01/home/mbzlld/data/danionella/basecalls_methylation_CpG


##  # merge dorado bams for fish B simplex
##  samtools merge \
##    --threads 16 \
##    --reference /share/deepseq/shenson/ds1664_Wilkinson/03_medaka/consensus.fasta \
##    -c -p -u - \
##    simplex_SUP_calls_ic_206.bam duplex_as_simplex_SUP_calls_duplex.bam duplex_as_simplex_SUP_calls_duplex2.bam |
##  samtools sort --threads 16 -o fish_B/fish_B_simplex_SUP.bam -
##  samtools index --threads 16 fish_B/fish_B_simplex_SUP.bam


##  # merge dorado bams for fish A simplex
##  samtools merge \
##    --threads 16 \
##    --reference /share/deepseq/shenson/ds1664_Wilkinson/03_medaka/consensus.fasta \
##    -c -p -u - \
##    simplex_SUP_calls_ic_207.bam simplex_SUP_calls_ic_208.bam |
##  samtools sort --threads 16 -o fish_A/fish_A_SUP.bam -
##  samtools index --threads 16 fish_A/fish_A_SUP.bam


# merge dorado duplex read bams for fish B
samtools merge \
  --threads 16 \
  --reference /share/deepseq/shenson/ds1664_Wilkinson/03_medaka/consensus.fasta \
  -c -p -u - \
  extracted_dx1_duplex.bam extracted_dx1_duplex2.bam |
samtools sort --threads 16 -o fish_B/fish_B_dup_dx1_SUP.bam -
samtools index --threads 16 fish_B/fish_B_dup_dx1_SUP.bam



# cleanup env
conda deactivate



