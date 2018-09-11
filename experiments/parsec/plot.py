import logging

from core import prepare
from core import draw

BENCH_NAME = 'parsec'
EXP_NAME = BENCH_NAME
BENCHMARK_ORDER = (
    "blackscholes",
    "vips",
    "fluidanimate",
    "bodytrack",
    "ferret",
    "dedup",
    "facesim",
    "streamcluster",
    "raytrace",
    "x264",
    "canneal",
    "swaptions",
)
OVERFLOWS = {
    "perf": (
        (11.17, 8.25, "12.6",),
    ),
    "mem": (
        (0.87, 6.25, "13.0",),
        (2.44, 6.25, "34.1",),
        (10.43, 8.25, "58.2",),
        (11.27, 8.25, "45",),
        (12.27, 8.25, "45",),
    ),
}


def process_type(t, df, plot_args, benchmark_order):
    columns = []

    # type specific processing
    if t == "perf":
        df = prepare.calculate_overhead(df)
        prepare.reorder_and_rename_benchmarks(df, benchmark_order)
        prepare.reorder_compilers(df, t)

        plot = draw.BarplotOverhead()
        plot_args.update({
            "ylabel": "Normalized runtime\n(w.r.t. native)",
            "logy": True,
        })

    elif t == "mem":
        df = prepare.calculate_overhead(df, column="maxsize")
        prepare.reorder_and_rename_benchmarks(df, benchmark_order)
        prepare.reorder_compilers(df, t)

        plot = draw.BarplotOverhead()
        plot_args.update({
            "ylabel": "Memory overhead\n(w.r.t. native)",
            "logy": True,
        })

    elif t == "multi":
        df = prepare.calculate_overhead(df)
        prepare.reorder_and_rename_benchmarks(df, benchmark_order)
        prepare.reorder_compilers(df, t)
        # df.sort_values(["threads"], inplace=True)

        plot = draw.BarplotOverhead()
        plot_args.update({
            "ylabel": "Scaling",
            "ylim": (0.95, 1.4),
            "logy": False,
            "ncol": 5,
        })

    else:
        logging.error("Unknown plot type")
        exit(-1)

    # no need to return plot_args, dict is mutable and is passed by reference
    return plot, columns


def main(t="perf"):
    logging.info("Processing data")

    df = prepare.process_results(t)
    plot_args = {
        "ylim": (0.85, 10),
        "vline_position": 11.6,
        "title": "PARSEC",  # uncomment for web version
        "text_points": OVERFLOWS.get(t, ())
    }

    plot, columns = process_type(t, df, plot_args, BENCHMARK_ORDER)

    plot.get_data(df, columns)
    plot.build_plot(**plot_args)
    plot.save_plot("%s_%s.pdf" % (BENCH_NAME, t))
