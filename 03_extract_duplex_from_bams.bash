#!/bin/bash
# Laura Dean
# 15/10/25
# script written for running on the UoN HPC Ada

#SBATCH --job-name=extract_duplex_reads
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=50g
#SBATCH --time=12:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


# create list of files to loop over
bams=( /gpfs01/home/mbzlld/data/danionella/basecalls/duplex_SUP_calls_1.bam /gpfs01/home/mbzlld/data/danionella/basecalls/duplex_SUP_calls_2.bam )



# load modules
module load samtools-uoneasy/1.18-GCC-12.3.0


for bam in ${bams[@]}

do

# extract duplex reads from bam files
samtools view \
--tag dx:1 \
--threads 48 \
-O bam \
--write-index \
--output ${bam%.*}_duplex.bam \
$bam

## extract simplex reads from bam files
#samtools view \
#--tag dx:0 \
#--tag dx:-1 \
#--threads 48 \
#-O bam \
#--write-index \
#--output ${bam%.*}_simplex.bam \
#$bam

done



