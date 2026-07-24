#!/bin/bash
# 24/7/26

# script to filter merged variants

#SBATCH --job-name=filter_variants
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=15g
#SBATCH --time=24:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out

# setup env
source $HOME/.bash_profile
module load bcftools-uoneasy/1.19-GCC-13.2.0
module load vcftools-uoneasy/0.1.16-GCC-12.3.0
cd /gpfs01/home/mbzlld/data/danionella/popgen/variants
INPUT=danionella_all_reads

# change half calls to missing
bcftools +setGT ${INPUT}.bcf -Ob -o ${INPUT}_nhc.bcf -- -t ./x -n .

# filter for quality and depth
bcftools filter -e 'QUAL<30 || DP<10' ${INPUT}_nhc.bcf -Oz --threads 16 -o ${INPUT}_Q30_DP10.vcf.gz

# set all genotype calls with a quality less than 20 to missing
bcftools +setGT ${INPUT}_Q30_DP10.vcf.gz -- -t q -n . -i 'FMT/GQ<20' | bcftools view -Oz -o ${INPUT}_Q30_DP10_GQ20.vcf.gz

# filter to retain only biallelic snps
bcftools view -v snps -m2 -M2 ${INPUT}_Q30_DP10_GQ20.vcf.gz -Oz --threads 16 -o ${INPUT}_Q30_DP10_GQ20_SNP.vcf.gz

# filter for missingness
vcftools --gzvcf ${INPUT}_Q30_DP10_GQ20_SNP.vcf.gz --max-missing 0.9 --recode --stdout |
bgzip > ${INPUT}_Q30_DP10_GQ20_SNP_mis0.9.vcf.gz
vcftools --gzvcf ${INPUT}_Q30_DP10_GQ20_SNP.vcf.gz --max-missing 0.8 --recode --stdout |
bgzip > ${INPUT}_Q30_DP10_GQ20_SNP_mis0.8.vcf.gz
vcftools --gzvcf ${INPUT}_Q30_DP10_GQ20_SNP.vcf.gz --max-missing 0.6 --recode --stdout |
bgzip > ${INPUT}_Q30_DP10_GQ20_SNP_mis0.6.vcf.gz






# cleanup env
module unload bcftools-uoneasy/1.19-GCC-13.2.0
module unload vcftools-uoneasy/0.1.16-GCC-12.3.0


