#!/bin/bash
# 23/7/26

# script to filter bams to remove low quality mappings, secondary alignments and unmapped reads

#SBATCH --job-name=FilterMappedReads
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=10g
#SBATCH --time=2:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out
#SBATCH --array=1-3


# setup env
source $HOME/.bash_profile
conda activate samtools1.22
cd /gpfs01/home/mbzlld/data/danionella/popgen/bams
mkdir -p mapping_info

# setup config
CONFIG=~/code_and_scripts/config_files/ctenella_the_thirteen_config.txt
ind=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $CONFIG)

echo "slurm array = $SLURM_ARRAY_TASK_ID
filtering mapped reads for sample = $ind
"



# NOTE the quality cut off 30 is reasonably high could try with 20 also
# filter bams to remove low quality mappings and secondary alignments and unmapped reads
samtools view \
--threads 16 \
-b \
-q 30 \
-F 260 \
${ind}.bam > ${ind}_filtered.bam
# index the filtered bams
samtools index --threads 16 ${ind}_filtered.bam
#-F 0x904 \ # to remove secondary and supplementary alignments and unmapped reads


# Generate info about how well the reads mapped
echo "the raw reads were mapped with the following success:" > mapping_info/${ind}_mapping_info.txt
samtools flagstat --threads 16 ${ind}.bam >> mapping_info/${ind}_mapping_info.txt
echo "the filtered reads were mapped with the following success:" >> mapping_info/${ind}_mapping_info.txt
samtools flagstat --threads 16 ${ind}_filtered.bam >> mapping_info/${ind}_mapping_info.txt


# cleanup env
conda deactivate

