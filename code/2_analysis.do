*-------------------------------------------------------------------------------
* MODULE 2: EMPIRICAL ANALYSIS
*-------------------------------------------------------------------------------

use "$derived/analysis_sample.dta", clear

* Define Controls Global
global controls Size Leverage ROA Growth PPE CFO Loss Dual TOP1 Top5 HHI Big4 Indep Board SOE Bank ListAge laggedliquidity

*-------------------------------------------------------------------------------
* [cite_start]Table 1: Summary Statistics [cite: 85]
*-------------------------------------------------------------------------------
local sum_vars Pandemic Treat_2 TC1A TC2A TC3A $controls
estpost tabstat `sum_vars', statistics(N mean sd p25 p50 p75) columns(statistics)

esttab using "$output/Table1_Summary.rtf", ///
    cells("count(fmt(0)) mean(fmt(3)) sd(fmt(3)) p25(fmt(3)) p50(fmt(3)) p75(fmt(3))") ///
    noobs label replace title("Summary Statistics")

*-------------------------------------------------------------------------------
* [cite_start]Table 2: Main Effect (DiD) [cite: 73, 81]
*-------------------------------------------------------------------------------
eststo clear

* Model 1: TC1
reghdfe TC1A DID $controls, absorb(firm_id Year) vce(cluster firm_id)
est store m1

* Model 2: TC2
reghdfe TC2A DID $controls, absorb(firm_id Year) vce(cluster firm_id)
est store m2

* Model 3: TC3
reghdfe TC3A DID $controls, absorb(firm_id Year) vce(cluster firm_id)
est store m3

* Output Table
esttab m1 m2 m3 using "$output/Table2_Baseline.rtf", ///
    replace b(3) t(3) star(* 0.10 ** 0.05 *** 0.01) ///
    r2 ar2 scalar(N) ///
    s(N r2_a, labels("Observations" "Adj. $R^2$")) ///
    keep(DID $controls) ///
    order(DID) ///
    indicate("Firm FE = *firm_id*" "Year FE = *Year*") ///
    title("The Effect of COVID-19 on Trade Credit Financing") ///
    mtitles("TC1" "TC2" "TC3") ///
    addnotes("Standard errors are clustered at the firm level.")

*-------------------------------------------------------------------------------
* [cite_start]Table 3: Parallel Trend Test [cite: 106]
*-------------------------------------------------------------------------------
eststo clear

* Note: We omit 'current' (2019) as the base period to avoid multicollinearity
reghdfe TC1A pre_3 pre_2 post_1 post_2 post_3 $controls, absorb(firm_id Year) vce(cluster firm_id)
est store pt1

reghdfe TC2A pre_3 pre_2 post_1 post_2 post_3 $controls, absorb(firm_id Year) vce(cluster firm_id)
est store pt2

reghdfe TC3A pre_3 pre_2 post_1 post_2 post_3 $controls, absorb(firm_id Year) vce(cluster firm_id)
est store pt3

esttab pt1 pt2 pt3 using "$output/Table3_ParallelTrends.rtf", ///
    replace b(3) t(3) star(* 0.10 ** 0.05 *** 0.01) ///
    keep(pre_3 pre_2 post_1 post_2 post_3) ///
    order(pre_3 pre_2 post_1 post_2 post_3) ///
    s(N r2_a, labels("Observations" "Adj. $R^2$")) ///
    indicate("Firm FE = *firm_id*" "Year FE = *Year*") ///
    title("Parallel Trend Assumption Test")