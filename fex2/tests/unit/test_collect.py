import pathlib
import tempfile
import unittest

import snapshottest as snapshottest
from pandas import read_csv

from fex2.collect import Experiments


class ExperimentsTest(snapshottest.TestCase):

    def test_csvGeneration(self):
        experiments = Experiments(str(pathlib.Path(__file__).parent.absolute()) + "/test_collect_experimentOutput.txt")
        csv_file = tempfile.mkdtemp() + "/test.csv"
        experiments.create_csv(csv_file)
        self.assertMatchSnapshot(read_csv(csv_file))


if __name__ == '__main__':
    unittest.main()
