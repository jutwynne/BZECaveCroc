The following are the R scripts for recreating several analyses presented in the publication:

Thermal Behavior of Crocodile Caves in Central Belize, Diversity (In Review)

Authors: Wynne, J.J., Shaffer, I.N., and Roberts, J.

Date: 16 November 2026


Analyses:
1. Thermal threshold analyses using Lang (1979) data.
2. Winter minimum temperature metrics (Table 3).
3. Monthly water temperature summaries per cave (Table 2) and per logger (Table 4).
4. Cross-spectral coherence and phase analyses for raw time series (Table 5) and detrended time series (Table S1).
5. Data-driven figures (Figures 2–4; Figures S1–S3).

Scripts:
S01_CrocThreshold_LangData.R: Thermal threshold analyses for (1) all observations across experimental conditions and (2) Fasted Nighttime as the reference condition.

S02_Tables2-4.R: Generates Tables 2–4.

S03_PeakCoherencePhase.R: Generates cross-spectral coherence and phase results for raw time series (Table 5) and detrended time series (Table S1).

S04_Figures.R: Generates Figures 2–4 and Supplemental Figures S1–S3. Requires S03_PeakCoherencePhase.R to be run first.

Required packages:
readxl 
lme4 
lmerTest 
performance 
DHARMa 
lubridate 
tidyverse

Input files:
Croc_Lang.csv
CaveCroc_Data.xlsx

AI-Assisted Code Development:  
Portions of the R scripts included in this repository were developed with assistance from generative artificial intelligence tools. All code was reviewed, modified as necessary, executed, debugged, and validated by the authors prior to use in analyses and manuscript preparation. The authors assume full responsibility for the accuracy and implementation of all code and results.

R version 4.6.0 (2026-04-24)
