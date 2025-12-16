#!/bin/bash
# Laura Dean
# 15/12/25
# script designed for running on the UoN HPC Ada

# script to plot synteny between the zebrafish assembly and 
# danionella scaffolded with the zebrafish assembly.

#SBATCH --job-name=syri_plotsr
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=80g
#SBATCH --time=3:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


# load software
source $HOME/.bash_profile

# set variables
wkdir=/gpfs01/home/mbzlld/data/danionella/zebrafish_synteny
# assembly1=/gpfs01/home/mbzlld/data/danionella/GCF_049306965.1_GRCz12tu_genomic.fna
# assembly2=/gpfs01/home/mbzlld/data/danionella/fish_B/hifiasm_asm1/ONTasm.bp.p_ctg_ragtag/ragtag.scaffolds_only.fasta
mkdir -p $wkdir
cd $wkdir


# # filter the chrs that don't exist in danionella out of the zebrafish asm
# echo "chromosome_4
# chromosome_16
# chromosome_22
# chromosome_24" > chrs_not_in_danionella.txt
# conda activate seqkit
# seqkit grep -v -f chrs_not_in_danionella.txt $assembly1 > zebrafish_asm_filtered.fasta

assembly1=zebrafish_asm_filtered.fasta

# # make sure the order of chrs in the 2nd file matches the order in the ref
# seqkit seq -n $assembly1 > ref.order.txt
# seqkit grep -n -f ref.order.txt --pattern-file-order $assembly2 > ragtag.scaffolds_only_reordered.fasta
# seqkit faidx $assembly2 --infile-list ref.order.txt > ragtag.scaffolds_only_reordered.fasta
# conda deactivate

assembly2=ragtag.scaffolds_only_reordered.fasta

################################################
### Align assemblies that will be compared #####
################################################

#asm=asm5 # 0.1% sequence divergence
#asm=asm10 # 1% sequence divergence
#asm=asm20 # 5% sequence divergence

# align assemblies to be compared
conda activate minimap2
minimap2 -ax asm10 -t 16 --eqx $assembly1 $assembly2 | samtools sort -O BAM - > alignment.bam
samtools index alignment.bam
conda deactivate

# write the names of the assemblies to a file for use by plotsr
echo -e ""$assembly1"\tZebrafish
"$assembly2"\tDanionella" > plotsr_assemblies_list.txt

##############################################################
### Identify structural rearrangements between assemblies ####
##############################################################

echo "identifying structural rearrangements between assemblies with syri..."
# create your syri environment
#conda create --name syri1.7.1 syri -y
conda activate syri1.7.1

# Run syri to find structural rearrangements between your assemblies
echo "running syri for asm1 and asm2..."
syri \
-c alignment.bam \
-r $assembly1 \
-q $assembly2 \
-F B \
--dir $wkdir \
--prefix asm1_asm2_

conda deactivate

###########################
### create plotsr plot ####
###########################

echo "plotting structural rearrangements with plotsr..."
#conda activate plotsr
#conda create --name plotsr1.1.0 plotsr -y
conda activate plotsr1.1.0

plotsr \
--sr asm1_asm2_syri.out \
--genomes plotsr_assemblies_list.txt \
-o plotsr_plot.png

### customise the plot for the paper
#plotsr \
#	-o plotsr_plot_MS.png \
#	--sr asm1_asm2_syri.out \
#	--genomes plotsr_assemblies_list.txt \
#	-H 23 \
#	-W 20 \
#	-f 14 \
#	--cfg base.cfg





conda deactivate
