import pylab as pl
import matplotlib.cm as cm
import numpy as np
import numpy.ma as ma


def make_mosaic(imgs, nrows, ncols, border=1):
    """
    Given a set of images with all the same shape, makes a
    mosaic with nrows and ncols
    """

    nimgs = imgs.shape[0]
    imshape = imgs.shape[1:]

    mosaic = ma.masked_all((nrows * imshape[0] + (nrows - 1) * border,
                            ncols * imshape[1] + (ncols - 1) * border),
                           dtype=np.float32)

    paddedh = imshape[0] + border
    paddedw = imshape[1] + border
    for i in xrange(nimgs):
        row = int(np.floor(i / ncols))
        col = i % ncols

        mosaic[row * paddedh:row * paddedh + imshape[0],
        col * paddedw:col * paddedw + imshape[1]] = imgs[i]
    return mosaic


# utility functions
from mpl_toolkits.axes_grid1 import make_axes_locatable


def nice_imshow(ax, data, vmin=None, vmax=None, cmap=None):
    """Wrapper around pl.imshow"""
    if cmap is None:
        cmap = cm.jet
    if vmin is None:
        vmin = data.min()
    if vmax is None:
        vmax = data.max()
    divider = make_axes_locatable(ax)
    cax = divider.append_axes("right", size="5%", pad=0.05)
    im = ax.imshow(data, vmin=vmin, vmax=vmax, interpolation='nearest', cmap=cmap)
    pl.colorbar(im, cax=cax)


# pl.imshow(make_mosaic(np.random.random((9, 10, 10)), 3, 3, border=1))

def plot_conv_weights(model, layer):
    # Visualize weights
    W = model.layers[layer].get_weights()
    W = np.squeeze(W)

    if len(W.shape) == 4:
        W = W.reshape((-1, W.shape[2], W.shape[3]))
    print("W shape : ", W.shape)

    pl.figure(figsize=(15, 15))
    pl.title('conv weights')
    s = int(np.sqrt(W.shape[0]) + 1)
    nice_imshow(pl.gca(), make_mosaic(W, s, s), cmap=cm.binary)