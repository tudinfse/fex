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

pthread_mutex_t printmutex;

typedef struct {
  size_t tid;
  sqlite3 *db;
  query *queries;
  size_t num_ops;
  size_t num_puts;
  size_t num_gets;
  size_t num_miss;
  size_t num_hits;
  double tput;
  double time;
} thread_param;

/* default parameter settings */
static size_t key_len;
static size_t val_len;
static size_t num_queries;
static size_t num_threads = 1;
static float duration = 10.0;

static char* loadfile = NULL;
static char* runfile  = NULL;

char *put_str = "REPLACE INTO test (key, value) VALUES (?, ?)";
char *get_str = "SELECT value FROM test WHERE key = ?";

/* Calculate the second difference*/
static double timeval_diff(struct timeval *start, 
                           struct timeval *end)
{
  double r = end->tv_sec - start->tv_sec;

  /* Calculate the microsecond difference */
  if (end->tv_usec > start->tv_usec)
    r += (end->tv_usec - start->tv_usec)/1000000.0;
  else if (end->tv_usec < start->tv_usec)
    r -= (start->tv_usec - end->tv_usec)/1000000.0;
  return r;
}

/* wrapper of set command */
static int _put(sqlite3 *db, sqlite3_stmt *put_stmt, char *key, char *val) {
  int status;

  status = sqlite3_bind_blob(put_stmt, 1, key, key_len, SQLITE_STATIC);
  if (status != SQLITE_OK) return 1;
  status = sqlite3_bind_blob(put_stmt, 2, val, val_len, SQLITE_STATIC);
  if (status != SQLITE_OK) return 1;

  status = sqlite3_step(put_stmt);
  if (status != SQLITE_DONE) return 1;

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

  status = sqlite3_bind_blob(get_stmt, 1, key, key_len, SQLITE_STATIC);
  if (status != SQLITE_OK) return NULL;

  status = sqlite3_step(get_stmt);
  if (status == SQLITE_ROW)
    val = sqlite3_column_blob(get_stmt, 0);
  else
    val = NULL;

  status = sqlite3_clear_bindings(get_stmt);
  if (status != SQLITE_OK) return NULL;
  status = sqlite3_reset(get_stmt);
  if (status != SQLITE_OK) return NULL;

  return val;
}

/* init all queries from the ycsb trace file before issuing them */
static query *queries_init(char* filename)
{
  FILE *input;

  input = fopen(filename, "rb");
  if (input == NULL) {
    perror("can not open file");
    perror(filename);
    exit(1);
  }

  int n;
  n = fread(&key_len, sizeof(key_len), 1, input);
  if (n != 1)
    perror("fread error");
  n = fread(&val_len, sizeof(val_len), 1, input);
  if (n != 1)
    perror("fread error");
  n = fread(&num_queries, sizeof(num_queries), 1, input);
  if (n != 1)
    perror("fread error");

  printf("trace(%s):\n", filename);
  printf("\tkey_len = %zu\n", key_len);
  printf("\tval_len = %zu\n", val_len);
  printf("\tnum_queries = %zu\n", num_queries);
  printf("\n");

  query *queries = malloc(sizeof(query) * num_queries);
  if (queries == NULL) {
    perror("not enough memory to init queries\n");
    exit(-1);
  }

  size_t num_read;
  num_read = fread(queries, sizeof(query), num_queries, input);
  if (num_read < num_queries) {
    fprintf(stderr, "num_read: %zu\n", num_read);
    perror("can not read all queries\n");
    fclose(input);
    exit(-1);
  }

  fclose(input);
  printf("queries_init...done\n");
  return queries;
}

/* executing queries at each thread */
static void* queries_exec(void *param)
{
  struct timeval tv_s, tv_e;

  thread_param* p = (thread_param*) param;

  int status;
  sqlite3_stmt *put_stmt, *get_stmt;
  status = sqlite3_prepare_v2(p->db, put_str, -1, &put_stmt, NULL);
  if (status != SQLITE_OK) exit(-1);
  status = sqlite3_prepare_v2(p->db, get_str, -1, &get_stmt, NULL);
  if (status != SQLITE_OK) exit(-1);

  pthread_mutex_lock (&printmutex);
  printf("start benching using thread %d\n", p->tid);
  pthread_mutex_unlock (&printmutex);

  query* queries = p->queries;
  p->time = 0;

  while (p->time < duration) {
    gettimeofday(&tv_s, NULL);  // start timing
    for (size_t i = 0 ; i < p->num_ops; i++) {
      enum query_types type = queries[i].type;
      char *key = queries[i].hashed_key;
      char buf[val_len];

      if (type == query_put) {
        _put(p->db, put_stmt, key, buf);
        p->num_puts++;
      } else if (type == query_get) {
        char *val = _get(p->db, get_stmt, key);
        p->num_gets++;
        if (val == NULL) {
          // cache miss, put something (gabage) in cache
          p->num_miss++;
          _put(p->db, put_stmt, key, buf);
        } else {
//          free(val);
          p->num_hits++;
        }
      } else {
        fprintf(stderr, "unknown query type\n");
      }
    }
    gettimeofday(&tv_e, NULL);  // stop timing
    p->time += timeval_diff(&tv_s, &tv_e);
  }

  size_t nops = p->num_gets + p->num_puts;
  p->tput = nops / p->time;

  pthread_mutex_lock (&printmutex);
  printf("thread %d gets %d items in %.2f sec \n",
         p->tid, nops, p->time);
  printf("#put = %zu, #get = %zu\n", p->num_puts, p->num_gets);
  printf("#miss = %zu, #hits = %zu\n", p->num_miss, p->num_hits);
  printf("hitratio = %.4f\n",   (float) p->num_hits / p->num_gets);
  printf("tput = %.2f\n",  p->tput);
  printf("\n");
  pthread_mutex_unlock (&printmutex);

  printf("queries_exec...done\n");

  status = sqlite3_finalize(put_stmt);
  if (status != SQLITE_OK) exit(-1);
  status = sqlite3_finalize(get_stmt);
  if (status != SQLITE_OK) exit(-1);

  pthread_exit(NULL);
}

