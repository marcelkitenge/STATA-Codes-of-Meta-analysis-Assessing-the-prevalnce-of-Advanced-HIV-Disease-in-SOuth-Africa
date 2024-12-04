
global DATA = "/Users/marcelkitenge/Documents/Doctoral/PhD 2021/Methodology papers/Meta-analysis-1 Objective/Data Extraction-Method Quality-Forms"


import excel "$DATA\Data Extraction Form.xlsx", sheet("Data") firstrow clear 
destring, replace 
br 
keep if Year!=.
keep if Year>=2010

save "$DATA\Data Extraction Form.dta", replace 

*set scheme s2color

*** SUMMARIZE meta data by using a TABLE or a FOREST PLOT

use "$DATA\Data Extraction Form.dta", clear

sort Year
metaprop NumberofAHD Totalsample,  ftt random notable
graph di

metaprop NumberofAHD Totalsample,  ftt random label(namevar= Studyauthors) 
graph di

//metaprop NumberofAHD Totalsample, ftt random label(namevar= Studyauthors) power(2)

metaprop NumberofAHD Totalsample, ftt random label(namevar= Studyauthors) power(2) ysize(6) xsize(4)  scale(1.7) xtitle(Proportion,size(2)) nowt xline(100) ///
xlab(0,25,50,75,100)xline(0, lcolor(black)) lcols (Studyauthors NumberofAHD Totalsample)

 //
/*olineopt(lcolor(red) lpattern(shortdash)) ///
diamopt(lcolor(red)) pointopt(msymbol(s) msize(1)) ///
astext(70) texts(100) */
 //scheme(sj)
graph di

graph export "$DATA/Overall-Meta-Analysis.png", as(png) name("Graph") replace

*** EXPLORE HETEROGENEITY - SUB-GROUP 

metaprop NumberofAHD Totalsample, ftt random label(namevar= Studyauthors) power(2) by(Assessmentmethod) ysize(6) xsize(4)  scale(1.7) xtitle(Proportion,size(2)) nowt xline(100) ///
xlab(0,25,50,75,100)xline(0, lcolor(black)) lcols (Studyauthors NumberofAHD Totalsample) // scheme(sj)

graph di
graph export "$DATA/CD4 Vs WHO Stage.png", as(png) name("Graph") replace


metaprop NumberofAHD Totalsample, ftt random label(namevar= Studyauthors) power(2) by(Studydesign) ysize(5) xsize(4) scale(1.8) xtitle(Proportion,size(2))lcols (Studyauthors NumberofAHD Totalsample) nowt //scheme(sj) 
graph di
graph export "$DATA/SD subgroup.png", as(png) name("Graph") replace


metaprop NumberofAHD Totalsample, ftt random label(namevar= Studyauthors) power(2) by(Population) ysize(6) xsize(4)  scale(1.7) xtitle(Proportion,size(2)) nowt xline(100) ///
xlab(0,25,50,75,100)xline(0, lcolor(black)) // scheme(sj)

graph dir

graph export "$DATA/Population subgroup.png", as(png) name("Graph") replace


metaprop NumberofAHD Totalsample, ftt random label(namevar= Studyauthors) power(2) by(Inoroupatient) ysize(6) xsize(4) scale(1.8) xtitle(Percenatge,size(2)) nowt //scheme(sj)
graph di
graph export "$DATA/Inpatient Vs Outopatient.png", as(png) name("Graph") replace


sort Year
metaprop NumberofAHD Totalsample, ftt random label(namevar= Studyauthors) power(2) by(Year) ysize(6) xsize(4) scale(1.8) xtitle(Percenatge,size(2)) nowt //scheme(sj)
graph di
graph export "$DATA/Yea.png", as(png) name("Graph") replace
//metaprop NumberofAHD Totalsample if , ftt random label(namevar= Studyauthors) power(2) 
graph di


meta set _ES _seES, studylabel(Studyauthors) eslabel(Advanced HIV Disease. Prevalence.)

meta forestplot, leaveoneout 
graph export "$DATA/Leaveone out.png", as(png) name("Graph") replace

*** Cumulative meta-analysis through time ***

meta summarize, cumulative(Year, ascending )

