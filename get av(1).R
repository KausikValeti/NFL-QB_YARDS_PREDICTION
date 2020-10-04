rm(list = ls())

library(XML)
library(dplyr)
library(RCurl)
library(tidyr)
# library(mice)

years <- seq(1999, 2019)

GET.TEAM.INFO <- T
GET.COMBINE.INFO <- F

if(GET.TEAM.INFO) {
  #team code list for scraping pfr
  teams <- c("crd",
             "ATL",
             "rav",
             "BUF",
             "CAR",
             "CHI",
             "CIN",
             "CLE",
             "DAL",
             "DEN",
             "DET",
             "GNB",
             "htx",
             "clt",
             "JAX",
             "KAN",
             "ram",
             "MIA",
             "MIN",
             "NOR",
             "NWE",
             "NYG",
             "NYJ",
             "rai",
             "PHI",
             "PIT",
             "SDG",
             "SEA",
             "SFO",
             "TAM",
             "oti",
             "WAS"
               )
  
team.data.list <- list() #initialize list of scraping results
t <- 0 #initialize team index
for(yr in years) {
  for(tm in teams) {
    try({ t <- t + 1
    URL <- tolower(paste0('https://www.pro-football-reference.com/teams/', tm,'/',yr,'_roster.htm'))
    webpage <- gsub('<!--', '', getURL(URL))
    tablesfromURL <- readHTMLTable(webpage, as.data.frame = TRUE, stringsAsFactors = FALSE)
    table <- tablesfromURL[[2]]
    names(table)[2] <- 'Player'
    table <- table[,1:13]
    table$team <- tm
    table$yr <- yr
    team.data.list[[t]] <-  table
    print(paste(tm,ncol(table)))
})
  }
}
team.data <- bind_rows(team.data.list) #combine all scraping results into single dataframe
names(team.data) <- make.names(names(team.data), unique = TRUE, allow_ = TRUE) #fix duplicate col names
team.data <- team.data %>% filter(!is.na(Player), Player != 'Player') #remove multiple header rows
team.data <- team.data %>% 
  mutate(
    Player =  gsub("[*]","", Player),
    Player =  gsub("[+]","", Player),
    AV = as.integer(AV),
    Age = as.integer(Age),
    G = as.integer(G),
    GS = as.integer(GS),
    Wt = as.integer(Wt),
    # Ht = as.integer(Ht),
    Yrs = ifelse(Yrs == 'Rook', as.integer(0), as.integer(Yrs)),
    draft.yr = yr - Yrs,
    age.at.draft = Age - Yrs
    
  ) #%>% filter(Yrs <= 3) #select first Y years of value here




 write.csv(team.data, paste0('c:/Data/combine/team_data ',years[1], '-', years[length(years)], '.csv'), row.names = F)

}

if(GET.COMBINE.INFO) {

combine.data.list <- list()
y <- 0
for(yr in years) {
  y <- y + 1
  # URL1 <- 'https://www.pro-football-reference.com/play-index/nfl-combine-results.cgi?request=1&year_min=2007&year_max=2007&pos%5B%5D=WR&pos%5B%5D=TE&pos%5B%5D=RB&pos%5B%5D=FB&pos%5B%5D=OT&pos%5B%5D=OG&show=all&order_by=year_id'
  URL1 <- paste0('https://www.pro-football-reference.com/play-index/nfl-combine-results.cgi?request=1&year_min=',yr,'&year_max=',yr,'&pos%5B%5D=WR&pos%5B%5D=TE&pos%5B%5D=RB&pos%5B%5D=FB&pos%5B%5D=OT&pos%5B%5D=OG&show=all&order_by=year_id')
  URL2 <- paste0('https://www.pro-football-reference.com/play-index/nfl-combine-results.cgi?request=1&year_min=',yr,'&year_max=',yr,'&pos%5B%5D=DE&pos%5B%5D=DT&pos%5B%5D=EDGE&pos%5B%5D=ILB&pos%5B%5D=OLB&pos%5B%5D=SS&show=all&order_by=year_id')
  URL3 <- paste0('https://www.pro-football-reference.com/play-index/nfl-combine-results.cgi?request=1&year_min=',yr,'&year_max=',yr,'&pos%5B%5D=QB&pos%5B%5D=C&pos%5B%5D=FS&pos%5B%5D=S&pos%5B%5D=CB&pos%5B%5D=LS&pos%5B%5D=K&pos%5B%5D=P&show=all&order_by=year_id')
  
  

  
  
  # website1 <- getURL(URL1) #gsub('<!--', '', getURL(URL1))
  # startpos1 <- regexpr('<table', website1)
  # endpos1 <- regexpr('</table>', website1) + 7
  # website1 <- substr(website1, startpos1, endpos1)
  
  
# grepl('<table', website1)
  # tablesfromURL1 <- readHTMLTable(website1, as.data.frame = TRUE, stringsAsFactors = FALSE)
 if(yr == 2007) {
   html.in <- readChar('c:/Data/wonderlic/fix.html', file.info('c:/Data/wonderlic/fix.html')$size)
   tablesfromURL1 <- readHTMLTable(html.in, as.data.frame = TRUE, stringsAsFactors = FALSE)
 } else {
    tablesfromURL1 <- readHTMLTable(gsub('<!--', '', getURL(URL1)), as.data.frame = TRUE, stringsAsFactors = FALSE)
 }
  tablesfromURL2 <- readHTMLTable(gsub('<!--', '', getURL(URL2)), as.data.frame = TRUE, stringsAsFactors = FALSE)
  tablesfromURL3 <- readHTMLTable(gsub('<!--', '', getURL(URL3)), as.data.frame = TRUE, stringsAsFactors = FALSE)
  table1 <- tablesfromURL1[[1]]
  table2 <- tablesfromURL2[[1]]
  table3 <- tablesfromURL3[[1]]
  table <- rbind(table1, table2, table3)
  table$yr <- yr  
  combine.data.list[[y]] <- table
    
    

  
}
combine.data <- do.call("rbind", combine.data.list) #combine all scraping results into single dataframe
names(combine.data) <- make.names(names(combine.data), unique = TRUE, allow_ = TRUE) #fix duplicate col names
combine.data <- combine.data %>% filter(!is.na(Player), Player != 'Player') #remove multiple header rows
combine.data <- combine.data %>% 
  separate(Height, c('ft', 'ht'), sep='-') %>% 
  mutate(Player =  gsub("[*]","", Player),
         Player =  gsub("[+]","", Player),
         ht = as.integer(ft) * 12 + as.integer(ht),
         Wt = as.integer(Wt),
         X40YD = as.numeric(X40YD),
         Vertical = as.numeric(Vertical),
         BenchReps = as.integer(BenchReps),
         Broad.Jump = as.numeric(Broad.Jump),
         X3Cone = as.numeric(X3Cone),
         Shuttle = as.numeric(Shuttle)
         )
  
write.csv(combine.data, 'c:/Data/wonderlic/combine_data.csv', row.names = F)
table(combine.data$Pos) 
}

beepr::beep()
# 
# fileConn<-file("c:/Data/wonderlic/test.html")
# writeLines(website1, fileConn)
# close(fileConn)

