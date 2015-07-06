rm(list =ls())
library(readxl)
library(dplyr)
library(RWeka)
library(stringr)

fin <- list.files(path = "data/", full.names = T)
ds.list <- lapply(fin, read_excel, col_names = F)
ds <- unique(do.call(rbind.data.frame, ds.list))
emoticons <- read.csv("emoticon_conversion_noGraphic.csv", header = F)
names(emoticons) <- c("unicode", "bytes","description")
rm(ds.list)
rm(fin)

names(ds) <- c("created","screenName", "text" , "ID", "map.info.A", "map.info.B")

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
emoji.indexes <- which(rowSums(emoji.frequency > -1) > 0)
emoji.ds <- NULL
for(i in emoji.indexes){
  
  valid.cols <- which(emoji.frequency[i,]>-1)
  for(j in valid.cols){
    emoji.ds <- rbind(cbind(ds[i,], emoticons[j,]), emoji.ds)
  }
}

# extract x, y coordinates
temp <- str_extract(emoji.ds$map.info.B,"\\d.*(,)-\\d.*(&z=14)")
locations = strsplit(temp, ",")
x <- as.numeric(unlist(lapply(locations, function(x)x[1])))
y <- as.numeric(
  unlist(
    lapply(locations, 
           function(x)strsplit(x[2], "&z")[[1]][1])))

emoji.ds$latitude = x
emoji.ds$longitude = y

# give us a CSV
write.csv(emoji.ds, file = "twimoji.csv")
