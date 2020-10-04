
##############################################################################################################################
rm(list = ls())

library(XML)
library(dplyr)
library(RCurl)
library(tidyr)
library(rvest)     

years <- seq(2010,2019)
t<-0
for (yr in years){
  if(yr <= years[length(years)]){
    page <- read_html(paste0('https://www.pro-football-reference.com/years/',yr,'/games.htm'))
    urls <- list()
    years.data.list <- list()
    urls<-page %>% html_nodes("td.center a") %>% html_attr('href')
    for(i in urls){
      try({t <- t + 1
        URL <- tolower(paste0('https://www.pro-football-reference.com',i))
        webpage <- gsub('<!--', '', getURL(URL))
        tablesfromURL <- readHTMLTable(webpage, as.data.frame = TRUE, stringsAsFactors = FALSE)
        table <- tablesfromURL[["pbp"]]
        table <- table[,c(1:6,9:10)]
        table$year <- yr
        years.data.list[[t]] <- table
        })
    }
    years.data <- bind_rows(years.data.list) #combine all scraping results into single dataframe
    names(years.data) <- make.names(names(years.data), unique = TRUE, allow_ = TRUE) #fix duplicate col names
    years.data <- years.data %>% filter(!is.na(Quarter),Quarter !='NA', Quarter !='Quarter', Quarter != '1st Quarter',Quarter != '2nd Quarter',Quarter != '3rd Quarter',Quarter !='4th Quarter',Quarter !='End of Regulation') #remove multiple header rows
    years.data <- years.data %>% 
      mutate(
        Quarter = as.integer(Quarter),
        Time = as.integer(Time),
        Down = as.integer(Down),
        ToGo = as.integer(ToGo),
        Location = as.character(Location),
        #Yrs = ifelse(Yrs == 'Rook', as.integer(0), as.integer(Yrs)),
        Detail = as.character(Detail),
        EPB = as.integer(EPB),
        EPA= as.integer(EPA)
        )
      write.csv(years.data, paste0('c:/Users/vkaus/OneDrive/Desktop/Masters/Semster-3/OR-603/Webscrapping_Script-R/NFL-Project1',yr, '.csv'), row.names = F)
      
  }
  
  yr <- yr +1
  
}



