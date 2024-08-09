import inspect
import time
import datetime
import logging
from scripts.algorithms.AbstractCode import AbstractCode
'''
This is a Convolutional Neural Network (CNN) implementation.
'''
class ConvolutionalNeuralNetworks(AbstractCode):
    logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.INFO)
    class_name = "ConvolutionalNeuralNetworks.py"  # f"{__class__.__name__}"

