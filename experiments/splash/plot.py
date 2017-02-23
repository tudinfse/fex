import logging

from core import prepare
from core import draw


BENCH_NAME = 'splash'
EXP_NAME = BENCH_NAME


def main(t="perf"):
    logging.info("Processing data")
    if t == "perf":
        df = prepare.process_results("perf")
        df = prepare.calculate_overhead(df, column="cycles", over_compilertype="gcc-native")
        prepare.reorder_compilers(df, t)
        draw.barplot_overhead(
            df,
            filename="phoenix_%s.pdf" % t,
            ylim=(0, 2.7),
            yticks=range(0, 3),
            ylabel="Normalized runtime\n(w.r.t. native GCC)",
            figsize=(5, 3)
        )
    else:
        logging.error("Unknown plot type")
        exit(-1)
