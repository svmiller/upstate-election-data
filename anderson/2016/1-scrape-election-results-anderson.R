library(tidyverse)
library(rvest)
library(stringr)

setwd("~/Dropbox/democrats/election-results-data/anderson/2016")

# Turnout is fairly easy.
# -----------------------

andeturnouturl <- read_html("http://www.enr-scvotes.org/SC/Anderson/64662/183596/en/vt_data.html")

andeturnout = html_table(html_nodes(andeturnouturl, "table")[[4]])

removethese <- c(-16,-32, -48, -64, -80)

andeturnout <- andeturnout[removethese,]

names(andeturnout) <- c("precinct","bc","rv","vtp")

andeturnout$bc <- as.numeric(gsub(',', '', andeturnout$bc))
andeturnout$rv <- as.numeric(gsub(',', '', andeturnout$rv))
andeturnout$vtp <- with(andeturnout, (bc/rv)*100)
andeturnout$county <- "anderson"

andeturnout <- andeturnout[,c(5,1:4)]

write_csv(andeturnout, "2016-ge-andeturnout.csv")


# Straight-ticket data.
# ---------------------

url <- "http://www.enr-scvotes.org/SC/Anderson/64662/183596/en/md_data.html?cid=0103&"

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", url), con="scrape.js")

system("phantomjs scrape.js > ande-st.html")

andesturl <- read_html("ande-st.html")

andest <- html_table(html_nodes(andesturl, "table")[[4]],fill=TRUE)

removethese <- c(-16,-32, -48, -64, -80, -96, -104)
andest <- andest[removethese,]
andest[1] <- NULL

names(andest) <- c("precinct","dem","wf","constitution",
                   "independence","green","gop",
                   "american","libertarian","sttotal")


andest[, 2:10] <- apply(andest[,2:10], 2, function(x) as.numeric(gsub(',', '',x)))
andest$county <- "anderson"

andest <- andest[,c(11,1:10)]

write_csv(andest, "2016-ge-andest.csv")


# President data.
# ---------------

url <- "http://www.enr-scvotes.org/SC/Anderson/64662/183596/en/md_data.html?cid=0104&"

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", url), con="scrape.js")

system("phantomjs scrape.js > ande-potus.html")

andepotusurl <- read_html("ande-potus.html")

andepotus <- html_table(html_nodes(andepotusurl, "table")[[4]],fill=TRUE)

andepotus <- andepotus[removethese,]
andepotus[1] <- NULL

names(andepotus) <- c("precinct","clinton","castle","mcmullin",
                      "stein","trump","skewes",
                      "johnson","potustotal")

andepotus[, 2:9] <- apply(andepotus[,2:9], 2, function(x) as.numeric(gsub(',', '',x)))
andepotus$county <- "anderson"

andepotus <- andepotus[,c(10,1:9)]

write_csv(andepotus, "2016-ge-andepotus.csv")



# Senate race data.
# -----------------

url <- "http://www.enr-scvotes.org/SC/Anderson/64662/183596/en/md_data.html?cid=0105&"

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", url), con="scrape.js")

system("phantomjs scrape.js > ande-senate.html")

andesenurl <- read_html("ande-senate.html")

andesen <- html_table(html_nodes(andesenurl, "table")[[4]],fill=TRUE)

andesen <- andesen[removethese,]
andesen[1] <- NULL

# Weirdly enough, Dixon is triple-counted and Bledsoe is double-counted. Fucking SC votes...

names(andesen) <- c("precinct","dixon","dixon2","bledsoe",
                    "dixon3","scott","scarborough",
                    "bledsoe2","senwritein","sentotal")

andesen[, 2:10] <- apply(andesen[,2:10], 2, function(x) as.numeric(gsub(',', '',x)))

andesen$dixon <- with(andesen, dixon+dixon2+dixon3)
andesen$dixon2 <- andesen$dixon3 <- NULL

andesen$bledsoe <- with(andesen, bledsoe + bledsoe2)
andesen$bledsoe2 <- NULL

andesen$county <- "anderson"

andesen <- andesen[,c(8,1:7)]

write_csv(andesen, "2016-ge-andesen.csv")

# House race data.
# ----------------

url <- "http://www.enr-scvotes.org/SC/Anderson/64662/183596/en/md_data.html?cid=0106&"

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", url), con="scrape.js")

system("phantomjs scrape.js > ande-house.html")

andehouseurl <- read_html("ande-house.html")

andehouse <- html_table(html_nodes(andehouseurl, "table")[[4]],fill=TRUE)

andehouse <- andehouse[removethese,]
andehouse[1] <- NULL

names(andehouse) <- c("precinct","cleveland","duncan","housewritein","housetotal")

andehouse[, 2:5] <- apply(andehouse[,2:5], 2, function(x) as.numeric(gsub(',', '',x)))

andehouse$county <- "anderson"

andehouse <- andehouse[,c(6,1:5)]

write_csv(andehouse, "2016-ge-andehouse.csv")

Anderson <- left_join(andeturnout, andest) %>%
  left_join(., andepotus) %>%
  left_join(., andesen) %>%
  left_join(., andehouse) %>%
  tbl_df()

write_csv(Anderson, "2016-ge-ande-total.csv")
