#!/bin/bash -l
#SBATCH --time=24:00:00
#SBATCH --ntasks=128
#SBATCH --mem=100gb
#SBATCH --tmp=300gb
#SBATCH --account=umii
#SBATCH --mail-type=ALL
#SBATCH --mail-user=goul0109@umn.edu

cd /scratch.global/goul0109/Kantarci/dada2output/split_tabs/
module load R/4.4.0-openblas-rocky8
module load parallel

Rscript build_command_list_list.R

./build_run_commands.cmd
chmod +x runcommands.cmd 
parallel < runcommands.cmd

for file in *RDS_templistout.txt; do 
    echo "Processing $file"
    sort -h "$file" > "$file.tmp" && mv "$file.tmp" "$file"
done

rm run_clustout.cmd
for file in *.RDS; do echo "Rscript clustering_multiple_seqtab.r $file ${file//RDS/RDS_templistout.txt} seqtab.rds" >> run_clustout.cmd; done
chmod +x run_clustout.cmd
parallel < run_clustout.cmd

awk 'FNR>1 || NR==1' {1..10}_merged_asvtable.txt > all_merged_asvtables.txt