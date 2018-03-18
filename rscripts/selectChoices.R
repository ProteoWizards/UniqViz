# library(data.table)
library(jsonlite)

args = commandArgs(trailingOnly=TRUE)
# print(args[1])
# Import data
DATA_DIR <- Sys.getenv('DATA_DIR')
data <- readRDS(paste(DATA_DIR, "FuncionalCategoryChoices.rda", sep='/'))
# AnnDt <- fread(paste(DATA_DIR, "uniprot-filtered-organism%3A%22Homo+sapiens+%28Human%29+%5B9606%5D%22+AND+review--.tab", sep='/'))
funcAnnCategory <- args[1]

funcAnnChoices <- data.frame(choices =data[[funcAnnCategory]])
stream_out(funcAnnChoices, verbose=FALSE)
