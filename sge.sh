#!/bin/bash
#PBS  -N regressionID
#PBS -q yosef2

cd /data/yosef2/scratch/chenling/clustering_eval

f='FILENAME'
Rscript SIMLR.R $f NTOTAL PROP POP REP 
count=$f.N=NTOTAL.prop=PROP.pop=POP.repREP.count.txt
label=$f.N=NTOTAL.prop=PROP.pop=POP.repREP.label.txt
Rscript PCA.R $count 
python SCVI.py $count $label
