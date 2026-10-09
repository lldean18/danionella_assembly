#!/bin/bash
# Laura Dean
# 8/10/26

# script to map short read data for fish D to the curated fish C reference

#SBATCH --job-name=MapAndCall_fishD
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=60g
#SBATCH --time=48:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out



# setup env
source $HOME/.bash_profile
conda activate samtools1.24
module load bwa-uoneasy/0.7.17-GCCcore-12.3.0
module load picard-uoneasy/3.0.0-Java-17
module load bcftools-uoneasy/1.19-GCC-13.2.0

cd /gpfs01/home/mbzlld/data/danionella/fish_d
ref=/gpfs01/home/mbzlld/data/danionella/fish_c/fishC_polished_nuclear_curated_no_ptg000061l.fa
SAMPLE=fish_d

# make a dir for the mapped bams and one for info
mkdir -p bams
mkdir -p bams/bam_info
mkdir -p variants

#####################################
# MAP READS TO THE REFERENCE GENOME #
#####################################

bwa index $ref

###### Align the reads to the reference genome using bwa mem ######
# BWA MEM command explanation:
# -M = Mark shorter split hits as secondary (for Picard compatibility)
# -R = Specify info to go in read group header line
bwa mem \
-t 16 \
-M \
-R "@RG\tID:"$SAMPLE"\tSM:"$SAMPLE"\tPL:ILLUMINA\tLB:"$SAMPLE"\tPU:"$SAMPLE"" \
$ref \
fastqs/trimmed_fastqs/ds1756_2_S3_L001_and_L002_R1.fastq.gz \
fastqs/trimmed_fastqs/ds1756_2_S3_L001_and_L002_R2.fastq.gz |
# add mate score tags then
# sort and index the bam files
samtools fixmate --threads 16 -m -O BAM - - |
samtools sort --threads 16 -o bams/${SAMPLE}_tmp.bam
samtools index bams/${SAMPLE}_tmp.bam

# remove pcr duplicaltes with picard
java -Xmx1g -jar $EBROOTPICARD/picard.jar \
MarkDuplicates \
REMOVE_DUPLICATES=true \
ASSUME_SORTED=true \
VALIDATION_STRINGENCY=SILENT \
MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 \
INPUT=bams/${SAMPLE}_tmp.bam \
OUTPUT=bams/${SAMPLE}.bam \
METRICS_FILE=bam_info/${SAMPLE}.rmd.bam.metrics

# index the final bam file
samtools index bams/${SAMPLE}.bam

# remove the temp file with duplicates not removed
rm bams/${SAMPLE}_tmp.bam*



# Generate info about how well the reads mapped
echo "the reads mapped with the following success:" > bams/bam_info/${SAMPLE}_mapping_info.txt
samtools flagstat --threads 16 bams/$SAMPLE.bam >> bams/bam_info/${SAMPLE}_mapping_info.txt

#######################################
# CALL VARIANTS AGAINST THE REFERENCE #
#######################################

samtools faidx $ref

bcftools mpileup --threads 16 -f $ref -Ou bams/${SAMPLE}.bam |
bcftools call -mv --threads 16 -Oz -o variants/curated_vs_fish_d_reads.vcf.gz
bcftools filter --threads 16 -i 'QUAL>=30 && DP>=20' variants/curated_vs_fish_d_reads.vcf.gz \
-Oz -o variants/curated_vs_fish_d_reads_flt.vcf.gz
bcftools index --threads 16 -t variants/curated_vs_fish_d_reads_flt.vcf.gz


# deactivate software
conda deactivate
module unload bwa-uoneasy/0.7.17-GCCcore-12.3.0
module unload picard-uoneasy/3.0.0-Java-17
module unload bcftools-uoneasy/1.19-GCC-13.2.0


