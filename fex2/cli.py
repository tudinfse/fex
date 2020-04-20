#!/usr/bin/env python3

from argparse import ArgumentParser, Namespace
from fex2 import helpers
import os
import shutil
import sys
import stat
import subprocess


def parse_arguments() -> Namespace:
    parser = ArgumentParser(description='', add_help=True)
    subparsers = parser.add_subparsers(help='Evaluation commands', dest='action')

    parser_init = subparsers.add_parser(
        'init',
        help='Initialize a standard Fex2 directory structure in the current directory')

    parser_template = subparsers.add_parser(
        'template',
        help='Setup a pre-configured experiment')
    parser_template.add_argument(
        "name",
        choices=Manager.template_files.keys(),
        help="Experiment name"
    )

    parser_install = subparsers.add_parser(
        'install',
        help='Download and install benchmarks or tools')
    parser_install.add_argument(
        "name",
        choices=Manager.template_files.keys(),
        help="Name of the software to install"
    )

    parser_run = subparsers.add_parser(
        'run',
        help='Build benchmarks and run the experiment')
    parser_run.add_argument(
        "name",
        help="Experiment name"
    )
    parser_run.add_argument(
        '-b', '--build-type',
        required=True,
        type=str,
        nargs='+',
        help='List of build types.'
    )
    parser_run.add_argument(
        '-t', '--type',
        type=str,
        default='perf',
        help='Experiment type'
    )
    parser_run.add_argument(
        '-r', '--runs',
        type=str,
        default='1',
        help="Number of runs (i.e., how many times to repeat the experiments)"
    )
    parser_run.add_argument(
        '-m', '--num-threads',
        nargs='+',
        type=str,
        default='1',
        help='[For multithreaded benchmarks] Number of threads. Multiple values possible.'
    )
    parser_run.add_argument(
        '--no-build',
        action='store_true',
        help='Don\'t build benchmarks (previous build is used, if any).'
    )
    parser_run.add_argument(
        '--no-run',
        action='store_true',
        help='Don\'t run the experiment (only build).'
    )
    parser_run.add_argument(
        '--dry-run',
        action='store_true',
        help='Don\'t run the experiment, but print the commands that are supposed to be executed.'
    )
    parser_run.add_argument(
        '--incremental-build',
        action='store_true',
        required=False,
        help='If set, the builds from previous experiments will be reused (if available).'
    )
    parser_run.add_argument(
        '-o', '--output',
        type=str,
        required=False,
        help='Output file (by default, printed to stdout)'
    )
    parser_run.add_argument(
        '--build-output',
        type=str,
        required=False,
        help='File for build logs (by default, printed to stdout)'
    )
    parser_run.add_argument(
        '-n', '--benchmark-name',
        required=False,
        type=str,
        help='Run only one benchmark from the benchmark suite'
    )

    parser_collect = subparsers.add_parser(
        'collect',
        help='Parse experiment logs')
    parser_collect.add_argument(
        "name",
        help="Experiment name"
    )
    parser_collect.add_argument(
        '-t', '--type',
        type=str,
        default='perf',
        help='Experiment type'
    )
    parser_collect.add_argument(
        '-i', '--input',
        type=str,
        required=True,
        help='Input file'
    )
    parser_collect.add_argument(
        '-o', '--output',
        type=str,
        required=True,
        help='Output file'
    )

    parser_plot = subparsers.add_parser(
        'plot',
        help='Build a plot')
    parser_plot.add_argument(
        "name",
        help="Experiment name"
    )
    parser_plot.add_argument(
        '-p', '--plot-type',
        type=str,
        default='perf',
        help='Plot type'
    )
    parser_plot.add_argument(
        '-i', '--input',
        type=str,
        required=True,
        help='Input file'
    )
    parser_plot.add_argument(
        '-o', '--output',
        type=str,
        required=True,
        help='Output file'
    )

    args = parser.parse_args()
    if not args.action:
        print("No action specified")
        parser.print_help()
        sys.exit(1)

    return args


