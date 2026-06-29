#!/bin/bash
# 29/6/26

# script to run busco on a genome assembly

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=80g
#SBATCH --time=8:00:00
#SBATCH --job-name=busco
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out

# setup env
mkdir -p /gpfs01/home/mbzlld/data/danionella/fish_c/busco
cd /gpfs01/home/mbzlld/data/danionella/fish_c/busco
source $HOME/.bash_profile
#conda create -n busco6.0.0 -c conda-forge -c bioconda busco=6.0.0 sepp=4.5.5
conda activate busco6.0.0

assembly=../dorado_polish/fish_c.bp.p_ctg_polished.fasta
lineage_dataset=actinopterygii_odb12


# run busco
# --in : input assembly in fasta format
# --lineage_dataset nearest class in the busco database for your species
# --mode specify you are working on a genome assembly
# --out name the output files (busco will create a dfolder with this name)
# --out_path specify the path to your desired output directory
# --cpu specify number of cores to use
busco \
--in $assembly \
--lineage_dataset $lineage_dataset \
--mode genome \
--out $(basename ${assembly%.*})_$lineage_dataset \
--out_path ./ \
--cpu 16 \
-f \
--download_path ~/busco_downloads

# busco --plot $(basename ${assembly%.*})_$lineage_dataset

# deactivate conda
conda deactivate


###  conda activate blobtoolkit
###  
###  blobtools create --fasta /gpfs01/home/mbzlld/data/ctenella/ctenella_chagius_asm.fasta /gpfs01/home/mbzlld/data/ctenella/blobtoolkit
###  blobtools add --busco /gpfs01/home/mbzlld/data/ctenella/busco/ctenella_chagius_asm_metazoa_odb12/run_metazoa_odb12/full_table.tsv /gpfs01/home/mbzlld/data/ctenella/blobtoolkit
###  blobtools view --view snail --plot --out /gpfs01/home/mbzlld/data/ctenella/blobtoolkit /gpfs01/home/mbzlld/data/ctenella/blobtoolkit
###  
###  conda deactivate
