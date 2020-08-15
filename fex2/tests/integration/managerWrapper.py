from argparse import Namespace

from fex2.cli import Manager


class ManagerWrapper:

    @staticmethod
    def init():
        manager = ManagerWrapper.__create_manager()
        manager.init()

    @staticmethod
    def template(experiment):
        manager = ManagerWrapper.__create_manager(name=experiment)
        manager.template()

    @staticmethod
    def install(experiment) -> bool:
        manager = ManagerWrapper.__create_manager(name=experiment)
        return manager.install()

    @staticmethod
    def run(experiment, type, output, build_type=None, runs="1", num_threads=None, no_build=False, no_run=False, dry_run=False, incremental_build=False, force=False, build_output=None, benchmark_name=None) -> bool:
        if num_threads is None:
            num_threads = ["1"]
        if build_type is None:
            build_type = ["gcc_native", "gcc_optimized"]
        manager = ManagerWrapper.__create_manager(name=experiment, type=type, output=output, build_type=build_type, runs=runs, num_threads=num_threads, no_build=no_build, no_run=no_run, dry_run=dry_run, incremental_build=incremental_build, force=force, build_output=build_output, benchmark_name=benchmark_name)
        return manager.run()

    @staticmethod
    def collect(experiment, input, output):
        manager = ManagerWrapper.__create_manager(name=experiment, input=input, output=output)
        manager.collect()

    @staticmethod
    def plot(experiment, plot_type, input, output):
        manager = ManagerWrapper.__create_manager(name=experiment, plot_type=plot_type, input=input, output=output)
        manager.plot()

    @staticmethod
    def __create_manager(**kwargs):
        manager = Manager(Namespace(action="unused", **kwargs))
        return manager
