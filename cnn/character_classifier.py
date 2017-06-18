#deep neural network for classifying cuneiform digits from training data

import numpy as np
import tensorflow as tf

class CharacterClassifier():
    def __init__(self, data_dict, save_loc, load_loc, fc_size=1024, epochs=20, keep_prob=0.5, batch_size=50, verbose=0):
        """
        Deep CNN performing classification on images.
        """

        self.fc_size, self.epochs, self.batch_size, self.verbose, self.keep_prob = fc_size, epochs, batch_size, verbose, keep_prob
        self.save_loc, self.load_loc = save_loc, load_loc
        self.setup_data(data_dict)

        self.session = tf.Session()

        self.logits = self.build_inference()

        #build loss computation
        self.loss = self.build_loss()

        #learning rate of 0.001 - change?
        self.train_op = tf.train.AdamOptimizer(.001).minimize(self.loss)

        #run initializer
        self.session.run(tf.global_variables_initializer())

        #build saver
        #self.saver = tf.train.Saver(var_list=tf.get_collection(tf.GraphKeys.TRAINABLE_VARIABLES, scope=tf.get_variable_scope().name))
        self.saver = tf.train.Saver() #saving all variables
        #write graph structure.
        if save_loc:
            tf.train.write_graph(self.session.graph_def, self.save_loc, "santak-graph.pbtxt")
        if load_loc:
            self.saver.restore(self.session, self.load_loc)
            print "loaded weights from {}".format(self.load_loc)


    def build_loss(self):
        """
        Builds loss computation.
        """
        return tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits(labels=self.y_, logits=self.logits))

    def setup_data(self, data_dict):
        """
        Setting up data.
        """
        #load training and test data from npz archive
        self.train_data, self.train_labels = data_dict['train_data'], data_dict['train_labels']
        self.test_data, self.test_labels = data_dict['test_data'], data_dict['test_labels']

        self.img_shape = self.train_data.shape[1:]

        #reshape into 4d tensor with dimension 1 at final dimension
        self.train_data = self.train_data[:, :, :, np.newaxis]
        self.test_data = self.test_data[:, :, :, np.newaxis]

        print self.train_data.shape

        self.num_classes = len(np.unique(self.train_labels))
        #convert to one hot
        self.label_train_onehot = self.convert_one_hot(self.train_labels, self.num_classes)
        self.label_test_onehot = self.convert_one_hot(self.test_labels, self.num_classes)

    def convert_one_hot(self, labels, num_classes):
        """
        Converting labels to one hot vectors.
        """

        #pre-allocate data

        one_hot = np.zeros((labels.shape[0], num_classes), dtype=np.float32)
        #print labels.shape
        #print one_hot.shape
        for i, label in enumerate(labels):
            one_hot[i, int(label)] = 1

        return one_hot

    def train(self):
        """
        Trains the model on the provided training data.
        """

        for e in range(self.epochs):
            curr_loss, batches = 0.0, 0

            for start, end in zip(range(0, self.train_data.shape[0] - self.batch_size, self.batch_size),
                                  range(self.batch_size, self.train_data.shape[0], self.batch_size)):

                loss, _ = self.session.run([self.loss, self.train_op],
                                           feed_dict={self.x_imgs: self.train_data[start:end, :, :, :],
                                                      self.y_: self.label_train_onehot[start:end, :],
                                                      self.keep_prob_placeholder: self.keep_prob})
                curr_loss += loss
                batches += 1
                if self.verbose == 1:
                    print 'Epoch %d Batch %d\tCurrent Loss: %.3f' % (e, batches, curr_loss / batches)
            print 'Epoch %s Average Loss:' % str(e), curr_loss / batches
        #only save weights at the end of training
        if self.save_loc:
            self.saver.save(self.session, "{}/{}".format(self.save_loc, 'santak-weights.ckpt'))


    def test(self):
        """
        Tests the model on the provided test data.
        Tests in batches.
        """
        num_correct = 0
        for start, end in zip(range(0, self.test_data.shape[0] - self.batch_size, self.batch_size),
                                          range(self.batch_size, self.test_data.shape[0], self.batch_size)):

            y = self.session.run(self.logits, feed_dict={self.x_imgs: self.test_data[start:end, :, :, :],
                                                        self.keep_prob_placeholder: 1})
            #compute argmax, compare
            y_hat = np.argmax(y, axis=1)

            num_correct += np.sum(np.equal(self.test_labels[start:end], y_hat))

        outstr = "accuracy: {}".format(float(num_correct)/self.test_data.shape[0])

        print outstr

        if self.save_loc:
            #write test results
            #TODO: add more of these
            outfile="{}/{}".format(self.save_loc, "test_report.txt")

            with open(outfile, 'w') as f:
                f.write(outstr)

            print "saved report to {}".format(outfile)


    def build_inference(self):
        """
        build inference graph. 3 convolutional layers, with 1 fully connected layer.
        """



        self.x_imgs = tf.placeholder(tf.float32, shape=[None, self.img_shape[0], self.img_shape[1], 1], name='input_imgs')
        self.y_ = tf.placeholder(tf.float32, shape=[None, self.num_classes], name='onehot_classes')

        #initialize weights for first convolutional layer
        #32 features
        #[pixel_x, pixel_y, depth, num_kernels]
        kernel_1 = tf.Variable(tf.truncated_normal([8, 8, 1, 32], stddev=0.1, dtype=tf.float32))

        bias_1 = tf.Variable(tf.truncated_normal(shape=[32], dtype=tf.float32, stddev=0.1))
        conv_1 = tf.nn.conv2d(self.x_imgs, kernel_1, strides=[1, 1, 1, 1], padding='SAME')

        h_conv1 = tf.nn.relu(tf.nn.bias_add(conv_1, bias_1))

        #max pooling 3x3
        pool1 = tf.nn.max_pool(h_conv1, ksize=[1, 3, 3, 1], strides=[1, 3, 3, 1], padding='SAME')

        #print "pool 1 shape: {}".format(pool1.shape)

        #second convolutional layer
        #depth changed b/c previous neuron volume is of depth 32 now!
        kernel_2 = tf.Variable(tf.truncated_normal([5, 5, 32, 64], stddev=0.1, dtype=tf.float32))

        bias_2 = tf.Variable(tf.truncated_normal(shape=[64], dtype=tf.float32))

        conv_2 = tf.nn.conv2d(pool1, kernel_2, strides=[1, 1, 1, 1], padding='SAME')

        h_conv2 = tf.nn.relu(tf.nn.bias_add(conv_2, bias_2))

        #max pooling 3x3
        pool2 = tf.nn.max_pool(h_conv2, ksize=[1, 3, 3, 1], strides=[1, 3, 3, 1], padding='SAME')

        #print "pool 2 shape: {}".format(pool2.shape)

        #third convolutional layer
        kernel_3 = tf.Variable(tf.truncated_normal([3, 3, 64, 128], stddev=0.1, dtype=tf.float32))

        bias_3 = tf.Variable(tf.truncated_normal(shape=[128], stddev=0.1, dtype=tf.float32))

        conv_3 = tf.nn.conv2d(pool2, kernel_3, strides=[1, 1, 1, 1], padding='SAME')

        h_conv3 = tf.nn.relu(tf.nn.bias_add(conv_3, bias_3))

        #max pooling 2xt
        pool3 = tf.nn.max_pool(h_conv3, ksize=[1, 2, 2, 1], strides=[1, 2, 2, 1], padding='SAME')
        #print "pool 3 shape: {}".format(pool3.shape)
        #fully connected layer

        #get shape of FC layer
        num_neurons_pool3 = int(pool3.shape[1]*pool3.shape[2]*pool3.shape[3])

        W_fc1 = tf.Variable(tf.truncated_normal([num_neurons_pool3, self.fc_size], stddev=0.1, dtype=tf.float32))

        b_fc = tf.Variable(tf.truncated_normal(shape=[self.fc_size], dtype=tf.float32))

        pool3_flattened = tf.reshape(pool3, [-1, num_neurons_pool3])

        h_fc1 = tf.nn.relu(tf.nn.bias_add(tf.matmul(pool3_flattened, W_fc1), b_fc))

        #add dropout
        #TODO: remove dropout if it'll cause a problem during Bender conversion
        self.keep_prob_placeholder = tf.placeholder(tf.float32, name="keep_prob")
        h_fc1_drop = tf.nn.dropout(h_fc1, self.keep_prob_placeholder)

        #readout layer!

        W_readout = tf.Variable(tf.truncated_normal([self.fc_size, self.num_classes], stddev=0.1, dtype=tf.float32))

        b_readout = tf.Variable(tf.truncated_normal(shape=[self.num_classes], stddev=0.1, dtype=tf.float32))

        y_logits = tf.nn.bias_add(tf.matmul(h_fc1_drop, W_readout), b_readout)

        return y_logits
