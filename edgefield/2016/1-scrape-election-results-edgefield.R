library(tidyverse)
library(rvest)
library(stringr)

setwd("~/Dropbox/democrats/election-results-data/edgefield/2016")

county <- "edgefield"

turnouturl <- read_html("http://www.enr-scvotes.org/SC/Edgefield/64677/183619/en/vt_data.html")
sturl <- "http://www.enr-scvotes.org/SC/Edgefield/64677/183619/en/md_data.html?cid=0103&&"
potusurl <- "http://www.enr-scvotes.org/SC/Edgefield/64677/183619/en/md_data.html?cid=0104&"
senurl <- "http://www.enr-scvotes.org/SC/Edgefield/64677/183619/en/md_data.html?cid=0105&"
houseurl <- "http://www.enr-scvotes.org/SC/Edgefield/64677/183619/en/md_data.html?cid=0106&"

# Turnout is fairly easy.
# -----------------------

edgeturnout = html_table(html_nodes(turnouturl, "table")[[4]])

names(edgeturnout) <- c("precinct","bc","rv","vtp")

edgeturnout %>%
  filter(precinct != "Precinct" & precinct != "Total:") -> edgeturnout

edgeturnout$bc <- as.numeric(gsub(',', '', edgeturnout$bc))
edgeturnout$rv <- as.numeric(gsub(',', '', edgeturnout$rv))
edgeturnout$vtp <- with(edgeturnout, (bc/rv)*100)
#edgeturnout$county <- county

#edgeturnout <- edgeturnout[,c(5,1:4)]

# write_csv(edgeturnout, "2016-ge-edgeturnout.csv")


# Straight-ticket data.
# ---------------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", sturl), con="scrape.js")

system("phantomjs scrape.js > edge-st.html")

edgesturl <- read_html("edge-st.html")

edgest <- html_table(html_nodes(edgesturl, "table")[[4]],fill=TRUE)

edgest[1] <- NULL

names(edgest) <- c("precinct","dem","wf","constitution",
                   "independence","green","gop",
                   "american","libertarian","sttotal")

edgest %>%
  filter(precinct != "Precinct" & precinct != "Total:") -> edgest


edgest[, 2:ncol(edgest)] <- apply(edgest[,2:ncol(edgest)], 2, function(x) as.numeric(gsub(',', '',x)))
# edgest$county <- county

# edgest <- edgest[,c(11,1:10)]

# write_csv(edgest, "2016-ge-edgest.csv")


# President data.
# ---------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", potusurl), con="scrape.js")

system("phantomjs scrape.js > edge-potus.html")

edgepotusurl <- read_html("edge-potus.html")

edgepotus <- html_table(html_nodes(edgepotusurl, "table")[[4]],fill=TRUE)

edgepotus[1] <- NULL

names(edgepotus) <- c("precinct","clinton","castle","mcmullin",
                      "stein","trump","skewes",
                      "johnson","potustotal")

edgepotus %>% 
  filter(precinct != "Precinct"  & precinct != "Total:") -> edgepotus

edgepotus[, 2:ncol(edgepotus)] <- apply(edgepotus[,2:ncol(edgepotus)], 2, function(x) as.numeric(gsub(',', '',x)))
# edgepotus$county <- county
# edgepotus <- edgepotus[,c(10,1:9)]

# write_csv(edgepotus, "2016-ge-edgepotus.csv")



# Senate race data.
# -----------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", senurl), con="scrape.js")

system("phantomjs scrape.js > edge-senate.html")

edgesenurl <- read_html("edge-senate.html")

edgesen <- html_table(html_nodes(edgesenurl, "table")[[4]],fill=TRUE)

edgesen[1] <- NULL

# Weirdly enough, Dixon is triple-counted and Bledsoe is double-counted. Fucking SC votes...

names(edgesen) <- c("precinct","dixon","dixon2","bledsoe",
                    "dixon3","scott","scarborough",
                    "bledsoe2","senwritein","sentotal")


edgesen %>% 
  filter(precinct != "Precinct"  & precinct != "Total:") -> edgesen

edgesen[, 2:ncol(edgesen)] <- apply(edgesen[,2:ncol(edgesen)], 2, function(x) as.numeric(gsub(',', '',x)))

edgesen$dixon <- with(edgesen, dixon+dixon2+dixon3)
edgesen$dixon2 <- edgesen$dixon3 <- NULL

edgesen$bledsoe <- with(edgesen, bledsoe + bledsoe2)
edgesen$bledsoe2 <- NULL

# edgesen$county <- county

# edgesen <- edgesen[,c(8,1:7)]

# write_csv(edgesen, "2016-ge-edgesen.csv")

# House race data.
# ----------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", houseurl), con="scrape.js")

system("phantomjs scrape.js > edge-house.html")

edgehouseurl <- read_html("edge-house.html")

edgehouse <- html_table(html_nodes(edgehouseurl, "table")[[4]],fill=TRUE)

edgehouse[1] <- NULL

names(edgehouse) <- c("precinct","cleveland","duncan", "housewritein","housetotal")

edgehouse %>% 
  filter(precinct != "Precinct"  & precinct != "Total:") -> edgehouse


edgehouse[, 2:ncol(edgehouse)] <- apply(edgehouse[,2:ncol(edgehouse)], 2, function(x) as.numeric(gsub(',', '',x)))

# edgehouse$county <- county

#edgehouse <- edgehouse %>%
#  select(county,precinct:housetotal)

# write_csv(edgehouse, "2016-ge-edgehouse.csv")

Edgefield <- left_join(edgeturnout, edgest) %>%
  left_join(., edgepotus) %>%
  left_join(., edgesen) %>%
  left_join(., edgehouse) %>%
  tbl_df() %>%
  mutate(county = county) %>%
  select(county, everything())

write_csv(Edgefield, "2016-ge-edge-total.csv")
