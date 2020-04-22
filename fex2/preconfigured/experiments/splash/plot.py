from fex2 import helpers, plot
from pandas import read_csv, DataFrame
from scipy import stats

RENAMINGS = {
    "('gcc', 'optimized', 1)": "1 thread",
    "('gcc', 'optimized', 2)": "2 threads",
    "('gcc', 'optimized', 4)": "4 threads",
    "('gcc', 'optimized', 8)": "8 threads",
    "('gcc', 'optimized', 16)": "16 threads"
}


class SplashBarplotStyle(plot.BarplotStyle):
    colors = plot.ColorPallets.PRINTER_FRIENDLY
    hatches = ("", "//////", "", "", r"\\\\\\", "//////",)


def build_plot(infile: str, outfile: str, plot_type: str = 'speedup'):
    if plot_type != 'speedup':
        helpers.error_exit(1, 'splash/plot.py: Not supported plot type')

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
    df = helpers.calculate_overheads(df, metadata_columns, data_column, baseline_subtype="native")
    df["overhead"] = 1 / df["overhead"]  # in this experiment, we're interested in speedup

    # cleanup
    df.dropna(inplace=True)
    df = df[df["subtype"] != 'native']  # native overhead is meaningless; it's always 1.0

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
    df.rename(columns=RENAMINGS, inplace=True)

    # the resulting table
    helpers.debug("Plot data\n" + str(df))

    # build the plot
    helpers.debug("Building a plot")
    plt = plot.BarplotOverhead(style=SplashBarplotStyle)
    plt.build(df,
              title="Speedup of GCC -O3 optimizations",
              ylabel="Normalized runtime\n(w.r.t. native GCC)",
              vline_position=11.5
              )

    plt.savefig(
        outfile,
        dpi="figure",
        pad_inches=0.1,
        bbox_inches='tight'
    )
