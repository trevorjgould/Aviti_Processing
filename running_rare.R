rarefyTable <- function(newtable){
    min(rowSums(newtable))
    graphics::hist(rowSums(newtable))
    sampler = 159596
    scount <- as.data.frame(rowSums(newtable))
    print(paste("lowest sample size is: ", sampler))
    if (sampler < 1000){
        print("Setting rarefaction threshold to: 1000")
        # set minimum sequences per sample
        keepers <- rowSums(newtable)>1000
        newtable <- newtable[keepers,]
        sampler = 1000
        scount$col <- cut(scount$scount, breaks = c(-Inf,1000,Inf), labels = c("<1000",">1000"))
        ggplot2::ggplot(scount, ggplot2::aes(x = scount)) + ggplot2::geom_dotplot(binwidth = 1000, ggplot2::aes(fill = col)) + ggplot2::geom_vline(xintercept = 1000, color = "red") + ggplot2::ylab("Samples") + ggplot2::xlab("Sequences") + ggplot2::scale_fill_manual(values = c("red","black"))
    } else {
        print(paste("Setting rarefaction threshold to: ", sampler))
    }
    
    # then we rarefy the datatable at chosen sample size
    rarefyAt <- function(newtable,sampler){
        # we want to do rrarefy 1000 times and get the average   
        # lets try with 10 first
        res <- lapply(as.list(1:10), function(x) vegan::rrarefy(newtable, sample=sampler))
        FULL <- plyr::aaply(plyr::laply(res, as.matrix), c(2, 3), mean)
        rm(res)
        return(FULL)
    }
    out <- rarefyAt(newtable,sampler)
    filename1 = paste0("rarified_",sampler,".txt")
    write.table(out, file = filename1, sep = "\t", quote = FALSE)
    # now we're going to compare the 1000 times rarefied table to the original run via clr transform
    propdistout <- sweep(out, 1, rowSums(out),'/')
    # distance:
    d2.mes <- vegan::vegdist(propdistout, method = "bray")
    PCOA <- stats::cmdscale(d2.mes, k = 3, eig = TRUE)
    # from diversity.R get brayWmeta
    brayWmeta$PC3pcoa <- PCOA$points[,3]
    brayWmeta$PC2pcoa <- PCOA$points[,2]
    brayWmeta$PC1pcoa <- PCOA$points[,1]
    ###################
    round(PCOA$eig*100/sum(PCOA$eig),2)
    utils::write.table(brayWmeta, file="proportional_diversity_stats.txt", quote = FALSE)
    outlist <- list("brayWmeta"=brayWmeta,"PCOA" = PCOA, "d2.mes" = d2.mes)
    return(outlist)
}

library(dada2analysis)
metadata <- read.csv("/scratch.global/goul0109/johnson/december/abbyj_december_dada2output_backup/metadata.txt", sep="")
inputtable <- readRDS("denovochimera_fix25.rds")
taxa <- readRDS("taxaIDsilva_25parent.rds")
outtab <- Create_Tables(inputtable, metadata, taxa)
brayWmeta <- diversity(outtab$newmap,outtab$newtable)
outlist <- rarefyTable(outtab$newtable)

# list object to single objects
PCOA <- outlist$PCOA
brayWmeta <- outlist$brayWmeta
ds.mes <- outlist$ds.mes
combined_taxa <-  outtab$combined_taxa

# diversity plots
Diversity_Plots(brayWmeta, outtab$newmap)

# taxonomy tables
taxaout <- Make_Taxa_Tables(combined_taxa)

#taxonomy plots
Create_Taxonomy_Plot(taxaout$Phylum,2,outtab$newmap)
Create_Taxonomy_Plot(taxaout$Class,10,outtab$newmap)
Create_Taxonomy_Plot(taxaout$Order,10,outtab$newmap)
Create_Taxonomy_Plot(taxaout$Family,10,outtab$newmap)
Create_Taxonomy_Plot(taxaout$Genus,10,outtab$newmap)
Create_Taxonomy_Plot(taxaout$Species,10,outtab$newmap)

