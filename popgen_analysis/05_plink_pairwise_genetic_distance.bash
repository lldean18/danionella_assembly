#!/bin/bash
# 28/7/26

# script to calculate pairwise genetic distances with plink2





# setup env
conda activate tmux
tmux new -t plink
srun --partition defq --cpus-per-task 1 --mem 20g --time 06:00:00 --pty bash
module load plink-uoneasy/2.00a3.7-foss-2023a
mkdir -p /gpfs01/home/mbzlld/data/danionella/popgen/plink
cd /gpfs01/home/mbzlld/data/danionella/popgen/plink
vcf=/gpfs01/home/mbzlld/data/danionella/popgen/variants/danionella_all_reads_Q30_DP10_GQ20_SNP_mis0.9.vcf.gz

# calculate genetic distances
plink \
  --vcf $vcf \
  --double-id \
  --allow-extra-chr \
  --distance square \
  --out distances_$(basename ${vcf%.*.*})

# calculate identity by state (IBS) and identity by distance (IBD)
plink \
  --vcf $vcf \
  --double-id \
  --allow-extra-chr \
  --genome \
  --out relatedness_$(basename ${vcf%.*.*})

# calcualte IBS matrix
plink \
  --vcf $vcf \
  --double-id \
  --allow-extra-chr \
  --distance ibs \
  --out distances_ibs_$(basename ${vcf%.*.*})

plink \
  --vcf $vcf \
  --double-id \
  --allow-extra-chr \
  --distance ibs square \
  --out ibs_$(basename ${vcf%.*.*})

# search for long runs of homozygosity (that indicate inbreeding)
plink \
--vcf $vcf \
  --double-id \
  --allow-extra-chr \
  --homozyg \
  --out homozyg_$(basename ${vcf%.*.*})



