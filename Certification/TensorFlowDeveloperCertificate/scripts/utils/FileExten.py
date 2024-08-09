import inspect
import time
import datetime
import logging
import tensorflow as tf

'''
This script downloads the data set from the internet.
'''
from enum import Enum
class FileExten(Enum):
    ZIP = '.zip'
    DATA = '.data'
    CSV = '.csv'
    GZ = '.gz'
    CSV_GZ = '.csv.gz'
    JSON = '.json'
    XML = '.xml'