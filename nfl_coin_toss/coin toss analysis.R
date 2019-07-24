setwd('C:/Users/dwald/OneDrive/ZenBook backup/Blog/Data/NFL/toss data')
library(data.table)
library(magrittr)

dt_toss <- lapply(1999:2018, function(y) {
  dt_year <- lapply(1:17, function(w, yr) {
    fread(paste0('toss', yr, '.', w, '.csv')) %>%
      .[, year := yr] %>%
      .[, week := w] %>%
      return()
  }, yr = y) %>%
    rbindlist()
}) %>%
  rbindlist()

dt_toss <- dt_toss[,
                   .(year,
                     week,
                     homeTeam = awayTeam,
                     awayTeam = homeTeam,
                     homeScore = awayScore,
                     awayScore = homeScore,
                     link,
                     wonToss,
                     recieve1 = kick1,
                     recieve2 = kick2)]
# fwrite(dt_toss, 'toss data.csv')
dt_toss <- fread('toss data.csv')
dt_toss[, deferred := grepl('defer', wonToss, fixed = TRUE)]
dt_toss[, wonToss := gsub(' (deferred)', '', wonToss, fixed = TRUE)]
dt_toss[, choice := ifelse((mapply(grepl, pattern = wonToss, x = homeTeam) & recieve1 =='home')
                           | (mapply(grepl, pattern = wonToss, x = awayTeam) & recieve1 =='visitor'),
                           'recieve',
                           ifelse(deferred | year >= 2008,
                                  'defer',
                                  'kick/defend'))]
dt_toss[, wonGame := 'tie']
dt_toss[homeScore > awayScore, wonGame := homeTeam]
dt_toss[awayScore > homeScore, wonGame := awayTeam]

dt_toss[, resultTossWinner := 'tie']
dt_toss[wonGame != 'tie', resultTossWinner := 'loss']
dt_toss[mapply(grepl, pattern = wonToss, x = wonGame), resultTossWinner := 'win']


dt.sum <- dt_toss[,
                  .(freq = .N),
                  .(wonToss,
                    year,
                    resultTossWinner,
                    choice)]

fwrite(dt_toss, 'results.csv')
fwrite(dt.sum, 'summary.csv')
fwrite(dt_toss[choice == 'kick/defend'], 'kick.csv')
