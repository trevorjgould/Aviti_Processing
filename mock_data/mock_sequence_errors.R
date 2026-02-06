library(Biostrings)

# table of counts by samples
# first and second column are mock sample counts
# third column is a sum of all real sample counts

mock2 <- read.delim("mock_sample.txt")
# one line per reference sequence file
reference <- read.delim("reference.txt")

# Calculate distances to each target sequence and add as new columns
mock3 = mock2
t=3
for (i in 1:nrow(reference)) {
  target <- reference[i,2]
  colid = i + t
  mock3[,colid] <- stringdist::stringdist(rownames(mock2), target, method = "lv")
}

# Function to align and extract changes
get_mutations <- function(query, ref_seq) {
  aln <- pairwiseAlignment(query, ref_seq, type = "global", gapOpening = 5, gapExtension = 2)
  aligned_query <- as.character(pattern(aln))
  aligned_ref <- as.character(subject(aln))
  
  q_split <- strsplit(aligned_query, "")[[1]]
  r_split <- strsplit(aligned_ref, "")[[1]]
  
  mismatches <- which(q_split != r_split)
  if (length(mismatches) == 0) return(NULL)
  
  data.frame(
    RefSeq = as.character(ref_seq),
    QuerySeq = as.character(query),
    Position = mismatches,
    RefBase = r_split[mismatches],
    QueryBase = q_split[mismatches],
    ChangeType = ifelse(
      r_split[mismatches] == "-",
      "Insertion",
      ifelse(q_split[mismatches] == "-", "Deletion", "Substitution")
    ),
    stringsAsFactors = FALSE
  )
}

getall <- function(x){
  queries <- DNAStringSet(rownames(df[df[,x] >= 1 & df[,x] <= 2, ]))
  ref <- DNAStringSet(rownames(df[df[,x] == 0,]))
  
  # Apply to each query
  results <- lapply(queries, get_mutations, ref_seq = ref)
  
  # Combine into a single data frame
  mutations_df <- do.call(rbind, results)
  print(mutations_df)
}
# input dataframe
df=mock3
# set numbers to columns that are distances
outlist <- lapply(4:23,getall)

all_changes <- as.data.frame(do.call(rbind, outlist))
all_changes$x2x = paste0(all_changes$RefBase,"-",all_changes$QueryBase)
table(all_changes$x2x)
#
