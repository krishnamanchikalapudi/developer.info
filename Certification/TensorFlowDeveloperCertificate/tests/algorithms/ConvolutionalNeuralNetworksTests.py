import unittest
import time
from scripts.utils.FileExten import FileExten
from scripts.algorithms.ConvolutionalNeuralNetworks import ConvolutionalNeuralNetworks

class ConvolutionalNeuralNetworksTests(unittest.TestCase):
    def setUp(self):
        self.startTime = time.time()
        self.CNN = ConvolutionalNeuralNetworks()

    def tearDown(self):
        t = time.time() - self.startTime
        print('%s: %.3f' % (self.id(), t))

    def test_retrieve_data_slump_test(self):
        # Downloading csv file
        dataset_name = 'slump_test'
        download_url = 'https://archive.ics.uci.edu/ml/machine-learning-databases/concrete/slump/slump_test.data'

        # print(f"dataset name : {dataset_name}.{exten}; remote url: {download_url}")
        dataset_file_path = self.CNN.retrieve_data(
            dataset_name, download_url)

        print(f"dataset_file_path: {dataset_file_path}")
        self.assertEqual(
            f"../../datasets/{dataset_name}{FileExten.DATA.value}", dataset_file_path)


# Main method
if __name__ == '__main__':
    # unittest.main()
    suite = unittest.TestLoader().loadTestsFromTestCase(
        ConvolutionalNeuralNetworksTests)
    unittest.TextTestRunner(verbosity=0).run(suite)
