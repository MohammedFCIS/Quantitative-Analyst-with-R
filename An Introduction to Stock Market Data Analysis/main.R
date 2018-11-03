# Getting Data from Yahoo! Finance with quantmod
# Get quantmod
if (!require("quantmod")) {
  install.packages("quantmod")
  library(quantmod)
}

start <- as.Date("2016-01-01")
end <- as.Date("2016-10-01")

# Let's get Apple stock data; Apple's ticker symbol is AAPL. We use the
# quantmod function getSymbols, and pass a string as a first argument to
# identify the desired ticker symbol, pass 'yahoo' to src for Yahoo!
# Finance, and from and to specify date ranges

# The default behavior for getSymbols is to load data directly into the
# global environment, with the object being named after the loaded ticker
# symbol. This feature may become deprecated in the future, but we exploit
# it now.

getSymbols("AAPL", src = "yahoo", from = start, to = end)

# What is AAPL?
class(AAPL)

# Let's see the first few rows
head(AAPL)

# The different series are the columns of the object,
# with the name of the associated security (here, AAPL) 
# being prefixed to the corresponding series.

## Yahoo! Finance provides six series with each security.
# Open -> is the price of the stock at the beginning of the trading day 
#       (it need not be the closing price of the previous trading day), 
# high -> is the highest price of the stock on that trading day,
# low -> the lowest price of the stock on that trading day,
# close -> the price of the stock at closing time. 
# Volume -> indicates how many stocks were traded. 
# Adjusted close -> (abreviated as “adjusted” by getSymbols()) is the 
#                   closing price of the stock that adjusts the price 
#                   of the stock for corporate actions. 
# While stock prices are considered to be set mostly by traders,
# stock splits (when the company makes each extant stock worth two 
# and halves the price) and dividends (payout of company profits per share)
# also affect the price of a stock and should be accounted for.