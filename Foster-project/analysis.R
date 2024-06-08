# Quantitative Finance: CPP2
# Adam Foster
# University of Warsaw
# 2024-06-08

library(ggplot2)
library(gridExtra)
library(tibble)

# Remove package if it exists
remove.packages("OptionPricer")
detach("package:OptionPricer", unload = TRUE)

# Install package and load to memory - ensure package path is correct
install.packages("../OptionPricer_0.1.0.tar.gz",
                 type = "source",
                 repos = NULL)

library("OptionPricer")

# Call the function and calculate stats
MCEuropeanCall <- function(antithetic) {
  prices <- rep(NA, 1000)
  for (i in 1:length(prices)) {
    cat(i, "\n")
    prices[i] <-
      MCEuropeanOptionPricer("C", 0.5, 100, 95, 0.2, 0.06, antithetic, 10000, i)
  }

  meanPrices <- mean(prices)
  stdPrices <- sd(prices)
  plotPrices <- tibble(prices = prices) %>%
    ggplot(aes(prices)) +
    geom_histogram(col = "black", fill = "pink", bins = 25) +
    ggtitle(paste("Prices: Antithetic Variates", antithetic))
  cat("Stats calculated\n")

  return(list(meanPrices = meanPrices, stdPrices = stdPrices, plotPrices = plotPrices))
}

prices <- MCEuropeanCall(FALSE)
pricesAntithetic <- MCEuropeanCall(TRUE)

cat(paste("Mean of prices without antithetic variates:", round(prices$meanPrices, digits = 4), "\n"))
cat(paste("Mean of prices with antithetic variates:", round(pricesAntithetic$meanPrices, digits = 4), "\n"))
cat(paste("Std of prices without antithetic variates:", round(prices$stdPrices, digits = 4), "\n"))
cat(paste("Std of prices with antithetic variates:", round(pricesAntithetic$stdPrices, digits = 4), "\n"))
grid.arrange(prices$plotPrices, pricesAntithetic$plotPrices, ncol = 2)
cat("Variance has been reduced with antithetic variates from", round(prices$stdPrices, digits = 4),
    "to", round(pricesAntithetic$stdPrices, digits = 4), "; the",
    round(-100 * (pricesAntithetic$stdPrices - prices$stdPrices) / prices$stdPrices, digits = 2),
    "% decrease is expected as antithetic variates provide antithetic equivalents of random variables,
    generating negative covariance and reducing overall variance", "\n")
