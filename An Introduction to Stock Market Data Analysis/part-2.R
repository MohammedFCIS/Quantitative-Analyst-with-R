# source: https://ntguardian.wordpress.com/2017/04/03/introduction-stock-market-data-r-2/
# open position -> a trade that will be terminated in the future when a condition is met.
# long position -> is one in which a profit is made if the financial instrument traded
# increases in value
# short position -> is on in which a profit is made if the financial asset being
# traded decreases in value.

## The fllowing are the commands that worked with me for installation
## I will leave the original code though
# install.packages("devtools")
# require(devtools)
# install_github("braverock/FinancialInstrument")
# install_github("joshuaulrich/xts")
# install_github("braverock/blotter")
# install_github("braverock/quantstrat")
# install_github("braverock/PerformanceAnalytics")

if (!require("TTR")) {
  install.packages("TTR")
  library(TTR)
}
if (!require("quantstrat")) {
  install.packages("quantstrat", repos = "http://R-Forge.R-project.org")
  library(quantstrat)
}

if (!require("IKTrading")) {
  if (!require("devtools")) {
    install.packages("devtools")
  }
  library(devtools)
  install_github("IlyaKipnis/IKTrading", username = "IlyaKipnis")
  library(IKTrading)
}
library(quantmod)

start <- as.Date("2010-01-01")
end <- as.Date("2016-10-01")

# Let's get Apple stock data; Apple's ticker symbol is AAPL.
# We use the quantmod function getSymbols, and pass a string as
# a first argument to identify the desired ticker symbol,
# pass "yahoo" to src for Yahoo! Finance, and from and to specify date ranges

# The default behavior for getSymbols is to load data directly 
# into the global environment, with the object being named after 
# the loaded ticker symbol. This feature may become deprecated in 
# the future, but we exploit it now.

getSymbols("AAPL",
           src = "yahoo",
           from = start,
           to = end)

# What is AAPL?
class(AAPL)

# Let's see the first few rows
head(AAPL)

candleChart(AAPL, up.col = "black", dn.col = "red", theme = "white", subset = "2016-01-04/")

AAPL_sma_20 <- SMA(
  Cl(AAPL),  # The closing price of AAPL, obtained by quantmod's Cl() function
  n = 20     # The number of days in the moving average window
)

AAPL_sma_50 <- SMA(
  Cl(AAPL),
  n = 50
)

AAPL_sma_200 <- SMA(
  Cl(AAPL),
  n = 200
)

zoomChart("2016")  # Zoom into the year 2016 in the chart
addTA(AAPL_sma_20, on = 1, col = "red")  # on = 1 plots the SMA with price
addTA(AAPL_sma_50, on = 1, col = "blue")
addTA(AAPL_sma_200, on = 1, col = "green")

# identify regimes with the following
AAPL_trade <- AAPL
AAPL_trade$`20d` <- AAPL_sma_20
AAPL_trade$`50d` <- AAPL_sma_50

regime_val <- sigComparison("", data = AAPL_trade,
                            columns = c("20d", "50d"), relationship = "gt") -
  sigComparison("", data = AAPL_trade,
                columns = c("20d", "50d"), relationship = "lt")

plot(regime_val["2016"], main = "Regime", ylim = c(-2, 2))
plot(regime_val, main = "Regime", ylim = c(-2, 2))

# visualize the regime along with the main series with the following code:
candleChart(AAPL, up.col = "black", dn.col = "red", theme = "white", subset = "2016-01-04/")
addTA(regime_val, col = "blue", yrange = c(-2, 2))
addLines(h = 0, col = "black", on = 3)
addSMA(n = c(20, 50), on = 1, col = c("red", "blue"))
zoomChart("2016")


candleChart(AAPL, up.col = "black", dn.col = "red", theme = "white", subset = "2016-01-04/")
addTA(regime_val, col = "blue", yrange = c(-2, 2))
addLines(h = 0, col = "black", on = 3)
addSMA(n = c(20, 50), on = 1, col = c("red", "blue"))

table(as.vector(regime_val))

# s_t \in \{-1, 0, 1\}, with -1 indicating “sell”,
# 1 indicating “buy”, and 0 no action. We can obtain signals like so:
sig <- diff(regime_val) / 2
plot(sig, main = "Signal", ylim = c(-2, 2))
table(sig)

# Let’s now try to identify what the prices of the stock is at every buy and every sell.
# The Cl function from quantmod pulls the closing price from the object
# holding a stock's data

# Buy prices
Cl(AAPL)[which(sig == 1)]
# Sell prices
Cl(AAPL)[sig == -1]

# Since these are of the same dimension, computing profit is easy
as.vector(Cl(AAPL)[sig == 1])[-1] - Cl(AAPL)[sig == -1][-table(sig)[["1"]]]

