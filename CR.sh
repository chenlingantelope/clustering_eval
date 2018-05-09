#!/bin/bash
#PBS  -N CQID
#PBS -q yosef2

cd /data/yosef2/scratch/chenling/clustering_eval/
f='FILENAME'
Rscript clustering_results.R $f

