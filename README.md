# danionella_assembly

Scripts for assembling and annotating the danionella genome.

Data are in: /share/deepseq/matt/danionella
(turns out this location didn't contain all of the pod5 files)
ALL raw Data (pod5s) are in: waterprom 

ic_205 and ic_206 are fish B, ic_207 and ic_208 are fish A

ic_205 are duplex runs.

All of the simplex runs are with the UL protocol

So far the best assembly seems to be for fish B with all simplex reads (including those extracted from the duplex runs) directly input into hifiasm 0.25.0 in ONT mode

