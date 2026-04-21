#!/bin/bash
# Laura Dean
# 2/4/26

# script to assess telomere presence within as well as at the ends of contigs

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=20g
#SBATCH --time=10:00:00
#SBATCH --job-name=tidk
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


# create and load conda env
source $HOME/.bash_profile
#conda create --name tidk -c bioconda tidk
conda activate tidk

cd /share/deepseq/shenson/ds1664_Wilkinson/03_medaka
genome=consensus.fasta

mkdir -p /gpfs01/home/mbzlld/data/danionella/fish_B/hifiasm_asm1/tidk

###  # run the telomere explorer
###  tidk explore \
###  --distance 0.5 \
###  --minimum 4 \
###  --maximum 12 \
###  $genome > tidk/${genome%.*}_tidk.tsv

###  ## build the database of telomeric sequences
###  tidk build

###  tidk find \
###  --clade Cypriniformes \
###  --output ${genome%.*}_tidk \
###  --dir tidk \
###  $genome

# first run searched for AACCCT

# running again for AAAAGAACT
tidk search \
--string AAAAGAACT \
--output ${genome%.*}_tidk_search_AAAAGAACT \
--dir /gpfs01/home/mbzlld/data/danionella/fish_B/hifiasm_asm1/tidk \
$genome

cd /gpfs01/home/mbzlld/data/danionella/fish_B/hifiasm_asm1/tidk

tidk plot \
--tsv ${genome%.*}_tidk_search_AAAAGAACT_telomeric_repeat_windows.tsv

conda deactivate


