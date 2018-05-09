args = commandArgs(trailingOnly=TRUE)
pref = args[1]

source('regression_summary.functions.R')
label <- read.table(file=paste(pref,'.label.txt',sep=''))
randsample <- sample(c(1:length(label[,1])), length(label[,1])/10)
label <- label[randsample,]
load(paste(pref,'.SIMLR.robj',sep=''))
simlr_space <- result$F[randsample,]
load(paste(pref,'.count.txt.pca.robj',sep=''))
data_pc <- count_pc[[5]][randsample,c(1:30)]
scvi_space <- read.csv(paste(pref,'.count.txt.latent.txt',sep=''),header=F)
scvi_space <- scvi_space[randsample,]

tree <- Phyla5()
dist = dist.nodes(tree)
temp = strsplit(as.character(label[,2]),'_')
tips <- sapply(temp,function(X){as.numeric(X[2])})
pars <- sapply(temp,function(X){as.numeric(X[1])})
depth <- label[,3]
data <- cbind(tips,pars,depth)
true_dist <- proxy::dist(data, method=pairwise_dist )

pc_qual <- cont_CQ(data_pc,true_dist)
scvi_qual <- cont_CQ(scvi_space,true_dist)
simlr_qual <- cont_CQ(simlr_space,true_dist)
save(pc_qual,scvi_qual,simlr_qual,file=paste(pref,'.CQ.robj',sep=''))






