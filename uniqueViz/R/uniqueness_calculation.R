library(data.table)
library(ggplot2)
#########################################
# Data input
#########################################

rootdir <- "~/code/biohack/"
setwd(rootdir)

homologues <- fread(paste0(rootdir,"data/homologues.txt"))
mapping <- fread(paste0(rootdir,"data/mapping_ens_uniprot_goslim.txt"))
goslim <- readRDS(paste0(rootdir, "data/GO_UNI.rda"))

# Merge homologues to annotations
joint_homologues <- merge(homologues, mapping, on = "Gene stable ID" ) # only 147 goterms in the mapping table

goslim <- apply(goslim, 1, function(x) data.table(goslim = x[1], uniprot = x[2][[1]]))
goslim <- do.call(rbind, goslim)
goslim$goslim <- as.character(goslim$goslim)
merged_mapping <- merge(goslim, mapping, by.x = "uniprot", by.y = "")

joint_homologues <- merge(homologues, goslim, on = "Gene stable ID" ) # only 147 goterms in the mapping table


# Overall distribution of similarity scores
hist(joint_homologues$`%id. query gene identical to target Chimpanzee gene`, breaks = 100)


#########################################
# Compute similarity score
#########################################
colums <- names(joint_homologues)
similarity_colums <- colums[grepl("\\%id\\.", colums)]

joint_homologues$uniqueness <- apply(joint_homologues[, similarity_colums, with = F], 1, max)
joint_homologues$uniqueness <- 1 - joint_homologues$uniqueness/100
hist(joint_homologues$uniqueness, breaks = 100)
ggplot(joint_homologues, aes(x = uniqueness)) +
  geom_histogram(binwidth = 0.01) +
  # scale_x_log10() +
  theme_classic()
ggsave("gene_uniqueness_distribution.pdf")

joint_homologues_clean <- subset(joint_homologues, select = c("Gene stable ID", "UniProtKB/Swiss-Prot ID", "GOSlim GOA Accession(s)", "uniqueness"))
names(joint_homologues_clean) <- c("ensg", "uniprot", "goslim", "uniqueness")
write.csv(joint_homologues_clean,  file = paste0(rootdir, "data/gene_uniqueness.csv"), quote = F, row.names = F)
go_uniqueness <- joint_homologues_clean[, .(uniquenessMean = mean(uniqueness, na.rm = T), uniquenessMax = max(uniqueness, na.rm = T)), by = goslim]
hist(go_uniqueness$uniquenessMean, breaks = 30)
hist(go_uniqueness$uniquenessMax, breaks = 30)
write.csv(go_uniqueness, file = paste0(rootdir, "data/go_uniqueness.csv"), quote = F, row.names = F)





