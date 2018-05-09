#################################################
# Running with figure 4 parameters
#################################################
cd /data/yosef2/scratch/chenling/clustering_eval
id=0
for i in {1..4}
do
for j in {1..7}
do
for minpop in 1 2 4
do 
for prop in 0.01 0.03 0.05 0.1 0.2
do
for N in 1000 2000 4000 6000 8000
do 
rep=1
id=$((id+1))
if [ ! -e exp_regression5pop_figure4params/obs_counts_ktrue$i\_kobs$j.RData.N=$N.prop=$prop.pop=$minpop.rep$rep.SIMLR.robj ]; then
    echo "exp_regression5pop_figure4params/obs_counts_ktrue$i\_kobs$j.RData.N=$N.prop=$prop.pop=$minpop.rep$rep not found"
    echo $id
    cp sge.sh sge.$id.sh
    sed -i "s/FILENAME/exp_regression5pop_figure4params\/obs_counts_ktrue$i\_kobs$j.RData/" sge.$id.sh
    sed -i "s/NTOTAL/$N/g" sge.$id.sh
    sed -i "s/PROP/$prop/g" sge.$id.sh
    sed -i "s/POP/$minpop/g" sge.$id.sh
    sed -i "s/REP/$rep/g" sge.$id.sh
    sed -i "s/ID/$id/g" sge.$id.sh
    if [ "$id" -gt 0 ];then qsub sge.$id.sh;fi 
    rm sge.$id.sh
fi
done
done
done
done
done



cd /data/yosef2/scratch/chenling/clustering_eval

id=0
for i in {1..4}
do
for j in {1..7}
do
for minpop in 1 2 4
do 
for prop in 0.01 0.03 0.05 0.1 0.2
do
for N in 1000 2000 4000 6000 8000
do 
rep=1
id=$((id+1))
if [ ! -e exp_regression5pop_figure4params/obs_counts_ktrue$i\_kobs$j.RData.N=$N.prop=$prop.pop=$minpop.rep$rep.CQ.robj ]; then
    echo "exp_regression5pop_figure4params/obs_counts_ktrue$i\_kobs$j.RData.N=$N.prop=$prop.pop=$minpop.rep$rep.CQ.robj not found"
    echo $id
    cp CQ.sh CQ.$id.sh
    sed -i "s|FILENAME|exp_regression5pop_figure4params/obs_counts_ktrue$i\_kobs$j.RData.N=$N.prop=$prop.pop=$minpop.rep$rep|" CQ.$id.sh
    sed -i "s/ID/$id/g" CQ.$id.sh
    if [ "$id" -gt 0 ];then qsub CQ.$id.sh;fi 
    rm CQ.$id.sh
fi
done
done
done
done
done

f='exp_regression5pop_figure4params/obs_counts_ktrue1_kobs1.RData.N=1000.prop=0.01.pop=1.rep1'
Rscript clustering_summary_save.R $f


#################################################
# continuous
#################################################
cd /data/yosef2/scratch/chenling/clustering_eval
id=0
minpop=0
prop=0
for i in {1..96}
do
for N in 1000 2000 4000 6000 8000
do 
rep=1
id=$((id+1))
if [ ! -e exp_5pop_continuous_grid/obs_counts_$i.RData.N=$N.prop=0.pop=0.rep$rep.count.txt.latent.txt ]; then
    echo "exp_5pop_continuous_grid/obs_counts_$i.RData.N=$N.prop=0.pop=0.rep$rep.count.txt.latent.txt not found"
    echo $id
    cp sge.sh sge.$id.sh
    sed -i "s/regressionID/continuousID/" sge.$id.sh
    sed -i "s/FILENAME/exp_5pop_continuous_grid\/obs_counts_$i.RData/" sge.$id.sh
    sed -i "s/NTOTAL/$N/g" sge.$id.sh
    sed -i "s/PROP/$prop/g" sge.$id.sh
    sed -i "s/POP/$minpop/g" sge.$id.sh
    sed -i "s/REP/$rep/g" sge.$id.sh
    sed -i "s/ID/$id/g" sge.$id.sh
    if [ "$id" -gt 0 ];then qsub sge.$id.sh;fi 
    rm sge.$id.sh
fi
done
done
done
done
done


id=0
minpop=0
prop=0
for i in {1..96}
do
for N in 1000 2000 4000 6000 8000
do 
rep=1
id=$((id+1))
if [ ! -e exp_5pop_continuous_grid/obs_counts_$i.RData.N=$N.prop=0.pop=0.rep$rep.CQ.robj ]; then
    echo "exp_5pop_continuous_grid/obs_counts_$i.RData.N=$N.prop=0.pop=0.rep$rep.CQ.robj not found"
    echo $id
    cp contCQ.sh contCQ.$id.sh
    sed -i "s|FILENAME|exp_5pop_continuous_grid/obs_counts_$i.RData.N=$N.prop=0.pop=0.rep$rep|" contCQ.$id.sh
    sed -i "s/ID/$id/g" contCQ.$id.sh
    if [ "$id" -gt 0 ];then qsub contCQ.$id.sh;fi 
    rm contCQ.$id.sh
fi
done
done
