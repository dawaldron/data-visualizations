setwd('C:/Users/dwald/OneDrive/ZenBook backup/Blog/Data/NFL')
library(rvest)
library(data.table)



getTossResultsWeek <- function(year, week) {
  
  getTossResult <- function(boxscoreLink) {
    print(paste0('Getting: ', boxscoreLink))
    Sys.sleep(5)
    html_page <- read_html(paste0('https://www.pro-football-reference.com', boxscoreLink))
    
    c_gameInfo <- html_page %>%
      html_node('body') %>%
      html_node('#all_game_info') %>%
      html_nodes(xpath = 'comment()') %>%
      html_text() %>%
      read_html() %>%
      html_node('table') %>%
      html_table() %>%
      data.table()
    
    c_homeDrives <- html_page %>%
      html_node('body') %>%
      html_node('#all_home_drives') %>%
      html_nodes(xpath = 'comment()') %>%
      html_text() %>%
      read_html() %>%
      html_node('#home_drives') %>%
      html_table() %>%
      data.table() %>%
      .[, team := 'home']
    
    c_awayDrives <- html_page %>%
      html_node('body') %>%
      html_node('#all_vis_drives') %>%
      html_nodes(xpath = 'comment()') %>%
      html_text() %>%
      read_html() %>%
      html_node('#vis_drives') %>%
      html_table() %>%
      data.table() %>%
      .[, team := 'visitor']
    
    c_drives <- rbind(c_homeDrives, c_awayDrives)
    
    result <- data.table(link = boxscoreLink,
                         wonToss = c_gameInfo[X1 == 'Won Toss', X2],
                         kick1 = c_drives[Quarter == 1 & Time == '15:00', team],
                         kick2 = c_drives[Quarter == 3 & Time == '15:00', team])
    return(result)
  }
  
  print(paste0('Starting ', year, ', week ', week, '...'))
  Sys.sleep(5)
  html_page <- read_html(paste0('https://www.pro-football-reference.com/years/', year, '/week_', week, '.htm'))
  boxscore <- html_page %>%
    html_nodes('.teams')
    
  boxscoreTable <- boxscore %>%
    html_table()
  
  boxscoreData <- lapply(boxscoreTable, function(x) {
    data.table(homeTeam = x[2,1],
               awayTeam = x[3,1],
               homeScore = x[2,2],
               awayScore = x[3,2])
  }) %>%
    rbindlist()
  
  boxscoreLinks <- boxscore %>%
    html_node('.gamelink') %>%
    html_node('a') %>%
    html_attr('href')
  
  boxscoreData[, link := boxscoreLinks]
  tossResults <- lapply(boxscoreData[, link], getTossResult) %>%
    rbindlist()
  tossResults <- boxscoreData[tossResults, on = 'link']
  return(tossResults)
}

runWeek <- function(year, week) {
  dt <- getTossResultsWeek(year, week)
  fwrite(dt, paste0('toss', year, '.', week, '.csv'))
}

runWeek(2018, 1)
runWeek(2018, 2)
runWeek(2018, 3)
runWeek(2018, 4)
runWeek(2018, 5)
runWeek(2018, 6)
runWeek(2018, 7)
runWeek(2018, 8)
runWeek(2018, 9)
runWeek(2018, 10)
runWeek(2018, 11)
runWeek(2018, 12)
runWeek(2018, 13)
runWeek(2018, 14)
runWeek(2018, 15)
runWeek(2018, 16)
runWeek(2018, 17)
