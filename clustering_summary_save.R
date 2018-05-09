args = commandArgs(trailingOnly=TRUE)
pref = args[1]

#setwd('/data/yosef2/users/chenling/scRNASeq-simulation/pipe_scVI/')
source('regression_summary.functions.R')
label <- read.table(file=paste(pref,'.label.txt',sep=''))
load(paste(pref,'.SIMLR.robj',sep=''))
simlr_space <- result$F
simlr_clust <- result$y$cluster
load(paste(pref,'.count.txt.pca.robj',sep=''))
data_pc <- count_pc[[5]][,c(1:30)]
pc_clust <- kmeans(x=data_pc,centers=5)$cluster
scvi_space <- read.csv(paste(pref,'.count.txt.latent.txt',sep=''),header=F)
scvi_pc <- prcomp(scvi_space)$x
scvi_clust <- kmeans(x=scvi_space,centers=5)$cluster
# plots <- lapply(list(simlr_space,scvi_pc,data_pc),function(X){
# 	data_plot <- data.frame(x=X[,1],y=X[,2],pop=label[,2])
# 	ggplot(data_plot,aes(x,y,colour=as.factor(pop)))+geom_point()
# })
pc_qual <- ClusterQuality(data_pc,as.numeric(label[,2]),pc_clust)
scvi_qual <- ClusterQuality(scvi_space,as.numeric(label[,2]),scvi_clust)
simlr_qual <- ClusterQuality(simlr_space,as.numeric(label[,2]),simlr_clust)
# save(pc_qual,scvi_qual,simlr_qual,plots,file=paste(pref,'.CQ.robj',sep=''))
save(pc_qual,scvi_qual,simlr_qual,file=paste(pref,'.CQ.robj',sep=''))

