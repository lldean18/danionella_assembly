#!/bin/bash
# 22/4/26

# script to assess telomere presence within as well as at the ends of contigs

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=20g
#SBATCH --time=2:00:00
#SBATCH --job-name=tidk
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


# setup env
source $HOME/.bash_profile
#conda create --name tidk -c bioconda tidk
conda activate tidk
cd /gpfs01/home/mbzlld/data/danionella/zebrafish
mkdir -p tidk
genome=GCF_049306965.1_GRCz12tu_genomic.fna


# run the telomere sequence search with the known repeat for zebrafish
tidk search \
--string AACCCT \
--output ${genome%.*}_tidk_search_AACCCT \
--dir tidk \
$genome


# plot the telomeres
cd tidk
tidk plot \
--tsv ${genome%.*}_tidk_search_AACCCT_telomeric_repeat_windows.tsv

conda deactivate


