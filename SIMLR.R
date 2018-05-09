library('SIMLR')

args = commandArgs(trailingOnly=TRUE)
filename <- args[1]
N <- as.numeric(args[2])
prop <- as.numeric(args[3])
i_minpop <- as.numeric(args[4])
rep <- args[5]
print(filename)
load(filename)
if(i_minpop!=0){
	cell_id <- c(1:length(observed_counts[[2]][,1]))
	others <- sample(size=N*(1-prop),x=cell_id[observed_counts[[2]][,2]!=i_minpop])
	minpop <- sample(size=N  * prop , x=cell_id[observed_counts[[2]][,2]==i_minpop])
	count <- observed_counts[[1]][,c(others,minpop)]
	label <- observed_counts[[2]][c(others,minpop),]
	write.table(count,file=paste(filename,'.N=',N,'.prop=',prop,'.pop=',i_minpop,'.rep',rep,'.count.txt',sep=''),quote=F, col.names=F, row.names=F)
	write.table(label,file=paste(filename,'.N=',N,'.prop=',prop,'.pop=',i_minpop,'.rep',rep,'.label.txt',sep=''),quote=F, col.names=F, row.names=F)	
}else{
	cell_id <- c(1:length(observed_counts[[2]][,1]))
	sampled <- sample(size=N , x=cell_id)
	count <- observed_counts[[1]][,sampled]
	label <- observed_counts[[2]][sampled,]
	write.table(count,file=paste(filename,'.N=',N,'.prop=',prop,'.pop=',i_minpop,'.rep',rep,'.count.txt',sep=''),quote=F, col.names=F, row.names=F)
	write.table(label,file=paste(filename,'.N=',N,'.prop=',prop,'.pop=',i_minpop,'.rep',rep,'.label.txt',sep=''),quote=F, col.names=F, row.names=F)	
}
count <- count[rowSums(count>0)>10,]
count <- t(t(count)/colSums(count))
count <- count *10^6
count <- apply(count,2,function(X){
        log(base=10,X+1)
})
result <- SIMLR_Large_Scale(X=count,c=5,k=30,kk=200)
save(result,file=paste(filename,'.N=',N,'.prop=',prop,'.pop=',i_minpop,'.rep',rep,'.SIMLR.robj',sep=''))
