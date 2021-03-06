import numpy as np

import matplotlib.pyplot as plt

import h5py

from scroll_stepper import IndexTracker

from keras.models import load_model

test_index = '/minnd/datasets/levelB/test/database.h5'
train_index = '/minnd/datasets/levelB/train/database.h5'


with h5py.File(test_index, 'r') as f, h5py.File(train_index, 'r') as g:
    test_y = f['label']
    test_x = f['data']
    train_y = f['label']
    train_x = f['data']
    test_orig = f['orig']
    train_orig = f['orig']

    net = load_model('model.h5')

    pred = net.predict(test_x, batch_size=512, verbose=1)

    shp = test_x.shape
    n = np.arange(0.0, shp[0])
    plt.figure(1)
    plt.plot(n, np.squeeze(pred[0:shp[0]]), n, np.squeeze(test_y[0:shp[0]]))



    fig, ax = plt.subplots(1, 1)
    tracker = IndexTracker(ax, test_orig, 0)

    fig.canvas.mpl_connect('scroll_event', tracker.onscroll)


    plt.show()