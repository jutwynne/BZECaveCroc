# Script S06. All data-driven figures

# Thermal Behavior of Crocodile Caves in Central Belize

# Authors: Wynne, J.J., Shaffer, I.N., Roberts, J.

# Script author: J. Judson Wynne

# R-Studio Version: 2025.05.1+513 (2025.05.1+513)

# Input file
# CrocCave_Data.xlsx

# Outputs

# Figure 2. 24-hour time series of raw water temperature data (from paper)
# Figure 3. Boxplots of winter water temperatures
# Figure 4. Heat map for raw time series (from paper)
# Figures S1 & S2. Phase-derived delay versus period (Sup. Mat.)
# Figure S3. Heat map for detrended time series (Sup. Mat.)

# Required other scripts
# Must run first: S05_PeakCohearencePhase.R

# Required packages:
# readxl
# tidyverse
# lubridate
# ggplot2
# dplyr
# tidyr

# Packages for generating figures

library(readxl)
library(tidyverse) 
library(lubridate)
library(ggplot2)
library(dplyr)
library(tidyr)

# Read and process Excel file
input_file <- "CrocCave_Data.xlsx"

sheets <- excel_sheets(input_file)

dat <- lapply(sheets, function(sheet) { data <- read_excel(input_file, sheet = sheet); data$Logger <- sub("_.*$", "", sheet); data$Cave <- sub("^[^_]+_", "", sheet); data$Cave[data$Cave == "Croc2"] <- "Croc 2"; data %>% mutate(DateTime = as.POSIXct(paste(as.Date(Date), format(Time, "%H:%M:%S")), format = "%Y-%m-%d %H:%M:%S", tz = "UTC"), Temp = `Temperature (C)`) }) %>% bind_rows()

# Winter period defined: 01 November 2022 through 18 February 2023

winter_start <- as.Date("2022-11-01") 

winter_end <- as.Date("2023-02-19")

# Keep the entire 24-hour record within the winter window

dat_winter <- dat %>% filter(DateTime >= winter_start, DateTime < winter_end) %>% mutate(DayDate = as.Date(DateTime, tz = "UTC"), MonthDate = floor_date(DayDate, unit = "month"))

# Figure 2. 24-hour time series of raw water temperature data

daily_cave <- dat %>% mutate(Date = as.Date(DateTime)) %>% group_by(Cave, Date) %>% summarize(MedianTemp = median(Temp, na.rm = TRUE), SDTemp = sd(Temp, na.rm = TRUE), Lower = MedianTemp - SDTemp, Upper = MedianTemp + SDTemp, .groups = "drop")

p <- ggplot(daily_cave, aes(Date, MedianTemp, color = Cave, fill = Cave)) + geom_ribbon(aes(ymin = Lower, ymax = Upper), alpha = 0.20, color = NA) + geom_line(linewidth = 0.8) + geom_hline(yintercept = 24.22, linetype = "dashed", linewidth = 0.8, color = "black") + scale_color_manual(values = c("KHC" = "#56B1E8", "Croc 2" = "#E69F00")) + scale_fill_manual(values = c("KHC" = "#56B1E8", "Croc 2" = "#E69F00")) + scale_x_date(date_breaks = "1 month", date_labels = "%B") + coord_cartesian(xlim = as.Date(c("2022-08-01", "2023-02-28"))) + scale_y_continuous(breaks = c(23, 25, 27)) + labs(x = "Time", y = expression(paste("Temperature (", degree, "C)"))) + theme_bw() + theme(legend.position = "none", panel.grid.major = element_line(color = "grey85", linewidth = 0.4), panel.grid.minor = element_blank(), axis.title = element_text(size = 14), axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 12), axis.text.y = element_text(size = 12))

print (p)

ggsave("Figure2_CaveWaterTemperature.png", p, width = 10, height = 6, dpi = 600)

# Figure 3. Boxplots of winter 24-hour daily minimum water temperatures

plot_dat <- dat_winter %>% mutate(DayDate = as.Date(DateTime), CavePlot = ifelse(Cave == "Croc2", "Croc 2", Cave)) %>% group_by(CavePlot, Logger, DayDate) %>% summarize(DailyMin = if (all(is.na(`Temperature (C)`))) NA_real_ else min(`Temperature (C)`, na.rm = TRUE), .groups = "drop") %>% filter(is.finite(DailyMin)) %>% mutate(LoggerPlot = factor(paste(CavePlot, Logger), levels = c("Croc 2 L2", "Croc 2 L3", "Croc 2 L4", "KHC L1", "KHC L2", "KHC L3", "KHC L4", "KHC L5")))

