import time, unittest
from scripts.GenerateSBOMreport import GenerateSBOMreport as sbomReport

class GenerateSBOMreportTests(unittest.TestCase):
    def setUp(self):
        self.startTime = time.time()
        self.db = MySqlDb()

    def test_dual(self):
        result = self.db.select("SELECT 1 + 1 as val FROM DUAL")
        self.assertEqual(1, len(result))

    def tearDown(self):
        self.db.close()
        t = time.time() - self.startTime
        print('%s: %.3f' % (self.id(), t))


if __name__ == '__main__':
    # unittest.main()
    suite = unittest.TestLoader().loadTestsFromTestCase(GenerateSBOMreportTests)
    unittest.TextTestRunner(verbosity=0).run(suite)