import ssl
import os
import urllib.request
import inspect
import time
import datetime
import logging
import tensorflow as tf
from scripts.utils.FileExten import FileExten
'''
This class is the base class for all algorithms.
'''
class AbstractCode:
    logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.INFO)
    data_dir = "./datasets"  # "../../datasets"
    class_name = "DownloadDataSet.py"  # f"{__class__.__name__}"
    # Constructor

    def __init__(self):
        method_name = f"{inspect.stack()[0][3]}"
        logging.debug(f"[BEGIN] CLASS: {self.class_name} "
                      f"METHOD: {method_name} at {datetime.datetime.now()}")
        startTime = time.perf_counter()
        try:
            print(f"Data Dir: {self.data_dir}")
            # BEGIN: fix Python or Notebook SSL CERTIFICATE_VERIFY_FAILED
            if (not os.environ.get('PYTHONHTTPSVERIFY', '') and getattr(ssl, '_create_unverified_context', None)):
                ssl._create_default_https_context = ssl._create_unverified_context
            # END: fix Python or Notebook SSL CERTIFICATE_VERIFY_FAILED
        finally:
            totalTime = (time.perf_counter() - startTime)
            logging.debug(
                f"[END] CLASS: {self.class_name} METHOD: {method_name} completed in {format(totalTime, '6.3f')} seconds or {format(totalTime / 60, '6.3f')} minutes ")

    def retrieve_data(self, dataset_name, remote_file):
        '''
        This method retrieves the data from the remote_file and saves it to the local_file.
            :param dataset_name: Name of the data set
            :param remote_file: URL to download the data set from internet
            :return: local_file path
        '''
        method_name = f"{inspect.stack()[0][3]}"
        logging.debug(f"[BEGIN] CLASS: {self.class_name} "
                      f"METHOD: {method_name} at {datetime.datetime.now()}")
        startTime = time.perf_counter()
        try:
            # BEGIN: fix Python or Notebook SSL CERTIFICATE_VERIFY_FAILED
            if (not os.environ.get('PYTHONHTTPSVERIFY', '') and getattr(ssl, '_create_unverified_context', None)):
                ssl._create_default_https_context = ssl._create_unverified_context
            # END: fix Python or Notebook SSL CERTIFICATE_VERIFY_FAILED

            local_file = f"{self.data_dir}/{dataset_name}{FileExten.DATA.value}"

            if ((not os.path.exists(local_file)) and (not os.path.isfile(local_file))):
                print(f"no local_file: {local_file}")
                urllib.request.urlretrieve(
                    remote_file, local_file)
                print(f"File: {local_file} download complete")
            else:
                print(f"File: '{local_file}' already exists!")
            return local_file
        finally:
            totalTime = (time.perf_counter() - startTime)
            logging.debug(
                f"[END] CLASS: {self.class_name} METHOD: {method_name} completed in {format(totalTime, '6.3f')} seconds or {format(totalTime / 60, '6.3f')} minutes ")


    def retrieve_gz(self, dataset_name, external_url=None):
        '''
        This method downloads the data set from the internet.
            :param dataset_name: Name of the data set
            :param download_url: URL to download the data set from internet
            :return: local_file path
        '''
        method_name = f"{inspect.stack()[0][3]}"
        logging.debug(f"[BEGIN] CLASS: {self.class_name} "
                      f"METHOD: {method_name} at {datetime.datetime.now()}")
        startTime = time.perf_counter()
        try:
            # BEGIN: fix Python or Notebook SSL CERTIFICATE_VERIFY_FAILED
            if (not os.environ.get('PYTHONHTTPSVERIFY', '') and getattr(ssl, '_create_unverified_context', None)):
                ssl._create_default_https_context = ssl._create_unverified_context
            # END: fix Python or Notebook SSL CERTIFICATE_VERIFY_FAILED

            local_file = f"{self.data_dir}/{dataset_name}{FileExten.GZ.value}"

            # if not os.path.exists(local_file) and not os.path.isfile(local_file):
            #     urllib.request.urlretrieve(download_url, local_file)
            #     print(f"File: {local_file} download complete")
            #  else:
            #         print(f"File: '{local_file}' already exists!")
            path_to_downloaded_file = None
            if ((not os.path.exists(local_file)) and (not os.path.isfile(local_file))):
                print(f"File: '{local_file}' does not exist!")
                if (external_url is not None):
                    print(f"Downloading file: {external_url}")
                    path_to_downloaded_file = tf.keras.utils.get_file(
                                    fname=f"{local_file}",
                                    origin=f"{external_url}",
                                    extract=True,
                                    cache_dir=self.data_dir,
                                    cache_subdir=f"{dataset_name}")
                    print(
                        f"Download dataset:{local_file}  \n path_to_downloaded_file: {path_to_downloaded_file}")
                else:
                    print(f"Download URL is NONE")
            else:
                print(f"File: '{local_file}' already exists!")
            # return f"{self.data_dir}/{dataset_name}{exten}"
            return path_to_downloaded_file
        finally:
            totalTime = (time.perf_counter() - startTime)
            logging.debug(
                f"[END] CLASS: {self.class_name} METHOD: {method_name} completed in {format(totalTime, '6.3f')} seconds or {format(totalTime / 60, '6.3f')} minutes ")
