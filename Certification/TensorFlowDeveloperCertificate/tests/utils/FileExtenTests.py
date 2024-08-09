import time, unittest

from scripts.utils.FileExten import FileExten

class FileExtenTests(unittest.TestCase):
    def setUp(self):
        self.startTime = time.time()

    def tearDown(self):
        t = time.time() - self.startTime
        print('%s: %.3f' % (self.id(), t))

    def test_zip(self):
        print(f"{FileExten.ZIP.name}: {FileExten.ZIP.value}")
        self.assertEqual(".zip", FileExten.ZIP.value)

    def test_csv(self):
        print(f"{FileExten.CSV.name}: {FileExten.CSV.value}")
        self.assertEqual(".csv", FileExten.CSV.value)

    def test_csv_gz(self):
        print(f"{FileExten.CSV_GZ.name}: {FileExten.CSV_GZ.value}")
        self.assertEqual(".csv.gz", FileExten.CSV_GZ.value)

    def test_data(self):
        print(f"{FileExten.DATA.name}: {FileExten.DATA.value}")
        self.assertEqual(".data", FileExten.DATA.value)

    def test_gz(self):
        print(f"{FileExten.GZ.name}: {FileExten.GZ.value}")
        self.assertEqual(".gz", FileExten.GZ.value)
        

# Main method
if __name__ == '__main__':
    # unittest.main()
    suite = unittest.TestLoader().loadTestsFromTestCase(FileExtenTests)
    unittest.TextTestRunner(verbosity=0).run(suite)
