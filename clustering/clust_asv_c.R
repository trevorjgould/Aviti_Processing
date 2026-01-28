library(Rcpp)
sourceCpp("/users/4/goul0109/Aviti_Documents/needleman.cpp")
# Rscript clust_asv.R seqtab_nochim.rds 
args = commandArgs(trailingOnly=TRUE)
#
ASVtab <- readRDS(args[1])
ASVtab = as.data.frame(t(ASVtab))

# set default number of errors allowed
wrong = as.numeric(args[3])

getalignrow <- function(x){
  ref_seq <- row.names(ASVtab)[x]
  start <- x + 1
  if (start > nrow(ASVtab)) return(NULL)
  
  query_seqs <- row.names(ASVtab)[start:nrow(ASVtab)]
  
  # 1. Get alignment scores
  out <- nw_align_score(query_seqs, ref_seq)
  
  # 2. Filter candidates
  max_score <- nchar(ref_seq)
  min_score <- max_score - (4 * wrong)
  
  # Logical index of rows that pass the score threshold
  pass_idx <- which(out >= min_score)
  
  if (length(pass_idx) > 0) {
    # Get the actual sequences that passed
    candidate_seqs <- query_seqs[pass_idx]
    
    # 3. Get Levenshtein distance for the FIRST candidate (matching your logic)
    # We use [1] to ensure it's a single string for the C++ 'ref' argument
    d <- cpp_levenshtein_vec(candidate_seqs[1], ref_seq)
    
    if (d[1] <= wrong) {
      # Return the original row index x and the row indices of the filtered matches
      mergerows <- t(c(x, (start:nrow(ASVtab))[pass_idx]))
      return(mergerows)
    }
  }
  return(NULL)
}

i = as.numeric(args[2])
alignlist <- getalignrow(i)

write.table(alignlist, "templistout.txt", append=TRUE, row.names = FALSE, col.names = FALSE)