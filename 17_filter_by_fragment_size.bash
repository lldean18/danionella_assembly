#!/bin/bash
# Laura Dean
# script to filter assembly by fragment size


assembly=/gpfs01/home/mbzlld/data/danionella/fish_B/hifiasm_asm1/ONTasm.bp.p_ctg.fasta
assembly=/gpfs01/home/mbzlld/data/danionella/fish_B/hifiasm_asm1/ONTasm.bp.p_ctg_ragtag/ragtag.scaffold.fasta

conda activate seqtk

# remove sequences shorter than 100kb
seqtk seq -L 100000 $assembly > ${assembly%.*}_100kb.fasta

conda deactivate


