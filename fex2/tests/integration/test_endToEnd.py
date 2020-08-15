import os
import unittest
import tempfile

from fex2.tests.integration.managerWrapper import ManagerWrapper


class EndToEndTest(unittest.TestCase):
    mainDir: str

    @classmethod
    def setUpClass(cls) -> None:
        super().setUpClass()
        cls.mainDir = tempfile.mkdtemp(prefix="fex2_test_integration_endToEnd_")
        os.chdir(cls.mainDir)
        os.chmod(cls.mainDir, 0o755)
        ManagerWrapper.init()

    def test_postgresql(self):
        self.__template_install("postgresql")
        self.__run_collect_plot("postgresql", "pgbench", "throughput")

    def test_splash(self):
        self.__template_install("splash")
        # TODO: Add benchmark "raytrace"
        for benchmark_name in ["barnes", "cholesky", "fft", "fmm", "lu", "ocean", "radiosity", "radix", "volrend", "water-nsquared", "water-spatial"]:
            self.__run_collect_plot("splash", "perf", "speedup_time", benchmark_name)

    def test_phoenix(self):
        self.__template_install("phoenix")
        self.__run_collect_plot("phoenix", "perf", "speedup_time")

    def __template_install(self, experiment):
        ManagerWrapper.template(experiment)
        install_success = ManagerWrapper.install(experiment)
        assert install_success, f"Installing of {experiment} unsuccessful"

    def __run_collect_plot(self, experiment, run_type, plot_type, benchmark_name=None):
        run_file = f"{experiment}_{benchmark_name}_run.log"
        build_file = f"{experiment}_{benchmark_name}_build.log"
        collect_file = f"{experiment}_{benchmark_name}_collected.csv"
        result_file = f"{experiment}_{benchmark_name}_result.pdf"

        run_success = ManagerWrapper.run(experiment, run_type, run_file, benchmark_name=benchmark_name, build_output=build_file, force=True)
        assert run_success and os.path.isfile(run_file), f"Running of {experiment}_{benchmark_name} unsuccessful"

        ManagerWrapper.collect(experiment, run_file, collect_file)
        assert os.path.isfile(collect_file), f"Collecting of {experiment}_{benchmark_name} unsuccessful"

        ManagerWrapper.plot(experiment, plot_type, collect_file, result_file)
        assert os.path.isfile(result_file), f"Plotting of {experiment}_{benchmark_name} unsuccessful"


if __name__ == '__main__':
    unittest.main()
