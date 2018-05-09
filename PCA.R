args = commandArgs(trailingOnly=TRUE)
filename=args[1]
count <- read.table(filename,header=F,as.is=T)
count <- count[rowSums(count>0)>10,]
count <- t(t(count)/colSums(count))
count <- count *10^6
count <- apply(count,2,function(X){
        log(base=10,X+1)
})
uniqcols<-c(1:length(count[1,]))[!duplicated(t(count))]
count <- count[,uniqcols]
uniqrows<-c(1:length(count[,1]))[!duplicated(count)]
count <- count[uniqrows,]
count_pc <- prcomp(t(count))
save(count_pc, uniqcols,file=paste(filename,'.pca.robj',sep=''))
