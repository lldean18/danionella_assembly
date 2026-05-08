#!/bin/bash
# 8/5/26

# filter the hox region from the flair bam file to look at read mapping

# setup env
conda activate samtools1.22
cd /gpfs01/home/mbzlld/data/danionella/flair

# extract the hox gene region from the flair bam file and index the new bam
samtools view flair.aligned.bam -O BAM ptg000006l:4690000-4830000 > flair.aligned.hox.bam
samtools index flair.aligned.hox.bam

conda deactivate




# 11 tranafer annot GTF


