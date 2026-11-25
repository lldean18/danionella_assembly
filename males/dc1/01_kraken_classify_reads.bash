#!/bin/bash
# Laura Dean
# 25/11/26

# script to install and use kraken2 to classify reads or contigs

#SBATCH --job-name=kraken2
#SBATCH --partition=hmemq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=500g
#SBATCH --time=8:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


##  # download the standard database (did with tmux & srun)
##  cd /gpfs01/home/mbzlld/data/ctenella/kraken2/database
##  wget https://genome-idx.s3.amazonaws.com/kraken/k2_standard_20240112.tar.gz
##  tar -xvzf k2_standard_20240112.tar.gz
##  
##  # download the core_nt database (did with tmux & srun)
##  cd /gpfs01/home/mbzlld/data/databases/core_nt
##  wget https://genome-idx.s3.amazonaws.com/kraken/k2_core_nt_20251015.tar.gz
##  tar -xvzf k2_core_nt_20251015.tar.gz


# setup env
source $HOME/.bash_profile
#conda create --name kraken2 bioconda::kraken2
conda activate kraken2
cd /gpfs01/home/mbzlld/data/danionella/males/dc1
mkdir -p kraken2/classified
mkdir -p kraken2/unclassified
mkdir -p kraken2/bracken

# set variables
#DBNAME=/gpfs01/home/mbzlld/data/databases/core_nt/k2_core_nt_20251015
DBNAME=/share/deepseq/matt/Ctenella/kraken_core
reads=fastqs/?.fastq.gz

echo "running k2 to classify $reads"

# Classify the reads with the K2 wrapper
k2 classify \
--db $DBNAME \
--threads 16 \
--classified-out kraken2/classified/$(basename ${reads%.*.*})_#.fasta \
--unclassified-out kraken2/unclassified/$(basename ${reads%.*.*})_#.fasta \
--use-names \
--report kraken2/$(basename ${reads%.*.*})_k2_report \
--output kraken2/$(basename ${reads%.*.*})_k2_output \
--log kraken2/$(basename ${reads%.*.*})_k2_log \
$reads

echo "running braken to calculate abundances for $reads"

# calculate abundances for plotting with bracken
bracken \
-d $DBNAME \
-i kraken2/$(basename ${reads%.*.*})_k2_report \
-o kraken2/bracken/$(basename ${reads%.*.*}).bracken.out \
-w kraken2/bracken/$(basename ${reads%.*.*}).breport

# then use the .breport file in the shiny app here to make the plot: https://fbreitwieser.shinyapps.io/pavian/

conda deactivate

