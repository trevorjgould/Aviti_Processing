#!/bin/bash -l
#SBATCH --time=12:00:00
#SBATCH --ntasks=128
#SBATCH --nodes=1
#SBATCH --mem=200gb
#SBATCH --tmp=200gb
#SBATCH --account=umii
#SBATCH --mail-type=ALL
#SBATCH --mail-user=goul0109@umn.edu
#SBATCH --array=1-5

# Move to your working directory
cd /scratch.global/goul0109/Kantarci/dada2output/split_tabs/split_output/

# Load necessary modules
module load R/4.4.0-openblas-rocky8
module load parallel

# Execute the commands for the specific array index
# The $SLURM_ARRAY_TASK_ID will be 1, 2, 3, 4, or 5
parallel --jobs 127 < ${SLURM_ARRAY_TASK_ID}.RDS_runcommands.cmd