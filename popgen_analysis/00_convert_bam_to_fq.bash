#!/bin/bash
# Laura Dean
# 8/10/26

# convert bam back to fastq so it can be remapped to new reference genome

#SBATCH --job-name=map_reads_to_new_ref
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=34
#SBATCH --mem=80g
#SBATCH --time=48:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out



source $HOME/.bash_profile
conda activate samtools1.24
#module load bwa-uoneasy/0.7.17-GCCcore-12.3.0

cd /gpfs01/home/mbzlld/data/danionella/popgen/downsampling
assembly=/gpfs01/home/mbzlld/data/danionella/fish_c/fishC_polished_nuclear_curated_no_ptg000061l.fa


# convert the reads back to fastq format
samtools fastq --threads 32 FishA_ALL_simplex_TO_consensus_flt_downsampled.bam | gzip > FishA_ALL_simplex_downsampled.fastq.gz
samtools fastq --threads 32 FishB_ALL_simplex_TO_consensus_flt_downsampled.bam | gzip > FishB_ALL_simplex_downsampled.fastq.gz
samtools fastq --threads 32 SUP_fish_c_TO_consensus_flt_downsampled.bam | gzip > SUP_fish_c_downsampled.fastq.gz

conda deactivate

# remap them to the new reference
conda activate minimap2

reads=( FishA_ALL_simplex_downsampled.fastq.gz FishB_ALL_simplex_downsampled.fastq.gz SUP_fish_c_downsampled.fastq.gz  )

for file in "${reads[@]}"; do
# map the raw reads back to our assembly
minimap2 \
	-a \
	-x map-ont \
	--split-prefix temp_prefix \
	-t 32 \
	-o ${file%.*.*}_mapped_to_curated.sam \
	$assembly $file


# sort the sam file and convert to bam format
samtools sort \
	--threads 32 \
	--output-fmt BAM \
	-o ${file%.*.*}_mapped_to_curated.bam ${file%.*.*}_mapped_to_curated.sam

# index the bam
samtools index ${file%.*.*}_mapped_to_curated.bam

# remove the intermediate sam file
rm ${file%.*.*}_mapped_to_curated.sam

done

conda deactivate




