*initial data preparation
drop table_1_flag Geocoded_City1 Geocoded_City1address Geocoded_City1city Geocoded_City1state Geocoded_City1zip Geocoded_City2 Geocoded_City2city Geocoded_City2address Geocoded_City2state Geocoded_City2zip

rename WJFUELUSGULF jetfuel

*exploration & visualization
summarize 

*drop 3 missing rows
drop if missing(lf_ms, fare_low)

*exploring relationships 
twoway (scatter fare jetfuel)
twoway (scatter fare lnpassenger)
twoway (scatter fare nsmiles)
twoway (scatter fare large_ms)



*create dummy var & logs
gen peakseason = (quarter == 3 | quarter == 4)
gen monopoly = (large_ms >= 0.8)
gen lccpres = 0
replace lccpres = 1 if inlist(carrier_lg, "WN", "B6", "NK", "F9", "G4", "SY", "XP", "MX") | ///
inlist(carrier_low, "WN", "B6", "NK", "F9", "G4", "SY", "XP", "MX")

gen lnfare = ln(fare)
gen lnpassenger = ln(passengers)
gen lnmiles = ln(nsmiles)
gen lnjetfuel = ln(jetfuel)

*summarize again for table & produce correlation chart
asdoc summarize fare nsmiles passengers jetfuel large_ms fare_lg lf_ms fare_low monopoly lccpres lnfare lnpassenger lnmiles lnjetfuel
asdoc correlate fare nsmiles passengers jetfuel large_ms fare_lg lf_ms fare_low monopoly lccpres 


*run regression  models
reg fare nsmiles passengers monopoly lccpres jetfuel 
eststo baseline

reg lnfare lnmiles lnpassenger monopoly lccpres peakseason lnjetfuel
eststo model2

reg lnfare lnmiles lnpassenger i.monopoly##i.lccpres peakseason lnjetfuel
eststo model3
avgplot

*store model2
esttab baseline model2 model3, se star(* 0.10 ** 0.05 *** 0.01) stats(N r2, labels("Observations" "R-squared")) 

*join test on interactiin term
testparm monopoly lccpres i.monopoly##i.lccpres
testparm lnmiles lnpassenger
lincom 1.monopoly + 1.monopoly#1.lccpres


margins monopoly, at (lnmiles=(4.5(0.5)8))
marginsplot




