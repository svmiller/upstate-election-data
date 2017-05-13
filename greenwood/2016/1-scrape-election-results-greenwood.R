library(tidyverse)
library(rvest)
library(stringr)

setwd("~/Dropbox/democrats/election-results-data/greenwood/2016")

county <- "greenwood"

turnouturl <- read_html("http://www.enr-scvotes.org/SC/Greenwood/64682/183626/en/vt_data.html")
sturl <- "http://www.enr-scvotes.org/SC/Greenwood/64682/183626/en/md_data.html?cid=0103&"
potusurl <- "http://www.enr-scvotes.org/SC/Greenwood/64682/183626/en/md_data.html?cid=0104&"
senurl <- "http://www.enr-scvotes.org/SC/Greenwood/64682/183626/en/md_data.html?cid=0105&"
houseurl <- "http://www.enr-scvotes.org/SC/Greenwood/64682/183626/en/md_data.html?cid=0106&"

# Turnout is fairly easy.
# -----------------------

gwooturnout = html_table(html_nodes(turnouturl, "table")[[4]])

names(gwooturnout) <- c("precinct","bc","rv","vtp")

gwooturnout %>%
  filter(precinct != "Precinct" & precinct != "Total:") -> gwooturnout

gwooturnout$bc <- as.numeric(gsub(',', '', gwooturnout$bc))
gwooturnout$rv <- as.numeric(gsub(',', '', gwooturnout$rv))
gwooturnout$vtp <- with(gwooturnout, (bc/rv)*100)
#gwooturnout$county <- county

#gwooturnout <- gwooturnout[,c(5,1:4)]

# write_csv(gwooturnout, "2016-ge-gwooturnout.csv")


# Straight-ticket data.
# ---------------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", sturl), con="scrape.js")

system("phantomjs scrape.js > gwoo-st.html")

gwoosturl <- read_html("gwoo-st.html")

gwoost <- html_table(html_nodes(gwoosturl, "table")[[4]],fill=TRUE)

gwoost[1] <- NULL

names(gwoost) <- c("precinct","dem","wf","constitution",
                   "independence","green","gop",
                   "american","libertarian","sttotal")

gwoost %>%
  filter(precinct != "Precinct" & precinct != "Total:") -> gwoost


gwoost[, 2:ncol(gwoost)] <- apply(gwoost[,2:ncol(gwoost)], 2, function(x) as.numeric(gsub(',', '',x)))
# gwoost$county <- county

# gwoost <- gwoost[,c(11,1:10)]

# write_csv(gwoost, "2016-ge-gwoost.csv")


# President data.
# ---------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", potusurl), con="scrape.js")

system("phantomjs scrape.js > gwoo-potus.html")

gwoopotusurl <- read_html("gwoo-potus.html")

gwoopotus <- html_table(html_nodes(gwoopotusurl, "table")[[4]],fill=TRUE)

gwoopotus[1] <- NULL

names(gwoopotus) <- c("precinct","clinton","castle","mcmullin",
                      "stein","trump","skewes",
                      "johnson","potustotal")

gwoopotus %>% 
  filter(precinct != "Precinct"  & precinct != "Total:") -> gwoopotus

gwoopotus[, 2:ncol(gwoopotus)] <- apply(gwoopotus[,2:ncol(gwoopotus)], 2, function(x) as.numeric(gsub(',', '',x)))
# gwoopotus$county <- county
# gwoopotus <- gwoopotus[,c(10,1:9)]

# write_csv(gwoopotus, "2016-ge-gwoopotus.csv")



# Senate race data.
# -----------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", senurl), con="scrape.js")

system("phantomjs scrape.js > gwoo-senate.html")

gwoosenurl <- read_html("gwoo-senate.html")

gwoosen <- html_table(html_nodes(gwoosenurl, "table")[[4]],fill=TRUE)

gwoosen[1] <- NULL

# Weirdly enough, Dixon is triple-counted and Bledsoe is double-counted. Fucking SC votes...

names(gwoosen) <- c("precinct","dixon","dixon2","bledsoe",
                    "dixon3","scott","scarborough",
                    "bledsoe2","senwritein","sentotal")


gwoosen %>% 
  filter(precinct != "Precinct"  & precinct != "Total:") -> gwoosen

gwoosen[, 2:ncol(gwoosen)] <- apply(gwoosen[,2:ncol(gwoosen)], 2, function(x) as.numeric(gsub(',', '',x)))

gwoosen$dixon <- with(gwoosen, dixon+dixon2+dixon3)
gwoosen$dixon2 <- gwoosen$dixon3 <- NULL

gwoosen$bledsoe <- with(gwoosen, bledsoe + bledsoe2)
gwoosen$bledsoe2 <- NULL

# gwoosen$county <- county

# gwoosen <- gwoosen[,c(8,1:7)]

# write_csv(gwoosen, "2016-ge-gwoosen.csv")

# House race data.
# ----------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", houseurl), con="scrape.js")

system("phantomjs scrape.js > gwoo-house.html")

gwoohouseurl <- read_html("gwoo-house.html")

gwoohouse <- html_table(html_nodes(gwoohouseurl, "table")[[4]],fill=TRUE)

gwoohouse[1] <- NULL

names(gwoohouse) <- c("precinct","cleveland","duncan", "housewritein","housetotal")

gwoohouse %>% 
  filter(precinct != "Precinct"  & precinct != "Total:") -> gwoohouse


gwoohouse[, 2:ncol(gwoohouse)] <- apply(gwoohouse[,2:ncol(gwoohouse)], 2, function(x) as.numeric(gsub(',', '',x)))

# gwoohouse$county <- county

#gwoohouse <- gwoohouse %>%
#  select(county,precinct:housetotal)

# write_csv(gwoohouse, "2016-ge-gwoohouse.csv")

Greenwood <- left_join(gwooturnout, gwoost) %>%
  left_join(., gwoopotus) %>%
  left_join(., gwoosen) %>%
  left_join(., gwoohouse) %>%
  tbl_df() %>%
  mutate(county = county) %>%
  select(county, everything())

write_csv(Greenwood, "2016-ge-gwoo-total.csv")
