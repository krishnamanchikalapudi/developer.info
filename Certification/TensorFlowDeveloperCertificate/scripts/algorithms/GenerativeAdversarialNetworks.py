import inspect
import time
import datetime
import logging

'''
This is a class that implements the Generative Adversarial Networks (GAN)
'''
class GenerativeAdversarialNetworks:
    logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.INFO)
    class_name = "GenerativeAdversarialNetworks.py"  # f"{__class__.__name__}"
    # Constructor

    def __init__(self):
        method_name = f"{inspect.stack()[0][3]}"
        logging.debug(f"[BEGIN] CLASS: {self.class_name} "
                      f"METHOD: {method_name} at {datetime.datetime.now()}")
        startTime = time.perf_counter()
        try:
           print(f"Class: {self.class_name}")
        finally:
            totalTime = (time.perf_counter() - startTime)
            logging.debug(
                f"[END] CLASS: {self.class_name} METHOD: {method_name} completed in {format(totalTime, '6.3f')} seconds or {format(totalTime / 60, '6.3f')} minutes ")
