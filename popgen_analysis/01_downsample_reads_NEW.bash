#!/bin/bash
# 22/7/26

# script to downsample reads to be processed together for popgen

#SBATCH --job-name=downsample_reads
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=50g
#SBATCH --time=40:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out

# setup env
source $HOME/.bash_profile
conda activate minimap2
mkdir -p /gpfs01/home/mbzlld/data/danionella/popgen/downsampling
cd /gpfs01/home/mbzlld/data/danionella/popgen/downsampling

reference=/gpfs01/home/mbzlld/data/danionella/fish_c/fishC_polished_nuclear_curated_no_ptg000061l.fa

fishes=( FishA_ALL_simplex FishB_ALL_simplex SUP_fish_c )

##############################

for fish in ${fishes[@]}
do

echo "running for fish $fish
against the reference $reference
"
# filter to retain only good mappings
samtools view \
-b \
-q 30 \
-F 260 \
${fish}_downsampled_mapped_to_curated.bam |
samtools sort --threads 16 -o ${fish}_downsampled_mapped_to_curated_flt.bam
samtools index --threads 16 ${fish}_downsampled_mapped_to_curated_flt.bam

# compute the current coverage of the reference bam
echo "the initial depth of coverage of the well mapped reads for fish $fish is:"
samtools depth \
${fish}_downsampled_mapped_to_curated_flt.bam |
awk '{sum+=$3} END {print sum/NR}'


# randomly subsample to the desired coverage
rasusa aln \
--coverage 15 \
${fish}_downsampled_mapped_to_curated_flt.bam |
samtools sort --threads 16 -o ${fish}_downsampled_mapped_to_curated_flt_downsampled.bam
samtools index --threads 16 ${fish}_downsampled_mapped_to_curated_flt_downsampled.bam

# check final depth
echo "the final depth of the downsampled bam file is:"
samtools depth \
${fish}_downsampled_mapped_to_curated_flt_downsampled.bam |
awk '{sum+=$3} END {print sum/NR}'

done

# cleanup env
conda deactivate


