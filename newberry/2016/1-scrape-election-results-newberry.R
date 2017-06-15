library(tidyverse)
library(rvest)
library(stringr)

setwd("~/Dropbox/democrats/election-results-data/newberry/2016")

county <- "newberry"

turnouturl <- read_html("http://www.enr-scvotes.org/SC/Newberry/64694/184700/en/vt_data.html")
sturl <- "http://www.enr-scvotes.org/SC/Newberry/64694/184700/en/md_data.html?cid=0103&"
potusurl <- "http://www.enr-scvotes.org/SC/Newberry/64694/184700/en/md_data.html?cid=0104&"
senurl <- "http://www.enr-scvotes.org/SC/Newberry/64694/184700/en/md_data.html?cid=0105&"
houseurl <- "http://www.enr-scvotes.org/SC/Newberry/64694/184700/en/md_data.html?cid=0106&"

# Turnout is fairly easy.
# -----------------------

newbturnout = html_table(html_nodes(turnouturl, "table")[[4]])

names(newbturnout) <- c("precinct","bc","rv","vtp")

newbturnout %>%
  filter(precinct != "Precinct" & precinct != "Total:") -> newbturnout

newbturnout$bc <- as.numeric(gsub(',', '', newbturnout$bc))
newbturnout$rv <- as.numeric(gsub(',', '', newbturnout$rv))
newbturnout$vtp <- with(newbturnout, (bc/rv)*100)
#newbturnout$county <- county

#newbturnout <- newbturnout[,c(5,1:4)]

# write_csv(newbturnout, "2016-ge-newbturnout.csv")


# Straight-ticket data.
# ---------------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", sturl), con="scrape.js")

system("phantomjs scrape.js > newb-st.html")

newbsturl <- read_html("newb-st.html")

newbst <- html_table(html_nodes(newbsturl, "table")[[4]],fill=TRUE)

newbst[1] <- NULL

names(newbst) <- c("precinct","dem","wf","constitution",
                   "independence","green","gop",
                   "american","libertarian","sttotal")

newbst %>%
  filter(precinct != "Precinct" & precinct != "Total:") -> newbst


newbst[, 2:ncol(newbst)] <- apply(newbst[,2:ncol(newbst)], 2, function(x) as.numeric(gsub(',', '',x)))
# newbst$county <- county

# newbst <- newbst[,c(11,1:10)]

# write_csv(newbst, "2016-ge-newbst.csv")


# President data.
# ---------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", potusurl), con="scrape.js")

system("phantomjs scrape.js > newb-potus.html")

newbpotusurl <- read_html("newb-potus.html")

newbpotus <- html_table(html_nodes(newbpotusurl, "table")[[4]],fill=TRUE)

newbpotus[1] <- NULL

names(newbpotus) <- c("precinct","clinton","castle","mcmullin",
                      "stein","trump","skewes",
                      "johnson","potustotal")

newbpotus %>% 
  filter(precinct != "Precinct"  & precinct != "Total:") -> newbpotus

newbpotus[, 2:ncol(newbpotus)] <- apply(newbpotus[,2:ncol(newbpotus)], 2, function(x) as.numeric(gsub(',', '',x)))
# newbpotus$county <- county
# newbpotus <- newbpotus[,c(10,1:9)]

# write_csv(newbpotus, "2016-ge-newbpotus.csv")



# Senate race data.
# -----------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", senurl), con="scrape.js")

system("phantomjs scrape.js > newb-senate.html")

newbsenurl <- read_html("newb-senate.html")

newbsen <- html_table(html_nodes(newbsenurl, "table")[[4]],fill=TRUE)

newbsen[1] <- NULL

# Weirdly enough, Dixon is triple-counted and Bledsoe is double-counted. Fucking SC votes...

names(newbsen) <- c("precinct","dixon","dixon2","bledsoe",
                    "dixon3","scott","scarborough",
                    "bledsoe2","senwritein","sentotal")


newbsen %>% 
  filter(precinct != "Precinct"  & precinct != "Total:") -> newbsen

newbsen[, 2:ncol(newbsen)] <- apply(newbsen[,2:ncol(newbsen)], 2, function(x) as.numeric(gsub(',', '',x)))

newbsen$dixon <- with(newbsen, dixon+dixon2+dixon3)
newbsen$dixon2 <- newbsen$dixon3 <- NULL

newbsen$bledsoe <- with(newbsen, bledsoe + bledsoe2)
newbsen$bledsoe2 <- NULL

# newbsen$county <- county

# newbsen <- newbsen[,c(8,1:7)]

# write_csv(newbsen, "2016-ge-newbsen.csv")

# House race data.
# ----------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", houseurl), con="scrape.js")

system("phantomjs scrape.js > newb-house.html")

newbhouseurl <- read_html("newb-house.html")

newbhouse <- html_table(html_nodes(newbhouseurl, "table")[[4]],fill=TRUE)

newbhouse[1] <- NULL

names(newbhouse) <- c("precinct","cleveland","duncan", "housewritein","housetotal")

newbhouse %>% 
  filter(precinct != "Precinct"  & precinct != "Total:") -> newbhouse


newbhouse[, 2:ncol(newbhouse)] <- apply(newbhouse[,2:ncol(newbhouse)], 2, function(x) as.numeric(gsub(',', '',x)))

# newbhouse$county <- county

#newbhouse <- newbhouse %>%
#  select(county,precinct:housetotal)

# write_csv(newbhouse, "2016-ge-newbhouse.csv")

newb <- left_join(newbturnout, newbst) %>%
  left_join(., newbpotus) %>%
  left_join(., newbsen) %>%
  left_join(., newbhouse) %>%
  tbl_df() %>%
  mutate(county = county) %>%
  select(county, everything())

# newb[, 29:ncol(newb)] <- apply(newb[,29:ncol(newb)], 2, function(x) as.numeric(x))


write_csv(newb, "2016-ge-newb-total.csv")
