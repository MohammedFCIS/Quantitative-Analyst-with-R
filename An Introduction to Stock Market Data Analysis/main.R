# Getting Data from Yahoo! Finance with quantmod
# Get quantmod
if (!require("quantmod")) {
  install.packages("quantmod")
  library(quantmod)
}

# Get me my beloved pipe operator!
if (!require("magrittr")) {
  install.packages("magrittr")
  library(magrittr)
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
#----------------------------------------------------------------------------------

# Visualizing Stock Data
plot(AAPL[, "AAPL.Close"], main = "AAPL")

# A linechart is fine, but there are at least four variables involved for 
# each date (open, high, low, and close), and we would like to have some visual
# way to see all four variables that does not require plotting four separate lines.
# Financial data is often plotted with a Japanese candlestick plot, so named because
# it was first created by 18th century Japanese rice traders. 
# Use the function candleChart() from quantmod to create such a chart.
candleChart(AAPL, up.col = "black", dn.col = "red", theme = "white")

#----------------------------------------------------------------------------------

# Let's get data for Microsoft (MSFT) and Google (GOOG) (actually, Google is
# held by a holding company called Alphabet, Inc., which is the company
# traded on the exchange and uses the ticker symbol GOOG).
getSymbols(c("MSFT", "GOOG"), src = "yahoo", from = start, to = end)

# Create an xts object (xts is loaded with quantmod) that contains closing
# prices for AAPL, MSFT, and GOOG
stocks <- as.xts(data.frame(AAPL = AAPL[, "AAPL.Close"], MSFT = MSFT[, "MSFT.Close"], 
                            GOOG = GOOG[, "GOOG.Close"]))
head(stocks)

# Create a plot showing all series as lines; must use as.zoo to use the zoo
# method for plot, which allows for multiple series to be plotted on same
# plot
plot(as.zoo(stocks), screens = 1, lty = 1:3, xlab = "Date", ylab = "Price")
legend("right", c("AAPL", "MSFT", "GOOG"), lty = 1:3, cex = 0.5)

# use two different scales when plotting the data; 
# one scale will be used by Apple and Microsoft stocks, and the other by Google.
plot(as.zoo(stocks[, c("AAPL.Close", "MSFT.Close")]), screens = 1, lty = 1:2, 
     xlab = "Date", ylab = "Price")
par(new = TRUE)
plot(as.zoo(stocks[, "GOOG.Close"]), screens = 1, lty = 3, xaxt = "n", yaxt = "n", 
     xlab = "", ylab = "")
axis(4)
mtext("Price", side = 4, line = 3)
legend("topleft", c("AAPL (left)", "MSFT (left)", "GOOG"), lty = 1:3, cex = 0.5)

# transform data
stock_return <- apply(stocks, 1, function(x) {
  x / stocks[1, ]
}) %>%
  t %>% as.xts

head(stock_return)


plot(
  as.zoo(stock_return),
  screens = 1,
  lty = 1:3,
  xlab = "Date",
  ylab = "Return"
)
legend("topleft",
       c("AAPL", "MSFT", "GOOG"),
       lty = 1:3,
       cex = 0.5)

#We can obtain and plot the log differences of the data in stocks as follows:

stock_change <- stocks %>% log %>% diff
head(stock_change)

plot(as.zoo(stock_change), screens = 1, lty = 1:3, xlab = "Date", ylab = "Log Difference")
legend("topleft", c("AAPL", "MSFT", "GOOG"), lty = 1:3, cex = 0.5)

#----------------------------------------------------------------------------------

# Moving Averages
# quantmod allows for easily adding moving averages to charts, via the addSMA() function.

candleChart(AAPL, up.col = "black", dn.col = "red", theme = "white")
addSMA(n = 20)

# increase the investigation period
start <-  as.Date("2010-01-01")
getSymbols(c("AAPL", "MSFT", "GOOG"), src = "yahoo", from = start, to = end)

# The subset argument allows specifying the date range to view in the chart.
# This uses xts style subsetting. Here, I'm using the idiom
# 'YYYY-MM-DD/YYYY-MM-DD', where the date on the left-hand side of the / is
# the start date, and the date on the right-hand side is the end date. If
# either is left blank, either the earliest date or latest date in the
# series is used (as appropriate). This method can be used for any xts
# object, say, AAPL
candleChart(AAPL, up.col = "black", dn.col = "red", theme = "white", subset = "2016-01-04/")
addSMA(n = 20)
