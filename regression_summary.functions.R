library(cluster)
library('FNN')
library('fossil')
# library('ggplot2')
# library('reshape2')
library('ape')
library('proxy')
library('FastKNN')

#dir <- 'exp_5pop_regresssion_large/'
#setwd(dir)

cont_CQ <- function(space,true_dist){
  knnp <-  cont_KNNP(space,true_dist)
  dc <- dist_cor(space,true_dist)
  return(c(mean(knnp),dc))
}
Phyla5 <- function(plotting=F){
  # par(mfrow=c(2,2))
  phyla<-rtree(2)
  phyla <- compute.brlen(phyla,1)
  tip<-rtree(2)
  tip <- compute.brlen(phyla,1)
  phyla<-bind.tree(phyla,tip,1)
  # if(plotting==T){plot(phyla)}
  phyla<-bind.tree(phyla,tip,2)
  # if(plotting==T){plot(phyla)}
  phyla<-bind.tree(phyla,tip,2)
  # if(plotting==T){plot(phyla)}
  phyla <- compute.brlen(phyla,c(1,1,1,1,1,0.2,0.2,3))
  edges <- cbind(phyla$edge,phyla$edge.length)
  edges <- cbind(c(1:length(edges[,1])),edges)
  connections <- table(c(edges[,2],edges[,3]))
  root <- as.numeric(names(connections)[connections==2])
  tips <- as.numeric(names(connections)[connections==1])
  phyla$tip.label <- as.character(tips)
  if(plotting==T){
    plot(phyla,show.tip.label = F,lwd=2)
    tiplabels(cex=2)
    nodelabels(cex=2)
  }
  return(phyla)
}

pairwise_dist <- function(x,y){
  if(x[1]!=y[1]){
    mrca <- getMRCA(tree, c(x[1],y[1]))
    return( (x[3]+y[3])-dist[6,mrca]*2 )
  }else{return(abs(x[3]-y[3]))}
}


cont_KNNP <- function(space,true_dist){
  knn <- get.knn(space,k=50)[[1]]
  purity <- sapply(c(1:length(data[,1])),function(i){
    true <- k.nearest.neighbors(i, as.matrix(true_dist), k = 50)
    length(intersect(knn[i,],true))/50
  })
  return(purity)
}

dist_cor <- function(space,true_dist){
  euclidean <- c(dist(space))
  truth <- c(true_dist)
  return(cor(euclidean,truth,method='spearman'))
}


GetParams <- function(paramfile,prefix){
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
	ktrue <- sapply(strsplit(prefix,'ktrue'),function(X){X[2]})
	ktrue <- sapply(strsplit(ktrue,'_',fixed=T),function(X){X[1]})
	ktrue <- as.numeric(ktrue)
	load(paramfile)
	true = sim_params_true[ktrue,]
	obs = sim_params_obs[kobs,]
	params <- data.frame(N=N,prop=prop,min=minpop,ktrue=ktrue,kobs=kobs,true,obs)
	return(params)
}

ClusterQuality <- function(x,label,cluster){
	ri_all <- adj.rand.index(cluster,label)
	ri_pop <- sapply(sort(unique(label)),function(i){
		adj.rand.index(cluster,label==i)
	})
	ri <- c(ri_all,ri_pop)
	sw <- summary(silhouette(x=label, dist=dist(x, method = "euclidean")))
	sw_all <- sw$avg.width
	sw_pop <- sw$clus.avg.widths
	sw <- c(sw_all,sw_pop)
	knn_purity <- KNNP(x, label)
	kp_all <- mean(knn_purity,na.rm=T)
	kp_pop <- sapply(sort(unique(label)),function(i){
		mean(knn_purity[label==i],na.rm=T)
	})
	kp <- c(kp_all,kp_pop)
	return(rbind(ri,sw,kp))
}
KNNP <- function(data,label,mutual=T){
	knn <- get.knn(data,k=20)
	if(mutual==T){
		knn <- lapply(c(1:length(data[,1])),function(i){
			X = knn[[1]][i,]
			mut=sapply(X,function(x){
				i%in%knn[[1]][x,]
			})
			return(X[mut])
		})		
	}else{
		knn <- lapply(c(1:length(data[,1])),function(i){
			X = knn[[1]][i,]
			return(X)})
	}
	purity <- sapply(c(1:length(knn)),function(i){
		correct <- label[i]==label[knn[[i]]]
		return(sum(correct)/length(correct))
	})
	return(purity)
}
GetDataset <- function(clust_qual,params,minpop){
	avg_kp <- lapply(c(1:3),function(m){
		sapply(clust_qual,function(X){X[[m]][3,1]})
	})
	avg_sw <- lapply(c(1:3),function(m){
		sapply(clust_qual,function(X){X[[m]][2,1]})
	})
	avg_ri <- lapply(c(1:3),function(m){
		sapply(clust_qual,function(X){X[[m]][1,1]})
	})
	min_kp <- lapply(c(1:3),function(m){
		sapply(c(1:length(clust_qual)),function(i){
			X <- clust_qual[[i]]
			X[[m]][3,minpop+1]})
	})
	min_sw <- lapply(c(1:3),function(m){
		sapply(c(1:length(clust_qual)),function(i){
			X <- clust_qual[[i]]
			X[[m]][2,minpop+1]})
	})
	min_ri <- lapply(c(1:3),function(m){
		sapply(c(1:length(clust_qual)),function(i){
			X <- clust_qual[[i]]
			X[[m]][1,minpop+1]})
	})
	data <- data.frame(
		params,
		avg_pc_kp=avg_kp[[1]],avg_scvi_kp=avg_kp[[2]],avg_simlr_kp=avg_kp[[3]],
		avg_pc_ri=avg_ri[[1]],avg_scvi_ri=avg_ri[[2]],avg_simlr_ri=avg_ri[[3]],
		avg_pc_sw=avg_sw[[1]],avg_scvi_sw=avg_sw[[2]],avg_simlr_sw=avg_sw[[3]],
		min_pc_kp=min_kp[[1]],min_scvi_kp=min_kp[[2]],min_simlr_kp=min_kp[[3]],
		min_pc_ri=min_ri[[1]],min_scvi_ri=min_ri[[2]],min_simlr_ri=min_ri[[3]],
		min_pc_sw=min_sw[[1]],min_scvi_sw=min_sw[[2]],min_simlr_sw=min_sw[[3]]	)
	return(data)
}


