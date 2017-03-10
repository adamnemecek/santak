#deep neural network for classifying cuneiform digits from training data

import numpy as np
import tensorflow as tf

class CharacterClassifier():
    def __init__(self, train_data, train_labels, test_data, test_labels, h1_size=60, h2_size=50, epochs=10, batch_size=32, verbose=1):
        """
        Deep CNN performing classification on images.
        """

        #load training and test data
        self.data_train, label_train = np.load(train_data), np.load(train_labels)
        self.data_test, label_test = np.load(test_data, test_labels)

        self.init = tf.truncated_normal_initializer(stddev=0.1)
        self.session = tf.Session()

        #convert to one hot
        self.label_train_onehot = self.convert_one_hot(self.label_train)
        self.label_test_onehot = self.convert_one_hot(self.label_test)

        #length of data vectors, flattened images
        self.vector_len = self.data_train.shape[1]
        self.num_classes = len(np.unique(self.label_train))

        x = tf.placeholder(tf.int32, shape=[None, self.vector_len])
        y_ = tf.placeholder(tf.float32, shape=[None, self.num_classes])


    def convert_one_hot(self, labels):
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
