library(ggplot2)
library(plyr)
library(psych)

spath = paste(Sys.getenv("DATA_PATH"), "/results/postgresql_perf", sep = "")
setwd(path)

df <- read.table('raw.csv', header = T, sep = ",")

df <- aggregate(cbind(tps, latency) ~ bench + type + threads + num_clients + input, data = df, mean)

df$tps = df$tps / 1000              # from messages -> thousands of messages
df$latency = df$latency * 1000 # from miliseconds -> microseconds

# tps - latency
pl <- ggplot(df, aes(x=tps, y=latency, colour=type, shape=type)) +
    geom_path() +
    geom_point() +
    theme_bw() +
    scale_colour_brewer(palette="Set1") +
    theme(legend.title=element_blank(), legend.position="top") +
    ylim(0, 150) +
    xlab("Throughput, 1000 messages") +
    ylab("Latency, us")
pl + facet_grid(threads ~ input)
ggsave("postgresql_perf/tps_latency.pdf")

# threads - max tps
df <- aggregate(tps ~ bench + type + threads + input, data = df, max)

pl <- ggplot(df, aes(x=threads, y=tps, colour=type, shape=type)) +
    geom_line() +
    geom_point() +
    theme_bw() +
    scale_colour_brewer(palette="Set1") +
    theme(legend.title=element_blank(), legend.position="top") +
    xlab("# Threads") +
    ylab("Throughput, 1000 messages")
pl + facet_grid(. ~ input)
ggsave("postgresql_perf/plot.pdf")

# emit gnuplot-style table: scalability of sqlite3
df1 = subset(df, type %in% c("llvm_native"))
df1 = subset(df1, select=c("bench", "type", "input", "threads", "tps"))
df1 = reshape(df1, idvar=c("bench", "threads", "input"), timevar="type", direction="wide")
df1 = reshape(df1, idvar=c("bench", "threads"), timevar="input", direction="wide")
write.table(df1, file = "postgresql_perf/scalability.txt", row.names = FALSE, na = "0")