static void usage(char* binname)
{
  printf("%s [-t #] [-l load_trace] [-r run_trace] [-d #] [-h]\n", binname);
  printf("\t-t #: number of working threads, by default %d\n", num_threads);
  printf("\t-d #: duration of the test in seconds, by default %f\n", duration);
  printf("\t-l load trace: e.g., /path/to/ycsbtrace, required\n");
  printf("\t-r run trace:  e.g., /path/to/ycsbtrace, required\n");
  printf("\t-h  : show usage\n");
}


int
main(int argc, char **argv)
{
  sqlite3 *db;

  if (argc <= 1) {
    usage(argv[0]);
    exit(-1);
  }

  char ch;
  while ((ch = getopt(argc, argv, "t:d:l:r:")) != -1) {
    switch (ch) {
    case 't': num_threads = atoi(optarg); break;
    case 'd': duration    = atof(optarg); break;
    case 'l': loadfile   = optarg; break;
    case 'r': runfile    = optarg; break;
    case 'h': usage(argv[0]); exit(0); break;
    default:
      usage(argv[0]);
      exit(-1);
    }
  }

  if (loadfile == NULL || runfile == NULL) {
    usage(argv[0]);
    exit(-1);
  }

  int status;
  status = sqlite3_open(":memory:", &db);
  if (status != SQLITE_OK) {   
    fprintf(stderr, "Cannot open database: %s\n", sqlite3_errmsg(db));
    sqlite3_close(db);        
    exit(-1);
  }

  char *err_msg = 0;
  char *sql = "CREATE TABLE test (key blob, value blob, PRIMARY KEY(key))";
  status = sqlite3_exec(db, sql, 0, 0, &err_msg);
  if (status != SQLITE_OK) {
    fprintf(stderr, "SQL error: %s\n", err_msg);
    sqlite3_free(err_msg);        
    sqlite3_close(db);
    exit(-1);
  }

  pthread_t threads[num_threads];
  pthread_attr_t attr;
  pthread_attr_init(&attr);
  pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);

  pthread_mutex_init(&printmutex, NULL);

  size_t real_num_threads = num_threads;
  for (int i = 0; i < 2; i++) {
      // first iteration  -- YCSB load phase;
      // second iteration -- YCSB run phase
      query *queries = NULL;

      if (i == 0) {
          num_threads = 1; // don't need more than 1 thread
          printf("----- LOAD PHASE -----\n");
          queries = queries_init(loadfile);
      }
      else {
          num_threads = real_num_threads; // restore real number of threads
          printf("----- RUN PHASE -----\n");
          queries = queries_init(runfile);
      }

      size_t t;
      thread_param tp[num_threads];
      for (t = 0; t < num_threads; t++) {
        tp[t].db = db;
        tp[t].queries = queries + t * (num_queries / num_threads);
        tp[t].tid     = t;
        tp[t].num_ops = num_queries / num_threads;
        tp[t].num_puts = tp[t].num_gets = tp[t].num_miss = tp[t].num_hits = 0;
        tp[t].time = tp[t].tput = 0.0;
        int rc = pthread_create(&threads[t], &attr, queries_exec, (void *) &tp[t]);
        if (rc) {
          perror("failed: pthread_create\n");
          exit(-1);
        }
      }

      result_t result;
      result.total_time = 0.0;
      result.total_tput = 0.0;
      result.total_latency = 0.0;
      result.total_hits = 0;
      result.total_miss = 0;
      result.total_gets = 0;
      result.total_puts = 0;
      result.num_threads = num_threads;

      for (t = 0; t < num_threads; t++) {
        void *status;
        int rc = pthread_join(threads[t], &status);
        if (rc) {
          perror("error, pthread_join\n");
          exit(-1);
        }
        result.total_time = (result.total_time > tp[t].time) ? result.total_time : tp[t].time;
        result.total_tput += tp[t].tput;
        result.total_latency += 1/tp[t].tput;
        result.total_hits += tp[t].num_hits;
        result.total_miss += tp[t].num_miss;
        result.total_gets += tp[t].num_gets;
        result.total_puts += tp[t].num_puts;
      }

      // final latency is the average of each thread's average latency
      result.total_latency = result.total_latency / result.num_threads;

      printf("total_time = %.2f\n", result.total_time);
      printf("total_tput = %.2f\n", result.total_tput);
      printf("total_lat  = %.9f\n", result.total_latency);
      printf("total_hitratio = %.4f\n", (float) result.total_hits / result.total_gets);
  }

  sqlite3_close(db);

  pthread_attr_destroy(&attr);
  printf("bye\n");
  return 0;
}