meta forestplot, cumulative(Year) nullrefline
graph export "$DATA/Cmulative.png", as(png) name("Graph") replace

*** Assessing Publication Bias 

** Declaring data 
//meta set _ES _seES, studylabel(Studyauthors) eslabel(Advanced HIV Disease. Prevalence.)

drop if Studyauthors=="Chihana 2019"
metaprop NumberofAHD1 Totalsample1, ftt random cimethod(score)label(namevar= Studyauthors) power(2) //scheme(sj)

metaprop NumberofAHD1 Totalsample1 if Studyauthors!="Osler 2018", label(namevar= Studyauthors) power(2) xtitle(Proportion,size(2)) xlab(0,25,50,75,100)xline(0, lcolor(black))  // scheme(sj)
graph export "$DATA/ART-experienced.png", as(png) name("Graph") replace




** Assessing Publication Bias
drop if Studyauthors=="Rossouw 2015"
drop if Studyauthors=="Feucht 2016"
meta funnelplot

graph export "$DATA/Funnel plot all.png", as(png) name("Graph") replace

metafunnel _meta_es _meta_se //, scheme(sj) // overall Funnel plot 
graph export "$DATA/Funnel plot all.png", as(png) name("Graph") replace

metafunnel _meta_es _meta_se if Population=="Adults" //, scheme(sj)
graph export "$DATA/Funnel Adults.png", as(png) name("Graph") replace

metabias _meta_es _meta_se, egger

//meta funnelplot, metric(invse)
graph display

*** Are smaller studies tended to have reported over reported the prevalence estimates

*** STEP 5- EXPLORE and ADDRESS SMALL-STUDY EFFECTS ****

meta bias, egger

meta trimfill
//drop if Studyauthors=="Tendesayi 2016" 
//drop if Studyauthors=="Carmona 2018"

*** STEP 6- EXPLORE HETEROGENEITY and META-REGRESSION analysis ****

label var Year "Publication year"
meta regress Year 
estat bubbleplot, reweighted //scheme(sj)
estat bubbleplot
graph di
graph export "$DATA/AHD vs Publication year.png", as(png) name("Graph") replace

/*
meta regress NumberofAHD 
estat bubbleplot 
graph di
*/
meta regress Totalsample 
estat bubbleplot, reweighted
graph di

meta regress MedianCD4
estat bubbleplot //, reweighted
graph di

***** Opening ROB data *******

import excel "$DATA\ROB.xlsx", sheet("Sheet1") firstrow clear

keep Studies Summaryscoreontheoverall Riskofbias
rename Studies Studyauthors

merge 1:1 Studyauthors using "$DATA\Data Extraction Form.dta"
destring , replace 

save "$DATA\Combined.dta", replace

**** meta regression ***

use "$DATA\Combined.dta", clear

********* Declaring meta-Analysis Data *******

metaprop NumberofAHD Totalsample, ftt random notable

meta set _ES _seES, studylabel(Studyauthors) eslabel(Advanced HIV Disease. Prevalence.)

metaprop NumberofAHD Totalsample, ftt random label(namevar= Studyauthors) power(2) by(Riskofbias) ysize(5) xsize(4) scale(1.8) xtitle(Proportion,size(2)) scheme(sj)

replace Province="National" if Province=="South Africa"
replace Province="Gauteng" if Province=="Johannesburg"
sort Province

metaprop NumberofAHD Totalsample, ftt random label(namevar= Studyauthors) power(2) by(Province) ysize(5) xsize(4) scale(1.8) xtitle(Proportion,size(2)) scheme(sj)
graph di
graph export "$DATA/AHD by Province.png", as(png) name("Graph") replace


quietly tab Studydesign, gen(Studydesign)

quietly tab Inoroupatient, gen(Inoroupatient)

quietly tab Assessmentmethod, gen(Assessmentmethod)

quietly tab Population, gen(Population)

/////// Crude and Adjsuted Meta-Regression //////

foreach x of varlist Year Studydesign1 NumberofAHD Inoroupatient2 Summaryscoreontheoverall Assessmentmethod2{
meta regress `x' 
}

meta regress Year Studydesign1 Inoroupatient2 Summaryscoreontheoverall Assessmentmethod2 Population3
