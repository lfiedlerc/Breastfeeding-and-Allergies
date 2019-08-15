/* This program creates the dataset used for the analysis. Only the records for children 5 or younger are used, and variables are recoded as well as created.
 * @author Lindsey Fiedler
 */

libname in '/home/lindsey/Documents/Secondary Data Analysis/Breastfeeding and Allergies' ;
libname library '/home/lindsey/Documents/Secondary Data Analysis/Breastfeeding and Allergies' ;


options nofmterr;

/* Writing the dataset for linux*/
data in.nsch2016_linux (encoding='latin1' outrep='LINUX_X86_64');
 set in.nsch2016;
run;

proc format library=library;
	value breastfeeding_fmt 0 = 'Never breastfed'
									    1 = '< 6 months'
										2 = '6 to 12 months'
										3 = '> 12 months';
	value first_formula_fmt 0 = 'Never fed formula'
									  1 = 'Earlier than 6 months'
									  2 = '6 months or after';
	value first_solids_fmt 0 = 'Have not been fed solid foods'
									  1 = 'Earlier than 6 months'
									  2 = '6 months or after';
run;

data in.nsch2016_zerofive_recoded;
	set in.nsch2016_linux;
	where SC_AGE_YEARS < 6 and allergies ne .M;
	*Recoding breastfeeding into duration groups;
	breastfeeding_duration = .;
	if BrstEver_16 = 2 then breastfeeding_duration = 0;
	else if BrstEver_16 = 1 then do;
		if (BREASTFEDEND_MO_S NE .M AND BREASTFEDEND_MO_S < 6) OR (SC_AGE_LT6 = 1 AND K6Q41R_STILL = 1) then breastfeeding_duration = 1;
		if (BREASTFEDEND_MO_S NE .M AND 6 <= BREASTFEDEND_MO_S <= 12) OR (SC_AGE_LT6 = 2 AND SC_AGE_YEARS = 0 AND K6Q41R_STILL = 1) then breastfeeding_duration = 2;
		if (BREASTFEDEND_MO_S NE .M AND BREASTFEDEND_MO_S > 12) OR (SC_AGE_YEARS >= 1 AND K6Q41R_STILL = 1) then breastfeeding_duration = 3;
	end;
	label breastfeeding_duration = "Duration breastfed in months";
	format breastfeeding_duration breastfeeding_fmt.;
	
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
	months_since_breastfed = .;
	age_in_months = 12*(SC_AGE_YEARS+1);
	if SC_AGE_YEARS = 0 then do;
		if SC_AGE_LT10 = 1 then age_in_months = 10;
		if SC_AGE_LT9 = 1 then age_in_months = 9;
		if SC_AGE_LT6 = 1 then age_in_months = 6;
		if SC_AGE_LT4 = 1 then age_in_months = 4;
	end;
	if BREASTFEDEND_MO_S = .L then months_since_breastfed = 0;
	else if BREASTFEDEND_MO_S NE .M then months_since_breastfed = age_in_months - BREASTFEDEND_MO_S;	
run;
