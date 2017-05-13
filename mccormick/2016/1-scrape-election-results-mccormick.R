library(tidyverse)
library(rvest)
library(stringr)

setwd("~/Dropbox/democrats/election-results-data/mccormick/2016")

county <- "mccormick"

turnouturl <- read_html("http://www.enr-scvotes.org/SC/McCormick/64693/183589/en/vt_data.html")
sturl <- "http://www.enr-scvotes.org/SC/McCormick/64693/183589/en/md_data.html?cid=0103&"
potusurl <- "http://www.enr-scvotes.org/SC/McCormick/64693/183589/en/md_data.html?cid=0104&"
senurl <- "http://www.enr-scvotes.org/SC/McCormick/64693/183589/en/md_data.html?cid=0105&"
houseurl <- "http://www.enr-scvotes.org/SC/McCormick/64693/183589/en/md_data.html?cid=0106&"

# Turnout is fairly easy.
# -----------------------

mccoturnout = html_table(html_nodes(turnouturl, "table")[[4]])

names(mccoturnout) <- c("precinct","bc","rv","vtp")

mccoturnout %>%
  filter(precinct != "Precinct" & precinct != "Total:") -> mccoturnout

mccoturnout$bc <- as.numeric(gsub(',', '', mccoturnout$bc))
mccoturnout$rv <- as.numeric(gsub(',', '', mccoturnout$rv))
mccoturnout$vtp <- with(mccoturnout, (bc/rv)*100)
#mccoturnout$county <- county

#mccoturnout <- mccoturnout[,c(5,1:4)]

# write_csv(mccoturnout, "2016-ge-mccoturnout.csv")


# Straight-ticket data.
# ---------------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", sturl), con="scrape.js")

system("phantomjs scrape.js > mcco-st.html")

mccosturl <- read_html("mcco-st.html")

mccost <- html_table(html_nodes(mccosturl, "table")[[4]],fill=TRUE)

mccost[1] <- NULL

names(mccost) <- c("precinct","dem","wf","constitution",
                   "independence","green","gop",
                   "american","libertarian","sttotal")

mccost %>%
  filter(precinct != "Precinct" & precinct != "Total:") -> mccost


mccost[, 2:ncol(mccost)] <- apply(mccost[,2:ncol(mccost)], 2, function(x) as.numeric(gsub(',', '',x)))
# mccost$county <- county

# mccost <- mccost[,c(11,1:10)]

# write_csv(mccost, "2016-ge-mccost.csv")


# President data.
# ---------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", potusurl), con="scrape.js")

system("phantomjs scrape.js > mcco-potus.html")

mccopotusurl <- read_html("mcco-potus.html")

mccopotus <- html_table(html_nodes(mccopotusurl, "table")[[4]],fill=TRUE)

mccopotus[1] <- NULL

names(mccopotus) <- c("precinct","clinton","castle","mcmullin",
                      "stein","trump","skewes",
                      "johnson","potustotal")

mccopotus %>% 
  filter(precinct != "Precinct"  & precinct != "Total:") -> mccopotus

mccopotus[, 2:ncol(mccopotus)] <- apply(mccopotus[,2:ncol(mccopotus)], 2, function(x) as.numeric(gsub(',', '',x)))
# mccopotus$county <- county
# mccopotus <- mccopotus[,c(10,1:9)]

# write_csv(mccopotus, "2016-ge-mccopotus.csv")



# Senate race data.
# -----------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", senurl), con="scrape.js")

system("phantomjs scrape.js > mcco-senate.html")

mccosenurl <- read_html("mcco-senate.html")

mccosen <- html_table(html_nodes(mccosenurl, "table")[[4]],fill=TRUE)

mccosen[1] <- NULL

# Weirdly enough, Dixon is triple-counted and Bledsoe is double-counted. Fucking SC votes...

names(mccosen) <- c("precinct","dixon","dixon2","bledsoe",
                    "dixon3","scott","scarborough",
                    "bledsoe2","senwritein","sentotal")


mccosen %>% 
  filter(precinct != "Precinct"  & precinct != "Total:") -> mccosen

mccosen[, 2:ncol(mccosen)] <- apply(mccosen[,2:ncol(mccosen)], 2, function(x) as.numeric(gsub(',', '',x)))

mccosen$dixon <- with(mccosen, dixon+dixon2+dixon3)
mccosen$dixon2 <- mccosen$dixon3 <- NULL

mccosen$bledsoe <- with(mccosen, bledsoe + bledsoe2)
mccosen$bledsoe2 <- NULL

# mccosen$county <- county

# mccosen <- mccosen[,c(8,1:7)]

# write_csv(mccosen, "2016-ge-mccosen.csv")

# House race data.
# ----------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", houseurl), con="scrape.js")

system("phantomjs scrape.js > mcco-house.html")

mccohouseurl <- read_html("mcco-house.html")

mccohouse <- html_table(html_nodes(mccohouseurl, "table")[[4]],fill=TRUE)

mccohouse[1] <- NULL

names(mccohouse) <- c("precinct","cleveland","duncan", "housewritein","housetotal")

mccohouse %>% 
  filter(precinct != "Precinct"  & precinct != "Total:") -> mccohouse


mccohouse[, 2:ncol(mccohouse)] <- apply(mccohouse[,2:ncol(mccohouse)], 2, function(x) as.numeric(gsub(',', '',x)))

# mccohouse$county <- county

#mccohouse <- mccohouse %>%
#  select(county,precinct:housetotal)

# write_csv(mccohouse, "2016-ge-mccohouse.csv")

McCormick <- left_join(mccoturnout, mccost) %>%
  left_join(., mccopotus) %>%
  left_join(., mccosen) %>%
  left_join(., mccohouse) %>%
  tbl_df() %>%
  mutate(county = county) %>%
  select(county, everything())

write_csv(McCormick, "2016-ge-mcco-total.csv")
