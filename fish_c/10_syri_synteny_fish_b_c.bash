#!/bin/bash
# 22/7/26

# script to plot fine scale synteny between assemblies for fish b and c with syri and plotsr

#SBATCH --job-name=syri_plotsr
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=50g
#SBATCH --time=48:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out





# setup env
source $HOME/.bash_profile
module load samtools-uoneasy/1.18-GCC-12.3.0
mkdir -p /gpfs01/home/mbzlld/data/danionella/plotsr/comparison1
cd /gpfs01/home/mbzlld/data/danionella/plotsr/comparison1
reference=/gpfs01/home/mbzlld/data/danionella/fish_B/hifiasm_3/fish_b.bp.p_ctg_100kb.fasta
assembly=/gpfs01/home/mbzlld/data/danionella/fish_c/hifiasm_2/fish_c.bp.p_ctg_100kb.fasta


# align our assembly to the reference
#asm=asm5 # 0.1% sequence divergence
#asm=asm10 # 1% sequence divergence
#asm=asm20 # 5% sequence divergence
echo "aligning our assembly to the reference for naming our chrs the same as theirs..."
conda activate minimap2
minimap2 -x asm5 -t 16 $reference $assembly > asm_to_ref_alignment.paf
conda deactivate
echo -e "Done\n\n"

# identify the best matching chromosomes for each of our fragments
echo "identifying the best matching chromosomes for each of our fragments..."
awk '{print $1, $6, $8-$7}' asm_to_ref_alignment.paf | sort -k1,1 -k3nr | awk '!seen[$1]++' > contig_assignments.txt
sed -i -r 's/[^ ]*$//' contig_assignments.txt # get rid of the contig lengths at the ends of the lines
sed -i -r 's/ /\t/' contig_assignments.txt # replace spaces with tabs
echo -e "Done\n\n"

# rename contigs in our assembly based on their assignments
echo "renaming contigs in our assembly based on their assignments relative to the reference..."
conda activate seqkit
seqkit replace -p "^(.*)" -r "{kv}" --kv-file contig_assignments.txt $assembly > assembly_ref_named_contigs.fasta
echo -e "Done\n\n"


# filter so that only the longest contig for each match to the reference is retained
echo "retaining only the longest contig for each match to the reference..."
seqkit seq -j 4 -w 0 assembly_ref_named_contigs.fasta | seqkit rename | seqkit sort -l -r | sed 's/_[0-9][0-9]*//' | seqkit rmdup > assembly_ref_named_contigs_longest.fasta
conda deactivate
echo -e "Done\n\n"

# Filter so that only contigs that are in our assembly are in a new version of the reference
# because syri won't work with differing numbers of chromosomes in the same assembly
echo "making a list of the fasta headers to filter with..."
# make a text file of the headers to search for
grep ">" assembly_ref_named_contigs_longest.fasta > asm_contig_names.txt
sed -i 's/>//' asm_contig_names.txt
sed -i 's/[[:space:]]*$//' asm_contig_names.txt
echo -e "Done\n\n"

# filter the reference with this file
echo "filtering the reference so that it only contains sequences that are in our assembly..."
conda activate seqkit
seqkit grep -f asm_contig_names.txt $reference > filtered_reference.fasta
conda deactivate
echo -e "Done\n\n"

################################################################################################
#### Flip the orientation of our sequences that are on the opposite strand to the reference ####
################################################################################################

# flip the orientation of our sequences that are on the wrong strand
echo "flipping the orientation of our sequences so that they match the reference..."
conda activate seqkit
# define output
touch assembly_ref_named_contigs_longest_orient.fasta

# Loop through sequences in our assembly fasta file
seqkit seq --seq-type dna -n assembly_ref_named_contigs_longest.fasta | while read name; do
    # Extract sequences
    seq1=$(seqkit grep -p "$name" assembly_ref_named_contigs_longest.fasta | seqkit seq --seq)
    seq2=$(seqkit grep -p "$name" filtered_reference.fasta | seqkit seq --seq)

    # Save sequences to temporary files
    echo -e ">$name\n$seq1" > ~/seq1.fasta
    echo -e ">$name\n$seq2" > ~/seq2.fasta
    echo -e ">$name\n$(seqkit seq --seq-type dna --reverse --complement ~/seq2.fasta | seqkit seq --seq)" > ~/seq2_rc.fasta

    # Align both orientations with MAFFT
    mafft --quiet ~/seq1.fasta ~/seq2.fasta > ~/aligned1.fasta
    mafft --quiet ~/seq1.fasta ~/seq2_rc.fasta > ~/aligned2.fasta

    # Calculate alignment scores
    score1=$(awk '/identity/ {print $3}' <(seqkit fx2tab -n -i -p ~/aligned1.fasta | seqkit stats))
    score2=$(awk '/identity/ {print $3}' <(seqkit fx2tab -n -i -p ~/aligned2.fasta | seqkit stats))

    # Choose best orientation
    if (( $(echo "$score1 >= $score2" | bc -l) )); then
        cat seq2.fasta >> assembly_ref_named_contigs_longest_orient.fasta
    else
        seqkit seq --reverse --complement seq2.fasta >> assembly_ref_named_contigs_longest_orient.fasta
    fi
done

# Cleanup
rm seq1.fasta seq2.fasta seq2_rc.fasta aligned1.fasta aligned2.fasta
conda deactivate
echo -e "Done\n\n"

###########################################
#### map our assembly to the reference ####
###########################################

echo "Mapping our assembly to the reference..."
conda activate minimap2

# align the genomes

# for reference asm5/asm10/asm20 = 0.1%/1%/5% sequence divergence
minimap2 \
-ax asm5 \
-t 16 \
--eqx assembly_ref_named_contigs_longest_orient.fasta filtered_reference.fasta \
-o tmp.sam
samtools sort tmp.sam \
-o final_mapping.bam
rm tmp.sam
conda deactivate

# index the bam file
samtools index -bc final_mapping.bam

# write the names of the assemblies to a file for use by plotsr
echo -e "assembly_ref_named_contigs_longest_orient.fasta\tfish_c
filtered_reference.fasta\tfish_b" > plotsr_assemblies_list.txt

module unload samtools-uoneasy/1.18-GCC-12.3.0
echo -e "Done\n\n"


###############################################################
#### Identify structural rearrangements between assemblies ####
###############################################################

echo "identifying structural rearrangements between assemblies with syri..."
# create your syri environment
#conda create -y --name syri -c bioconda -c conda-forge -c anaconda python=3.8 syri
conda activate syri

# Run syri to find structural rearrangements between your assemblies
syri \
-c final_mapping.bam \
-r filtered_reference.fasta \
-q assembly_ref_named_contigs_longest_orient.fasta \
-F B \
--dir ./ \
--prefix syri

conda deactivate
echo -e "Done\n\n"

############################
#### create plotsr plot ####
############################

echo "plotting structural rearrangements with plotsr..."
conda activate plotsr

plotsr \
--sr syri.out \
--genomes plotsr_assemblies_list.txt \
-o plot.png

conda deactivate
echo "Done"
