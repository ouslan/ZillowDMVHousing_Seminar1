# Set working directory
setwd("/Users/alexdelatorre/Desktop/IES Abroad Courses/(URL) SO 440-01 Research Techniques and Statistics/Learning Units/seminar1_so440")

# Load necessary libraries
library(tidyverse)
library(readr)
library(zoo)

# Load data
rent_data <- read_csv("City_zori_uc_sfrcondomfr_sm_month.csv")

# Filter for Washington D.C. Metro Area (DMV)
dmv_rent <- rent_data %>%
  filter(Metro == "Washington-Arlington-Alexandria, DC-VA-MD-WV")

# Convert to long format
dmv_rent_long <- dmv_rent %>%
  pivot_longer(cols = starts_with("20"), names_to = "Date", values_to = "Rent")

# Format Date properly
dmv_rent_long$Date <- as.Date(paste0(dmv_rent_long$Date, "-01"))

# Calculate 3-month rolling average
dmv_rent_long <- dmv_rent_long %>%
  arrange(Date) %>%
  mutate(rolling_avg = rollmean(Rent, k = 3, fill = NA, align = "right"))

# Generate summary statistics
summary_stats <- dmv_rent_long %>%
  summarize(
    mean_rent = mean(Rent, na.rm = TRUE),
    median_rent = median(Rent, na.rm = TRUE),
    sd_rent = sd(Rent, na.rm = TRUE)
  )

print(summary_stats)

# Plot with legend and caption
ggplot(dmv_rent_long, aes(x = Date)) +
  geom_line(aes(y = Rent, color = "Observed Rent"), alpha = 0.5, linewidth = 0.5) + 
  geom_line(aes(y = rolling_avg, color = "3-Month Rolling Avg"), linewidth = 1) +
  scale_color_manual(values = c("Observed Rent" = "blue", "3-Month Rolling Avg" = "red")) +
  labs(
    title = "DMV Metro Area Rental Price Trends",
    x = "Date",
    y = "Rent ($)",
    color = "Legend",  # Title for the legend
    caption = "Source: Zillow Observed Rent Index (ZORI) data, accessed from Zillow Research. 
               This plot displays the smoothed, seasonally adjusted typical market rate rent 
               for all homes and multifamily residences in the DMV metro area over the 
               specified time period. The data reflects observed asking rents and is weighted 
               to represent the entire rental housing stock, not just currently listed properties. 
               This plot does not account for rental concessions or off-market agreements 
               and may not capture rapid short-term fluctuations in rental prices."
  ) +
  theme_minimal()