library(tidyverse)
library(rvest)
library(stringr)

setwd("~/Dropbox/democrats/election-results-data/cherokee/2016")

county <- "cherokee"

turnouturl <- read_html("http://www.enr-scvotes.org/SC/Cherokee/64669/183609/en/vt_data.html")
sturl <- "http://www.enr-scvotes.org/SC/Cherokee/64669/183609/en/md_data.html?cid=0103&"
potusurl <- "http://www.enr-scvotes.org/SC/Cherokee/64669/183609/en/md_data.html?cid=0104&"
senurl <- "http://www.enr-scvotes.org/SC/Cherokee/64669/183609/en/md_data.html?cid=0105&"
houseurl <- "http://www.enr-scvotes.org/SC/Cherokee/64669/183609/en/md_data.html?cid=0106&"

# Turnout is fairly easy.
# -----------------------

cherturnout = html_table(html_nodes(turnouturl, "table")[[4]])

names(cherturnout) <- c("precinct","bc","rv","vtp")

cherturnout %>%
  filter(precinct != "Precinct" & precinct != "Total:") -> cherturnout

cherturnout$bc <- as.numeric(gsub(',', '', cherturnout$bc))
cherturnout$rv <- as.numeric(gsub(',', '', cherturnout$rv))
cherturnout$vtp <- with(cherturnout, (bc/rv)*100)
cherturnout$county <- county

cherturnout <- cherturnout[,c(5,1:4)]

# write_csv(cherturnout, "2016-ge-cherturnout.csv")


# Straight-ticket data.
# ---------------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", sturl), con="scrape.js")

system("phantomjs scrape.js > cher-st.html")

chersturl <- read_html("cher-st.html")

cherst <- html_table(html_nodes(chersturl, "table")[[4]],fill=TRUE)

cherst[1] <- NULL

names(cherst) <- c("precinct","dem","wf","constitution",
                   "independence","green","gop",
                   "american","libertarian","sttotal")

cherst %>%
  filter(precinct != "Precinct" & precinct != "Total:") -> cherst


cherst[, 2:10] <- apply(cherst[,2:10], 2, function(x) as.numeric(gsub(',', '',x)))
cherst$county <- county

cherst <- cherst[,c(11,1:10)]

# write_csv(cherst, "2016-ge-cherst.csv")


# President data.
# ---------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", potusurl), con="scrape.js")

system("phantomjs scrape.js > cher-potus.html")

cherpotusurl <- read_html("cher-potus.html")

cherpotus <- html_table(html_nodes(cherpotusurl, "table")[[4]],fill=TRUE)

cherpotus[1] <- NULL

names(cherpotus) <- c("precinct","clinton","castle","mcmullin",
                      "stein","trump","skewes",
                      "johnson","potustotal")

cherpotus %>% 
  filter(precinct != "Precinct"  & precinct != "Total:") -> cherpotus

cherpotus[, 2:9] <- apply(cherpotus[,2:9], 2, function(x) as.numeric(gsub(',', '',x)))
cherpotus$county <- county

cherpotus <- cherpotus[,c(10,1:9)]

# write_csv(cherpotus, "2016-ge-cherpotus.csv")



# Senate race data.
# -----------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", senurl), con="scrape.js")

system("phantomjs scrape.js > cher-senate.html")

chersenurl <- read_html("cher-senate.html")

chersen <- html_table(html_nodes(chersenurl, "table")[[4]],fill=TRUE)

chersen[1] <- NULL

# Weirdly enough, Dixon is triple-counted and Bledsoe is double-counted. Fucking SC votes...

names(chersen) <- c("precinct","dixon","dixon2","bledsoe",
                    "dixon3","scott","scarborough",
                    "bledsoe2","senwritein","sentotal")


chersen %>% 
  filter(precinct != "Precinct"  & precinct != "Total:") -> chersen

chersen[, 2:10] <- apply(chersen[,2:10], 2, function(x) as.numeric(gsub(',', '',x)))

chersen$dixon <- with(chersen, dixon+dixon2+dixon3)
chersen$dixon2 <- chersen$dixon3 <- NULL

chersen$bledsoe <- with(chersen, bledsoe + bledsoe2)
chersen$bledsoe2 <- NULL

chersen$county <- county

chersen <- chersen[,c(8,1:7)]

# write_csv(chersen, "2016-ge-chersen.csv")

# House race data.
# ----------------

writeLines(sprintf("var page = require('webpage').create();
                   page.open('%s', function () {
                   console.log(page.content); //page source
                   phantom.exit();
                   });", houseurl), con="scrape.js")

system("phantomjs scrape.js > cher-house.html")

cherhouseurl <- read_html("cher-house.html")

cherhouse <- html_table(html_nodes(cherhouseurl, "table")[[4]],fill=TRUE)

cherhouse[1] <- NULL

names(cherhouse) <- c("precinct","person","mulvaney","barnes", "housewritein","housetotal")

cherhouse %>% 
  filter(precinct != "Precinct"  & precinct != "Total:") -> cherhouse


cherhouse[, 2:ncol(cherhouse)] <- apply(cherhouse[,2:ncol(cherhouse)], 2, function(x) as.numeric(gsub(',', '',x)))

cherhouse$county <- county

cherhouse <- cherhouse %>%
  select(county,precinct:housetotal)

# write_csv(cherhouse, "2016-ge-cherhouse.csv")

Cherokee <- left_join(cherturnout, cherst) %>%
  left_join(., cherpotus) %>%
  left_join(., chersen) %>%
  left_join(., cherhouse) %>%
  tbl_df()

write_csv(Cherokee, "2016-ge-cher-total.csv")
