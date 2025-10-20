#!/bin/bash
# Laura Dean
# 20/10/25
# for running on Ada

#SBATCH --partition=ampereq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --gres=gpu:2
#SBATCH --mem=747g
#SBATCH --time=167:00:00
#SBATCH --job-name=herro_pt3
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out

# load your bash environment for using conda
source $HOME/.bash_profile


# set variables
raw_fastq=/gpfs01/home/mbzlld/data/OrgOne/sumatran_tiger/basecalls/all_simplex_simplex.fastq.gz



echo "These are the CUDA_VISIBLE_DEVICES: $CUDA_VISIBLE_DEVICES
"

# load singularity
module load singularity/3.8.5
# run herro
# this bit will need the GPU partition
# herro inference --read-alns <directory_alignment_batches> -t <feat_gen_threads_per_device> -d <gpus> -m <model_path> -b <batch_size> <preprocessed_reads> <fasta_output>
# -b (batch size) Recommended batch size is 64 for GPUs with 40 GB (possibly also for 32 GB) of VRAM and 128 for GPUs with 80 GB of VRAM.
# -t number of threads per GPU card
# -d names of the GPUs
singularity run \
--nv \
--bind ${raw_fastq%/*}:${raw_fastq%/*} \
/gpfs01/home/mbzlld/software_bin/herro/herro.sif inference \
--read-alns ${raw_fastq%.*.*}_preprocessed_batches \
-t 16 \
-d $CUDA_VISIBLE_DEVICES \
-m /gpfs01/home/mbzlld/software_bin/herro/model_v0.1.pt \
-b 256 \
${raw_fastq%.*.*}_preprocessed.fastq.gz ${raw_fastq%.*.*}_herro_corrected.fa.gz



# herro outputs a fasta file. Use this file as input into first SLURM_STEP_GPUS
# step of hifiasm.
