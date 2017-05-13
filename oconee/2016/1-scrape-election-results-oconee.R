setwd("~/Dropbox/democrats/election-results-data/oconee/2016")

library(rvest)
library(stringr)
library(dplyr)

# Turnout is fairly easy.
# -----------------------

oconturnurl <- read_html("http://www.enr-scvotes.org/SC/Oconee/64695/183642/en/vt_data.html")


oconturnout = html_table(html_nodes(oconturnurl, "table")[[4]])

oconturnout <- oconturnout[c(-16,-32),]

names(oconturnout) <- c("precinct","bc","rv","vtp")

oconturnout$bc <- as.numeric(gsub(',', '', oconturnout$bc))
oconturnout$rv <- as.numeric(gsub(',', '', oconturnout$rv))
oconturnout$vtp <- with(oconturnout, (bc/rv)*100)
oconturnout$county <- "oconee"

oconturnout <- oconturnout[,c(5,1:4)]

write.table(oconturnout,file="2016-ge-oconturnout.csv",sep=",",row.names=F,na="") 

# Straight-ticket data.
# ---------------------

url <- "http://www.enr-scvotes.org/SC/Oconee/64695/183642/en/md_data.html?cid=0103"

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", url), con="scrape.js")

system("phantomjs scrape.js > ocon-st.html")

oconsturl <- read_html("ocon-st.html")

oconst <- html_table(html_nodes(oconsturl, "table")[[4]],fill=TRUE)

oconst <- oconst[c(-16,-32, -39),]
oconst[1] <- NULL

names(oconst) <- c("precinct","dem","wf","constitution",
                   "independence","green","gop",
                   "american","libertarian","sttotal")


oconst[, 2:10] <- apply(oconst[,2:10], 2, function(x) as.numeric(gsub(',', '',x)))
oconst$county <- "oconee"

oconst <- oconst[,c(11,1:10)]

write.table(oconst,file="2016-ge-oconst.csv",sep=",",row.names=F,na="") 

# President data.
# ---------------

url <- "http://www.enr-scvotes.org/SC/Oconee/64695/183642/en/md_data.html?cid=0104&"

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", url), con="scrape.js")

system("phantomjs scrape.js > ocon-potus.html")

oconpotusurl <- read_html("ocon-potus.html")

oconpotus <- html_table(html_nodes(oconpotusurl, "table")[[4]],fill=TRUE)

oconpotus <- oconpotus[c(-16,-32, -39),]
oconpotus[1] <- NULL

names(oconpotus) <- c("precinct","clinton","castle","mcmullin",
                   "stein","trump","skewes",
                   "johnson","potustotal")

oconpotus[, 2:9] <- apply(oconpotus[,2:9], 2, function(x) as.numeric(gsub(',', '',x)))
oconpotus$county <- "oconee"

oconpotus <- oconpotus[,c(10,1:9)]

write.table(oconpotus,file="2016-ge-oconpotus.csv",sep=",",row.names=F,na="") 

# Senate race data.
# -----------------

url <- "http://www.enr-scvotes.org/SC/Oconee/64695/183642/en/md_data.html?cid=0105&"

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", url), con="scrape.js")

system("phantomjs scrape.js > ocon-senate.html")

oconsenurl <- read_html("ocon-senate.html")

oconsen <- html_table(html_nodes(oconsenurl, "table")[[4]],fill=TRUE)

oconsen <- oconsen[c(-16,-32, -39),]
oconsen[1] <- NULL

# Weirdly enough, Dixon is triple-counted and Bledsoe is double-counted. Fucking SC votes...

names(oconsen) <- c("precinct","dixon","dixon2","bledsoe",
                      "dixon3","scott","scarborough",
                      "bledsoe2","senwritein","sentotal")

oconsen[, 2:10] <- apply(oconsen[,2:10], 2, function(x) as.numeric(gsub(',', '',x)))

oconsen$dixon <- with(oconsen, dixon+dixon2+dixon3)
oconsen$dixon2 <- oconsen$dixon3 <- NULL

oconsen$bledsoe <- with(oconsen, bledsoe + bledsoe2)
oconsen$bledsoe2 <- NULL

oconsen$county <- "oconee"

oconsen <- oconsen[,c(8,1:7)]

write.table(oconsen,file="2016-ge-oconsen.csv",sep=",",row.names=F,na="")

# House race data.
# ----------------

url <- "http://www.enr-scvotes.org/SC/Oconee/64695/183642/en/md_data.html?cid=0106&"

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", url), con="scrape.js")

system("phantomjs scrape.js > ocon-house.html")

oconhouseurl <- read_html("ocon-house.html")

oconhouse <- html_table(html_nodes(oconhouseurl, "table")[[4]],fill=TRUE)

oconhouse <- oconhouse[c(-16,-32, -39),]
oconhouse[1] <- NULL

names(oconhouse) <- c("precinct","cleveland","duncan","housewritein","housetotal")

oconhouse[, 2:5] <- apply(oconhouse[,2:5], 2, function(x) as.numeric(gsub(',', '',x)))

oconhouse$county <- "oconee"

oconhouse <- oconhouse[,c(6,1:5)]

write.table(oconhouse,file="2016-ge-oconhouse.csv",sep=",",row.names=F,na="")


Oconee <- left_join(oconturnout, oconst) %>%
  left_join(., oconpotus) %>%
  left_join(., oconsen) %>%
  left_join(., oconhouse) %>%
  as.data.frame()

write.table(Oconee,file="2016-ge-ocon-total.csv",sep=",",row.names=F,na="")
