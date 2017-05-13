library(tidyverse)
library(rvest)
library(stringr)

setwd("~/Dropbox/democrats/election-results-data/abbeville/2016")

# Turnout is fairly easy.
# -----------------------

abbeturnouturl <- read_html("http://www.enr-scvotes.org/SC/Abbeville/64659/183591/en/vt_data.html")

abbeturnout = html_table(html_nodes(abbeturnouturl, "table")[[4]])

# removethese <- c(-16,-32, -48, -64, -80)
# abbeturnout <- abbeturnout[removethese,]

names(abbeturnout) <- c("precinct","bc","rv","vtp")

abbeturnout$bc <- as.numeric(gsub(',', '', abbeturnout$bc))
abbeturnout$rv <- as.numeric(gsub(',', '', abbeturnout$rv))
abbeturnout$vtp <- with(abbeturnout, (bc/rv)*100)
abbeturnout$county <- "abbeville"

abbeturnout <- abbeturnout[,c(5,1:4)]

# write_csv(abbeturnout, "2016-ge-abbeturnout.csv")


# Straight-ticket data.
# ---------------------

url <- "http://www.enr-scvotes.org/SC/Abbeville/64659/183591/en/md_data.html?cid=0103&"

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", url), con="scrape.js")

system("phantomjs scrape.js > abbe-st.html")

abbesturl <- read_html("abbe-st.html")

abbest <- html_table(html_nodes(abbesturl, "table")[[4]],fill=TRUE)

removethese <- c(-16,-21)
abbest <- abbest[removethese,]
abbest[1] <- NULL

names(abbest) <- c("precinct","dem","wf","constitution",
                   "independence","green","gop",
                   "american","libertarian","sttotal")


abbest[, 2:10] <- apply(abbest[,2:10], 2, function(x) as.numeric(gsub(',', '',x)))
abbest$county <- "abbeville"

abbest <- abbest[,c(11,1:10)]

# write_csv(abbest, "2016-ge-abbest.csv")


# President data.
# ---------------

url <- "http://www.enr-scvotes.org/SC/Abbeville/64659/183591/en/md_data.html?cid=0104&"

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", url), con="scrape.js")

system("phantomjs scrape.js > abbe-potus.html")

abbepotusurl <- read_html("abbe-potus.html")

abbepotus <- html_table(html_nodes(abbepotusurl, "table")[[4]],fill=TRUE)

abbepotus[1] <- NULL

names(abbepotus) <- c("precinct","clinton","castle","mcmullin",
                      "stein","trump","skewes",
                      "johnson","potustotal")

abbepotus %>% 
  filter(precinct != "Precinct"  & precinct != "Total:") -> abbepotus

abbepotus[, 2:9] <- apply(abbepotus[,2:9], 2, function(x) as.numeric(gsub(',', '',x)))
abbepotus$county <- "abbeville"

abbepotus <- abbepotus[,c(10,1:9)]

# write_csv(abbepotus, "2016-ge-abbepotus.csv")



# Senate race data.
# -----------------

url <- "http://www.enr-scvotes.org/SC/Abbeville/64659/183591/en/md_data.html?cid=0105&"

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", url), con="scrape.js")

system("phantomjs scrape.js > abbe-senate.html")

abbesenurl <- read_html("abbe-senate.html")

abbesen <- html_table(html_nodes(abbesenurl, "table")[[4]],fill=TRUE)

abbesen[1] <- NULL

# Weirdly enough, Dixon is triple-counted and Bledsoe is double-counted. Fucking SC votes...

names(abbesen) <- c("precinct","dixon","dixon2","bledsoe",
                    "dixon3","scott","scarborough",
                    "bledsoe2","senwritein","sentotal")


abbesen %>% 
  filter(precinct != "Precinct"  & precinct != "Total:") -> abbesen

abbesen[, 2:10] <- apply(abbesen[,2:10], 2, function(x) as.numeric(gsub(',', '',x)))

abbesen$dixon <- with(abbesen, dixon+dixon2+dixon3)
abbesen$dixon2 <- abbesen$dixon3 <- NULL

abbesen$bledsoe <- with(abbesen, bledsoe + bledsoe2)
abbesen$bledsoe2 <- NULL

abbesen$county <- "abbeville"

abbesen <- abbesen[,c(8,1:7)]

# write_csv(abbesen, "2016-ge-abbesen.csv")

# House race data.
# ----------------

url <- "http://www.enr-scvotes.org/SC/Abbeville/64659/183591/en/md_data.html?cid=0106&"

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", url), con="scrape.js")

system("phantomjs scrape.js > abbe-house.html")

abbehouseurl <- read_html("abbe-house.html")

abbehouse <- html_table(html_nodes(abbehouseurl, "table")[[4]],fill=TRUE)

abbehouse[1] <- NULL

names(abbehouse) <- c("precinct","cleveland","duncan","housewritein","housetotal")

abbehouse %>% 
  filter(precinct != "Precinct"  & precinct != "Total:") -> abbehouse


abbehouse[, 2:5] <- apply(abbehouse[,2:5], 2, function(x) as.numeric(gsub(',', '',x)))

abbehouse$county <- "abbeville"

abbehouse <- abbehouse[,c(6,1:5)]

# write_csv(abbehouse, "2016-ge-abbehouse.csv")

abbeville <- left_join(abbeturnout, abbest) %>%
  left_join(., abbepotus) %>%
  left_join(., abbesen) %>%
  left_join(., abbehouse) %>%
  tbl_df()

write_csv(abbeville, "2016-ge-abbe-total.csv")
