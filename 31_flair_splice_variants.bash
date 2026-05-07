#!/bin/bash
# Laura Dean
# 28/4/26

# Script to use FLAIR to detect splice variants from RNAseq data
# input is raw fastq files, plus a reference genome and annotation file

#SBATCH --job-name=flair_splice_variant_search
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=50g
#SBATCH --time=10:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out
#SBATCH --mem=200g



# setup env
source $HOME/.bash_profile
#conda create --name flair bioconda::flair -y
conda activate flair
cd /gpfs01/home/mbzlld/data/danionella/flair

reference=/share/deepseq/shenson/ds1664_Wilkinson/03_medaka/consensus.fasta
annotation=../braker.gtf
fastqs=../long_read_RNAseq/barcode01/*.fastq.gz
manifest=manifest.tsv

### # make the manifest file
### \ls /gpfs01/home/mbzlld/data/danionella/long_read_RNAseq/barcode01/*.fastq.gz > $manifest
### sed -i 's/^/fish_B\tadult\tflowcell1\t/' $manifest

# # flair align - aligns reads to the genome using minimap2, and converts the SAM output to BED12
# flair align \
# 	--genome $reference \
# 	--threads 8 \
# 	--reads $fastqs
# 
# # flair correct - corrects misaligned splice sites using genome annotations
# flair correct \
# 	--query flair.aligned.bed \
# 	--gtf $annotation \
# 	--genome $reference \
# 	--threads 8

# # flair collapse - Defines high-confidence isoforms from corrected reads
# flair collapse \
# 	--genome $reference \
# 	--gtf $annotation \
# 	--query flair_all_corrected.bed \
# 	--reads $fastqs \
# 	--generate_map \
# 	--check_splice \
# 	--stringent \
# 	--annotation_reliant generate

# flair quantify - Identifes the best isoform assignment 
flair quantify \
	--isoforms flair.collapse.isoforms.fa \
	--reads_manifest $manifest \
	--threads 40

### # This didnt really work because it turned all the 0 read counts into 1s so not using it
### # normalise the counts to be per million reads
### normalize_counts_matrix \
### 	flair.quantify.counts.tsv \
### 	flair.quantify.counts.cpm.tsv \
### 	cpm

# deactivate software
conda deactivate

################################################################
# processing the output (ran this manually in terminal window) #
################################################################

# sum across replicates of the same sample (which in this case is all of them)
awk '{for(i=2;i<=NF;i++) a[$1]+=$i} END{for(k in a) print k,a[k]}' flair.quantify.counts.tsv > flair.quantify.counts.summed.tsv

# extract only the splice variants for the genes of interest
# these are the hox genes
declare -a arr=("g16391" "g16392" "g16393" "g16394" "g16395" "g16396" "g16397" "g16398" "g16399" "g16400" "g16401" "g16402" "g16403")
for gene_of_interest in "${arr[@]}"
do
grep -i $gene_of_interest flair.quantify.counts.summed.tsv > ${gene_of_interest}.flair.quantify.counts.summed.tsv

# remove the transcript info we're not interested in here
sed -i 's/^.*_//' ${gene_of_interest}.flair.quantify.counts.summed.tsv

# merge the counts for each gene
awk 'BEGIN{OFS="\t"}
 {sum[$1] += $2} END {for(gene in sum) print gene, sum[gene]}' ${gene_of_interest}.flair.quantify.counts.summed.tsv > tmp
mv tmp ${gene_of_interest}.flair.quantify.counts.summed.tsv
done

# concatenate the gene counts
cat *.flair.quantify.counts.summed.tsv > hox.gene.flair.counts.tsv




