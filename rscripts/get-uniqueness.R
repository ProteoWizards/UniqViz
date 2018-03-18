DATA_DIR <- Sys.getenv('DATA_DIR')

library(data.table)
library(jsonlite)
library(magrittr)

data <- unique(fread(paste(DATA_DIR, "radius_score.csv", sep='/'))[, goslim := NULL])
annTable <- fread(paste(DATA_DIR, "uniprot-filtered-organism%3A%22Homo+sapiens+%28Human%29+%5B9606%5D%22+AND+review--.tab", sep = "/"))
data <- data[!is.na(uniqueness)]
data$angle <- runif(n = nrow(data), min = 0, max = 2*pi)
data <- data[order(uniqueness)]

interesting_go <- c("GO:0005730", "GO:0008284",  "GO:0003700", "GO:0006915",  	"GO:0006364")
isGo <-sapply(interesting_go, function(x) grepl(x, annTable$`Gene ontology (GO)`))
isGo <- as.data.table(isGo)
isGo <- cbind(isGo, annTable$Entry)
names(isGo) <- c(interesting_go, "uniprot")
data <- merge(data, isGo, by = "uniprot")

stream_out(data, verbose=FALSE)