# Above, we can see that on May 22nd, 2013,
# there was a massive drop in the price of Apple stock,
# and it looks like our trading system would do badly. 
# But this price drop is not because of a massive shock to Apple,
# but simply due to a stock split. And while dividend payments are 
# not as obvious as a stock split, 
# they may be affecting the performance of our system.

candleChart(AAPL, up.col = "black", dn.col = "red", theme = "white")
addTA(regime_val, col = "blue", yrange = c(-2, 2))
addLines(h = 0, col = "black", on = 3)
addSMA(n = c(20, 50), on = 1, col = c("red", "blue"))
zoomChart("2014-05/2014-07")

# Let’s go back, adjust the apple data, and reevaluate our trading system using the adjusted data.
candleChart(adjustOHLC(AAPL), up.col = "black", dn.col = "red", theme = "white")
addLines(h = 0, col = "black", on = 3)
addSMA(n = c(20, 50), on = 1, col = c("red", "blue"))

# Test strategy
rm(list = ls(.blotter), envir = .blotter)  # Clear blotter environment
currency("USD")  # Currency being used
Sys.setenv(TZ = "MDT")  # Allows quantstrat to use timestamps
# Next, we declare the stocks we are going to be working with.
AAPL_adj <- adjustOHLC(AAPL)
stock("AAPL_adj", currency = "USD", multiplier = 1)
initDate <- "1990-01-01"  # A date prior to first close price; needed (why?)

# Now we create a portfolio and account object that will be used in the simulation

strategy_st <- portfolio_st <- account_st <- "SMAC-20-50"  # Names of objects
rm.strat(portfolio_st)  # Need to remove portfolio from blotter env
rm.strat(strategy_st)   # Ensure no strategy by this name exists either
initPortf(portfolio_st, symbols = "AAPL_adj",  # This is a simple portfolio
          # trading AAPL only
          initDate = initDate, currency = "USD")
initAcct(account_st, portfolios = portfolio_st,  # Uses only one portfolio
         initDate = initDate, currency = "USD",
         initEq = 1000000)  # Start with a million dollars
initOrders(portfolio_st, store = TRUE)  # Initialize the order container; will
# contain all orders made by strategy

# Now we define the strategy
strategy(strategy_st, store = TRUE)  # store = TRUE tells function to store in
# the .strategy environment

# Now define trading rules
# Indicators are used to construct signals
add.indicator(strategy = strategy_st, name = "SMA",     # SMA is a function
              arguments = list(x = quote(Cl(mktdata)),  # args of SMA
                               n = 20),
              label = "fastMA")
add.indicator(strategy = strategy_st, name = "SMA",
              arguments = list(x = quote(Cl(mktdata)),
                               n = 50),
              label = "slowMA")
# Next comes trading signals
add.signal(strategy = strategy_st, name = "sigComparison",  # Remember me?
           arguments = list(columns = c("fastMA", "slowMA"),
                            relationship = "gt"),
           label = "bull")
add.signal(strategy = strategy_st, name = "sigComparison",
           arguments = list(columns = c("fastMA", "slowMA"),
                            relationship = "lt"),
           label = "bear")

# Finally, rules that generate trades
add.rule(strategy = strategy_st, name = "ruleSignal",  # Almost always this one
         arguments = list(sigcol = "bull",  # Signal (see above) that triggers
                          sigval = TRUE,
                          ordertype = "market",
                          orderside = "long",
                          replace = FALSE,
                          prefer = "Open",
                          osFUN = osMaxDollar,
                          # The next parameter, which is a parameter passed to
                          # osMaxDollar, will ensure that trades are about 10%
                          # of portfolio equity
                          maxSize = quote(floor(getEndEq(account_st,
                                                         Date = timestamp) * .1)),
                          tradeSize = quote(floor(getEndEq(account_st,
                                                           Date = timestamp) * .1))),
         type = "enter", path.dep = TRUE, label = "buy")
add.rule(strategy = strategy_st, name = "ruleSignal",
         arguments = list(sigcol = "bear",
                          sigval = TRUE,
                          orderqty = "all",
                          ordertype = "market",
                          orderside = "long",
                          replace = FALSE,
                          prefer = "Open"),
         type = "exit", path.dep = TRUE, label = "sell")
applyStrategy(strategy_st, portfolios = portfolio_st)

# Here we effectvely conclude the study so we can perform some analytics.

updatePortf(portfolio_st)
dateRange <- time(getPortfolio(portfolio_st)$summary)[-1]
updateAcct(portfolio_st, dateRange)
updateEndEq(account_st)

# Here’s our first set of useful summary statistics.
tStats <- tradeStats(Portfolios = portfolio_st, use="trades",
                     inclZeroDays = FALSE)
tStats[, 4:ncol(tStats)] <- round(tStats[, 4:ncol(tStats)], 2)
print(data.frame(t(tStats[, -c(1,2)])))

final_acct <- getAccount(account_st)
plot(final_acct$summary$End.Eq["2010/2016"], main = "Portfolio Equity")
