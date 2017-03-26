clear all
capture log close

cd "/Users/David/GitHub/IO/ps2/IO-Assign-3" //  WD
use "/Users/David/Downloads/HW3/cars1.dta"

summarize year country co segment domestic firm qu price horsepower fuel width height pop ngdp

// Define panel 

egen yearcountry=group(year country), label
xtset co yearcountry

// Defining outside good as MSIZE

gen MSIZE=pop/4

#delimit ;

local characteristics "horsepower fuel width height domestic";

* Sum of the characteristics of all competing products and competing products produced by other firms;


*** 	i_hp= sum(hp)-hp 					sum of the characteristics of all competing products
	if_hp= sum(hp of firm j) - hp  			sum of the characteristics of all other makes of firm j
	CFi_hp= sum(hp)- sum(hp of firm j)		sum of the characteristics of all other non-firm j makes;
	
foreach inst in `characteristics'{;
qui{;
	egen i_`inst'=sum(`inst'), by (year country);
	egen if_`inst'=sum(`inst'), by (year country firm);
	gen CFi_`inst'=i_`inst'-if_`inst';
	replace i_`inst'=i_`inst'-`inst';
	replace if_`inst'=if_`inst'-`inst';
};
};



qui egen tot_sales=sum(qu), by(year country);
qui egen i_num=count(qu), by(year country);

qui egen firm_sales=sum(qu), by(year country firm);
qui egen if_num=count(qu), by(year country firm);


qui gen CFi_num=i_num-if_num;

replace i_num=i_num-1;
gen lni_num=ln(i_num);

replace if_num=if_num-1;
gen lnif_num=ln(if_num);


* PART 2. ONE LEVEL NESTED LOGIT INSTRUMENTS;


* Per year market firm and segment;

*** 	is_hp= sum(hp in segment k)-hp 							sum of the characteristics of all competing products in segment k
	ifs_hp= sum(hp of firm j in segment k) - hp  					sum of the characteristics of all other makes of firm j in segment k
	CFis_hp= sum(hp in segment k)- sum(hp of firm j in segment k)		sum of the characteristics of all other non-firm j makes in segment k;


foreach inst in `characteristics'{;
qui{;
	egen is_`inst'=sum(`inst'),  by (year country segment);
	egen ifs_`inst'=sum(`inst'), by (year country segment firm);
	gen CFis_`inst'=is_`inst'-ifs_`inst';
	replace is_`inst'=is_`inst'-`inst';
	replace ifs_`inst'=ifs_`inst'-`inst';
};
};

egen seg_sales=sum(qu), by(year country segment);
egen is_num=count(qu), by(year country segment);

egen fs_sales=sum(qu), by(year country segment firm);
egen ifs_num=count (qu), by(year country segment firm);

qui gen CFis_num=is_num-ifs_num;

replace is_num=is_num-1;
gen lnis_num=ln(is_num);
replace ifs_num=ifs_num-1;
gen lnifs_num=ln(ifs_num);

mergersim init, nests(segment) price(price) quantity(qu) marketsize(MSIZE) firm(firm);

// THIS DOES the first regression without instruments,
// MERGER SIM creates M_ls which is ln(st) - ln(s0) can gen on my own

xtreg M_ls price 			horsepower fuel width height domestic year country2-country5, fe;



