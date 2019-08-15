/* This is the program for performing multiple imputation. Based on the efficiency calculation only 5 imputations were needed.
 * @author Lindsey Fiedler
 */

libname in '/home/lindsey/Documents/Secondary Data Analysis/Breastfeeding and Allergies' ;
libname library '/home/lindsey/Documents/Secondary Data Analysis/Breastfeeding and Allergies' ;

* Analysis of missingness for by age and outcome;
proc freq data = in.nsch2016_zerofive_recoded;
	tables breastfeeding_duration*allergies/missing;
	tables first_formula*allergies/missing;
	tables first_solids*allergies/missing;
	tables smoking_16*allergies/missing;
	tables FoodSit_16*allergies/missing;
	tables months_since_breastfed*allergies/missing;
	title 'ANALYSIS OF MISSINGNESS PRIOR TO IMPUTATION';
run;

* Multiple imputation;
proc mi data=in.nsch2016_zerofive_recoded seed=54321 nimpute=5 out=imputed
	round= 1 1 1 1 1 1 1 1 1 1 1 1
	min= 1 1 1 1 1 1 1 1 1 0 0 0;
	class BrstEver_16 smoking_16 FoodSit_16 K6Q41R_STILL K6Q42R_NEVER K6Q43R_NEVER;
	fcs nbiter=10 logistic(BrstEver_16 = allergies race4_16 sex_16/details);
	fcs nbiter=10 logistic(smoking_16 = allergies race4_16 sex_16 BrstEver_16/details);
	fcs nbiter=10 logistic(FoodSit_16 = allergies race4_16 sex_16 BrstEver_16 smoking_16/details);
	fcs nbiter=10 logistic(K6Q41R_STILL = allergies race4_16 sex_16 BrstEver_16 smoking_16 FoodSit_16/details);
	fcs nbiter=10 logistic(K6Q42R_NEVER = allergies race4_16 sex_16 BrstEver_16 smoking_16 FoodSit_16 K6Q41R_STILL/details);
	fcs nbiter=10 logistic(K6Q43R_NEVER = allergies race4_16 sex_16 BrstEver_16 smoking_16 FoodSit_16 K6Q41R_STILL K6Q42R_NEVER/details);
	fcs nbiter=10 reg(FRSTFORMULA_MO_S = allergies race4_16 sex_16 BrstEver_16 smoking_16 FoodSit_16 K6Q41R_STILL K6Q42R_NEVER K6Q43R_NEVER/details);
	fcs nbiter=10 reg(FRSTSOLIDS_MO_S = allergies race4_16 sex_16 BrstEver_16 smoking_16 FoodSit_16 K6Q41R_STILL K6Q42R_NEVER K6Q43R_NEVER FRSTFORMULA_MO_S/details);
	fcs nbiter=10 reg(BREASTFEDEND_MO_S = allergies race4_16 sex_16 BrstEver_16 smoking_16 FoodSit_16 K6Q41R_STILL K6Q42R_NEVER K6Q43R_NEVER FRSTFORMULA_MO_S FRSTSOLIDS_MO_S/details);
    var allergies race4_16 sex_16 BrstEver_16 smoking_16 FoodSit_16 K6Q41R_STILL K6Q42R_NEVER K6Q43R_NEVER FRSTFORMULA_MO_S FRSTSOLIDS_MO_S BREASTFEDEND_MO_S;
run;

options nofmterr;
data in.imputed_full;
	set imputed;
	*Recoding breastfeeding into duration groups;
	bfd = .;
	if BrstEver_16 = 2 then bfd = 0;
	else if BrstEver_16 = 1 then do;
		if (BREASTFEDEND_MO_S NE .M AND BREASTFEDEND_MO_S < 6) OR (SC_AGE_LT6 = 1 AND K6Q41R_STILL = 1) then bfd = 1;
		if (BREASTFEDEND_MO_S NE .M AND 6 <= BREASTFEDEND_MO_S <= 12) OR (SC_AGE_LT6 = 2 AND SC_AGE_YEARS = 0 AND K6Q41R_STILL = 1) then bfd = 2;
		if (BREASTFEDEND_MO_S NE .M AND BREASTFEDEND_MO_S > 12) OR (SC_AGE_YEARS >= 1 AND K6Q41R_STILL = 1) then bfd = 3;
	end;
	label bfd = "Duration breastfed in months";
	format bfd breastfeeding_fmt.;
	
	*Recoding for first formula feeding;
	first_formula =.;
	if K6Q42R_NEVER = 1 then first_formula = 0;
	else if K6Q42R_NEVER = 2 AND FRSTFORMULA_MO_S < 6 then first_formula = 1;
	else if K6Q42R_NEVER = 2 AND FRSTFORMULA_MO_S >= 6 then first_formula = 2;
	label first_formula = "Age in months when first fed formula";
	format first_formula first_formula_fmt.;
	
	*Recoding for first solid food feeding;
	first_solids =.;
	if K6Q43R_NEVER = 1 then first_solids = 0;
	else if K6Q43R_NEVER = 2 AND FRSTSOLIDS_MO_S < 6 then first_solids = 1;
	else if K6Q43R_NEVER = 2 AND FRSTSOLIDS_MO_S >= 6 then first_solids = 2;
	label first_solids = "Age in months when first fed solid foods";
	format first_solids first_solids_fmt.;
	
	*Time removed from breastfeeding;
	msb = .;
	age_in_months = 12*(SC_AGE_YEARS+1);
	if SC_AGE_YEARS = 0 then do;
		if SC_AGE_LT10 = 1 then age_in_months = 10;
		if SC_AGE_LT9 = 1 then age_in_months = 9;
		if SC_AGE_LT6 = 1 then age_in_months = 6;
		if SC_AGE_LT4 = 1 then age_in_months = 4;
	end;
	if K6Q41R_STILL = 1 OR BREASTFEDEND_MO_S = .L then msb = 0;
	else if BREASTFEDEND_MO_S NE .M then msb = MAX(age_in_months - BREASTFEDEND_MO_S, 0);	
