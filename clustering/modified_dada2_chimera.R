# modified the c code for chimera check in dada2 to allow minOneOffParentDistance without offbyone parents   
library(devtools)
load_all('/users/4/goul0109/dada2_V2/')

seqtab_clustered <- readRDS("seqtab_merged_asvtable.rds")
seqtab_clustered <- t(seqtab_clustered)
set.seed(1234)

seqtab.clustered.nochim <- removeBimeraDenovo(seqtab_clustered, method="pooled", allowOneOff=FALSE, minOneOffParentDistance=25, multithread=TRUE, verbose=TRUE)
saveRDS(seqtab.clustered.nochim, file = "denovochimera_fix25.rds")