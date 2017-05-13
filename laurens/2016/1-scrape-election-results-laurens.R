library(tidyverse)
library(rvest)
library(stringr)

setwd("~/Dropbox/democrats/election-results-data/laurens/2016")

county <- "laurens"

turnouturl <- read_html("http://www.enr-scvotes.org/SC/Laurens/64688/183636/en/vt_data.html")
sturl <- "http://www.enr-scvotes.org/SC/Laurens/64688/183636/en/md_data.html?cid=0103&"
potusurl <- "http://www.enr-scvotes.org/SC/Laurens/64688/183636/en/md_data.html?cid=0104&"
senurl <- "http://www.enr-scvotes.org/SC/Laurens/64688/183636/en/md_data.html?cid=0105&"
houseurl <- "http://www.enr-scvotes.org/SC/Laurens/64688/183636/en/md_data.html?cid=0106&"

# Turnout is fairly easy.
# -----------------------

laurturnout = html_table(html_nodes(turnouturl, "table")[[4]])

names(laurturnout) <- c("precinct","bc","rv","vtp")

laurturnout %>%
  filter(precinct != "Precinct" & precinct != "Total:") -> laurturnout

laurturnout$bc <- as.numeric(gsub(',', '', laurturnout$bc))
laurturnout$rv <- as.numeric(gsub(',', '', laurturnout$rv))
laurturnout$vtp <- with(laurturnout, (bc/rv)*100)
#laurturnout$county <- county

#laurturnout <- laurturnout[,c(5,1:4)]

# write_csv(laurturnout, "2016-ge-laurturnout.csv")


# Straight-ticket data.
# ---------------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", sturl), con="scrape.js")

system("phantomjs scrape.js > laur-st.html")

laursturl <- read_html("laur-st.html")

laurst <- html_table(html_nodes(laursturl, "table")[[4]],fill=TRUE)

laurst[1] <- NULL

names(laurst) <- c("precinct","dem","wf","constitution",
                   "independence","green","gop",
                   "american","libertarian","sttotal")

laurst %>%
  filter(precinct != "Precinct" & precinct != "Total:") -> laurst


laurst[, 2:ncol(laurst)] <- apply(laurst[,2:ncol(laurst)], 2, function(x) as.numeric(gsub(',', '',x)))
# laurst$county <- county

# laurst <- laurst[,c(11,1:10)]

# write_csv(laurst, "2016-ge-laurst.csv")


# President data.
# ---------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", potusurl), con="scrape.js")

system("phantomjs scrape.js > laur-potus.html")

laurpotusurl <- read_html("laur-potus.html")

laurpotus <- html_table(html_nodes(laurpotusurl, "table")[[4]],fill=TRUE)

laurpotus[1] <- NULL

names(laurpotus) <- c("precinct","clinton","castle","mcmullin",
                      "stein","trump","skewes",
                      "johnson","potustotal")

laurpotus %>% 
  filter(precinct != "Precinct"  & precinct != "Total:") -> laurpotus

laurpotus[, 2:ncol(laurpotus)] <- apply(laurpotus[,2:ncol(laurpotus)], 2, function(x) as.numeric(gsub(',', '',x)))
# laurpotus$county <- county
# laurpotus <- laurpotus[,c(10,1:9)]

# write_csv(laurpotus, "2016-ge-laurpotus.csv")



# Senate race data.
# -----------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", senurl), con="scrape.js")

system("phantomjs scrape.js > laur-senate.html")

laursenurl <- read_html("laur-senate.html")

laursen <- html_table(html_nodes(laursenurl, "table")[[4]],fill=TRUE)

laursen[1] <- NULL

# Weirdly enough, Dixon is triple-counted and Bledsoe is double-counted. Fucking SC votes...

names(laursen) <- c("precinct","dixon","dixon2","bledsoe",
                    "dixon3","scott","scarborough",
                    "bledsoe2","senwritein","sentotal")


laursen %>% 
  filter(precinct != "Precinct"  & precinct != "Total:") -> laursen

laursen[, 2:ncol(laursen)] <- apply(laursen[,2:ncol(laursen)], 2, function(x) as.numeric(gsub(',', '',x)))

laursen$dixon <- with(laursen, dixon+dixon2+dixon3)
laursen$dixon2 <- laursen$dixon3 <- NULL

laursen$bledsoe <- with(laursen, bledsoe + bledsoe2)
laursen$bledsoe2 <- NULL

# laursen$county <- county

# laursen <- laursen[,c(8,1:7)]

# write_csv(laursen, "2016-ge-laursen.csv")

# House race data.
# ----------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", houseurl), con="scrape.js")

system("phantomjs scrape.js > laur-house.html")

laurhouseurl <- read_html("laur-house.html")

laurhouse <- html_table(html_nodes(laurhouseurl, "table")[[4]],fill=TRUE)

laurhouse[1] <- NULL

names(laurhouse) <- c("precinct","cleveland","duncan", "housewritein","housetotal")

laurhouse %>% 
  filter(precinct != "Precinct"  & precinct != "Total:") -> laurhouse


laurhouse[, 2:ncol(laurhouse)] <- apply(laurhouse[,2:ncol(laurhouse)], 2, function(x) as.numeric(gsub(',', '',x)))

# laurhouse$county <- county

#laurhouse <- laurhouse %>%
#  select(county,precinct:housetotal)

# write_csv(laurhouse, "2016-ge-laurhouse.csv")

Laurens <- left_join(laurturnout, laurst) %>%
  left_join(., laurpotus) %>%
  left_join(., laursen) %>%
  left_join(., laurhouse) %>%
  tbl_df() %>%
  mutate(county = county) %>%
  select(county, everything())

write_csv(Laurens, "2016-ge-laur-total.csv")
