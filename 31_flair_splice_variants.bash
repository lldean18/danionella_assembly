#!/bin/bash
# Laura Dean
# 28/4/26

# Script to use FLAIR to detect splice variants from RNAseq data
# input is raw fastq files, plus a reference genome and annotation file

#SBATCH --job-name=flair_splice_variant_search
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=50g
#SBATCH --time=10:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out
#SBATCH --mem=200g



# setup env
source $HOME/.bash_profile
#conda create --name flair bioconda::flair -y
conda activate flair
cd /gpfs01/home/mbzlld/data/danionella/flair

reference=/share/deepseq/shenson/ds1664_Wilkinson/03_medaka/consensus.fasta
annotation=../braker.gtf
fastqs=../long_read_RNAseq/barcode01/*.fastq.gz
manifest=manifest.tsv

### # make the manifest file
### \ls /gpfs01/home/mbzlld/data/danionella/long_read_RNAseq/barcode01/*.fastq.gz > $manifest
### sed -i 's/^/fish_B\tadult\tflowcell1\t/' $manifest

# # flair align - aligns reads to the genome using minimap2, and converts the SAM output to BED12
# flair align \
# 	--genome $reference \
# 	--threads 8 \
# 	--reads $fastqs
# 
# # flair correct - corrects misaligned splice sites using genome annotations
# flair correct \
# 	--query flair.aligned.bed \
# 	--gtf $annotation \
# 	--genome $reference \
# 	--threads 8

# # flair collapse - Defines high-confidence isoforms from corrected reads
# flair collapse \
# 	--genome $reference \
# 	--gtf $annotation \
# 	--query flair_all_corrected.bed \
# 	--reads $fastqs \
# 	--generate_map \
# 	--check_splice \
# 	--stringent \
# 	--annotation_reliant generate

# flair quantify - Identifes the best isoform assignment 
flair quantify \
	--isoforms flair.collapse.isoforms.fa \
	--reads_manifest $manifest \
	--threads 40



# deactivate software
conda deactivate
