#!/bin/bash
# 24/7/26

# script to merge individual level vcf files output by clair3

#SBATCH --job-name=joint_genotype
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=96
#SBATCH --mem=361g
#SBATCH --time=5:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


# setup env
cd /gpfs01/home/mbzlld/data/danionella/popgen/variants
source $HOME/.bash_profile
#conda create --name glnexus bioconda::glnexus
conda activate glnexus


# merge and joint genotype the individual level vcfs
glnexus_cli \
  --config /gpfs01/home/mbzlld/github/danionella_assembly/popgen_analysis/clair3.yml \
  --threads 32 \
  --trim-uncalled-alleles \
  /gpfs01/home/mbzlld/data/danionella/popgen/variants/*/*.gvcf.gz > danionella_all_reads.bcf

conda deactivate

# index the bcf file
module load bcftools-uoneasy/1.19-GCC-13.2.0
bcftools index danionella_all_reads.bcf
module unload bcftools-uoneasy/1.19-GCC-13.2.0


