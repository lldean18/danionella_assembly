#!/bin/bash
# 29/7/26

# script to plot tree

#SBATCH --job-name=iqtree
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=15g
#SBATCH --time=6:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


module load vcftools-uoneasy/0.1.16-GCC-12.3.0
source $HOME/.bash_profile
conda activate iqtree
mkdir -p /gpfs01/home/mbzlld/data/danionella/popgen/iqtree
cd /gpfs01/home/mbzlld/data/danionella/popgen/iqtree
vcf=/gpfs01/home/mbzlld/data/danionella/popgen/variants/danionella_all_reads_Q30_DP10_GQ20_SNP_mis0.9.vcf.gz

# convert the vcf to phylip format
python /gpfs01/home/mbzlld/software_bin/vcf2phylip.py -i $vcf

# generate the tree
iqtree \
    -s $(basename ${vcf%.*.*}).min3.phy \
    -m MFP+ASC \
    -bb 1000 \
    -T AUTO



