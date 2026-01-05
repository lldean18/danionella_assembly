

# setup env
conda activate tmux
tmux new -t syri
srun --partition defq --cpus-per-task 16 --mem 80g --time 12:00:00 --pty bash

wkdir=/gpfs01/home/mbzlld/data/danionella/try2_zfish_synteny
cd $wkdir
ref=/gpfs01/home/mbzlld/data/danionella/GCF_049306965.1_GRCz12tu_genomic.fna
asm=/gpfs01/home/mbzlld/data/danionella/fish_B/hifiasm_asm1/ONTasm.bp.p_ctg.fasta

#############################
#### produce alignments #####
#############################

conda activate minimap2
minimap2 -x asm5 -t 8 $ref $asm > aln.paf
conda deactivate

# convert the paf alignment file to input tsv for croder
awk 'BEGIN{OFS="\t"}
{
  pid = ($10/$11)*100
  print $6, $8, $9, $1, $3, $4, $5, pid
}' aln.paf > chroder.coords.tsv

# filter for >=10 kb alignments, >=90% identity
awk '$2-$1 >= 10000 && $8 >= 90' chroder.coords.tsv \
> chroder.coords.filtered.tsv

###########################
# scaffold with syri tool #
###########################

# index asms
conda activate samtools
samtools faidx $ref
samtools faidx $asm
conda deactivate


conda activate syri1.7.1
chroder chroder.coords.filtered.tsv $ref $asm -o chroder

