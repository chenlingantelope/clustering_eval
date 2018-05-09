#!/bin/bash
#PBS  -N contCQID
#PBS -q yosef2

cd /data/yosef2/scratch/chenling/clustering_eval/
f='FILENAME'
Rscript continuous_clustering_summary_save.R $f

