import sys
import numpy as np

class Colors:
    DEBUG = '\033[94m\033[1m'
    WARNING = '\033[93m\033[1m'
    ERROR = '\033[91m\033[1m'
    ENDC = '\033[0m'


# Logging and exiting
# TODO: make the output files configurable
def debug(message: str = None):
    print(f"{Colors.DEBUG}[DEBUG] {message}{Colors.ENDC}", file=sys.stdout)


def warning(message: str = None):
    print(f"{Colors.WARNING}[WARNING] {message}{Colors.ENDC}", file=sys.stderr)


def error(message: str = None):
    print(f"{Colors.ERROR}[ERROR] {message}{Colors.ENDC}", file=sys.stderr)


def error_exit(status: int = 0, message: str = None):
    if message:
        print(f"{Colors.ERROR}[ERROR] {message}{Colors.ENDC}", file=sys.stderr)
    sys.exit(status)


# Working with out-of-directory modules
def load_module_from_path(module_name: str, path: str):
    import importlib.util
    spec = importlib.util.spec_from_file_location(module_name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


# Processing experiment data
def calculate_overheads(df, metadata_columns, data_column, baseline_subtype="native"):
    """
    Calculate overheads for all build types.
    If `baseline` is not provided, overhead is calculated over `*_native` build type.
    :param df: DataFrame to be processed
    :param metadata_columns: Columns to be preserved
    :param data_column: Which column to process
    :param baseline_subtype: A subtype used as a baseline measurement. 'native' by default
    :return: processed DataFrame with the overhead in the "overhead" column
    """

    if "subtype" in metadata_columns:
        metadata_columns.remove("subtype")

    # initialize
    df["overhead"] = 0

    # store baselines
    baselines = {}
    for i, row in df.iterrows():
        if baseline_subtype != row["subtype"]:
            continue

        key = ""
        for c in metadata_columns:
            key += str(row[c])
        baselines[key] = row[data_column]

    # normalize the rest of the rows over the baselines
    for i, row in df.iterrows():
        key = ""
        for c in metadata_columns:
            key += str(row[c])
        normalize_over = baselines.get(key, 0.0)

        row["overhead"] = row[data_column] / normalize_over if normalize_over else np.nan
        df.iloc[i] = row  # copy the result into the dataframe

    return df
