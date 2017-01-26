library(ggplot2)
library(plyr)
library(psych)

path = paste(Sys.getenv("DATA_PATH"), "/results/sqlite3_perf", sep = "")
setwd(path)

df <- read.table('raw.csv', header = T, sep = ",")

df <- aggregate(time ~ compiler + type + bench + threads + compiler, data = df, mean)
df <- aggregate(cbind(total_tput, total_lat) ~ bench + type + threads + input + compiler, data = df, mean)

df$total_tput = df$total_tput / 1000              # from messages -> thousands of messages
df$total_lat = df$total_lat * 1000 * 1000 # from seconds -> microseconds

# threads - max tput
pl <- ggplot(df, aes(x=threads, y=total_tput, colour=type, shape=type)) +
    geom_line() +
    geom_point() +
    theme_bw() +
    scale_colour_brewer(palette="Set1") +
    theme(legend.title=element_blank(), legend.position="top") +
    xlab("# Threads") +
    ylab("Throughput, 1000 messages")
pl <- pl + facet_grid(. ~ input)
ggsave("plot.pdf")

# emit gnuplot-style table: scalability of sqlite3
df1 = subset(df, type %in% c("native", "avxswift"))
df1 = subset(df1, select=c("bench", "type", "input", "threads", "total_tput"))
df1 = reshape(df1, idvar=c("bench", "threads", "input"), timevar="type", direction="wide")
df1 = reshape(df1, idvar=c("bench", "threads"), timevar="input", direction="wide")
write.table(df1, file = "sqlite3-scalability.txt", row.names = FALSE, na = "0")
