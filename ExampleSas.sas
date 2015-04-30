*******************************
*********Set library***********
*******************************;
libname example 'N:\Transfer\HBurak\Specs task';

DATA  _null_;
   call symput('fdate',left(put("&sysdate"d,yymmdd6.))); /*fdate is today's date in yymmdd format*/
RUN;

PROC PRINTTO new
   log = "N:\Transfer\HBurak\Specs task\Example_SAS._&fdate..log"
 print = "N:\Transfer\HBurak\Specs task\Example_SAS._&fdate..lst";
RUN;

Data readdistricts;
	SET example.ag092a;
RUN;

Data readschools; 
	SET example.sc092a;
RUN;

*******************************************************************
**Subset data to districts with fewer than 30,000 students**
*******************************************************************;
/*subset the districts dataset*/
DATA largedist(keep=LEAID over30k);
	SET readdistricts;
		if PK1209 >= 30000 then over30k= 1;
		else if PK1209<30000 then over30k=0;
		else if PK1209 = . then over30k = 0;
		
		if over30k ^= 1 then delete;	
RUN;

/*Merge with the school dataset*/

PROC SORT data=largedist;
	BY LEAID;
RUN;

PROC SORT data=readschools;
	BY LEAID;
RUN;

DATA tempschools (rename=(FIPST=state SCHNO=schid SCHNAM09=schoolname LEANM09=lea_name));
	MERGE largedist readschools;
	BY LEAID;
	IF over30k ^= 1 then delete;
RUN;

/*Limit the data to schools with students in grades 3-5*/

DATA tempschools;
	SET tempschools;
	IF G0309 < 1 | G0409 < 1 | G0509 < 1 then delete;
RUN;

PROC MEANS data=tempschools;
	var G0309 G0409 G0509;
RUN; 

/*find avg # students in 3-5*/
DATA tempschools;
	SET tempschools;
	avgstud_3to5 = mean(G0309,G0409,G0509);
	
	totalstud =.;
	totalstud = G0309+G0409+G0509;
	more_300 = .;
	if totalstud > 300 then more_300 = 1;
	else if totalstud <= 300 then more_300 = 0;
RUN;
PROC MEANS data=tempschools;
	var G0309 G0409 G0509 totalstud avgstud_3to5 more_300;
RUN;

/*create percent race variables*/

DATA tempschools;
	SET tempschools;
	
	IF HI03M09 < 0 | HI03F09  < 0 |HI04M09  < 0 |HI04F09 < 0 | HI05M09 < 0 | HI05F09 < 0 | WH03M09 < 0 | WH03F09 < 0 | WH04M09 < 0 |
			 WH04F09 < 0 | WH05M09 < 0 | WH05F09 < 0 | BL03M09 < 0 | BL03F09 < 0 | BL04M09 < 0 | BL04F09 < 0 | BL05M09 < 0 | BL05F09 < 0  then delete;
	
	per_hispanic = .;
	per_white = .;
	per_black = .;
	
	per_hispanic = (HI03M09+HI03F09+HI04M09+HI04F09+HI05M09+HI05F09)/(G0309+G0409+G0509);
	per_white = (WH03M09+WH03F09+WH04M09+WH04F09+WH05M09+WH05F09)/(G0309+G0409+G0509);
	per_black = (BL03M09+BL03F09+BL04M09+BL04F09+BL05M09+BL05F09)/(G0309+G0409+G0509);

RUN;

PROC MEANS data = tempschools;
	VAR HI03M09 HI03F09 HI04M09 HI04F09 HI05M09 HI05F09 WH03M09 WH03F09 WH04M09 WH04F09 WH05M09 
		WH05F09 BL03M09 BL03F09 BL04M09 BL04F09 BL05M09 BL05F09 G0309 G0409 G0509; 
RUN;

************************************
**Save a permanent schools dataset**
************************************;

