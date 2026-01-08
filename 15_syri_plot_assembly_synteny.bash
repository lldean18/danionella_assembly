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
mkdir -p $wkdir
cd $wkdir

assembly1=/gpfs01/home/mbzlld/data/danionella/GCF_049306965.1_GRCz12tu_genomic.fna
# assembly2=/gpfs01/home/mbzlld/data/danionella/fish_B/hifiasm_asm1/ONTasm.bp.p_ctg_ragtag/ragtag.scaffolds_only.fasta
assembly2=/gpfs01/home/mbzlld/data/danionella/fish_B/hifiasm_asm1/ONTasm.bp.p_ctg_ragtag/ragtag.scaffold_100kb.fasta


# filter the chrs that don't exist in danionella out of the zebrafish asm
echo "chromosome_4
chromosome_15
chromosome_16
chromosome_22
chromosome_24
mitochondrion" > chrs_not_in_danionella.txt
#conda activate seqkit
seqkit grep -v -f chrs_not_in_danionella.txt $assembly1 > zebrafish_asm_filtered.fasta

assembly1=zebrafish_asm_filtered.fasta

# make sure the order of chrs in the 2nd file matches the order in the ref
seqkit seq -n $assembly1 > ref.order.txt
seqkit faidx $assembly2 --infile-list ref.order.txt > ragtag.scaffold_100kb_reordered.fasta
conda deactivate

assembly2=ragtag.scaffold_100kb_reordered.fasta

################################################
### Align assemblies that will be compared #####
################################################

#asm=asm5 # 0.1% sequence divergence
#asm=asm10 # 1% sequence divergence
#asm=asm20 # 5% sequence divergence

# align assemblies to be compared
conda activate syri_new

minimap2 -ax asm5 -N 50 --secondary=no -t 16 --eqx $assembly1 $assembly2 | samtools sort -O BAM - > alignment.bam
samtools view alignment.bam | awk '{print $1,$2,$3}' # troubleshooting
# # remove all but primary mapped reads
# samtools view -b -F 0x904 alignment.bam > temp && mv temp alignment.bam
# samtools view alignment.bam | awk '{print $1,$2,$3}' # troubleshooting
samtools index alignment.bam


# write the names of the assemblies to a file for use by plotsr
echo -e ""$assembly1"\tZebrafish
"$assembly2"\tDanionella" > plotsr_assemblies_list.txt


# some chrs are inverted. Determine which need reverse complementing
samtools view alignment.bam | awk '
{
  ref = $3
  flag = $2
  cigar = $6

  # detect reverse strand (FLAG 16)
  strand = (int(flag/16)%2 == 1) ? "-" : "+"

  len = 0
  while (match(cigar, /[0-9]+[=X]/)) {
    seg = substr(cigar, RSTART, RLENGTH)
    sub(/[=X]/, "", seg)
    len += seg
    cigar = substr(cigar, RSTART+RLENGTH)
  }

  cov[ref,strand] += len
}
END {
  for (k in cov) {
    split(k,a,SUBSEP)
    total[a[1]] += cov[k]
  }
  for (k in cov) {
    split(k,a,SUBSEP)
    printf "%s\t%s\t%.3f\n", a[1], a[2], cov[k]/total[a[1]]
  }
}' | sort -k1,1 -k3,3nr > strand_fraction.tsv

# determine which chrs should be inverted
awk '$2=="-" && $3>0.55 {print $1}' strand_fraction.tsv > inverted_chrs.txt

# flip the inverted ones
conda activate seqkit
seqkit grep -f inverted_chrs.txt $assembly2 \
| seqkit seq -r -p \
> asm.inverted.fa
# extract the non inverted ones
seqkit grep -v -f inverted_chrs.txt $assembly2 > asm.normal.fa
# merge inverted and non inverted back together
cat asm.normal.fa asm.inverted.fa > asm.fixed.fa
samtools faidx asm.fixed.fa

# remove 21 and 14 that are throwing errors
seqkit grep -v -n -p chromosome_14 -p chromosome_21 $assembly1 > filtered_ref.fa
seqkit grep -v -n -p chromosome_14 -p chromosome_21 asm.fixed.fa > asm.fixed2.fa

##### remake the bam
minimap2 -ax asm5 --secondary=no -t 16 --eqx filtered_ref.fa asm.fixed2.fa | samtools sort -O BAM - > new_alignment2.bam
#samtools view new_alignment.bam | awk '{print $1,$2,$3}' # troubleshooting
samtools index new_alignment2.bam


##############################################################
### Identify structural rearrangements between assemblies ####
##############################################################

#conda activate syri_new

# Run syri to find structural rearrangements between your assemblies
syri \
-c new_alignment2.bam \
-r filtered_ref.fa \
-q asm.fixed.fa \
-F B \
--nc 16 \
--dir $wkdir \
--prefix asm1_asm2_


# try loosening the parameters
syri \
-c new_alignment2.bam \
-r filtered_ref.fa \
-q asm.fixed.fa \
-F B \
--nc 16 \
--dir $wkdir \
--prefix syri_less_strict_ \
-f


conda deactivate

###########################
### create plotsr plot ####
###########################

# write the names of the assemblies to a file for use by plotsr
echo -e ""$wkdir/filtered_ref.fa"\tZebrafish
"$wkdir/asm.fixed.fa"\tDanionella" > plotsr_assemblies_list.txt

#conda create --name plotsr1.1.0 plotsr -y
conda activate plotsr1.1.0

# the basic plot
plotsr \
--sr asm1_asm2_syri.out \
--genomes plotsr_assemblies_list.txt \
-o plotsr_plot.png

### customise the plot for more pretties
plotsr \
	-o synteny_plot_less_strict.png \
	--sr asm1_asm2_syri.out \
	--genomes plotsr_assemblies_list.txt \
	-H 23 \
	-W 20 \
	-f 14 \
	--cfg base.cfg





conda deactivate
