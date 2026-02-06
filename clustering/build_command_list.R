seqtab <- readRDS("seqtab.rds")
seqtab = t(seqtab)
sequences <- rownames(seqtab)
sequences <- as.data.frame(1:nrow(seqtab))
rownames(sequences) <- rownames(seqtab)
sequences$Group = sample(10, size = nrow(sequences), replace = TRUE)
tablist <- split(sequences, sequences$Group)

df_list_no_id <- lapply(tablist, subset, select = -Group)
allNames <- names(df_list_no_id)
for(thisName in allNames){
    saveName = paste0(thisName, '.RDS')
    saveRDS(t(df_list_no_id[[thisName]]), file = saveName)
}

files <- list.files(".")
for (i in files){
comlist <- paste0("Rscript /Aviti_Documents/clustering/build_command_list.R ",i," 4")
lapply(comlist, write, "build_run_commands.cmd", append=TRUE)
}

#Rscript build_command_list.R seqtab_nochim.rds [integer errors allowed]
args = commandArgs(trailingOnly=TRUE)
ASVtab <- readRDS("seqtab.rds")
#ASVtab <- readRDS(args[1])
ASVtab = as.data.frame(t(ASVtab))
endnum = nrow(ASVtab)-1
# set default number of errors allowed
wrong = 4
#wrong = as.numeric(args[2])
for (i in (1:endnum)){
comlist <- paste0("Rscript clust_asv.R seqtab.rds ",i," ",wrong)
#comlist <- paste0("Rscript clust_asv.R ",args[1]," ",i," ",wrong)
lapply(comlist, write, "runcommands.cmd", append=TRUE)
}