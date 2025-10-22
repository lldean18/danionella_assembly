#!/bin/bash
# Laura Dean
# 21/10/25
# script written for running on the UoN HPC Ada


# create new tmux window
conda activate tmux
tmux new -s data_transfer


# in one Tmux window connect to a node with srun
srun --partition defq --cpus-per-task 1 --mem 50g --time 168:00:00 --pty bash



####################################
#### copy the pod5 files to Ada ####
####################################

### FISH A ###

# ic_207
rsync -rvh --progress \
mbzlld@10.157.200.14:/mnt/waterprom/ic_runs/ic_207/danionellaA_ULK114_recovered/20240801_1516_2G_PAW68934_b978428c/pod5 \
/gpfs01/home/mbzlld/data/danionella/pod5s/fish_A/ic_207/
# COMPLETED


# ic_208
rsync -rvh --progress \
mbzlld@10.157.200.14:/mnt/waterprom/ic_runs/ic_208/danionellaA_ULK114/20240805_1303_2G_PAW67982_1d1c1c5b/pod5 \
/gpfs01/home/mbzlld/data/danionella/pod5s/fish_A/ic_208/
# COMPLETED


### Fish B ###


# ic_206
rsync -rvh --progress \
mbzlld@10.157.200.14:/mnt/waterprom/ic_runs/ic_206/danionellaB_ULK114_recut/20240813_1227_1G_PAW67982_053b98a4/pod5 \
/gpfs01/home/mbzlld/data/danionella/pod5s/fish_B/ic_206/
# RUNNING




# ic_205 (duplex)
rsync -rvh --progress \
mbzlld@10.157.200.14:/mnt/waterprom/ic_runs/ic_205/danionellaB_duplex/20240724_1050_1G_PAU74023_daf962d9/pod5 \
/gpfs01/home/mbzlld/data/danionella/pod5s/fish_B/ic_205/duplex/

# ic_205 (duplex2)
rsync -rvh --progress \
mbzlld@10.157.200.14:/mnt/waterprom/ic_runs/ic_205/danionellaB_duplex2/20240725_1332_1G_PAU74023_69d9c428/pod5 \
/gpfs01/home/mbzlld/data/danionella/pod5s/fish_B/ic_205/duplex2/



