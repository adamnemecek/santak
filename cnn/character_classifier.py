#deep neural network for classifying cuneiform digits from training data

import numpy as np
import tensorflow as tf

class CharacterClassifier():
    def __init__(self, data_archive, h1_size=60, h2_size=50, epochs=10, batch_size=32, verbose=1):
        """
        Deep CNN performing classification on images.
        """

        #load training and test data from npz archive
        data = np.load(data_archive)
        self.train_data, self.train_labels = data['train_labels'], data['train_labels']
        self.test_data, self.test_labels = data['test_labels'], data['test_labels']

        self.init = tf.truncated_normal_initializer(stddev=0.1)
        self.session = tf.Session()

        self.img_shape = self.data_train.shape[1:]
        self.num_classes = len(np.unique(self.label_train))
        #convert to one hot
        self.label_train_onehot = self.convert_one_hot(self.label_train)
        self.label_test_onehot = self.convert_one_hot(self.label_test)









    def convert_one_hot(self, labels, num_classes):
        """
        Converting labels to one hot vectors.
        """

    def train(self):
        """
        Trains the model on the provided training data.
        """

    def test(self):
        """
        Tests the model on the provided test data.
        """

    def build_inference(self):
        """
        build inference graph.
        """

        x_imgs = tf.placeholder(tf.int32, shape=[None, *self.img_shape])
        y_ = tf.placeholder(tf.float32, shape=[None, self.num_classes])