p <- ggplot(plot_dat, aes(LoggerPlot, DailyMin, fill = CavePlot)) + geom_boxplot(width = 0.75, outlier.size = 2, coef = 1.5) + geom_hline(aes(yintercept = 24.22, linetype = "24.22 C threshold"), color = "black", linewidth = 0.8) + scale_linetype_manual(name = NULL, values = c("24.22 C threshold" = "dashed")) + scale_fill_manual(values = c("Croc 2" = "#56B1E8", "KHC" = "#E69F00")) + scale_x_discrete(labels = c("L2", "L3", "L4", "L1", "L2", "L3", "L4", "L5")) + scale_y_continuous(breaks = c(21, 23, 25)) + labs(x = "Data Logger", y = expression(paste("Daily Minimum Temperature (", degree, "C)"))) + theme_bw() + theme(panel.grid.major = element_line(color = "grey85", linewidth = 0.4), panel.grid.minor = element_blank(), legend.title = element_blank(), axis.title = element_text(size = 14), axis.text = element_text(size = 12), legend.position = c(0.88, 0.22), legend.background = element_rect(fill = "white", color = "black"))

print(p)

ggsave("Figure3_DailyMinTemp_Boxplots.png", p, width = 8, height = 7, dpi = 600)

# Figure 4. Heat map for raw time series (from paper) 

make_heatmap <- function(table_in, figure_out) {plot_dat <- table_in %>% separate(Pair, into = c("Logger1", "Logger2"), sep = "-") %>% mutate(Cave = factor(Cave, levels = c("Croc 2", "KHC"))); upper <- plot_dat %>% transmute(Cave, Reference = Logger1, Comparison = Logger2, Value = Delay_h); lower <- plot_dat %>% transmute(Cave, Reference = Logger2, Comparison = Logger1, Value = -Delay_h); heatmap_dat <- bind_rows(upper, lower); logger_order <- c("L1","L2","L3","L4","L5"); heatmap_dat$Reference <- factor(heatmap_dat$Reference, levels = logger_order); heatmap_dat$Comparison <- factor(heatmap_dat$Comparison, levels = logger_order); p <- ggplot(heatmap_dat, aes(Comparison, Reference, fill = Value)) + geom_tile(color = "white", linewidth = 1) + geom_text(aes(label = round(Value, 1)), size = 3) + scale_fill_gradient2(low = "#56B1E8", mid = "#E5E5E5", high = "#E69F00", midpoint = 0, name = "Delay (h)") + scale_y_discrete(limits = rev(logger_order)) + facet_wrap(~Cave, nrow = 1) + labs(x = "Logger", y = "Logger") + coord_equal() + theme_bw() + theme(panel.grid = element_blank(), strip.background = element_blank(), strip.text = element_text(size = 28, face = "bold"), axis.title = element_text(size = 14), axis.text = element_text(size = 12), legend.position = "right"); ggsave(figure_out, p, width = 10, height = 5, dpi = 600); return(p)}

heatmap_raw <- make_heatmap(table5_raw, "Figure4_DelayHeatmap_raw.png")

# Figure S3. Heat map for detrended time series (Sup. Mat.)

heatmap_detrend <- make_heatmap(tableS1_detrend, "FigureS3_DelayHeatmap_detend.png")

# Figures S1 & S2. Phase-derived delay versus period (Sup. Mat.)

make_delay_plot <- function(cave_name, line_color, figure_out) {cave_dat <- dat %>% filter(Cave == cave_name); calc_delay_curve <- function(df, logger1, logger2) { dat_pair <- df %>% filter(Logger %in% c(logger1, logger2)) %>% select(DateTime, Logger, Temp) %>% pivot_wider(names_from = Logger, values_from = Temp) %>% drop_na(all_of(c(logger1, logger2))) %>% arrange(DateTime); x <- dat_pair[[logger1]]; y <- dat_pair[[logger2]]; sp <- spec.pgram(cbind(x, y), demean = TRUE, detrend = TRUE, spans = c(5,5), plot = FALSE); period_h <- 1 / sp$freq; delay_h <- sp$phase / (2 * pi * sp$freq); tibble(Pair = paste(logger1, logger2, sep = "-"), Period_h = period_h, Delay_h = delay_h) %>% filter(Period_h >= 2 & Period_h <= 168) }; pairs <- combn(sort(unique(cave_dat$Logger)), 2, simplify = FALSE); delay_curves <- map_dfr(pairs, ~calc_delay_curve(cave_dat, .x[1], .x[2])); p <- ggplot(delay_curves, aes(x = Period_h, y = Delay_h)) + geom_hline(yintercept = 0, linetype = "dashed", color = "black") + geom_line(color = line_color, linewidth = 0.6) + scale_x_log10(breaks = c(2, 6, 12, 24, 48, 72, 168)) + facet_wrap(~Pair, ncol = 2) + labs(title = cave_name, x = "Period (hours, log scale)", y = "Delay (h)") + theme_bw() + theme(panel.grid.major = element_line(color = "grey85"), panel.grid.minor = element_blank(), strip.background = element_blank(), strip.text = element_text(face = "bold", size = 11), plot.title = element_text(face = "bold", size = 16), axis.title = element_text(size = 12), axis.text = element_text(size = 10)); ggsave(figure_out, p, width = 8, height = 10, dpi = 600); return(p)}

# Crocodile Cave 2, Figure S1

plot_croc2 <- make_delay_plot("Croc 2", "#56B1E8", "FigureS1_Croc2_DelaySpectra.png")  

# KHC Complex, Figure S2

plot_khc <- make_delay_plot("KHC", "#E69F00", "FigureS2_KHC_DelaySpectra.png")  
