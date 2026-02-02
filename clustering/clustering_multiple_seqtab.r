library(dplyr)
# need to run "sort -h templistout.txt" numerically by first number
# Rscript output_asv.R 1.RDS 1.RDS_templistout.txt seqtab_nochim.rds 
args = commandArgs(trailingOnly=TRUE)
finalASVlista <- readLines(args[2])
finalASVlist <- strsplit(finalASVlista, " ")
ASVtab <- readRDS(args[1])
ASVtabfull <- readRDS(args[3])
ASVtab = as.data.frame(t(ASVtab))
ASVtabfull <- as.data.frame(t(ASVtabfull))
keep <- ASVtab[,1]
ASVtab <- ASVtabfull[keep,]

ASVtab2 = ASVtab
ASVtab2$asvgroup = 0

# starting at last item in list make all rows = group
endl <- length(finalASVlist)
# for each line in templistout
for (x in rev(seq_along(1:endl))) {
# get line
  these <- as.numeric(finalASVlist[[x]])
# for each item in list
  for (i in these){
  current <- ASVtab2[i, "asvgroup"]
  new = as.numeric(min(finalASVlist[[x]][1], current[current >0]))
  # this row switch to group (or stay same)
  ASVtab2[i,]$asvgroup <- new
  # any row in same group as this one should do same
  if(nrow(ASVtab2[ASVtab2$asvgroup == i,]>0)){
  ASVtab2[ASVtab2$asvgroup == i,]$asvgroup <- new
  }
  }
}

# split off rows that are not grouped
non_group <- subset(ASVtab2, asvgroup == 0)
yes_group <-  subset(ASVtab2, asvgroup != 0)

# grouped <- yes_group %>% group_by(asvgroup) %>% summarize_each(list(sum))
grouped <- yes_group %>% group_by(asvgroup) %>% summarize(across(where(is.numeric), sum), .groups = 'drop')

grouped <- as.data.frame(grouped)
for (x in 1:nrow(grouped)){
y = as.numeric(grouped[x,1])
row.names(grouped)[x] = row.names(ASVtab2[y,])
}

# recombine grouped and non-grouped asvs
grouped = grouped[,-c(1)]
end <- ncol(non_group)-1
non_group = non_group[,1:end]
both = rbind(grouped,non_group)

# save output
fname <- tools::file_path_sans_ext(args[1])
fname <- paste0(fname,"_merged_asvtable.txt")
write.table(both, file = fname, sep = "\t", quote = FALSE)
