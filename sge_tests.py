import logging
import luigi
import os
from luigi.contrib.sge import SGEJobTask

logger = logging.getLogger('luigi-interface')


class TestJobTask(SGEJobTask):

    i = luigi.Parameter()

    def work(self):
        logger.info('Running test job...')
        with open(self.output().path, 'w') as f:
            f.write('this is a test')

    def output(self):
        return luigi.LocalTarget(os.path.join('/home', 'testfile_' + str(self.i)))


if __name__ == '__main__':
    tasks = [TestJobTask(i=str(i), n_cpu=i+1) for i in range(3)]
    luigi.build(tasks, local_scheduler=True, workers=3)
