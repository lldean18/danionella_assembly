#!/bin/bash
# Laura Dean
# 27/11/26

# script to assemble a genome with hifiasm v 0.25.0

#SBATCH --partition=hmemq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=96
#SBATCH --mem=1000g
#SBATCH --time=140:00:00
#SBATCH --job-name=MaleFish2_danionella_assembly
#SBATCH --output=/gpfs01/home/mbzlld/data/danionella/fish_c/hifiasm_2/slurm-%x-%j.out

# setup env
source $HOME/.bash_profile
#conda create --name hifiasm_0.25.0 hifiasm -y
conda activate hifiasm_0.25.0

ATTEMPT=1

#IND=ds1777_1
#OUTDIR=/share/deepseq/danionella/maleFish/ds1777_1/hifiasm_$ATTEMPT
#READS=/share/deepseq/danionella/maleFish/ds1777_1.pass_chordata.fastq

IND=ds1777_2
OUTDIR=/share/deepseq/danionella/maleFish/ds1777_2/hifiasm_$ATTEMPT
READS=/share/deepseq/danionella/maleFish/ds1777_2.pass_chordata.fastq.gz

mkdir -p $OUTDIR
cd $OUTDIR

# print a line to the slurm output that says exactly what was done on this run
echo "This is hifiasm version 0.25.0 running on the file $READS and saving the output to the directory $OUTDIR"

# run hifiasm on the simplex reads with the new --ont flag to generate the assembly
hifiasm \
-t 96 \
--ont \
--dual-scaf \
--telo-m AACCCT \
-o $IND \
$READS

# convert the final assembly to fasta format
awk '/^S/{print ">"$2;print $3}' $IND.bp.p_ctg.gfa > $IND.bp.p_ctg.fasta
awk '/^S/{print ">"$2;print $3}' $IND.bp.hap1.p_ctg.gfa > $IND.bp.hap1.p_ctg.fasta
awk '/^S/{print ">"$2;print $3}' $IND.bp.hap2.p_ctg.gfa > $IND.bp.hap2.p_ctg.fasta

# cleanup env
conda deactivate

