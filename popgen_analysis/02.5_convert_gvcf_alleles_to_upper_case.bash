#!/bin/bash
# Laura Dean
# 14/10/16

# script to convert gvcfs called against a reference with soft masking to upper case
# so they can be merged by glnexus


# setup compute resource
srun --partition defq --cpus-per-task 16 --mem 30g --time 12:00:00 --pty bash

# setup env
source $HOME/.bash_profile
module load bcftools-uoneasy/1.19-GCC-13.2.0
cd /gpfs01/home/mbzlld/data/danionella/popgen


# convert lower case variants to upper case
for file in variants/*/*.gvcf.gz; do
    [[ "$file" == *.uppercase.gvcf.gz ]] && continue

    out="${file%.gvcf.gz}.uppercase.gvcf.gz"
    echo "Processing $file"

    bcftools view -h "$file" > header.tmp

    bcftools view -H "$file" |
    awk 'BEGIN{OFS="\t"} {
        $4=toupper($4)
        n=split($5,a,",")
        for(i=1;i<=n;i++) {
            if(a[i] !~ /^<.*>$/ && a[i] != "*")
                a[i]=toupper(a[i])
        }
        $5=a[1]
        for(i=2;i<=n;i++) $5=$5 "," a[i]
        print
    }' > records.tmp

    cat header.tmp records.tmp |
        bgzip -c > "$out" || exit 1
    bcftools index -t "$out" || exit 1
    rm header.tmp records.tmp
done





