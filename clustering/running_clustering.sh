#!/bin/bash -l
#SBATCH --time=4:00:00
#SBATCH --ntasks=8
#SBATCH --mem=100gb
#SBATCH --tmp=200gb
#SBATCH --account=umii
#SBATCH --mail-type=ALL
#SBATCH --mail-user=goul0109@umn.edu

cd /scratch.global/goul0109/
module load R/4.4.0-openblas-rocky8
module load parallel

Rscript /users/4/goul0109/scripts/build_command_list.R seqtab.rds 2
# Rscript clust_asv.R test_seqtab.rds
parallel < runcommands.cmd
sort -h templistout.txt > templistout.txt
Rscript /users/4/goul0109/scripts/output_asv.R seqtab.rds 
