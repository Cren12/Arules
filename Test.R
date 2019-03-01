packages <- c('arules',
              'Rblpapi',
              'quantmod',
              'magrittr',
              'PerformanceAnalytics')

# +------------------------------------------------------------------
# | library and require load and attach add-on packages. Download and
# | install packages from CRAN-like repositories.
# +------------------------------------------------------------------

lapply(X = packages,
       FUN = function(package){
         if (!require(package = package,
                      character.only = TRUE))
         {
           install.packages(pkgs = package,
                            repos = "https://cloud.r-project.org")
           library(package = package,
                   character.only = TRUE)
         } else {
           library(package = package,
                   character.only = TRUE)    
         }
       })

# +------------------------------------------------------------------
# | Sys.setenv sets environment variables.
# +------------------------------------------------------------------

Sys.setenv(TZ = 'UTC')

# +------------------------------------------------------------------
# | source() causes R to accept its input from the named file or URL
# | or connection or expressions directly.
# +------------------------------------------------------------------

source('getSymbolsFromBloomberg.R')

securities <- c('SPX Index', 'DAX Index')
getSymbolsFromBloomberg(securities = securities,
                        start.date = Sys.Date() - 5 * 365)
X <- na.omit(merge(Cl(`SPX Index`), Cl(`DAX Index`)))
dX <- CalculateReturns(prices = X) ; dX[1, ] <- 0
colnames(dX) <- NULL
items <- round(scale(dX))
items.matrix <- data.frame(trID = index(items), SPX = as.character(items[, 1]), DAX = as.character(items[, 2]))
rownames(items.matrix) <- NULL
items.matrix <- as.matrix(items.matrix)
trans.list <- split(x = items.matrix[, -1],
                    f = items.matrix[, 1])
trans <- as(trans.list, 'transactions')
itemsets <- apriori(data = trans,
                    parameter = list(support = 0))
rules <- ruleInduction(itemsets, trans)
inspect(rules)