DATA example.schools;
	SET tempschools(keep = LEAID lea_name state schid schoolname avgstud_3to5 totalstud more_300 per_hispanic per_white per_black) ;
RUN;

********************************
**Create a district level file**
********************************;

/*start with schools data*/
DATA tempdistricts;
	SET tempschools;
		
	totalstud_300p = .;
	IF more_300 = 1 then totalstud_300p = G0309+G0409+G0509;
	
	totalhi = .;
	totalwh = .;
	totalbl = .;
	
	totalhi = (HI03M09+HI03F09+HI04M09+HI04F09+HI05M09+HI05F09);
	totalwh = (WH03M09+WH03F09+WH04M09+WH04F09+WH05M09+WH05F09);
	totalbl = (BL03M09+BL03F09+BL04M09+BL04F09+BL05M09+BL05F09);

	totalhi_300p = .;
	totalwh_300p = .;
	totalbl_300p = .;
	
	IF more_300 = 1 then totalhi_300p = (HI03M09+HI03F09+HI04M09+HI04F09+HI05M09+HI05F09);
	IF more_300 = 1 then totalwh_300p = (WH03M09+WH03F09+WH04M09+WH04F09+WH05M09+WH05F09);
	IF more_300 = 1 then totalbl_300p = (BL03M09+BL03F09+BL04M09+BL04F09+BL05M09+BL05F09);
RUN;

PROC SORT data=tempdistricts;
	BY LEAID;
RUN;

/*add district level counts*/

%macro add_dist_cts(school_ct,dist_ct);

	DATA tempdistricts;
		SET tempdistricts;
		BY LEAID;
		IF first.LEAID then &dist_ct = 0;
		&dist_ct + &school_ct;
		
		IF last.LEAID then output;
	RUN;
%mend;

%add_dist_cts(totalhi,dist_totalhi)
%add_dist_cts(totalwh,dist_totalwh)
%add_dist_cts(totalbl,dist_totalbl)
%add_dist_cts(totalhi_300p,dist_totalhi_300p)
%add_dist_cts(totalwh_300p,dist_totalwh_300p)
%add_dist_cts(totalbl_300p,dist_totalbl_300p)
%add_dist_cts(totalstud,dist_totalstud)
%add_dist_cts(totalstud_300p,dist_totalstud_300p)


***********************************************************************
***Create variables of interest and save completed districts dataset***
***********************************************************************;
DATA tempdistricts;
	SET tempdistricts;
		avg_hispanic_all = .;
		if dist_totalstud >= 1 then avg_hispanic_all = dist_totalhi/dist_totalstud;

		avg_white_all = .;
		if dist_totalstud >= 1 then avg_white_all = dist_totalwh/dist_totalstud;

		avg_black_all = .;
		if dist_totalstud >= 1 then avg_black_all = dist_totalbl/dist_totalstud;

		avg_hispanic_300p = . ;
		if dist_totalstud_300p >= 1 then avg_hispanic_300p = dist_totalhi_300p/dist_totalstud_300p;

		avg_white_300p = .;
		if dist_totalstud_300p >= 1 then avg_white_300p =  dist_totalwh_300p/dist_totalstud_300p;

		avg_black_300p = .;
		if dist_totalstud_300p >= 1 then avg_black_300p = dist_totalbl_300p/dist_totalstud_300p;
		
		mergevar = .;
		mergevar = leaid;
RUN;

DATA districts;
	SET tempdistricts;
	BY LEAID;
	IF last.LEAID then output;
RUN;

Data example.districts(keep = leaid name09 fipst avg_hispanic_all avg_white_all avg_black_all avg_hispanic_300p avg_white_300p avg_black_300p rename=(fipst=state name09=lea_name));
	MERGE tempdistricts readdistricts;  
	if mergevar = . then delete;
RUN;

PROC MEANS data = districts;
	VAR avg_hispanic_all avg_white_all avg_black_all avg_hispanic_300p avg_white_300p avg_black_300p;
RUN;
