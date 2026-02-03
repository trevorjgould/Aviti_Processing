# Aviti_Publication
 Documentation for Aviti Publication

Processing of Aviti data for this publication starts 
with a seqtab.rds table typically output from DADA2

This will likely only work on a decent sized supercomputer node as it takes advantage of 
parallelization modules. 

run_clustering_multiple.sh 
or 
run_clustering_single.sh

are the shell script for calling the rest of the pileline. 
multiple breaks up larger ASV tables (500,000 unique ASVs) 
into 10 separate files and runs clustering with the intention 
of then running single with the output of multiple.

I'm including the dada2_chimera.cpp file for modifying dada2 but 
hopefully dada2 devs will consider that change as an option 
instead of manually modifying the script. 
