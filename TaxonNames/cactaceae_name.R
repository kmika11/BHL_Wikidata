library(rbhl)
library(dplyr)
library(tidyr)
library(jsonlite)

options(bhl_key = "your_api_key")

#get itemIDs from titleID 46288 "The Cactaceae:..."
cactus <- bhl_gettitlemetadata(46288,TRUE,as="json")
cactus <- fromJSON(cactus)
items <- cactus$Result$Items$ItemID

#get pageIDs for each itemID

d <- bhl_getitemmetadata(itemid=items[1])

for(i in 1:length(items)){
  name <- bhl_getitemmetadata(itemid=items[i])
    d <- rbind(d,name)
}

pages <- d$Pages.PageID

#get name list from each pageID

e <- data.frame()

for(i in 1:length(pages)){
  tryCatch({
    parse_name <- bhl_getpagenames(pages[i])
  },error=function(e){})
  tryCatch({
  e <- bind_rows(e,parse_name)},
  error=function(e){})
}

#write data frame to csv!

write.csv(e,"cactaceae_names.csv")

#create table with unique EOL IDs

f <- e[!duplicated(e[,2]),]
write.csv(f,"cactaceae_unique.csv")
