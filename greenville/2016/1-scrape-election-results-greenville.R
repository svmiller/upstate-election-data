library(tidyverse)
library(rvest)
library(stringr)

setwd("~/Dropbox/democrats/election-results-data/greenville/2016")

county <- "greenville"

turnouturl <- read_html("http://www.enr-scvotes.org/SC/Greenville/64681/183624/en/vt_data.html")
sturl <- "http://www.enr-scvotes.org/SC/Greenville/64681/183624/en/md_data.html?cid=0103&"
potusurl <- "http://www.enr-scvotes.org/SC/Greenville/64681/183624/en/md_data.html?cid=0104&"
senurl <- "http://www.enr-scvotes.org/SC/Greenville/64681/183624/en/md_data.html?cid=0105&"
houseurl <- "http://www.enr-scvotes.org/SC/Greenville/64681/183624/en/md_data.html?cid=0106&"

# Turnout is fairly easy.
# -----------------------

gvilturnout = html_table(html_nodes(turnouturl, "table")[[4]])

names(gvilturnout) <- c("precinct","bc","rv","vtp")

gvilturnout %>%
  filter(precinct != "Precinct" & precinct != "Total:") -> gvilturnout

gvilturnout$bc <- as.numeric(gsub(',', '', gvilturnout$bc))
gvilturnout$rv <- as.numeric(gsub(',', '', gvilturnout$rv))
gvilturnout$vtp <- with(gvilturnout, (bc/rv)*100)
#gvilturnout$county <- county

#gvilturnout <- gvilturnout[,c(5,1:4)]

# write_csv(gvilturnout, "2016-ge-gvilturnout.csv")


# Straight-ticket data.
# ---------------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", sturl), con="scrape.js")

system("phantomjs scrape.js > gvil-st.html")

gvilsturl <- read_html("gvil-st.html")

gvilst <- html_table(html_nodes(gvilsturl, "table")[[4]],fill=TRUE)

gvilst[1] <- NULL

names(gvilst) <- c("precinct","dem","wf","constitution",
                   "independence","green","gop",
                   "american","libertarian","sttotal")

gvilst %>%
  filter(precinct != "Precinct" & precinct != "Total:") -> gvilst


gvilst[, 2:ncol(gvilst)] <- apply(gvilst[,2:ncol(gvilst)], 2, function(x) as.numeric(gsub(',', '',x)))
# gvilst$county <- county

# gvilst <- gvilst[,c(11,1:10)]

# write_csv(gvilst, "2016-ge-gvilst.csv")


# President data.
# ---------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", potusurl), con="scrape.js")

system("phantomjs scrape.js > gvil-potus.html")

gvilpotusurl <- read_html("gvil-potus.html")

gvilpotus <- html_table(html_nodes(gvilpotusurl, "table")[[4]],fill=TRUE)

gvilpotus[1] <- NULL

names(gvilpotus) <- c("precinct","clinton","castle","mcmullin",
                      "stein","trump","skewes",
                      "johnson","potustotal")

gvilpotus %>% 
  filter(precinct != "Precinct"  & precinct != "Total:") -> gvilpotus

gvilpotus[, 2:ncol(gvilpotus)] <- apply(gvilpotus[,2:ncol(gvilpotus)], 2, function(x) as.numeric(gsub(',', '',x)))
# gvilpotus$county <- county
# gvilpotus <- gvilpotus[,c(10,1:9)]

# write_csv(gvilpotus, "2016-ge-gvilpotus.csv")



# Senate race data.
# -----------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", senurl), con="scrape.js")

system("phantomjs scrape.js > gvil-senate.html")

gvilsenurl <- read_html("gvil-senate.html")

gvilsen <- html_table(html_nodes(gvilsenurl, "table")[[4]],fill=TRUE)

gvilsen[1] <- NULL

# Weirdly enough, Dixon is triple-counted and Bledsoe is double-counted. Fucking SC votes...

names(gvilsen) <- c("precinct","dixon","dixon2","bledsoe",
                    "dixon3","scott","scarborough",
                    "bledsoe2","senwritein","sentotal")


gvilsen %>% 
  filter(precinct != "Precinct"  & precinct != "Total:") -> gvilsen

gvilsen[, 2:ncol(gvilsen)] <- apply(gvilsen[,2:ncol(gvilsen)], 2, function(x) as.numeric(gsub(',', '',x)))

gvilsen$dixon <- with(gvilsen, dixon+dixon2+dixon3)
gvilsen$dixon2 <- gvilsen$dixon3 <- NULL

gvilsen$bledsoe <- with(gvilsen, bledsoe + bledsoe2)
gvilsen$bledsoe2 <- NULL

# gvilsen$county <- county

# gvilsen <- gvilsen[,c(8,1:7)]

# write_csv(gvilsen, "2016-ge-gvilsen.csv")

# House race data.
# ----------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", houseurl), con="scrape.js")

system("phantomjs scrape.js > gvil-house.html")

gvilhouseurl <- read_html("gvil-house.html")

gvilhouse <- html_table(html_nodes(gvilhouseurl, "table")[[4]],fill=TRUE)

gvilhouse[1] <- NULL

names(gvilhouse) <- c("precinct","cleveland","duncan", "housewritein","housetotal")

gvilhouse %>% 
  filter(precinct != "Precinct"  & precinct != "Total:") -> gvilhouse


gvilhouse[, 2:ncol(gvilhouse)] <- apply(gvilhouse[,2:ncol(gvilhouse)], 2, function(x) as.numeric(gsub(',', '',x)))

# gvilhouse$county <- county

#gvilhouse <- gvilhouse %>%
#  select(county,precinct:housetotal)

# write_csv(gvilhouse, "2016-ge-gvilhouse.csv")

gvil <- left_join(gvilturnout, gvilst) %>%
  left_join(., gvilpotus) %>%
  left_join(., gvilsen) %>%
  left_join(., gvilhouse) %>%
  tbl_df() %>%
  mutate(county = county) %>%
  select(county, everything())

# gvil[, 29:ncol(gvil)] <- apply(gvil[,29:ncol(gvil)], 2, function(x) as.numeric(x))


write_csv(gvil, "2016-ge-gvil-total.csv")
