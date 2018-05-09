args = commandArgs(trailingOnly=TRUE)
pref = args[1]

#setwd('/data/yosef2/users/chenling/scRNASeq-simulation/pipe_scVI/')
source('regression_summary.functions.R')
label <- read.table(file=paste(pref,'.label.txt',sep=''))
load(paste(pref,'.SIMLR.robj',sep=''))
simlr_clust <- result$y$cluster
load(paste(pref,'.count.txt.pca.robj',sep=''))
data_pc <- count_pc[[5]][,c(1:30)]
pc_clust <- kmeans(x=data_pc,centers=5)$cluster
scvi_space <- read.csv(paste(pref,'.count.txt.latent.txt',sep=''),header=F)
scvi_clust <- kmeans(x=scvi_space,centers=5)$cluster
minpop = as.numeric(strsplit(strsplit(pref,'pop=')[[1]][2],'.',fixed=T)[[1]][1])

save(label,pc_clust,scvi_clust,simlr_clust,minpop,file=paste(pref,'.CR.robj',sep=''))
