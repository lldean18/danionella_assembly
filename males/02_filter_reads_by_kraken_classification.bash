#!/bin/bash
# 6/2/26
# Laura Dean
# I ran this on UoN HPC

# record of code used to extract reads classified as certain taxonomic groups

# set up env

conda activate tmux
tmux attach -t kraken
srun --partition defq --cpus-per-task 2 --mem 30g --time 24:00:00 --pty bash
source $HOME/.bash_profile
conda activate kraken2

# TaxID for Chordata = 7711

# Extract just the reads we want for fish 1
python /share/deepseq/laura/ctenella/extract_kraken_reads.py \
-s /share/deepseq/danionella/maleFish/ds1777_1.pass.fastq \
-o /gpfs01/home/mbzlld/data/danionella/males/dc1/kraken2/ds1777_1.pass_chordata.fastq \
--taxid 7711 \
--fastq-output \
--include-children \
-k /gpfs01/home/mbzlld/data/danionella/males/dc1/kraken2/ds1777_1.pass_k2_output \
--report /gpfs01/home/mbzlld/data/danionella/males/dc1/kraken2/ds1777_1.pass_k2_report

# compress the fastq output
gzip -k /gpfs01/home/mbzlld/data/danionella/males/dc1/kraken2/ds1777_1.pass_chordata.fastq


# Extract just the reads we want for fish 2
python /share/deepseq/laura/ctenella/extract_kraken_reads.py \
-s /gpfs01/home/mbzlld/data/danionella/males/dc2/kraken2/classified/ds1777_2.pass_classified.fastq \
-o /gpfs01/home/mbzlld/data/danionella/males/dc2/kraken2/ds1777_2.pass_chordata.fastq \
--taxid 7711 \
--fastq-output \
--include-children \
-k /gpfs01/home/mbzlld/data/danionella/males/dc2/kraken2/ds1777_2.pass_k2_output \
--report /gpfs01/home/mbzlld/data/danionella/males/dc2/kraken2/ds1777_2.pass_k2_report

# compress the fastq output
gzip -k /gpfs01/home/mbzlld/data/danionella/males/dc2/kraken2/ds1777_2.pass_chordata.fastq

