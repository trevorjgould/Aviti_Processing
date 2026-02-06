#!/bin/bash -l
#SBATCH --time=4:00:00
#SBATCH --ntasks=8
#SBATCH --mem=100gb
#SBATCH --tmp=200gb
#SBATCH --mail-type=ALL

cd directory
module load R/4.4.0-openblas-rocky8
module load parallel

Rscript build_command_list.R seqtab.rds 2
# Rscript clust_asv.R test_seqtab.rds
parallel < runcommands.cmd
sort -h templistout.txt > templistout.txt
Rscript output_asv.R seqtab.rds