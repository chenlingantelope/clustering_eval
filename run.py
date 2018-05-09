import luigi
import subprocess

###############################################
# run SIMLR
###############################################
class runSIMLR(luigi.Task):
    filename = luigi.Parameter()
    N = luigi.Parameter()
    prop = luigi.Parameter()
    pop = luigi.Parameter()
    rep = luigi.Parameter()

    def run(self):
        subprocess.check_call("Rscript SIMLR.R "+self.filename+" "+self.N+" "+self.prop+" "+self.pop+" "+self.rep, shell=True)

    def output(self):
        return luigi.LocalTarget(self.filename+'.N='+self.N+'.prop='+self.prop+'.pop='+self.pop+'.rep'+self.rep+'.SIMLR.robj')
        return luigi.LocalTarget(self.filename+'.N='+self.N+'.prop='+self.prop+'.pop='+self.pop+'.rep'+self.rep+'.count.txt')
        return luigi.LocalTarget(self.filename+'.N='+self.N+'.prop='+self.prop+'.pop='+self.pop+'.rep'+self.rep+'.label.txt')

###############################################
# run PCA
###############################################
class runPCA(luigi.Task):
    filename = luigi.Parameter()
    N = luigi.Parameter()
    prop = luigi.Parameter()
    pop = luigi.Parameter()
    rep = luigi.Parameter()

    def requires(self):
        return runSIMLR(self.filename,self.N,self.prop,self.pop,self.rep)

    def run(self):
        count=self.filename+'.N='+self.N+'.prop='+self.prop+'.pop='+self.pop+'.rep'+self.rep+'.count.txt'
        subprocess.check_call("Rscript PCA.R "+count,shell=True)

    def output(self):
        return luigi.LocalTarget(self.filename+'.N='+self.N+'.prop='+self.prop+'.pop='+self.pop+'.rep'+self.rep+'.count.txt.pca.robj')

###############################################
# run scVI
###############################################
class runSCVI(luigi.Task):
    filename = luigi.Parameter()
    N = luigi.Parameter()
    prop = luigi.Parameter()
    pop = luigi.Parameter()
    rep = luigi.Parameter()

    def requires(self):
        return runSIMLR(self.filename,self.N,self.prop,self.pop,self.rep),runPCA(self.filename,self.N,self.prop,self.pop,self.rep)

    def run(self):
        f=self.filename+'.N='+self.N+'.prop='+self.prop+'.pop='+self.pop+'.rep'+self.rep
        count=f+'.count.txt'
        label=f+'.label.txt'
        subprocess.check_call("python SCVI.py "+count+" "+label,shell=True)

    def output(self):
        return luigi.LocalTarget(self.filename+'.N='+self.N+'.prop='+self.prop+'.pop='+self.pop+'.rep'+self.rep+'.count.txt.latent.txt')

