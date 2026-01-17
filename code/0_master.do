*-------------------------------------------------------------------------------
* MASTER SCRIPT: The effect of the COVID-19 pandemic on corporate trade credit financing
* Authors: Wenlan (Tony) Xie
* Context: Economics Letters (2023) Replication
*-------------------------------------------------------------------------------

clear all
set more off
macro drop _all

* --- 1. SET ROOT PATH (USER EDIT REQUIRED) ---
* NOTE: Change this path to the folder where you cloned the repository
global root "C:/Users/YourName/Documents/GitHub/TradeCredit-Pandemic-Replication"

* --- 2. SET DYNAMIC PATHS ---
global raw      "$root/data/raw"
global derived  "$root/data/derived"
global code     "$root/code"
global output   "$root/output"

* --- 3. INSTALL DEPENDENCIES ---
* Ensures the user has the necessary packages to reproduce results
cap ssc install winsor2
cap ssc install estout
cap ssc install reghdfe  // Standard for high-dimensional FE in top journals
cap ssc install ftools

* --- 4. EXECUTE MODULES ---
do "$code/1_build.do"
do "$code/2_analysis.do"

* End of Master Script