
srun --partition defq --cpus-per-task 1 --mem 50g --time 08:00:00 --pty bash



awk '/^S/{print ">"$2;print $3}' sup_asm.bp.p_ctg.gfa > sup_asm.bp.p_ctg.fasta

awk '/^S/{print ">"$2;print $3}' ic_206_duplex_asm.bp.p_ctg.gfa > ic_206_duplex_asm.bp.p_ctg.fasta

awk '/^S/{print ">"$2;print $3}' ic_206_asm.bp.p_ctg.gfa > ic_206_asm.bp.p_ctg.fasta


