

# setup env
conda activate tmux
tmux new -t syri
srun --partition defq --cpus-per-task 16 --mem 80g --time 12:00:00 --pty bash

wkdir=/gpfs01/home/mbzlld/data/danionella/try2_zfish_synteny
cd $wkdir
ref=/gpfs01/home/mbzlld/data/danionella/GCF_049306965.1_GRCz12tu_genomic.fna
asm=/gpfs01/home/mbzlld/data/danionella/fish_B/hifiasm_asm1/ONTasm.bp.p_ctg.fasta

# produce alignments 
conda activate minimap2
minimap2 -x asm5 -t 8 $ref $asm > aln.paf
conda deactivate

# scaffold with syri tool
conda activate syri1.7.1