class Manager:
    """
    Main management point
    """
    action: str
    args: Namespace

    template_files = {
        "splash": (("splash.sh",), ("splash",), ("splash",))
    }

    def __init__(self, args: Namespace):
        self.action = args.action
        self.args = args

    def execute_action(self):
        # call the Manager method with the corresponding name
        getattr(self, self.action)()

    @staticmethod
    def init():
        data_dir = os.path.dirname(helpers.__file__) + "/preconfigured/"

        # make sure that we won't overwrite anything
        if os.listdir():
            helpers.error_exit(2, "The project directory must be empty")

        # create standard directories
        os.mkdir("experiments")
        os.mkdir("install")
        os.mkdir("build_types")
        os.mkdir("benchmarks")

        # copy example files and templates
        shutil.copy2(data_dir + "template_config.py", "config.py")

        shutil.copy2(data_dir + "build_types/gcc_native.mk", "build_types")
        shutil.copy2(data_dir + "build_types/common.mk", "build_types")
        shutil.copy2(data_dir + "experiments/common.sh", "experiments")

        shutil.copy2(data_dir + "install/common.sh", "install")
        shutil.copy2(data_dir + "install/gcc.sh", "install")
        shutil.copy2(data_dir + "install/llvm.sh", "install")
        os.chmod("install/gcc.sh", stat.S_IXUSR | stat.S_IRUSR)
        os.chmod("install/llvm.sh", stat.S_IXUSR | stat.S_IRUSR)

    def template(self):
        data_dir = os.path.dirname(helpers.__file__) + "/preconfigured/"

        template_files = self.template_files[self.args.name]
        install_files = template_files[0]
        benchmark_dirs = template_files[1]
        experiment_dirs = template_files[2]

        for f in install_files:
            if not os.path.isfile("install/" + f):
                shutil.copy2(data_dir + "install/" + f, "install")
                os.chmod("install/" + f, stat.S_IXUSR | stat.S_IRUSR)

        for d in benchmark_dirs:
            if not os.path.isdir("benchmarks/" + d):
                shutil.copytree(data_dir + "benchmarks/" + d, "benchmarks/" + d)

        for d in experiment_dirs:
            if not os.path.isdir("experiments/" + d):
                shutil.copytree(data_dir + "experiments/" + d, "experiments/" + d)
                os.chmod("experiments/" + d + "/run.sh", stat.S_IXUSR | stat.S_IRUSR)

    def install(self):
        name = self.args.name
        helpers.debug("Installing " + name)

        os.putenv("PROJ_ROOT", os.getcwd())
        try:
            subprocess.run("install/%s.sh" % name, capture_output=False, shell=True, check=True)
        except subprocess.CalledProcessError as e:
            helpers.error("Installation failed with code %d" % e.returncode)
        else:
            helpers.debug("Installation finished")

    def run(self):
        name = self.args.name
        helpers.debug("Starting experiment " + name)

        # pass the arguments down to bash
        os.putenv("PROJ_ROOT", os.getcwd())
        os.putenv("NAME", name)
        os.putenv("BUILD_TYPES", " ".join(self.args.build_type))
        os.putenv("EXPERIMENT_TYPE", self.args.type)
        os.putenv("ITERATIONS", self.args.runs)
        os.putenv("NUM_THREADS", " ".join(self.args.num_threads))

        if self.args.no_build:
            os.putenv("NO_BUILD", "1")
        if self.args.no_run:
            os.putenv("NO_RUN", "1")
        if self.args.dry_run:
            os.putenv("DRY_RUN", "1")
        if self.args.incremental_build:
            os.putenv("INCREMENTAL_BUILD", "1")

        if getattr(self.args, "output", False):
            os.putenv("EXPERIMENT_OUTPUT", self.args.output)
        if getattr(self.args, "build_output", False):
            os.putenv("BUILD_LOG", self.args.build_output)
        if getattr(self.args, "benchmark_name", False):
            os.putenv("BENCHMARK_NAME", self.args.benchmark_name)

        # run the experiment
        try:
            subprocess.run(f"experiments/{name}/run.sh", capture_output=False, shell=True, check=True)
        except subprocess.CalledProcessError as e:
            helpers.error("Experiment failed with code %d" % e.returncode)
        else:
            helpers.debug("Experiment finished")

    def collect(self):
        name = self.args.name
        module = helpers.load_module_from_path(f"{name}.collect", f"experiments/{name}/collect.py")
        module.parse(infile=self.args.input, outfile=self.args.output, experiment_type=self.args.type)

    def plot(self):
        name = self.args.name
        module = helpers.load_module_from_path(f"{name}.plot", f"experiments/{name}/plot.py")
        module.build_plot(infile=self.args.input, outfile=self.args.output, plot_type=self.args.plot_type)

    # def print_hw_parameters(self, args):
    #     msg = "Experiment parameters:\n"
    #
    #     info = cpuinfo.get_cpu_info()
    #     msg += "CPU: {0} ({1} cores)\n".format(info['brand'], info['count']) + \
    #            "Architecture: {0}\n".format(platform.machine()) + \
    #            "L2 size: {0}\n".format(info['l2_cache_size']) + \
    #            "Platform: {0}\n\n".format(platform.platform()) + \
    #            "Environment variables:\n{0}\n\n".format(os.environ) + \
    #            "Command line arguments:\n{0}\n\n".format(args.__dict__)
    #
    #     logging.info(msg)


def main():
    manager = Manager(parse_arguments())
    manager.execute_action()


if __name__ == '__main__':
    main()
