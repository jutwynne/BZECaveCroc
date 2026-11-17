# Script S2. Tables 2 Ð 4 

# Thermal Behavior of Crocodile Caves in Central Belize

# Authors: Wynne, J.J., Shaffer, I.N., Roberts, J.

# Script Author: J. Judson Wynne

# Input file: CrocCave_Data.xlsx

# Outputs:
# Table 2: Monthly water temperature summaries for the winter period.
# Table 3: Per logger summary statistics of daily minimum temperatures across the winter period.
# Table 4: Per logger per month with median temperature across all hourly readings, and percentage of days with a daily median above 24.22¡C.

# Packages required: 
# readxl
# dplyr
# lubridate

library(readxl)
library(dplyr)
library(lubridate)

# Read and process Excel file
input_file <- "CrocCave_Data.xlsx"

sheets <- excel_sheets(input_file)

dat <- lapply(sheets, function(sheet) { data <- read_excel(input_file, sheet = sheet); data$Logger <- sub("_.*$", "", sheet); data$Cave <- sub("^[^_]+_", "", sheet); data %>% mutate(DateTime = as.POSIXct(paste(as.Date(Date), format(Time, "%H:%M:%S")), format = "%Y-%m-%d %H:%M:%S", tz = "UTC")) }) %>% bind_rows()

# Winter period defined: 01 November 2022 through 18 February 2023

winter_start <- as.Date("2022-11-01") 

winter_end <- as.Date("2023-02-19")

# Keep the entire 24-hour record within the winter window

dat_winter <- dat %>% filter(DateTime >= winter_start, DateTime < winter_end) %>% mutate(DayDate = as.Date(DateTime, tz = "UTC"), MonthDate = floor_date(DayDate, unit = "month"))

# Table 2: Monthly water temperature summaries for the winter period

# Median and range per cave and day

daily_stats <- dat_winter %>% group_by(Cave, MonthDate, DayDate) %>% summarize(DailyMedian = if (all(is.na(`Temperature (C)`))) NA_real_ else median(`Temperature (C)`, na.rm = TRUE), DailyRange = if (all(is.na(`Temperature (C)`))) NA_real_ else max(`Temperature (C)`, na.rm = TRUE) - min(`Temperature (C)`, na.rm = TRUE), .groups = "drop") %>% filter(is.finite(DailyMedian), is.finite(DailyRange))

# Monthly median across all hourly readings

monthly_medians <- dat_winter %>% group_by(Cave, MonthDate) %>% summarize(Median = median(`Temperature (C)`, na.rm = TRUE), .groups = "drop")

# Monthly percentage of days above the threshold and median daily range

monthly_daily_stats <- daily_stats %>% group_by(Cave, MonthDate) %>% summarize(`% Days > 24.22 C` = mean(DailyMedian > 24.22) * 100, `Median Range` = median(DailyRange), .groups = "drop")

# Combine and format the table

Table2 <- monthly_medians %>% left_join(monthly_daily_stats, by = c("Cave", "MonthDate")) %>% mutate(Month = format(MonthDate, "%Y-%m"), Median = round(Median, 2), `% Days > 24.22 C` = round(`% Days > 24.22 C`, 2), `Median Range` = round(`Median Range`, 2)) %>% select(Cave, Month, Median, `% Days > 24.22 C`, `Median Range`) %>% arrange(Cave, Month)

# Table 3. Distributional metrics of winter minimum temperatures

daily_minima <- dat_winter %>% group_by(Cave, Logger, DayDate) %>% summarize(DailyMin = if (all(is.na(`Temperature (C)`))) NA_real_ else min(`Temperature (C)`, na.rm = TRUE), .groups = "drop") %>% filter(!is.na(DailyMin), is.finite(DailyMin))

Table3 <- daily_minima %>% group_by(Cave, Logger) %>% summarize(Tmin = round(min(DailyMin), 2), `5th %` = round(quantile(DailyMin, 0.05), 2), `10th %` = round(quantile(DailyMin, 0.10), 2), Median = round(median(DailyMin), 2), .groups = "drop") %>% arrange(Cave, Logger)

# Table 4: Per logger monthly statistics using the 24-hour time series
daily_medians <- dat_winter %>% group_by(Cave, Logger, DayDate, MonthDate) %>% summarize(DailyMedian = if (all(is.na(`Temperature (C)`))) NA_real_ else median(`Temperature (C)`, na.rm = TRUE), .groups = "drop") %>% filter(!is.na(DailyMedian), is.finite(DailyMedian))

monthly_medians <- dat_winter %>% group_by(Cave, Logger, MonthDate) %>% summarize(Median = if (all(is.na(`Temperature (C)`))) NA_real_ else round(median(`Temperature (C)`, na.rm = TRUE), 2), .groups = "drop")

monthly_percentages <- daily_medians %>% group_by(Cave, Logger, MonthDate) %>% summarize(Percent_Above_24_22 = round(mean(DailyMedian > 24.22) * 100, 1), .groups = "drop")

Table4 <- monthly_medians %>% left_join(monthly_percentages, by = c("Cave", "Logger", "MonthDate")) %>% arrange(Cave, Logger, MonthDate) %>% mutate(Month = format(MonthDate, "%b %Y")) %>% select(Cave, Logger, Month, Median, Percent_Above_24_22)

# Save results
write.csv(Table2, "Table2_Winter_Monthly.csv", row.names = FALSE)

write.csv(Table3, "Table3_WinterDailyMinima.csv", row.names = FALSE)

write.csv(Table4, "Table4_WinterMonthly_Logger_Stats.csv", row.names = FALSE)
