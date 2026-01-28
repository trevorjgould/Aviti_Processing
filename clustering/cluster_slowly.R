#Rscript cluster_slowly.R seqtab.rds [integer diffs allowed]
args = commandArgs(trailingOnly=TRUE)
# asv table
ASVtab <- readRDS(args[1])
ASVtab = as.data.frame(t(ASVtab))
# number of differences allowed
wrong = as.numeric(args[2])

# setup alignment
mat <- pwalign::nucleotideSubstitutionMatrix(match = 1, mismatch = -3, baseOnly = TRUE)
# function for the parallel loop
getalignrow <- function(x){
  ref_seq = row.names(ASVtab[x,])
  start = x+1
  query <- row.names(ASVtab[start:nrow(ASVtab),])
  #out <- pairwiseAlignment(query, ref_seq, substitutionMatrix = mat, type = "global", gapOpening = 5, gapExtension = 2, scoreOnly=TRUE)
  out <- pwalign::pairwiseAlignment(query, ref_seq, substitutionMatrix = mat, type = "global", gapOpening = 5, gapExtension = 2, scoreOnly=TRUE)
  subASV = ASVtab
  subASV$score = 0
  subASV[start:nrow(ASVtab),]$score = out

  max_score = nchar(row.names(ASVtab[1,]))
  min_score = nchar(row.names(ASVtab[1,])) - (4 * wrong)
  
  subASV$rownumber =1:nrow(subASV)
  
  subASV = subset(subASV, subASV$score >= min_score)
  c <- row.names(subASV[1])
  d=wrong+1
  d <- stringdist::stringdist(ref_seq, c, method = "lv")
  print(x)
  if (d[1]<=wrong){
    mergerows <- c(x,subASV$rownumber)
    mergerows <- t(mergerows)
   return(mergerows)
  }
}

# Run 
endnum = nrow(ASVtab)-1
commands <- 1:endnum
i <- 1

while (i <= length(commands)) {
  current_cmd <- commands[i]
  
  alignlist <- getalignrow(i)
  write.table(alignlist, "templistout.txt", append=TRUE, row.names = FALSE, col.names = FALSE)
  commands <- commands[!(commands %in% alignlist)]
  
  i <- i + 1
}