library(rbhl)
library(dplyr)

options(options(bhl_key = "your_api_key"))

## select a number of random names to draw
n = 2000

dois <- read.delim("doi.txt",sep="\t")
## select random dois to sample
IDs <- sample(1:length(dois$DOI), n)
dois <- dois[IDs,]

parts <- dois[dois$EntityType=="Part",]
parts$DOI <- factor(parts$DOI)
parts <- levels(parts$DOI)

## start parts search!

## initialize data.frame
p <- data.frame()

for(i in 1:length(parts)){
  tryCatch({
    data <- bhl_getpartbyidentifier(type="doi", value=parts[i])

    # initialize data1
    data1 <- data.frame()
    for(j in 1:length(data.frame(data$Authors)$CreatorID)){
      d1 <- data[,c("Doi","PartID","ItemID","Title")]
      d1$CreatorID <- data.frame(data$Authors)$CreatorID[j]
      d1$Author <- data.frame(data$Authors)$Name[j]
      d1$segment <- "Part"
      data <- bind_rows(data1,d1)
    }

    p <- bind_rows(p,data)
  }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
}

titles <- dois[dois$EntityType=="Title",]
titles$DOI <- factor(titles$DOI)
titles <- levels(titles$DOI)

## start titles search!

## initialize data.frame
t <- data.frame()

for(i in 1:length(titles)){
  tryCatch({
    data <- bhl_gettitlebyidentifier(type="doi", value=titles[i])

    # initialize data1
    data1 <- data.frame()
    for(j in 1:length(data.frame(data$Authors)$CreatorID)){
      d1 <- data[,c("Doi","FullTitle")]
      d1$CreatorID <- data.frame(data$Authors)$CreatorID[j]
      d1$Author <- data.frame(data$Authors)$Name[j]
      d1$segment <- "Title"
      data <- bind_rows(data1,d1)
    }

    t <- bind_rows(t,data)
  }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
}

colnames(t) <- c("Doi","Title","segment","CreatorID","Author")
d <-bind_rows(p,t)

# write to csv!
write.csv(d, file="bhl_creatorIDs_sample.csv")
