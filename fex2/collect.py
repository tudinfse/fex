import csv
import re


def parse_time(s):
    """
    Parse time as reported by /usr/bin/time, i.e., [hours:]minutes:seconds"
    and return it as number of seconds (float )
    Return 0.0 if does not match
    """
    s = s.replace(',', '.')  # due to different locales

    pattern = r"((\d{0,2}):)?(\d{1,2}):(\d{1,2}\.\d{1,5})"
    match = re.search(pattern, s)
    if not match:
        return 0.0

    hours = int(match.group(2)) if match.group(2) else 0
    minutes = int(match.group(3))
    seconds = float(match.group(4))

    return hours * 3600 + minutes * 60 + seconds


def get_float_from_string(s):
    s = s.replace(',', '.')         # due to different locales
    pattern = r'\d{1,10}\.\d{1,10}'
    match = re.search(pattern, s)
    if match:
        match = match.group(0)
        result = float(match)
        return result
    return 0.0


def get_int_from_string(s, ignore_period=True, ignore_comma=True):
    if ignore_period:
        s = s.replace('.', '')
    if ignore_comma:
        s = s.replace(',', '')
    pattern = r'\d{1,20}'
    match = re.search(pattern, s)
    if match:
        match = match.group(0)
        result = int(match)
        return result
    return 0


def get_run_argument(name, line):
    try:
        return re.search(r'%s: (\S+);' % name, line).group(1)
    except AttributeError as e:
        print("Wrong format of the log file")
        raise e


def parse_logs(experiment_output, parsed_csv, parsers):
    """
    A somewhat generic benchmark output parser
    """
    new_experiment_keyword = '[FEX2] '
    with open(experiment_output, 'r') as infile:
        with open(parsed_csv, 'w') as outfile:
            field_names = ['benchmark', 'type', 'subtype', 'thread_count'] + list(parsers.keys())
            writer = csv.DictWriter(outfile, fieldnames=field_names)
            writer.writeheader()
            values = {}

            for line in infile.readlines():
                # Did we reach the next run?
                if line.startswith(new_experiment_keyword):
                    # Write out the results of the previous experiment
                    if values:  # skip if it's the first experiment in the log
                        writer.writerow(values)

                    # Remove old data
                    values = {i: '' for i in field_names}

                    # parse results of the next run (custom params are nullified)
                    values['benchmark'] = get_run_argument('benchmark', line)
                    values['thread_count'] = get_run_argument('thread_count', line)
                    build_type = get_run_argument('type', line).split('_')
                    assert(len(build_type) == 2)
                    values['type'] = build_type[0]
                    values['subtype'] = build_type[1]

                    continue

                # Otherwise, search for the desired data in the line
                for parameter, parser in parsers.items():
                    key = parser[0]
                    parse_function = parser[1]
                    if key in line:
                        values[parameter] = parse_function(line)

            # write results form the last log entry
            writer.writerow(values)
