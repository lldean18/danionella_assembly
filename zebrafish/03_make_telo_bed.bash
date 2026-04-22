#!/bin/bash
# 22/4/26

# code to make the genome info file for karyotype plot
# then
# code to make bed file to annotate telomeric sequence on a karyotype plot for zebrafish




cd /gpfs01/home/mbzlld/data/danionella/zebrafish
cut -f1,2 GCF_049306965.1_GRCz12tu_genomic.fna.fai > chr_sizes.txt
sed -i 's/\t/\t1\t/' chr_sizes.txt






cd /gpfs01/home/mbzlld/data/danionella/zebrafish/tidk

# extract telomeric regions in bed format where at least 10 repeats are found
awk 'BEGIN{OFS="\t"}
NR>1 && ($3>9 || $4>9){
    start=(($2-10000));
    end=($2);
    print $1,start,end
}' GCF_049306965.1_GRCz12tu_genomic_tidk_search_AACCCT_telomeric_repeat_windows.tsv > telomeres.bed

# merge adjacent windows
bedtools merge -i telomeres.bed > telomeres_merged.bed


