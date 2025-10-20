#!/bin/bash
# Laura Dean
# 20/10/25
# for running on Ada

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --mem=400g
#SBATCH --time=24:00:00
#SBATCH --job-name=herro_pt2
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out

# load your bash environment for using conda
source $HOME/.bash_profile


# set variables
raw_fastq=/gpfs01/home/mbzlld/data/OrgOne/sumatran_tiger/basecalls/all_simplex_simplex.fastq.gz


# minimap2 alignment and batching
# get the read id's using seqkit
#conda create --name seqkit
conda activate seqkit
#conda install -c conda-forge -c bioconda seqkit
seqkit seq -ni --threads 40 ${raw_fastq%.*.*}_preprocessed.fastq.gz > ${raw_fastq%.*.*}_preprocessed_readIDs
conda deactivate

conda activate herro
# scripts/create_batched_alignments.sh <output_from_reads_preprocessing> <read_ids> <num_of_threads> <directory_for_batches_of_alignments> 
/gpfs01/home/mbzlld/software_bin/herro/scripts/create_batched_alignments.sh \
${raw_fastq%.*.*}_preprocessed.fastq.gz ${raw_fastq%.*.*}_preprocessed_readIDs 40 ${raw_fastq%.*.*}_preprocessed_batches
conda deactivate
# it used the cores pretty efficiently, but max memory use was only ~90Gb so didn't need the hmemq. took 11hrs to run


