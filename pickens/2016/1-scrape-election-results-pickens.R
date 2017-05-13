library(tidyverse)
library(rvest)
library(stringr)

setwd("~/Dropbox/democrats/election-results-data/2016")

# Turnout is fairly easy.
# -----------------------

pickturnouturl <- read_html("http://www.enr-scvotes.org/SC/Pickens/64697/183644/en/vt_data.html")

pickturnout = html_table(html_nodes(pickturnouturl, "table")[[4]])

pickturnout <- pickturnout[c(-16,-32, -48, -64),]

names(pickturnout) <- c("precinct","bc","rv","vtp")

pickturnout$bc <- as.numeric(gsub(',', '', pickturnout$bc))
pickturnout$rv <- as.numeric(gsub(',', '', pickturnout$rv))
pickturnout$vtp <- with(pickturnout, (bc/rv)*100)
pickturnout$county <- "pickens"

pickturnout <- pickturnout[,c(5,1:4)]

write_csv(pickturnout, "2016-ge-pickturnout.csv")


# Straight-ticket data.
# ---------------------

url <- "http://www.enr-scvotes.org/SC/Pickens/64697/183644/en/md_data.html?cid=0103&"

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", url), con="scrape.js")

system("phantomjs scrape.js > pick-st.html")

picksturl <- read_html("pick-st.html")

pickst <- html_table(html_nodes(picksturl, "table")[[4]],fill=TRUE)

pickst <- pickst[c(-16,-32, -48, -64, -75),]
pickst[1] <- NULL

names(pickst) <- c("precinct","dem","wf","constitution",
                   "independence","green","gop",
                   "american","libertarian","sttotal")


pickst[, 2:10] <- apply(pickst[,2:10], 2, function(x) as.numeric(gsub(',', '',x)))
pickst$county <- "pickens"

pickst <- pickst[,c(11,1:10)]

write.table(pickst,file="2016-ge-pickst.csv",sep=",",row.names=F,na="")


# President data.
# ---------------

url <- "http://www.enr-scvotes.org/SC/Pickens/64697/183644/en/md_data.html?cid=0104&"

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", url), con="scrape.js")

system("phantomjs scrape.js > pick-potus.html")

pickpotusurl <- read_html("pick-potus.html")

pickpotus <- html_table(html_nodes(pickpotusurl, "table")[[4]],fill=TRUE)

pickpotus <- pickpotus[c(-16,-32, -48, -64, -75),]
pickpotus[1] <- NULL

names(pickpotus) <- c("precinct","clinton","castle","mcmullin",
                      "stein","trump","skewes",
                      "johnson","potustotal")

pickpotus[, 2:9] <- apply(pickpotus[,2:9], 2, function(x) as.numeric(gsub(',', '',x)))
pickpotus$county <- "pickens"

pickpotus <- pickpotus[,c(10,1:9)]

write.table(pickpotus,file="2016-ge-pickpotus.csv",sep=",",row.names=F,na="") 



# Senate race data.
# -----------------

url <- "http://www.enr-scvotes.org/SC/Pickens/64697/183644/en/md_data.html?cid=0105&"

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", url), con="scrape.js")

system("phantomjs scrape.js > pick-senate.html")

picksenurl <- read_html("pick-senate.html")

picksen <- html_table(html_nodes(picksenurl, "table")[[4]],fill=TRUE)

picksen <- picksen[c(-16,-32, -48, -64, -75),]
picksen[1] <- NULL

# Weirdly enough, Dixon is triple-counted and Bledsoe is double-counted. Fucking SC votes...

names(picksen) <- c("precinct","dixon","dixon2","bledsoe",
                    "dixon3","scott","scarborough",
                    "bledsoe2","senwritein","sentotal")

picksen[, 2:10] <- apply(picksen[,2:10], 2, function(x) as.numeric(gsub(',', '',x)))

picksen$dixon <- with(picksen, dixon+dixon2+dixon3)
picksen$dixon2 <- picksen$dixon3 <- NULL

picksen$bledsoe <- with(picksen, bledsoe + bledsoe2)
picksen$bledsoe2 <- NULL

picksen$county <- "pickens"

picksen <- picksen[,c(8,1:7)]

write.table(picksen,file="2016-ge-picksen.csv",sep=",",row.names=F,na="")

# House race data.
# ----------------

url <- "http://www.enr-scvotes.org/SC/Pickens/64697/183644/en/md_data.html?cid=0106&"

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", url), con="scrape.js")

system("phantomjs scrape.js > pick-house.html")

pickhouseurl <- read_html("pick-house.html")

pickhouse <- html_table(html_nodes(pickhouseurl, "table")[[4]],fill=TRUE)

pickhouse <- pickhouse[c(-16,-32, -48, -64, -75),]
pickhouse[1] <- NULL

names(pickhouse) <- c("precinct","cleveland","duncan","housewritein","housetotal")

pickhouse[, 2:5] <- apply(pickhouse[,2:5], 2, function(x) as.numeric(gsub(',', '',x)))

pickhouse$county <- "pickens"

pickhouse <- pickhouse[,c(6,1:5)]

write.table(pickhouse,file="2016-ge-pickhouse.csv",sep=",",row.names=F,na="")

Pickens <- left_join(pickturnout, pickst) %>%
  left_join(., pickpotus) %>%
  left_join(., picksen) %>%
  left_join(., pickhouse) %>%
  tbl_df()

write.table(Pickens,file="2016-ge-pick-total.csv",sep=",",row.names=F,na="")

