#!/bin/bash
# Laura Dean
# 9/1/26
# code used to rename the contigs in danionella assembly so that information
# about synteny to zebrafish chromosomes is included

new_headers=/gpfs01/home/mbzlld/github/danionella_assembly/synteny_zebrafish_chr_list.txt
assembly=/gpfs01/home/mbzlld/data/danionella/fish_B/hifiasm_asm1/ONTasm.bp.p_ctg_100kb.fasta



conda activate seqkit
seqkit replace \
--keep-key \
--pattern '^(\S+)' \
--replacement '{kv}' \
 -k $new_headers \
$assembly > ${assembly%.*}_synt.fasta
conda deactivate



