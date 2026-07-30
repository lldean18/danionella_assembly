#!/bin/bash
# 29/7/26

# script to map phased assemblies to the reference

#SBATCH --job-name=map_pahsed
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=50g
#SBATCH --time=24:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out

# setup env
source $HOME/.bash_profile
conda activate minimap2
module load bcftools-uoneasy/1.19-GCC-13.2.0
mkdir -p /gpfs01/home/mbzlld/data/danionella/haplotype_comparison
cd /gpfs01/home/mbzlld/data/danionella/haplotype_comparison

reference=/share/deepseq/shenson/ds1664_Wilkinson/03_medaka/consensus.fasta

asms=(
/gpfs01/home/mbzlld/data/danionella/fish_A/hifiasm_asm1/ONTasm.bp.hap1.p_ctg.fasta
/gpfs01/home/mbzlld/data/danionella/fish_A/hifiasm_asm1/ONTasm.bp.hap2.p_ctg.fasta
/gpfs01/home/mbzlld/data/danionella/fish_B/hifiasm_3/fish_b.bp.hap1.p_ctg.fasta
/gpfs01/home/mbzlld/data/danionella/fish_B/hifiasm_3/fish_b.bp.hap2.p_ctg.fasta
/gpfs01/home/mbzlld/data/danionella/fish_c/hifiasm_2/fish_c.bp.hap1.p_ctg.fasta
/gpfs01/home/mbzlld/data/danionella/fish_c/hifiasm_2/fish_c.bp.hap2.p_ctg.fasta
)

# hashing out this block bc it ran successfully
##  for  asm in ${asms[@]}
##  do
##  
##  # Map the haplotype assemblies
##  minimap2 -t 16 -ax asm5 $reference $asm > $(basename ${asm%.*.*}).paf
##  
##  # call SNPs and indels
##  paftools.js call -L1000 -f $reference $(basename ${asm%.*.*}).paf > $(basename ${asm%.*.*}).vcf
##  
##  # compress and index
##  bgzip $(basename ${asm%.*.*}).vcf
##  tabix -p vcf $(basename ${asm%.*.*}).vcf.gz
##  
##  done 

# merge the resulting vcfs
bcftools merge \
    --threads 16 \
    ONTasm.bp.hap1.vcf.gz \
    ONTasm.bp.hap2.vcf.gz \
    fish_b.bp.hap1.vcf.gz \
    fish_b.bp.hap2.vcf.gz \
    fish_c.bp.hap1.vcf.gz \
    fish_c.bp.hap2.vcf.gz \
    -Oz \
    -o haplotypes.vcf.gz








