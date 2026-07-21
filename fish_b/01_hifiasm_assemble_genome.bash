#!/bin/bash
# 21/7/26

# script to assemble genome with hifiasm

#SBATCH --partition=hmemq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=96
#SBATCH --mem=1000g
#SBATCH --time=140:00:00
#SBATCH --job-name=fish_b_assembly
#SBATCH --output=/gpfs01/home/mbzlld/data/danionella/fish_B/hifiasm_3/slurm-%x-%j.out

# setup env
source $HOME/.bash_profile
#conda create --name hifiasm_0.25.0 hifiasm -y
conda activate hifiasm_0.25.0
attempt=3
mkdir -p /gpfs01/home/mbzlld/data/danionella/fish_B/hifiasm_$attempt
cd /gpfs01/home/mbzlld/data/danionella/fish_B/hifiasm_$attempt
reads=/gpfs01/home/mbzlld/data/danionella/basecalls/FishB_ALL_simplex.fastq.gz


# print a line to the slurm output that says exactly what was done on this run
echo "This is hifiasm version 0.25.0 running on the file $reads and saving the output to the directory /gpfs01/home/mbzlld/data/danionella/fish_B/hifiasm_$attempt"


# run hifiasm on the simplex reads with the new --ont flag to generate the assembly
hifiasm \
-t 96 \
--ont \
--dual-scaf \
--telo-m AACCCT \
-o fish_b \
$reads

# convert the final assembly to fasta format
awk '/^S/{print ">"$2;print $3}' fish_b.bp.p_ctg.gfa > fish_b.bp.p_ctg.fasta
awk '/^S/{print ">"$2;print $3}' fish_b.bp.hap1.p_ctg.gfa > fish_b.bp.hap1.p_ctg.fasta
awk '/^S/{print ">"$2;print $3}' fish_b.bp.hap2.p_ctg.gfa > fish_b.bp.hap2.p_ctg.fasta

# cleanup env
conda deactivate


