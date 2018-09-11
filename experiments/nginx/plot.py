import logging
import numpy as np

from core import prepare
from core import draw

BENCH_NAME = 'nginx'
EXP_NAME = BENCH_NAME
COMPILER_NAME = "long"


def main(t="perf"):
    logging.info("Processing data")
    df = prepare.process_results(t)
    if t == "tput":
        prepare.reorder_compilers(df, t)
        plot = draw.LinePlotTput()
        plot.get_data(df, [])
        plot.build_plot(
            xlim=(0, 65),
            xticks=range(0, 100, 10),
            ylim=(0.1, 0.8),
            yticks=np.arange(0.2, 0.79, 0.1),
            legend_loc=(0.01, 0.45),
            figsize=(5, 2.5),
        )
        plot.save_plot("%s_%s.pdf" % (BENCH_NAME, t))

    else:
        logging.error("Unknown plot type")
        exit(-1)
