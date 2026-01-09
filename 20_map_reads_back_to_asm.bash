#!/bin/bash
# Laura Dean
# 9/1/26
# script written for running on the UoN HPC Ada

# script to map raw reads back to our assembly so we can see what the reads
# look like in places where bits of zebrafish chromosome appear to be joined
# in the danionella assembly

#SBATCH --job-name=map_reads_to_ref
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=34
#SBATCH --mem=50g
#SBATCH --time=6:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


# activate software
source $HOME/.bash_profile
conda activate minimap2

reads=/gpfs01/home/mbzlld/data/danionella/basecalls/FishB_ALL_simplex.fastq.gz
assembly=/gpfs01/home/mbzlld/data/danionella/fish_B/hifiasm_asm1/ONTasm.bp.p_ctg_100kb_synt.fasta

# map the raw reads back to our assembly
minimap2 \
	-a \
	-x map-ont \
	--split-prefix temp_prefix \
	-t 32 \
	-o ${assembly%.*}_mapped_raw_reads.sam \
	$assembly $reads


# sort and index the sam file and convert to bam format
samtools sort \
	--threads 32 \
	--write-index \
	--output-fmt BAM \
	-o ${assembly%.*}_mapped_raw_reads.bam ${assembly%.*}_mapped_raw_reads.sam


# remove the intermediate sam file
rm ${assembly%.*}_mapped_raw_reads.sam

conda deactivate

