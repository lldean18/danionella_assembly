#!/bin/bash
# 24/7/26

# script to call variants from ONT data

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=96
#SBATCH --mem=361g
#SBATCH --time=90:00:00
#SBATCH --job-name=Clair3_variant_call
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out
#SBATCH --array=1-3

# setup config
CONFIG=~/code_and_scripts/config_files/danionella_inds_config.txt
ind=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $CONFIG)

echo "slurm array = $SLURM_ARRAY_TASK_ID
calling variants for sample = $ind
"


# setup env
source $HOME/.bash_profile
#########
# install the latest version to fix invalid gvcf output when no variants detected
#conda create -n clair3_2.0.2 -c conda-forge -c bioconda -y clair3
conda activate clair3_2.0.2
#########
#conda activate clair3
CLAIR3_PATH=/gpfs01/home/mbzlld/software_bin/Clair3
MODEL_NAME=r1041_e82_400bps_sup_v500
#dna_r10.4.1_e8.2_400bps_sup@v5.2.0
cd /gpfs01/home/mbzlld/data/danionella/popgen
mkdir -p variants
reference=/share/deepseq/shenson/ds1664_Wilkinson/03_medaka/consensus.fasta



# run clair3 to call variants for each ind
#python3 ${CLAIR3_PATH}/run_clair3.py \
run_clair3.sh \
  --bam_fn=downsampling/${ind}_TO_consensus_flt.bam \
  --ref_fn=$reference \
  --threads=48 \
  --platform="ont" \
  --model_path="${CLAIR3_PATH}/models/${MODEL_NAME}" \
  --output=variants/${ind} \
  --include_all_ctgs \
  --output_all_contigs_in_gvcf_header \
  --sample_name=${ind} \
  --gvcf

# rename the output files to contain the ind name as GLNexus requires this in the joint genotyping step
mv variants/${ind}/merge_output.gvcf.gz variants/${ind}/merge_output_${ind}.gvcf.gz
mv variants/${ind}/merge_output.gvcf.gz.tbi variants/${ind}/merge_output_${ind}.gvcf.gz.tbi


# cleanup env
conda deactivate

