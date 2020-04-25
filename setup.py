#!/usr/bin/env python
import sys
import os
from setuptools import setup

CURRENT_PYTHON = sys.version_info[:2]
REQUIRED_PYTHON = (3, 7)

# This check and everything above must remain compatible with Python 2.7.
if CURRENT_PYTHON < REQUIRED_PYTHON:
    sys.stderr.write("""
==========================
Unsupported Python version
==========================
This version of Fex requires Python {}.{}, but you're trying to
install it on Python {}.{}.
""".format(*(REQUIRED_PYTHON + CURRENT_PYTHON)))
    sys.exit(1)


def package_files(directory):
    paths = []
    for (path, directories, filenames) in os.walk(directory):
        for filename in filenames:
            paths.append(os.path.join('..', path, filename))
    return paths


setup(name='fex2',
      version='2.0',
      description='A Software Evaluation Framework',
      author='Oleksii Oleksenko',
      url='https://github.com/tudinfse/fex',
      packages=['fex2'],
      package_data={'fex2': package_files('fex2/preconfigured/')},
      entry_points={
          "console_scripts": [
              "fex2=fex2.cli:main",
          ],
      },
      install_requires=[
          'pandas>=1.0.2',
          'numpy>=1.18.1',
          'scipy>=1.4.1',
          'matplotlib>=3.2.1',
          'pyyaml>=5.1'
      ],
      )