FilterData <- function(filternames,filtervalue,clust_qual,params,yaxis,xaxis){
	filter=''
	id <- c(1:length(prefix))
	for(i in c(1:length(filternames))){
		id <- id[params[filternames[i]]==filtervalue[i]]
		prefix <- prefix[params[filternames[i]]==filtervalue[i]]
		params <- params[params[filternames[i]]==filtervalue[i],]
		filter <- paste(filter,'.',filternames[i],'=',filtervalue[i],sep='')
	}
	data <- GetDataset(clust_qual[id],params,filtervalue[filternames=='min'])
	allinfo <- data
	ydata <- data[,grep(yaxis,colnames(data))]
	k=c(1:length(data[1,]))[colnames(data)==xaxis]
	data <- data.frame(data[,k],ydata)
	colnames(data) <- c(xaxis,colnames(data)[2:length(data[1,])])
	return(list(allinfo,data))
}


Figure6 <- function(filternames,filtervalue,xaxis,yaxis){
	temp <- FilterData(filternames,filtervalue,clust_qual,params,yaxis,xaxis)
	data <- melt(temp[[2]],id.vars=xaxis)
	method <- sapply(strsplit(as.character(data[,2]),'_'),function(X){X[2]})
	measure <- sapply(strsplit(as.character(data[,2]),'_'),function(X){X[1]})
	data <- data.frame(data,method=as.factor(method),measure=as.factor(measure))
	colnames(data)[colnames(data)==xaxis] = 'x'
	ggplot(aes(x=x,y=value,colour=method,shape=measure),data=data)+
	geom_point()+geom_line(aes(colour=method,linetype=measure))+labs(x = xaxis)
}

PlotMultiReg <- function(multi.fit,ncoeffs){
	coeffs<- summary(multi.fit)[[4]][c(2:(1+ncoeffs)),]
	coeffs<- cbind(coeffs,coeffs[,1] - coeffs[,2])
	coeffs<- cbind(coeffs,coeffs[,1] + coeffs[,2])
	colnames(coeffs)<-c('estim','ste','t','p','lower','upper')
	plot_coeffs <- melt(coeffs[,c(1:6)])
	p<-ggplot(data=plot_coeffs[plot_coeffs$Var2=='estim',], aes(x=Var1, y=value,fill=Var1)) +
	  geom_bar(stat="identity") + 
	  geom_errorbar(aes(
	  	ymin=plot_coeffs[plot_coeffs$Var2=='lower',3],
	  	ymax=plot_coeffs[plot_coeffs$Var2=='upper',3]), 
	    width=.2,position=position_dodge(.9)) + 
	   theme(axis.text.x = element_text(angle = 45, hjust = 1),
	   	axis.title.x=element_blank(),
	   	axis.title.y=element_blank())+ 
	   guides(fill=FALSE)
	return(p)
}


FilterPrefix <- function(prefix,filternames,filtervalue){
	filter=''
	id <- c(1:length(prefix))
	for(i in c(1:length(filternames))){
		id <- id[params[filternames[i]]==filtervalue[i]]
		prefix <- prefix[params[filternames[i]]==filtervalue[i]]
		params <- params[params[filternames[i]]==filtervalue[i],]
		filter <- paste(filter,'.',filternames[i],'=',filtervalue[i],sep='')
	}
	return(list(prefix,params,filter))
}

FilterPrefix2 <- function(prefix,filternames,filtervalue){
	filter=''
	id <- c(1:length(prefix))
	for(i in c(1:length(filternames))){
		id <- id[params[filternames[i]][,1]%in%filtervalue[[i]]]
		prefix <- prefix[params[filternames[i]][,1]%in%filtervalue[[i]]]
		params <- params[params[filternames[i]][,1]%in%filtervalue[[i]],]
		filter <- paste(filter,'.',filternames[i],'=',filtervalue[i],sep='')
		filter <- gsub(' ','',filter)
	}
	return(list(prefix,params,filter))
}

