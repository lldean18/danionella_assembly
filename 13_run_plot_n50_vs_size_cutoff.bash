#!/bin/bash

# setup screen and environment
conda activate tmux
tmux new -t danionella_plot
srun --partition defq --cpus-per-task 1 --mem 20g --time 2:00:00 --pty bash
conda activate python3.12


python ~/github/danionella_assembly/12_plot_n50_vs_size_cutoff.py ~/data/danionella/fish_B/hifiasm_asm1/ONTasm.bp.p_ctg.fasta -o ~/data/danionella/fish_B/hifiasm_asm1/ONTasm.bp.p_ctg_size_cutoff.png