run;

proc freq data = in.imputed_full;
	tables bfd*allergies/missing;
	tables first_formula*allergies/missing;
	tables first_solids*allergies/missing;
	tables smoking_16*allergies/missing;
	tables FoodSit_16*allergies/missing;
	tables msb*allergies/missing;
	title ' FREQUENCIES AFTER IMPUTING AND RECALCULATION VARIABLES';
run;

* Analysis with imputed data sets;
ods exclude all; 

* Crude analysis;
proc surveylogistic data = in.imputed_full;
	strata FIPSST;
	cluster hhid;
	weight FWC;
	CLASS  bfd (PARAM=REF REF='Never breastfed');
	MODEL ALLERGIES = bfd;
	domain _imputation_;
	ods output ParameterEstimates=in.imputed_crude;
	TITLE 'MULTIPLE IMPUTATION (MVN) WEIGHTED CRUDE ODDS FOR ALLERGIES AND BREASTFEEDING DURATION'; 
RUN;


* Mulitvariate analysis;
proc surveylogistic data = in.imputed_full;
	strata FIPSST;
	cluster hhid;
	weight FWC;
	CLASS  bfd (PARAM=REF REF='Never breastfed')  first_formula (PARAM=REF REF='Never fed formula') first_solids (PARAM=REF REF='Have not been fed solid foods') race4_16 (PARAM=REF REF='Multi-racial/Other, non-Hispanic') sex_16 (PARAM=REF REF='Male') smoking_16 (PARAM=REF REF='No') FoodSit_16 (PARAM=REF REF='We could always afford to eat good nutritious meals ');
	MODEL ALLERGIES = bfd  first_formula first_solids race4_16 sex_16 smoking_16 FoodSit_16 msb;
	domain _imputation_;
	ods output ParameterEstimates=in.imputed_adjusted;
	TITLE 'MULTIPLE IMPUTATION (MVN) WEIGHTED ADJUSTED ODDS FOR ALLERGIES AND BREASTFEEDING DURATION'; 
RUN;

* Interaction analysis;
proc surveylogistic data = in.imputed_full;
	strata FIPSST;
	cluster hhid;
	weight FWC;
	CLASS  bfd (PARAM=REF REF='Never breastfed')  first_formula (PARAM=REF REF='Never fed formula') first_solids (PARAM=REF REF='Have not been fed solid foods') race4_16 (PARAM=REF REF='Multi-racial/Other, non-Hispanic') sex_16 (PARAM=REF REF='Male') smoking_16 (PARAM=REF REF='No') FoodSit_16 (PARAM=REF REF='We could always afford to eat good nutritious meals ');
	MODEL ALLERGIES = bfd  first_formula first_solids race4_16 sex_16 smoking_16 FoodSit_16 msb bfd*msb;
	domain _imputation_;
	ods output ParameterEstimates=in.imputed_interaction;
	TITLE 'MULTIPLE IMPUTATION (MVN) WEIGHTED INTERACTION ANALYSIS FOR ALLERGIES AND BREASTFEEDING DURATION*MONTHS SINCE BREASTFED'; 
RUN;

* Pooling of results;
ods exclude none; 

* Crude analysis;
proc mianalyze parms(classvar=CLASSVAL)=in.imputed_crude;
	class bfd;
	modeleffects intercept bfd; 
run;

* Multivariate analysis;
proc mianalyze parms(classvar=CLASSVAL)=in.imputed_adjusted;
	class bfd first_formula first_solids race4_16 sex_16 smoking_16 FoodSit_16;
	modeleffects intercept bfd  first_formula first_solids race4_16 sex_16 smoking_16 FoodSit_16 msb;
run;

* Interaction analysis;
proc mianalyze parms(classvar=CLASSVAL)=in.imputed_interaction;
	class bfd first_formula first_solids race4_16 sex_16 smoking_16 FoodSit_16;
	modeleffects intercept bfd  first_formula first_solids race4_16 sex_16 smoking_16 FoodSit_16 msb msb*bfd;
run;
