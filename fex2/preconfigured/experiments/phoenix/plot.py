from fex2 import helpers, plot, config
from pandas import read_csv, DataFrame
from scipy import stats

RENAMINGS_SPEEDUP = {
    "('gcc', 'optimized', 1)": "1 thread",
    "('gcc', 'optimized', 2)": "2 threads",
    "('gcc', 'optimized', 4)": "4 threads",
    "('gcc', 'optimized', 8)": "8 threads",
    "('gcc', 'optimized', 16)": "16 threads"
}


class SplashBarPlotStyle(plot.BarPlotStyle):
    colors = plot.ColorPallets.PRINTER_FRIENDLY
    hatches = ("", "//////", "", "", r"\\\\\\", "//////",)


def build_plot(infile: str, outfile: str, plot_type: str = 'speedup'):
    if plot_type == 'speedup':
        build_plot_speedup(infile, outfile)
    else:
        helpers.error_exit(1, f'phoenix/plot.py: Not supported plot type "{plot_type}"')


def build_plot_speedup(infile: str, outfile: str):
    conf = config.Config()

    # print(df)
    metadata_columns = ["benchmark", "type", "subtype", "thread_count"]
    data_column = "cycles"
    all_columns = metadata_columns + [data_column]

    # load the results into a DataFrame
    helpers.debug("Loading data")
    df = read_csv(infile, usecols=all_columns)
    if df.empty:
        helpers.error_exit(1, "The input file is empty or not readable")

    # aggregate the results of repeated experiments (i.e., average across all runs of the same experiment)
    helpers.debug("Processing results")
    df = DataFrame({data_column: df.groupby(metadata_columns)[data_column].apply(stats.gmean, axis=0)})
    df = df.reset_index()

    # normalize
    df = helpers.calculate_overheads(df, metadata_columns, data_column, baseline_subtype=conf.baseline_subtype)
    df["overhead"] = 1 / df["overhead"]  # in this experiment, we're interested in speedup

    # cleanup
    df.dropna(inplace=True)
    df = df[df["subtype"] != conf.baseline_subtype]  # baseline overhead is meaningless; it's always 1.0

    # restructure the table for easier plotting and calculate the overall mean values across all benchmarks
    pivoted = df.pivot_table(
        index="benchmark",
        columns=["type", "subtype", "thread_count"],
        values="overhead",
        margins=True,
        aggfunc=stats.gmean,
        margins_name="mean"
    )
    pivoted.drop("mean", 1, inplace=True)  # row means are useless in this context
    df = DataFrame(pivoted.to_records()).set_index("benchmark", drop=True)

    # rename builds
    df.rename(columns=RENAMINGS_SPEEDUP, inplace=True)

    # the resulting table
    helpers.debug("Plot data\n" + str(df))

    # build the plot
    helpers.debug("Building a plot")
    plt = plot.BarPlot(style=SplashBarPlotStyle)
    plt.build(
        df,
        title="Speedup of GCC -O3 optimizations",
        ylabel="Normalized runtime\n(w.r.t. native GCC)",
        vline_position=18.5
    )

    plt.savefig(
        outfile,
        dpi="figure",
        pad_inches=0.1,
        bbox_inches='tight'
    )
