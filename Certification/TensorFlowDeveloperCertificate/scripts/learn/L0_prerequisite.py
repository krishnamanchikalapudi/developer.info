import sys
import datetime, platform

class Prerequisite:
    """
    Class to create a prerequisite object
    """
    def __init__(self):
        """
        Constructor method
        """
        print(f"\n\nVerifying prerequisites... {datetime.datetime.now()}")

    def verify_python(self):
        """
        Method to verify if the prerequisite is a python module
        """
        message = None
        # ver = sys.version_info[0]
        ver = platform.python_version()
        if (ver >= '3.8'):
            success = True
            log = f"PASS: Python version: {ver}"
        else:
            success = False
            log = f"FAIL: Python version: {ver}"
            message = """
                Please install Python 3.0 (or higher) and try again.
            """
        print(log)
        if message:
            print(message)
        return success

    def verify_tensorflow(self):
        """
        Method to verify if the prerequisite is a tensorflow module
        """
        message = None
        try:
            import tensorflow as tf
            ver = tf.__version__
            if (ver >= '2.5.1'):
                success = True
                log = f"PASS: Tensorflow version: {ver}"
            else:
                success = False
                log = f"FAIL: Tensorflow version: {ver}"
                message = """
                    Please install Tensorflow 2.5 (or higher) and try again.
                """
        except ImportError:
            success = False
            log = f"FAIL: Tensorflow not installed"
            message = """
                Please install Tensorflow and try again.
            """
        print(log)
        if message:
            print(message)
        return success

    def verify_keras(self):
        """
        Method to verify if the prerequisite is a Keras module
        """
        message = None
        try:
            from tensorflow import keras as k
            ver = k.__version__
            if (ver >= '2.5.0'):
                success = True
                log = f"PASS: keras version: {ver}"
            else:
                success = False
                log = f"FAIL: keras version: {ver}"
                message = """
                    Please install keras 2.50 (or higher) and try again.
                """
        except ImportError:
            success = False
            log = f"FAIL: keras not installed"
            message = """
                Please install keras and try again.
            """
        print(log)
        if message:
            print(message)
        return success

    def verify_processing(self):
        """
        Method to verify the hardware processing is CPU, GPU, or TPU
        """
        message = None
        try:
            import tensorflow as tf

            gpu = tf.config.list_physical_devices('GPU')
            cpu = tf.config.list_physical_devices('CPU')
            tpu = tf.config.list_physical_devices('TPU')
            
            if (len(tpu) > 0):
                success = True
                log = (
                    f"PASS: TPU available number: {len(tpu)} ")
            elif (len(gpu) > 0):
                success = True
                log = (
                    f"PASS: GPU available number: {len(gpu)} ")
            elif (len(cpu) > 0):
                success = True
                log = (
                    f"PASS: CPU available number: {len(cpu)} ")
            else:
                success = False
                log = (f"FAIL: NO processes available")
        except ImportError:
            success = False
            log = (f"FAIL: Processing not installed")
            message = """
                Please install Processing and try again.
            """
        print(log)
        if message:
            print(message)
        return success

if __name__ == '__main__':
    prereq = Prerequisite()
    test_results = [
        prereq.verify_python(),
        prereq.verify_tensorflow(),
        prereq.verify_keras(),
        prereq.verify_processing()
    ]

    if False in test_results:
        print(
            """
        ** Please install prerequsite software requirements. **
            """
        )
