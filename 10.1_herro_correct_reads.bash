#!/bin/bash
# Laura Dean
# 20/10/25
# for running on Ada
# had to run this bit on the hmemq with 1495g mem 20 cores & 20 hours

#SBATCH --partition=hmemq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=1495g
#SBATCH --time=24:00:00
#SBATCH --job-name=herro_pt1
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out

# load your bash environment for using conda
source $HOME/.bash_profile

# download & install software
# # clone the git repository
# cd ~/software_bin
# git clone https://github.com/dominikstanojevic/herro.git
# # move to cloned git repository
# cd ~/software_bin/herro
# # activate conda env created with yaml file
# #conda env create --file scripts/herro-env.yml
# conda activate herro
# # download the singularity image
# wget http://complex.zesoi.fer.hr/data/downloads/herro.sif
# # load singularity
#module load singularity/3.8.5
# # build singularity image
# #singularity build herro.sif herro-singularity.def # this wouldn't work
# # download the model
# wget http://complex.zesoi.fer.hr/data/downloads/model_v0.1.pt

# set variables
raw_fastq=/gpfs01/home/mbzlld/data/OrgOne/sumatran_tiger/basecalls/FishA_ALL_simplex.fastq.gz

# preprocess reads input fastq, output prefix, number of threads, number of parts to split job into (if low mem)
/gpfs01/home/mbzlld/software_bin/herro/scripts/preprocess.sh $raw_fastq ${raw_fastq%.*.*}_preprocessed 20 1
# the command before this used one core
# pigz used all 20 cores at max cpu and ~500GB memory
# duplex_tools only used 1 core and ~30GB memory



