import sys
import scVI
import tensorflow as tf
from benchmarking import *
import numpy as np
import time
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.manifold import TSNE

filename= sys.argv[1]
print(filename)
labelname= sys.argv[2]
print(labelname)

X = pd.read_table(filename,sep=" ",low_memory=False,header=None).T
labels = pd.read_table(labelname,sep=" ",low_memory=False,header=None)
labels = labels[1]
print(len(labels))
expression_data =  np.array(X, dtype=np.int)

clusters = np.array(labels, dtype=str)
label_names, labels = np.unique(clusters, return_inverse=True)

expression_train, expression_test, c_train, c_test = train_test_split(expression_data, labels)

log_library_size = np.log(np.sum(expression_data, axis=1)+1)
mean, var = np.mean(log_library_size), np.var(log_library_size)

batch_size = 128
learning_rate = 0.001
epsilon = 0.01
latent_dimension = 10

tf.reset_default_graph()
expression = tf.placeholder(tf.float32, (None, expression_train.shape[1]), name='x')
kl_scalar = tf.placeholder(tf.float32, (), name='kl_scalar')
optimizer = tf.train.AdamOptimizer(learning_rate=learning_rate, epsilon=epsilon)
training_phase = tf.placeholder(tf.bool, (), name='training_phase')

model = scVI.scVIModel(expression=expression, kl_scale=kl_scalar, \
                        optimize_algo=optimizer, phase=training_phase, \
                        library_size_mean=mean, library_size_var=var,\
                        n_hidden=128, dropout_rate=0.1, n_layers=1, \
                        n_latent=latent_dimension, log_variational=True)

# Session creation
sess = tf.Session()
sess.run(tf.global_variables_initializer())

def next_batch(data, batch_size):
    index = np.random.choice(np.arange(data.shape[0]), size=batch_size)
    return data[index].astype(np.float32)

def train_model(num_epochs, expression_train, expression_test, step, kl_scale=1):
    iterep = int(expression_train.shape[0]/float(batch_size))-1  
    for t in range(iterep * num_epochs):            
        # arange data in batches
        x_train = next_batch(expression_train, batch_size)
        x_test = next_batch(expression_test, batch_size)
        #prepare data dictionaries
        dic_train = {expression: x_train, training_phase:True, kl_scalar:kl_scale}
        dic_test = {expression: expression_test, training_phase:False, kl_scalar:kl_scale} 
        # run an optimization set
        _, l_tr = sess.run([step, model.loss], feed_dict=dic_train)
        end_epoch, epoch = t % iterep == 0, t / iterep
        if end_epoch:          
            print(epoch)
            l_t = sess.run((model.loss), feed_dict=dic_test)
            print ('Train / Test performance:', l_tr, l_t)
            if np.isnan(l_tr):
                break


# this takes 45 seconds on a Tesla K80
train_model(200, expression_data, expression_test, model.train_step, kl_scale=0)

def eval_latent(data, sess, model):
    dic_full = {expression: data, training_phase:False, kl_scalar:1}
    return sess.run(model.z, feed_dict=dic_full)

latent = eval_latent(expression_data, sess, model)
np.savetxt(filename+'.latent.txt',latent, delimiter=',')
# np.savetxt(filename+'.latent.label.txt',c_train, delimiter=',')


