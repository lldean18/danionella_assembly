

# setup env
mkdir -p /gpfs01/home/mbzlld/data/danionella/popgen/windowed_divergence
cd /gpfs01/home/mbzlld/data/danionella/popgen/windowed_divergence
reference=/share/deepseq/shenson/ds1664_Wilkinson/03_medaka/consensus.fasta
vcf=/gpfs01/home/mbzlld/data/danionella/popgen/variants/danionella_all_reads_Q30_DP10_GQ20_SNP_mis0.9.vcf.gz

conda activate samtools1.22
samtools faidx $reference
cut -f1,2 $reference.fai > genome.txt

# make windows
bedtools makewindows \
    -g genome.txt \
    -w 100000 > windows_100kb.bed

# calculate differences for each pair
python pairwise_discordance.py $vcf FishA_ALL_simplex FishB_ALL_simplex 100000 > FishA_vs_FishB.tsv
python pairwise_discordance.py $vcf FishA_ALL_simplex SUP_fish_c 100000 > FishA_vs_FishC.tsv
python pairwise_discordance.py $vcf FishB_ALL_simplex SUP_fish_c 100000 > FishB_vs_FishC.tsv


# calculate the windowed heterozygosity
python windowed_heterozygosity.py $vcf FishA_ALL_simplex 100000 FishA_100kb.tsv
python windowed_heterozygosity.py $vcf FishB_ALL_simplex 100000 FishB_100kb.tsv
python windowed_heterozygosity.py $vcf SUP_fish_c 100000 FishC_100kb.tsv



