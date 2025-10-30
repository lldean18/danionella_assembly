#!/bin/bash
# Laura Dean
# 29/10/25
# for running on the UoN HPC Ada

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=10g
#SBATCH --time=12:00:00
#SBATCH --job-name=bam2fastq
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out
#SBATCH --array=1-3

# set variables
wkdir=/gpfs01/home/mbzlld/data/danionella
config=/gpfs01/home/mbzlld/code_and_scripts/config_files/danionella_bam_convert_array_config.txt


###### GENERATE THE ARRAY CONFIG FILE #####
## generate list of file paths for the array config
#find $wkdir -type f -name "*.bam" > $config
## add array numbers to config file
#awk '{print NR,$0}' $config > ~/tmp && mv ~/tmp $config
## then I manually edited the config to remove the two original duplex bam files prior to tag extraction with samtools
## also removed the unfinished basecalls to progress with fish A for now
## now running for fish B only

# extract the bam file paths and names from the config file
bam=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $config)

# load modules
module load samtools-uoneasy/1.18-GCC-12.3.0

# write the name of the file being converted
echo "converting reads from $bam"

# check how many reads are in the bam file or files you want to convert
samtools flagstat $bam

# convert the bam files to fastq format
# -O output quality tags if they exist
# -t output RG, BC and QT tags to the FASTQ header line
# then pipe to gzip so that the file is properly compressed for flye to run on it later
samtools bam2fq \
-O \
-t \
--threads 23 \
$bam | gzip > ${bam%.*}.fastq.gz

# unload modules
module unload samtools-uoneasy/1.18-GCC-12.3.0



