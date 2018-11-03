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

# Let's get Apple stock data; Apple's ticker symbol is AAPL. We use the quantmod function getSymbols, and pass a string as a first argument to identify the desired ticker symbol, pass "yahoo" to src for Yahoo! Finance, and from and to specify date ranges

# The default behavior for getSymbols is to load data directly into the global environment, with the object being named after the loaded ticker symbol. This feature may become deprecated in the future, but we exploit it now.

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
