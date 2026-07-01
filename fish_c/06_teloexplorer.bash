#!/bin/bash
# 1/7/26

# script to assess telomere presence and draw telomere plots

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=15g
#SBATCH --time=1:00:00
#SBATCH --job-name=telo_explorer
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


# setup env
source $HOME/.bash_profile
conda activate quartet
mkdir /gpfs01/home/mbzlld/data/danionella/fish_c/teloexplorer
cd /gpfs01/home/mbzlld/data/danionella/fish_c/teloexplorer
#genome=/gpfs01/home/mbzlld/data/danionella/fish_c/hifiasm_1/fish_c.bp.p_ctg.fasta
#genome=/gpfs01/home/mbzlld/data/danionella/fish_c/hifiasm_1/fish_c.bp.hap2.p_ctg.fasta
#genome=/gpfs01/home/mbzlld/data/danionella/fish_c/hifiasm_1/fish_c.bp.p_ctg_100kb.fasta
genome=/gpfs01/home/mbzlld/data/danionella/fish_c/hifiasm_1/fish_c.bp.hap2.p_ctg_100kb.fasta

# unzip the input fasta file if it is gzipped and reassign its name
if [[ "$genome" == *.gz ]]; then
    gunzip -k $genome
    echo "Unzipped: $genome"
    genome=${genome%.*}
else
    echo "The input genome does not have a .gz extension so it won't be decompressed."
fi

# Check if the file contains multiline sequences and convert them to single line if it does
if awk '/^>/ {if (seqlen > 1) exit 0; seqlen=0} !/^>/ {seqlen++} END {if (seqlen > 1) exit 0; exit 1}' "$genome"; then
    echo "The FASTA file contains multiline sequences, converting to single line..."
    conda activate seqkit
    seqkit seq -w 0 $genome -o tmp.fasta && mv tmp.fasta $genome
    conda deactivate
    echo "Conversion to single line fasta format complete."
else
    echo "The FASTA file already contains single-line sequences. No conversion needed."
fi

# run the telomere explorer
python ~/software_bin/quarTeT/quartet.py TeloExplorer \
	-i $genome \
	-c animal \
	-p $(basename ${genome%.*})_quartet

conda deactivate


