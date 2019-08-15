/* This is the main program for conducting the analysis presented in the report.
 * @author Lindsey Fiedler
 */


libname in '/home/lindsey/Documents/Secondary Data Analysis/Breastfeeding and Allergies' ;
libname library '/home/lindsey/Documents/Secondary Data Analysis/Breastfeeding and Allergies' ;

proc sort data = in.nsch2016_zerofive_recoded;
	by allergies;
run;

proc freq data = in.nsch2016_zerofive_recoded;
	tables breastfeeding_duration*allergies/missing;
run;

proc surveyfreq data = in.nsch2016_zerofive_recoded;
	strata FIPSST;
	cluster hhid;
	weight FWC;
	tables allergies;
	title 'WEIGHTED SAMPLE SIZE';
run;

* Univariate analysis;
proc surveyfreq data = in.nsch2016_zerofive_recoded;
	strata FIPSST;
	cluster hhid;
	weight FWC;
	tables allergies*(breastfeeding_duration first_formula first_solids race4_16 sex_16 smoking_16 FoodSit_16)/ROW COL CHISQ OR;
	title 'UNIVARIATE ANALYSIS';
run;

proc surveymeans data = in.nsch2016_zerofive_recoded;
	strata FIPSST;
	cluster hhid;
	weight FWC;
	domain allergies;
	var months_since_breastfed;
run;

* Crude analysis;
proc surveylogistic data = in.nsch2016_zerofive_recoded;
	strata FIPSST;
	cluster hhid;
	weight FWC;
	CLASS  breastfeeding_duration (PARAM=REF REF='Never breastfed');
	MODEL ALLERGIES = breastfeeding_duration;
	TITLE 'WEIGHTED CRUDE ODDS FOR ALLERGIES AND BREASTFEEDING DURATION'; 
RUN;

* Mulitvariate analysis;
proc surveylogistic data = in.nsch2016_zerofive_recoded;
	strata FIPSST;
	cluster hhid;
	weight FWC;
	CLASS  breastfeeding_duration (PARAM=REF REF='Never breastfed')  first_formula (PARAM=REF REF='Never fed formula') first_solids (PARAM=REF REF='Have not been fed solid foods') race4_16 (PARAM=REF REF='Multi-racial/Other, non-Hispanic') sex_16 (PARAM=REF REF='Male') smoking_16 (PARAM=REF REF='No') FoodSit_16 (PARAM=REF REF='We could always afford to eat good nutritious meals ');
	MODEL ALLERGIES = breastfeeding_duration  first_formula first_solids race4_16 sex_16 smoking_16 FoodSit_16 months_since_breastfed;
	TITLE 'WEIGHTED ADJUSTED ODDS FOR ALLERGIES AND BREASTFEEDING DURATION (ALL COVARIATES)'; 
RUN;

proc surveylogistic data = in.nsch2016_zerofive_recoded;
	strata FIPSST;
	cluster hhid;
	weight FWC;
	CLASS  breastfeeding_duration (PARAM=REF REF='Never breastfed')  first_solids (PARAM=REF REF='Have not been fed solid foods') race4_16 (PARAM=REF REF='Multi-racial/Other, non-Hispanic') FoodSit_16 (PARAM=REF REF='We could always afford to eat good nutritious meals ');
	MODEL ALLERGIES = breastfeeding_duration first_solids race4_16 FoodSit_16 months_since_breastfed;
	TITLE 'WEIGHTED ADJUSTED ODDS FOR ALLERGIES AND BREASTFEEDING DURATION (SELECT COVARIATES)'; 
RUN;

* Interaction analysis;
proc surveylogistic data = in.nsch2016_zerofive_recoded;
	strata FIPSST;
	cluster hhid;
	weight FWC;
	CLASS  breastfeeding_duration (PARAM=REF REF='Never breastfed')  first_formula (PARAM=REF REF='Never fed formula') first_solids (PARAM=REF REF='Have not been fed solid foods') race4_16 (PARAM=REF REF='Multi-racial/Other, non-Hispanic') sex_16 (PARAM=REF REF='Male') smoking_16 (PARAM=REF REF='No') FoodSit_16 (PARAM=REF REF='We could always afford to eat good nutritious meals ');
	MODEL ALLERGIES = breastfeeding_duration  first_formula first_solids race4_16 sex_16 smoking_16 FoodSit_16 months_since_breastfed breastfeeding_duration*months_since_breastfed;
	TITLE 'WEIGHTED INTERACTION ANALYSIS FOR ALLERGIES AND BREASTFEEDING DURATION*MONTHS SINCE BREASTFED (ALL COVARIATES)'; 
RUN;

proc surveylogistic data = in.nsch2016_zerofive_recoded;
	strata FIPSST;
	cluster hhid;
	weight FWC;
	CLASS  breastfeeding_duration (PARAM=REF REF='Never breastfed')  first_solids (PARAM=REF REF='Have not been fed solid foods') race4_16 (PARAM=REF REF='Multi-racial/Other, non-Hispanic') FoodSit_16 (PARAM=REF REF='We could always afford to eat good nutritious meals ');
	MODEL ALLERGIES = breastfeeding_duration first_solids race4_16 FoodSit_16 months_since_breastfed breastfeeding_duration*months_since_breastfed;
	TITLE 'WEIGHTED INTERACTION ANALYSIS FOR ALLERGIES AND BREASTFEEDING DURATION (SELECT COVARIATES)'; 
RUN;

proc surveylogistic data = in.nsch2016_zerofive_recoded;
	WHERE breastfeeding_duration in (0, 2);
	strata FIPSST;
	cluster hhid;
	weight FWC;
	CLASS  breastfeeding_duration (PARAM=REF REF='Never breastfed')  first_solids (PARAM=REF REF='Have not been fed solid foods') race4_16 (PARAM=REF REF='Multi-racial/Other, non-Hispanic') FoodSit_16 (PARAM=REF REF='We could always afford to eat good nutritious meals ');
	MODEL ALLERGIES = breastfeeding_duration first_solids race4_16 FoodSit_16 months_since_breastfed breastfeeding_duration*months_since_breastfed;
	TITLE 'WEIGHTED INTERACTION ANALYSIS FOR ALLERGIES AND BREASTFEEDING DURATION (SELECT COVARIATES, ONLY SIGNIFICANT GROUP)'; 
RUN;
