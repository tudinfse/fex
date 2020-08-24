# -*- coding: utf-8 -*-
# snapshottest: v1 - https://goo.gl/zC4yUc
from __future__ import unicode_literals

from snapshottest import GenericRepr, Snapshot


snapshots = Snapshot()

snapshots['ExperimentsTest::test_csvGeneration 1'] = GenericRepr('       benchmark      thread_count      type      subtype\n0  <benchmark-0>  <thread_count-0>  <type-0>  <subtype-0>\n1  <benchmark-1>  <thread_count-1>  <type-1>  <subtype-1>\n2  <benchmark-2>  <thread_count-2>  <type-2>  <subtype-2>')
