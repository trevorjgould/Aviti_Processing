args = commandArgs(trailingOnly=TRUE)
seqtab <- readRDS("seqtab.rds")
seqtab = t(seqtab)
sequences <- rownames(seqtab)
sequences <- as.data.frame(1:nrow(seqtab))
rownames(sequences) <- rownames(seqtab)
groupings = as.numeric(args[1])
sequences$Group = sample(groupings, size = nrow(sequences), replace = TRUE)
tablist <- split(sequences, sequences$Group)

df_list_no_id <- lapply(tablist, subset, select = -Group)
allNames <- names(df_list_no_id)
for(thisName in allNames){
    saveName = paste0(thisName, '.RDS')
    saveRDS(t(df_list_no_id[[thisName]]), file = saveName)
}

files <- list.files(pattern = "RDS")
for (i in files){
comlist <- paste0("Rscript /users/4/goul0109/Aviti_Documents/clustering/build_command_list.R ",i," 4")
lapply(comlist, write, "build_run_commands.cmd", append=TRUE)
}