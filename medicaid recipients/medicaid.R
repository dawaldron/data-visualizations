library(data.table)

d <- fread('usa_00099.csv')

# employment status
d[EMPSTAT == 1, Emp := 'Employed']
d[EMPSTAT == 2, Emp := 'Unemployed']
d[EMPSTAT == 3, Emp := 'Not in Labor Force']

d.e <- d[HINSCAID == 2 & AGE >= 18 & AGE < 65,
         .(sample = length(PERWT),
           number = sum(PERWT)),
         .(EMPSTAT, Emp)][order(EMPSTAT)]
d.e[, cumul := cumsum(number) - number]

# disabled/SSI categories
d[, Disabled := 'Not disabled']
d[DIFFREM == 2 |
    DIFFPHYS == 2 |
    DIFFMOB == 2 |
    DIFFCARE == 2 |
    DIFFSENS == 2 |
    DIFFEYE == 2 |
    DIFFHEAR == 2,
  Disabled := 'Disabled - No SSI']
d[INCSUPP > 0 & Disabled == 'Disabled - No SSI',
  Disabled := 'Disabled - On SSI']

d.d <- d[HINSCAID == 2 & AGE >= 18 & AGE < 65,
         .(sample = length(PERWT),
           number = sum(PERWT)),
         .(Disabled)][order(Disabled)]
d.d[, cumul := cumsum(number) - number]
d.d[, Disabled1 := tstrsplit(Disabled, ' - ', fixed = T)[1]]
d.d[, Disabled2 := tstrsplit(Disabled, ' - ', fixed = T)[2]]

# disability type
d.t <- d[HINSCAID == 2 & AGE >= 18 & AGE < 65,
         .(Cognitive = sum((DIFFREM == 2) * PERWT),
           Walking = sum((DIFFPHYS == 2) * PERWT),
           `Independent living` = sum((DIFFMOB == 2) * PERWT),
           `Self-care` = sum((DIFFCARE == 2) * PERWT),
           Vision = sum((DIFFEYE == 2) * PERWT),
           Hearing = sum((DIFFHEAR == 2) * PERWT)),
         .(Disabled)][order(Disabled)]

d.t <- melt(d.t[Disabled != 'Not disabled'], id.vars = 'Disabled')
d.t <- dcast(d.t, variable ~ Disabled, value.var = 'value')
setnames(d.t, names(d.t), c('Disability','No SSI','SSI'))

# write files
write.csv(d.e, 'e.csv', row.names = F)
write.csv(d.d, 'd.csv', row.names = F, na = '')
write.csv(d.t, 't.csv', row.names = F)
