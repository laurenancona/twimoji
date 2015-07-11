rm(list =ls())
library(readxl)
library(dplyr)
library(RWeka)
library(lubridate)
library(stringr)

# import all tweet data####
fin <- list.files(path = "data/", full.names = T)
ds.list <- lapply(fin, read_excel, col_names = F)
ds <- unique(do.call(rbind.data.frame, ds.list))
# change column names 
names(ds) <- c("created","screenName", "text" , "ID", "map.info.A", "map.info.B")
# convert date
ds$created <- mdy_hm(ds$created)

write.csv(ds, file="urtweets.csv")

# import emoticon table ####
emoticons <- read.csv("emoticon_conversion_noGraphic.csv", header = F)
# set colum names
names(emoticons) <- c("unicode", "bytes","description")
rm(ds.list)
rm(fin)


# get word frequencies and tokens
tokens <- WordTokenizer(ds$text)

# create an argument for Weka Control
# tokenize tweets
n.gram.options <- Weka_control(max = 4, min = 2)
ngram_2 <- NGramTokenizer(ds$text, n.gram.options)
t <- arrange(as.data.frame(table(tokens)), desc(Freq))

# search for all emoticons 
# emoji frequency - rows: individual tweets
# emoji frequency - columns : emojis
emoji.frequency <- matrix(NA, nrow = nrow(ds), ncol = nrow(emoticons))
for(i in 1:nrow(emoticons)){
  print(i)
  emoji.frequency[,i] <- regexpr(emoticons$bytes[i],ds$text, useBytes = T )
}

emoji.counts <- colSums(emoji.frequency>-1)
emoticons <- cbind(emoji.counts, emoticons)



# emoticons <- arrange(emoticons, desc(emoji.counts))

# get data set of all rows with emojis and identify the emoji type
# emoji.ds contains all tweet info with description of emoji found
emoji.per.tweet <- rowSums(emoji.frequency > -1)
emoji.indexes <- which( emoji.per.tweet > 0)
emoji.ds <- NULL
for(i in emoji.indexes){
  
  valid.cols <- which(emoji.frequency[i,]>-1)
  for(j in valid.cols){
    emoji.ds <- rbind(cbind(ds[i,], emoticons[j,]), emoji.ds)
  }
}

# extract x, y coordinates ####
temp <- str_extract(emoji.ds$map.info.B,"\\d.*(,)-\\d.*(&z=14)")
locations = strsplit(temp, ",")
emoji.ds$latitude <- as.numeric(unlist(lapply(locations, function(x)x[1])))
emoji.ds$longitude <- as.numeric(
  unlist(
    lapply(locations, 
           function(x)strsplit(x[2], "&z")[[1]][1])))


# stats####
percentage.emoji <- 100*length(emoji.indexes)/nrow(ds)
cat("percentage of tweets with emoji: ",  round(percentage.emoji,2),"%", sep = "")

# 
print("Summary of emoji use per tweet (all tweets): \n")
print(summary(emoji.per.tweet))
print("Summary of emoji use per tweet (all tweets containing at least one emoji: \n")
print(summary(emoji.per.tweet[emoji.indexes]))

# write csv containing rows for each unique tweet:emoji combo ####
write.csv(emoji.ds, file = "twimoji.csv")

# write csv containing frequencies of emojis
write.csv(arrange(emoticons, desc(emoji.counts)), "emoticon_counts.csv")
