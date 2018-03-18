library(igraph)
library(visNetwork)

df <- read.delim('9606.protein.links.full.v10.5.txt', header=TRUE, sep=' ')
coexpr <- df[df$coexpression != 0]
coexpr <- coexpr[,c("protein1", "protein2", "coexpression")]

coexpr700 <- coexpr[coexpr$coexpression >= 700,]
nodes <- data.frame(id=unique(coexpr700$protein1))
nodes <- cbind(nodes, color="orange") # example just to show how to change color, assuming #ff0000 works too..

g <- graph_from_data_frame(coexpr[coexpr$coexpression >= 700,], vertices=nodes)

# vis <- visNetwork(nodes, coexpr700)

# force driected layout, use it with layout=lay
# lay = layout_with_fr(g)

# show it, opens browser:
# layout='layout_with_circle', for example
visIgraph(g)
# vis
