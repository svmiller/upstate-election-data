library(tidyverse)
library(rvest)
library(stringr)

setwd("~/Dropbox/democrats/election-results-data/saluda/2016")

county <- "saluda"

turnouturl <- read_html("http://www.enr-scvotes.org/SC/Saluda/64699/183646/en/vt_data.html")
sturl <- "http://www.enr-scvotes.org/SC/Saluda/64699/183646/en/md_data.html?cid=0103&"
potusurl <- "http://www.enr-scvotes.org/SC/Saluda/64699/183646/en/md_data.html?cid=0104&"
senurl <- "http://www.enr-scvotes.org/SC/Saluda/64699/183646/en/md_data.html?cid=0105&"
houseurl <- "http://www.enr-scvotes.org/SC/Saluda/64699/183646/en/md_data.html?cid=0106&"

# Turnout is fairly easy.
# -----------------------

saluturnout = html_table(html_nodes(turnouturl, "table")[[4]])

names(saluturnout) <- c("precinct","bc","rv","vtp")

saluturnout %>%
  filter(precinct != "Precinct" & precinct != "Total:") -> saluturnout

saluturnout$bc <- as.numeric(gsub(',', '', saluturnout$bc))
saluturnout$rv <- as.numeric(gsub(',', '', saluturnout$rv))
saluturnout$vtp <- with(saluturnout, (bc/rv)*100)
#saluturnout$county <- county

#saluturnout <- saluturnout[,c(5,1:4)]

# write_csv(saluturnout, "2016-ge-saluturnout.csv")


# Straight-ticket data.
# ---------------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", sturl), con="scrape.js")

system("phantomjs scrape.js > salu-st.html")

salusturl <- read_html("salu-st.html")

salust <- html_table(html_nodes(salusturl, "table")[[4]],fill=TRUE)

salust[1] <- NULL

names(salust) <- c("precinct","dem","wf","constitution",
                   "independence","green","gop",
                   "american","libertarian","sttotal")

salust %>%
  filter(precinct != "Precinct" & precinct != "Total:") -> salust


salust[, 2:ncol(salust)] <- apply(salust[,2:ncol(salust)], 2, function(x) as.numeric(gsub(',', '',x)))
# salust$county <- county

# salust <- salust[,c(11,1:10)]

# write_csv(salust, "2016-ge-salust.csv")


# President data.
# ---------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", potusurl), con="scrape.js")

system("phantomjs scrape.js > salu-potus.html")

salupotusurl <- read_html("salu-potus.html")

salupotus <- html_table(html_nodes(salupotusurl, "table")[[4]],fill=TRUE)

salupotus[1] <- NULL

names(salupotus) <- c("precinct","clinton","castle","mcmullin",
                      "stein","trump","skewes",
                      "johnson","potustotal")

salupotus %>% 
  filter(precinct != "Precinct"  & precinct != "Total:") -> salupotus

salupotus[, 2:ncol(salupotus)] <- apply(salupotus[,2:ncol(salupotus)], 2, function(x) as.numeric(gsub(',', '',x)))
# salupotus$county <- county
# salupotus <- salupotus[,c(10,1:9)]

# write_csv(salupotus, "2016-ge-salupotus.csv")



# Senate race data.
# -----------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", senurl), con="scrape.js")

system("phantomjs scrape.js > salu-senate.html")

salusenurl <- read_html("salu-senate.html")

salusen <- html_table(html_nodes(salusenurl, "table")[[4]],fill=TRUE)

salusen[1] <- NULL

# Weirdly enough, Dixon is triple-counted and Bledsoe is double-counted. Fucking SC votes...

names(salusen) <- c("precinct","dixon","dixon2","bledsoe",
                    "dixon3","scott","scarborough",
                    "bledsoe2","senwritein","sentotal")


salusen %>% 
  filter(precinct != "Precinct"  & precinct != "Total:") -> salusen

salusen[, 2:ncol(salusen)] <- apply(salusen[,2:ncol(salusen)], 2, function(x) as.numeric(gsub(',', '',x)))

salusen$dixon <- with(salusen, dixon+dixon2+dixon3)
salusen$dixon2 <- salusen$dixon3 <- NULL

salusen$bledsoe <- with(salusen, bledsoe + bledsoe2)
salusen$bledsoe2 <- NULL

# salusen$county <- county

# salusen <- salusen[,c(8,1:7)]

# write_csv(salusen, "2016-ge-salusen.csv")

# House race data.
# ----------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", houseurl), con="scrape.js")

system("phantomjs scrape.js > salu-house.html")

saluhouseurl <- read_html("salu-house.html")

saluhouse <- html_table(html_nodes(saluhouseurl, "table")[[4]],fill=TRUE)

saluhouse[1] <- NULL

names(saluhouse) <- c("precinct","cleveland","duncan", "housewritein","housetotal")

saluhouse %>% 
  filter(precinct != "Precinct"  & precinct != "Total:") -> saluhouse


saluhouse[, 2:ncol(saluhouse)] <- apply(saluhouse[,2:ncol(saluhouse)], 2, function(x) as.numeric(gsub(',', '',x)))

# saluhouse$county <- county

#saluhouse <- saluhouse %>%
#  select(county,precinct:housetotal)

# write_csv(saluhouse, "2016-ge-saluhouse.csv")

salu <- left_join(saluturnout, salust) %>%
  left_join(., salupotus) %>%
  left_join(., salusen) %>%
  left_join(., saluhouse) %>%
  tbl_df() %>%
  mutate(county = county) %>%
  select(county, everything())

write_csv(salu, "2016-ge-salu-total.csv")
