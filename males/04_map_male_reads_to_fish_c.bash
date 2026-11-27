#!/bin/bash
# Laura Dean
# 27/11/26

# script to map male danionella reads (all and chordata only) to the female fish c assembly

#SBATCH --job-name=map_reads_to_ref
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=34
#SBATCH --mem=50g
#SBATCH --time=24:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out

# setup env
source $HOME/.bash_profile
conda activate minimap2

#OUTDIR=/gpfs01/home/mbzlld/data/danionella/males/dc1/bams
OUTDIR=/gpfs01/home/mbzlld/data/danionella/males/dc2/bams
cd $OUTDIR

#READS=/share/deepseq/danionella/maleFish/ds1777_1.pass.fastq
#READS=/share/deepseq/danionella/maleFish/ds1777_1.pass_chordata.fastq
#READS=/share/deepseq/danionella/maleFish/ds1777_2.pass.fastq
READS=/share/deepseq/danionella/maleFish/ds1777_2.pass_chordata.fastq.gz

ASSEMBLY=/gpfs01/home/mbzlld/data/danionella/fish_c/fishC_polished_nuclear_curated_no_ptg000061l.fa

# map reads to assembly
minimap2 \
    -ax map-ont \
    -t 32 \
    $ASSEMBLY $READS > $(basename ${READS%.*})_map_fish_c.sam 

# sort the sam file and convert to bam format
samtools sort \
    --threads 32 \
    --output-fmt BAM \
    -o $(basename ${READS%.*})_map_fish_c.bam $(basename ${READS%.*})_map_fish_c.sam

# index the bam
samtools index $(basename ${READS%.*})_map_fish_c.bam

# remove sam file
#rm $(basename ${READS%.*})_map_fish_c.sam


