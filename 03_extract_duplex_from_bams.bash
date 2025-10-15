





# load modules
module load samtools-uoneasy/1.18-GCC-12.3.0


for bam in
do


# extract duplex reads from bam files
samtools view \
--tag dx:1 \
--threads 48 \
-O bam \
--write-index \
--output ${bam%.*}_duplex.bam \
$bam

## extract simplex reads from bam files
#samtools view \
#--tag dx:0 \
#--tag dx:-1 \
#--threads 48 \
#-O bam \
#--write-index \
#--output ${bam%.*}_simplex.bam \
#$bam
