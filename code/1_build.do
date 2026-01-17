*-------------------------------------------------------------------------------
* MODULE 1: DATA CONSTRUCTION
*-------------------------------------------------------------------------------

* 1. Import Raw Data
import excel "$raw/TradeCredit_Data.xlsx", sheet("Master_Data") firstrow clear

* [cite_start]2. Sample Filtering [cite: 69, 70]
keep if Year >= 2017
drop if ST == 1                  // Exclude ST firms
drop if Industry == "U" | Industry == "J" // Exclude Financials/Utilities

* [cite_start]3. Handle Missing Values [cite: 69]
egen mis = rowmiss(_all)
drop if mis > 0
drop mis

* 4. Panel Setup
duplicates drop Year Stkcd, force
encode Stkcd, generate(firm_id)
xtset firm_id Year

* 5. Variable Generation
* Main DiD Estimator: Pandemic (Post-2020) * Treat (High Infection Area)
* [cite_start]Note: Ensure 'Treat_2' matches the paper's definition (Top 50% cases) [cite: 78]
gen DID = Pandemic * Treat_2 

* Parallel Trend Variables
gen pre_3   = (Year == 2017) * Treat_2
gen pre_2   = (Year == 2018) * Treat_2
gen current = (Year == 2019) * Treat_2 // Benchmark year (usually omitted)
gen post_1  = (Year == 2020) * Treat_2
gen post_2  = (Year == 2021) * Treat_2
gen post_3  = (Year == 2022) * Treat_2

* 6. Winsorization (1% and 99%)
local vars_to_winsor TC1A TC1B TC1C TC2A TC2B TC2C TC3A TC3B TC3C ///
                     Size Bank ROA Leverage PPE SOE CFO TOP1 HHI ///
                     Growth Big4 Indep Loss Board Dual Top5 ListAge laggedliquidity
winsor2 `vars_to_winsor', replace cuts(1 99)

* 7. Labeling (Crucial for professional tables)
label var TC1A "Trade Credit (AP/Assets)"
label var TC2A "Trade Credit (AP+Notes/Assets)"
label var TC3A "Net Trade Credit"
label var DID "Treat $\times$ Pandemic"
label var Size "Firm Size"
label var Leverage "Leverage"
label var ROA "Return on Assets"

* 8. Save Processed Data
save "$derived/analysis_sample.dta", replace