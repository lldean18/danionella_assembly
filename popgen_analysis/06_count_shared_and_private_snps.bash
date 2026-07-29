#!/bin/bash
# 28/7/26

# script to calculate pairwise genetic distances with plink2





# setup env
conda activate tmux
tmux new -t plink
srun --partition defq --cpus-per-task 1 --mem 20g --time 06:00:00 --pty bash
module load BCFtools/1.19-GCC-13.2.0 
mkdir -p /gpfs01/home/mbzlld/data/danionella/popgen/bcftools
cd /gpfs01/home/mbzlld/data/danionella/popgen/bcftools
vcf=/gpfs01/home/mbzlld/data/danionella/popgen/variants/danionella_all_reads_Q30_DP10_GQ20_SNP_mis0.9.vcf.gz


# alternative counting every possible combination:
bcftools query \
    -f '[%GT\t]\n' $vcf |
awk '
{
    A=$1; B=$2; S=$3
    if (A=="./." || B=="./." || S=="./.") next

    gsub(/\|/,"/",A)
    gsub(/\|/,"/",B)
    gsub(/\|/,"/",S)

    if (A=="1/0") A="0/1"
    if (B=="1/0") B="0/1"
    if (S=="1/0") S="0/1"

    count[A"\t"B"\t"S]++
}
END{
    for (i in count)
        print i"\t"count[i]
}' | sort -k4,4nr


#  # result
# FishA   FishB   FishC     Count
#  0/1     0/0     0/0     612308
#  0/0     0/0     0/1     587788
#  1/1     0/1     1/1     447499
#  0/1     0/1     0/1     373479
#  0/1     0/0     0/1     370230
#  0/0     0/1     0/0     315756
#  1/1     0/1     0/1     250238
#  0/1     0/1     1/1     203482
#  0/1     0/1     0/0     196211
#  0/0     0/1     0/1     193636
#  0/1     0/0     1/1     122014
#  1/1     0/0     1/1     97349
#  1/1     0/0     0/1     96393
#  0/0     0/0     1/1     91674
#  1/1     0/1     0/0     66576
#  1/1     0/0     0/0     62578
#  0/0     0/1     1/1     51375
#  1/1     1/1     1/1     2699
#  0/1     1/1     1/1     278
#  1/1     1/1     0/1     179
#  0/1     1/1     0/1     120
#  1/1     1/1     0/0     86
#  0/1     1/1     0/0     48
#  0/0     1/1     0/0     25
#  0/0     1/1     1/1     14
#  0/0     1/1     0/1     8

#  # summarised count
#  Category	Count
#  All identical	376,178
#  FishA = FishB	1,079,420
#  FishA = SUP	1,230,979
#  FishB = SUP	1,119,052
#  All different	336,414


# even more cleanly summarised
#  comparison	matching_genotypes 	%_identical_genotypes
#  FishA=FishB	1,455,598	38.8%
#  FishA=FishC	1,607,157	36.1%
#  FishB=FishC	1,495,230	35.1%


bcftools query \
    -f '[%GT\t]\n' $vcf |
awk '
BEGIN{
    A_only=0
    B_only=0
    S_only=0
    AB=0
    AS=0
    BS=0
    ABS=0
    missing=0
}

{
    A=$1
    B=$2
    S=$3

    # Skip missing calls
    if (A=="./." || B=="./." || S=="./.") {
        missing++
        next
    }

    # Treat phased and unphased genotypes the same
    gsub(/\|/,"/",A)
    gsub(/\|/,"/",B)
    gsub(/\|/,"/",S)

    # Does each sample carry at least one ALT allele?
    a = (A!="0/0")
    b = (B!="0/0")
    s = (S!="0/0")

    if      ( a && !b && !s ) A_only++
    else if (!a &&  b && !s ) B_only++
    else if (!a && !b &&  s ) S_only++
    else if ( a &&  b && !s ) AB++
    else if ( a && !b &&  s ) AS++
    else if (!a &&  b &&  s ) BS++
    else if ( a &&  b &&  s ) ABS++
}

END{
    print "ALT only in FishA:\t\t" A_only
    print "ALT only in FishB:\t\t" B_only
    print "ALT only in SUP:\t\t" S_only
    print "ALT shared FishA+FishB:\t" AB
    print "ALT shared FishA+SUP:\t\t" AS
    print "ALT shared FishB+SUP:\t\t" BS
    print "ALT shared by all three:\t" ABS
    print "Missing:\t\t\t" missing
}'

# results
#ALT only in FishA:              674886
#ALT only in FishB:              315781
#ALT only in SUP:                679462
#ALT shared FishA+FishB: 262921
#ALT shared FishA+SUP:           685986
#ALT shared FishB+SUP:           245033
#ALT shared by all three:        1277974
#Missing:                        0


