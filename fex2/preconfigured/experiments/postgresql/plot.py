from fex2 import helpers, plot
from pandas import read_csv
from scipy import stats


def build_plot(infile: str, outfile: str, plot_type: str = 'throughput'):
    if plot_type == 'throughput':
        build_plot_throughput(infile, outfile)
    else:
        helpers.error_exit(1, f'pstgresql/plot.py: Not supported plot type "{plot_type}"')

def build_plot_throughput(infile: str, outfile: str):
    metadata_columns = ["benchmark", "type", "subtype", "thread_count"]
    data_columns = ["num_clients", "latency", "tps"]
    all_columns = metadata_columns + data_columns

    # load the results into a DataFrame
    helpers.debug("Loading data")
    df = read_csv(infile, usecols=all_columns)
    if df.empty:
        helpers.error_exit(1, "The input file is empty or not readable")

    # aggregate the results of repeated experiments (i.e., average across all runs of the same experiment)
    helpers.debug("Processing results")
    df = df.groupby(metadata_columns + ["num_clients"])\
        .agg(stats.gmean)\
        .sort_values(by=['num_clients'])

    # Per thousand tps
    df["tps"] = df["tps"] / 1000

    # cleanup
    df.dropna(inplace=True)

    # the resulting table
    helpers.debug("Plot data\n" + str(df))

    labels = lambda key: f'{key[2][0:3]} ({key[1]}/{key[3]}cpus)'

    # build the plot
    helpers.debug("Building a plot")
    plt = plot.LinePlotThroughput()
    plt.build(
        df,
        metadata_columns,
        labels=labels
    )

    plt.savefig(
        outfile,
        dpi="figure",
        pad_inches=0.1,
        bbox_inches='tight'
    )
