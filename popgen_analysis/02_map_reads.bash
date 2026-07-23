#!/bin/bash
# 23/7/26

# script to map ONT reads to a reference genome

#SBATCH --job-name=map_reads
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=50g
#SBATCH --time=60:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out
#SBATCH --array=1-3

# setup env
source $HOME/.bash_profile
conda activate minimap2
mkdir -p /gpfs01/home/mbzlld/data/danionella/popgen/bams
cd /gpfs01/home/mbzlld/data/danionella/popgen/bams

# setup config
CONFIG=~/code_and_scripts/config_files/danionella_reads_config.txt
reads=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $CONFIG)
ref=/share/deepseq/shenson/ds1664_Wilkinson/03_medaka/consensus.fasta

echo "slurm array = $SLURM_ARRAY_TASK_ID
mapping the reads: $reads
to the reference: $ref
"


# map the reads to the reference
minimap2 \
-y \
-ax map-ont \
-t 24 \
$ref $reads |
samtools sort --threads 24 -o $(basename ${reads%.*.*}).bam
samtools index --threads 24 $(basename ${reads%.*.*}).bam


# cleanup env
conda deactivate

