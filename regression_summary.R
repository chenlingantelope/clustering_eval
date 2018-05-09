args = commandArgs(trailingOnly=TRUE)
filename=args[1]
# filename="obs_counts_ktrue22"
source('regression_summary.functions.R')

files <- list.files()
files <- files[grep(filename,files)]
labelfiles <- files[grep('label',files)]
simlrfiles <- files[grep('SIMLR',files)]
scvifiles <- files[grep('latent',files)]
pcafiles <- files[grep('pca',files)]
#ktrue71 and ktrue24 lacks a few hundred run

prefix <- sapply(strsplit(pcafiles,'.count',fixed=T),function(X){X[1]})
N <- sapply(strsplit(prefix,'N='),function(X){X[2]})
N <- sapply(strsplit(N,'.',fixed=T),function(X){X[1]})
N <- as.numeric(N)
prop <- sapply(strsplit(prefix,'prop='),function(X){X[2]})
prop <- sapply(strsplit(prop,'.pop',fixed=T),function(X){X[1]})
prop <- as.numeric(prop)
minpop <- sapply(strsplit(prefix,'pop='),function(X){X[2]})
minpop <- sapply(strsplit(minpop,'.',fixed=T),function(X){X[1]})
minpop <- as.numeric(minpop)
minpop[minpop==4]=3
kobs <- sapply(strsplit(prefix,'kobs'),function(X){X[2]})
kobs <- sapply(strsplit(kobs,'.RData',fixed=T),function(X){X[1]})
kobs <- as.numeric(kobs)


lapply(prefix,function(pref){
	print(pref)
	label <- read.table(file=paste(pref,'.label.txt',sep=''))
	load(paste(pref,'.SIMLR.robj',sep=''))
	simlr_space <- result$ydata
	simlr_clust <- result$y$cluster
	load(paste(pref,'.count.txt.pca.robj',sep=''))
	data_pc <- count_pc[[5]][,c(1:30)]
	pc_clust <- kmeans(x=data_pc,centers=5)$cluster
	scvi_space <- read.csv(paste(pref,'.count.txt.latent.txt',sep=''),header=F)
	scvi_pc <- prcomp(scvi_space)$x
	scvi_clust <- kmeans(x=scvi_space,centers=5)$cluster
	plots <- lapply(list(simlr_space,scvi_pc,data_pc),function(X){
		data_plot <- data.frame(x=X[,1],y=X[,2],pop=label[,2])
		ggplot(data_plot,aes(x,y,colour=as.factor(pop)))+geom_point()
	})
	pc_qual <- ClusterQuality(data_pc,as.numeric(label[,2]),pc_clust)
	scvi_qual <- ClusterQuality(scvi_space,as.numeric(label[,2]),scvi_clust)
	simlr_qual <- ClusterQuality(simlr_space,as.numeric(label[,2]),simlr_clust)
	save(pc_qual,scvi_qual,simlr_qual,plots,file=paste(pref,'.CQ.robj',sep=''))
})
files <- list.files()
cqfiles <- files[grep('CQ',files)]
prefix <- sapply(strsplit(pcafiles,'.count',fixed=T),function(X){X[1]})
clust_qual <- lapply(prefix,function(pref){
	load(paste(pref,'.CQ.robj',sep=''))
	return(list(pc_qual,scvi_qual,simlr_qual))
})
save(prefix,clust_qual,N,prop,minpop,kobs,file=paste(filename,'.CQ.robj',sep=''))

