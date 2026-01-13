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
nucmer $ref $asm -p asm
show-coords -THrd asm.delta > chroder.coords.tsv
conda deactivate

##########################################################################
# filter out all contigs from danionella that do not match the zebrafish #
##########################################################################

cut -f11 chroder.coords.tsv | sort -u > qry.contigs.with.alignments.txt
# then delete the line for the contig that is still causing errors
sed -i '/ptg000022l/d' qry.contigs.with.alignments.txt
conda activate seqkit
seqkit grep -f qry.contigs.with.alignments.txt $asm > asm.filtered.fa
# this kept 111 of 350 contigs in the danionella asm
conda deactivate

# now filter them from the coords file
awk 'NR==FNR {keep[$1]; next} ($11 in keep)' \
  qry.contigs.with.alignments.txt \
  chroder.coords.tsv > chroder.coords.filtered.tsv

###########################
# scaffold with syri tool #
###########################

# index asms
# don't think this was necessary in the end but ran it anyway
conda activate samtools
samtools faidx $ref
samtools faidx $asm
samtools faidx asm.filtered.fa
conda deactivate


conda activate syri1.7.1
# scaffold the danionella asm using the zebrafish as a ref
chroder chroder.coords.filtered.tsv $ref asm.filtered.fa -o chroder

########################################
# align the scaffolded asm and the ref #
########################################

conda activate minimap2
minimap2 -ax asm5 --eqx --secondary=no -t 16 $ref asm.filtered.fa | samtools sort -o syri.bam
samtools index syri.bam
conda deactivate

# filter out the chrs in the ref that have no match
conda activate samtools
samtools idxstats syri.bam | awk '$3>0 {print $1}' > ref.keep.txt
conda deactivate

conda activate seqkit
seqkit grep -f ref.keep.txt $ref > ref.filtered.fa
conda deactivate

conda activate samtools
samtools faidx ref.filtered.fa
conda deactivate

##############################################################
### Identify structural rearrangements between assemblies ####
##############################################################

# write the names of the assemblies to a file for use by plotsr
echo -e ""$wkdir/ref.filtered.fa"\tZebrafish
"$wkdir/asm.filtered.fa"\tDanionella" > plotsr_assemblies_list.txt

conda activate syri_new

# Run syri to find structural rearrangements between your assemblies
syri \
-c out.bam \
-r ref.filtered.fa \
-q asm.filtered.fa \
-F B \
--nc 16 \
--dir $wkdir \
--prefix Zeb_Dan_

conda deactivate

###########################
### create plotsr plot ####
###########################

## conda activate plotsr1.1.0
## 
## plotsr \
## --sr asm1_asm2_syri.out \
## --genomes plotsr_assemblies_list.txt \
## -o plotsr_plot.png

### customise the plot for the paper
#plotsr \
#       -o plotsr_plot_MS.png \
#       --sr asm1_asm2_syri.out \
#       --genomes plotsr_assemblies_list.txt \
#       -H 23 \
#       -W 20 \
#       -f 14 \
#       --cfg base.cfg

conda deactivate


