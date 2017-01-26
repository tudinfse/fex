/* Copyright (c) 2011 The LevelDB Authors. All rights reserved.
   Use of this source code is governed by a BSD-style license that can be
   found in the LICENSE file. See the AUTHORS file for names of contributors. */

#include "sqlite3.h"
#include "bench_common.h"

#include <getopt.h>
#include <unistd.h>
#include <math.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <sys/time.h>
#include <pthread.h>

pthread_t thread_id;

static char *put_str = "REPLACE INTO test (key, value) VALUES (?, ?)";
static char *get_str = "SELECT value FROM test WHERE key = ?";

static sqlite3 *db;
static sqlite3_stmt *put_stmt, *get_stmt;

static char* key = "dummykey";
static char* val = "dummyvalue";

static int status;

/* wrapper of set command */
static int _put(sqlite3 *db, sqlite3_stmt *put_stmt, char *key, char *val) {
  int status;

  status = sqlite3_bind_text(put_stmt, 1, key, strlen(key), SQLITE_STATIC);
  if (status != SQLITE_OK) return 1;
  status = sqlite3_bind_text(put_stmt, 2, val, strlen(val), SQLITE_STATIC);
  if (status != SQLITE_OK) return 1;

  status = sqlite3_step(put_stmt);
  if (status != SQLITE_DONE) return 1;

  printf("put: %s\n", val);

  status = sqlite3_clear_bindings(put_stmt);
  if (status != SQLITE_OK) return 1;
  status = sqlite3_reset(put_stmt);
  if (status != SQLITE_OK) return 1;

  return 0;
}

/* wrapper of get command */
static char* _get(sqlite3 *db, sqlite3_stmt *get_stmt, char *key) {
  int status;
  char *val;

  status = sqlite3_bind_text(get_stmt, 1, key, strlen(key), SQLITE_STATIC);
  if (status != SQLITE_OK) return NULL;

  status = sqlite3_step(get_stmt);
  if (status == SQLITE_ROW)
    val = sqlite3_column_text(get_stmt, 0);
  else
    val = NULL;

  if (val)
    printf("get: %s\n", val);

  status = sqlite3_clear_bindings(get_stmt);
  if (status != SQLITE_OK) return NULL;
  status = sqlite3_reset(get_stmt);
  if (status != SQLITE_OK) return NULL;

  return val;
}


static void *thread_start(void *arg) {
  // put dummy value
  status = sqlite3_prepare_v2(db, put_str, -1, &put_stmt, NULL);
  if (status != SQLITE_OK) {
    fprintf(stderr, "Cannot prepare statement during put\n");
    exit(1);
  }
  status = _put(db, put_stmt, key, val);
  if (status != 0) {
    fprintf(stderr, "Cannot put\n");
    exit(1);
  }
  status = sqlite3_finalize(put_stmt);
  if (status != SQLITE_OK) {
    fprintf(stderr, "Cannot finalize statement during put\n");
    exit(1);
  }

  // get dummy value
  status = sqlite3_prepare_v2(db, get_str, -1, &get_stmt, NULL);
  if (status != SQLITE_OK) {
    fprintf(stderr, "Cannot prepare statement during get\n");
    exit(1);
  }
  char *gotval = _get(db, get_stmt, key);
  if (gotval == NULL) {
    fprintf(stderr, "Cannot get\n");
    exit(1);
  }

  status = sqlite3_finalize(get_stmt);
  if (status != SQLITE_OK) {
    fprintf(stderr, "Cannot finalize statement during get\n");
    exit(1);
  }
  
  return NULL;
}

int
main(int argc, char **argv)
{
  status = sqlite3_open(":memory:", &db);
  if (status != SQLITE_OK) {   
    fprintf(stderr, "Cannot open database\n");
    exit(1);
  }

  char *err_msg = 0;
  char *sql = "CREATE TABLE test (key TEXT, value TEXT, PRIMARY KEY(key))";
  status = sqlite3_exec(db, sql, 0, 0, &err_msg);
  if (status != SQLITE_OK) {
    fprintf(stderr, "SQL error\n");
    exit(1);
  }

  pthread_create(&thread_id, NULL, thread_start, NULL);
  pthread_join(thread_id, NULL);

  sqlite3_close(db);

  printf("bye\n");
  return 0;
}

