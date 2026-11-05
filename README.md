This repository contains R scripts for recreating several analyses presented in the publication:

Thermal Behavior of Crocodile Caves in Central Belize, Diversity (In Review)

Authors: Wynne, J.J., Shaffer, I.N., and Roberts, J.

Date: 05 November 2026

Analyses:
1. Thermal threshold analyses using Lang (1979) data 

2. Winter nighttime winter temperature summaries (Table 2)

3. Distributional winter nighttime minimum temperature metrics (Table 3) 

4. Monthly nighttime temperatures per cave and datalogger (Table 4) 

5. Cross-spectral coherence and phase analyses (Table 5; Table S1) 

6. Data-driven figures (Figures 2–4; Figures S1–S3)

Scripts: 
S01_ThermCroc.R: Thermal threshold analysis for both (1) all observations across experimental conditions and (2) Fasted Nighttime condition as the reference level

S02_Month_Nighttime.R: Generates Table 2 from paper. Monthly median nighttime temperatures and percentage of nights above modeled thermal threshold.

S03_Winter_NightMinima.R: Generates Table 3 from paper. Includes Minimum nightly temperature, 5th percentile, and 10th percentile per datalogger.

S04_MonthLog_Nighttime.R: Generates Table 4 from paper. Monthly median nighttime temperatures and percentage of nights above modeled thermal threshold per datalogger.

S05_PeakCohearencePhase.R: Cross-spectral coherence and phase results for raw time series (Table 5 from paper) and detrended time series (Table S1 from Supp. Mat. File 1).

S06_Figures.R: Generates Figures 2–4 and Supplemental Figures S1–S3.

Required packages:
readxl, 
lme4, 
lmerTest, 
performance, 
DHARMa, 
lubridate, 
tidyverse

Input files:
Croc_Lang.csv; 
CaveCroc_Data.xlsx

AI-Assisted Code Development:  
Portions of the R scripts included in this repository were developed with assistance from generative artificial intelligence tools. All code was reviewed, modified as necessary, executed, debugged, and validated by the authors prior to use in analyses and manuscript preparation. The authors assume full responsibility for the accuracy and implementation of all code and results.

R version 4.6.0 (2026-04-24)
