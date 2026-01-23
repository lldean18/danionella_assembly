#!/bin/bash
# Laura Dean
# 23/1/26
# For running on the UoN HPC Ada
# script to align our danionella assembly with the published danionella translucida
# assembly that was published here: https://www.nature.com/articles/s41597-019-0161-z#Sec6



####### PREPARE ENVIRONMENT #######
conda activate tmux
tmux new -t last
# OR to reattach
tmux attach -t last
srun --partition defq --cpus-per-task 24 --mem 100g --time 18:00:00 --pty bash
#conda create --name last last -y
conda activate last



####### SET VARIABLES #######
reference=/gpfs01/home/mbzlld/data/danionella/fish_B/hifiasm_asm1/ONTasm.bp.p_ctg_100kb.fasta
assembly=/gpfs01/home/mbzlld/data/danionella/translucida/GCA_007224835.1_ASM722483v1_genomic.fna.gz



####### RUN ANALYSIS ########
# -P = number of threads
# Create database from the reference genome
# -uRY128 combined flag - makes it faster but less sensitive: it'll miss tiny rearranged fragments. To find them, try -uRY4
# -uRY16 seemed to work well
uRY=128
lastdb \
	-P24 \
	-c \
	-uRY$uRY \
	${reference%.*.*}_db \
	$reference

# find score parameters for aligning the assembly to the reference
last-train \
	-P24 \
	--revsym \
	-C2 \
	${reference%.*.*}_db \
	$assembly > ${assembly%.*}hc.train

# find and align similar sequences
lastal \
	-P24 \
	-D1e9 \
	-C2 \
	--split-f=MAF+ \
	-p ${assembly%.*}hc.train \
	${reference%.*.*}_db $assembly > ${assembly%.*}many-to-one.maf

# get one to one alignments
last-split \
	-r \
	${assembly%.*}many-to-one.maf > ${assembly%.*}one-to-one.maf

# make a dotplot
last-dotplot \
--verbose \
--rot1=v \
--rot2=h \
--fontsize=10 \
--sort1=3 \
--sort2=1 \
${assembly%.*}one-to-one.maf \
${assembly%.*}dotplot.png

## # specify which of the fragments to include in the plot
## last-dotplot \
## --verbose \
## --rot1=v \
## --rot2=h \
## --fontsize=10 \
## -1 'NC_133187*' \
## -1 'NC_133190*' \
## -2 'ptg000012*' \
## ${assembly%.*}one-to-one.maf \
## ${assembly%.*}dotplot2.png 


################################################################
################################################################

SCORE=2500

# get one to one alignments with filtering for slignment score
last-split \
        -r \
        --score=$SCORE \
        ${assembly%.*}many-to-one.maf > ${assembly%.*}one-to-one_score$SCORE.maf

# make a dotplot
last-dotplot \
--verbose \
--rot1=v \
--rot2=h \
--fontsize=10 \
--sort1=3 \
--sort2=1 \
${assembly%.*}one-to-one_score$SCORE.maf \
${assembly%.*}dotplot_score$SCORE.png


conda deactivate
