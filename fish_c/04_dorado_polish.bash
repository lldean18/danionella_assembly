#!/bin/bash
# 29/6/26

# script to polish the danionella fish c assembly with dorado polish

#SBATCH --job-name=dorado_polish
#SBATCH --partition=ampereq
#SBATCH --gres=gpu:A100-full:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=50
#SBATCH --mem=300g
#SBATCH --time=100:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


# setup env
source $HOME/.bash_profile
module load cuda-12.2.2
conda activate samtools1.22
mkdir -p /gpfs01/home/mbzlld/data/danionella/fish_c/dorado_polish
cd /gpfs01/home/mbzlld/data/danionella/fish_c/dorado_polish
assembly=/gpfs01/home/mbzlld/data/danionella/fish_c/hifiasm_1/fish_c.bp.p_ctg.fasta
#assembly=/gpfs01/home/mbzlld/data/danionella/fish_c/hifiasm_1/fish_c.bp.hap2.p_ctg.fasta
reads=/gpfs01/home/mbzlld/data/danionella/fish_c/basecalls/SUP_fish_c.bam

##  # Align reads to a reference using dorado aligner, sort and index
##  dorado aligner $assembly $reads |
##  samtools sort --threads 48 > $(basename ${assembly%.*})_mapped_reads.bam
##  samtools index $(basename ${assembly%.*})_mapped_reads.bam

# troubleshooting
echo "output of scontrol:"
scontrol show job $SLURM_JOB_ID
echo "output of nvidia-smi -L:"
nvidia-smi -L
echo "output of nvidia-smi:"
nvidia-smi

# polish the draft assembly
dorado polish \
--threads 48 \
--device cuda:all \
--RG dc9366d5-cb17-4754-8820-490bff64f548_dna_r10.4.1_e8.2_400bps_sup@v5.2.0 \
$(basename ${assembly%.*})_mapped_reads.bam \
$assembly > $(basename ${assembly%.*})_polished.fasta



# cleanup env
module unload cuda-12.2.2
conda deactivate


