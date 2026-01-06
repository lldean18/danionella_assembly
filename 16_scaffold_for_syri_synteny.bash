#!/bin/bash
# record of code trying to plot the danionella assembly, scaffolded with
# zebrafish against the zebrafish assembly in a synteny plot

# setup env
conda activate tmux
tmux new -t syri
# increased mem and decreased threads as this version of mummer is single threaded but ran OOM with 80G
srun --partition defq --cpus-per-task 16 --mem 180g --time 24:00:00 --pty bash

wkdir=/gpfs01/home/mbzlld/data/danionella/try2_zfish_synteny
cd $wkdir
ref=/gpfs01/home/mbzlld/data/danionella/GCF_049306965.1_GRCz12tu_genomic.fna
asm=/gpfs01/home/mbzlld/data/danionella/fish_B/hifiasm_asm1/ONTasm.bp.p_ctg.fasta

## #############################
## #### produce alignments #####
## #############################
## 
## conda activate minimap2
## minimap2 -x asm5 -t 8 $ref $asm > aln.paf
## conda deactivate
## 
## # convert the paf alignment file to input tsv for croder
## awk 'BEGIN{OFS="\t"}
## {
##   idy = ($10/$11)*100
##   print \
##     $8,  $9, \
##     $3,  $4, \
##     $7,  $2, \
##     idy, \
##     $6,  $1, \
##     $11, \
##     0
## }' aln.paf > chroder.coords.tsv

##############################################
# produce alignments 2nd attempt with mummer #
##############################################

conda activate mummer
nucmer --maxmatch $ref $asm -p asm
show-coords -THrd asm.delta > chroder.coords.tsv
conda deactivate

###########################
# scaffold with syri tool #
###########################

# index asms
conda activate samtools
samtools faidx $ref
samtools faidx $asm
conda deactivate


conda activate syri1.7.1
chroder chroder.coords.tsv $ref $asm -o chroder




