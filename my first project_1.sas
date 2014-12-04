/* ----------------------------------------
Code exported from SAS Enterprise Guide
DATE: Thursday, December 04, 2014     TIME: 1:28:08 PM
PROJECT: my first project_1
PROJECT PATH: Z:\PSYC\LDierker\JROSE01\big data courses\data management\EG demo project\my first project_1.egp
---------------------------------------- */

/* Library assignment for Local.MYDATA */
Libname MYDATA BASE 'Z:\PSYC\LDierker\JROSE01\big data courses\data management\data sets\NHIS' ;
/* Library assignment for Local.MYDATA */
Libname MYDATA BASE 'Z:\PSYC\LDierker\JROSE01\big data courses\data management\data sets\NHIS' ;


/* Conditionally delete set of tables or views, if they exists          */
/* If the member does not exist, then no action is performed   */
%macro _eg_conditional_dropds /parmbuff;
	
   	%local num;
   	%local stepneeded;
   	%local stepstarted;
   	%local dsname;
	%local name;

   	%let num=1;
	/* flags to determine whether a PROC SQL step is needed */
	/* or even started yet                                  */
	%let stepneeded=0;
	%let stepstarted=0;
   	%let dsname= %qscan(&syspbuff,&num,',()');
	%do %while(&dsname ne);	
		%let name = %sysfunc(left(&dsname));
		%if %qsysfunc(exist(&name)) %then %do;
			%let stepneeded=1;
			%if (&stepstarted eq 0) %then %do;
				proc sql;
				%let stepstarted=1;

			%end;
				drop table &name;
		%end;

		%if %sysfunc(exist(&name,view)) %then %do;
			%let stepneeded=1;
			%if (&stepstarted eq 0) %then %do;
				proc sql;
				%let stepstarted=1;
			%end;
				drop view &name;
		%end;
		%let num=%eval(&num+1);
      	%let dsname=%qscan(&syspbuff,&num,',()');
	%end;
	%if &stepstarted %then %do;
		quit;
	%end;
%mend _eg_conditional_dropds;

/* ---------------------------------- */
/* MACRO: enterpriseguide             */
/* PURPOSE: define a macro variable   */
/*   that contains the file system    */
/*   path of the WORK library on the  */
/*   server.  Note that different     */
/*   logic is needed depending on the */
/*   server type.                     */
/* ---------------------------------- */
%macro enterpriseguide;
%global sasworklocation;
%local tempdsn unique_dsn path;

%if &sysscp=OS %then %do; /* MVS Server */
	%if %sysfunc(getoption(filesystem))=MVS %then %do;
        /* By default, physical file name will be considered a classic MVS data set. */
	    /* Construct dsn that will be unique for each concurrent session under a particular account: */
		filename egtemp '&egtemp' disp=(new,delete); /* create a temporary data set */
 		%let tempdsn=%sysfunc(pathname(egtemp)); /* get dsn */
		filename egtemp clear; /* get rid of data set - we only wanted its name */
		%let unique_dsn=".EGTEMP.%substr(&tempdsn, 1, 16).PDSE"; 
		filename egtmpdir &unique_dsn
			disp=(new,delete,delete) space=(cyl,(5,5,50))
			dsorg=po dsntype=library recfm=vb
			lrecl=8000 blksize=8004 ;
		options fileext=ignore ;
	%end; 
 	%else %do; 
        /* 
		By default, physical file name will be considered an HFS 
		(hierarchical file system) file. 
		*/
		%if "%sysfunc(getoption(filetempdir))"="" %then %do;
			filename egtmpdir '/tmp';
		%end;
		%else %do;
			filename egtmpdir "%sysfunc(getoption(filetempdir))";
		%end;
	%end; 
	%let path=%sysfunc(pathname(egtmpdir));
    %let sasworklocation=%sysfunc(quote(&path));  
%end; /* MVS Server */
%else %do;
	%let sasworklocation = "%sysfunc(getoption(work))/";
%end;
%if &sysscp=VMS_AXP %then %do; /* Alpha VMS server */
	%let sasworklocation = "%sysfunc(getoption(work))";                         
%end;
%if &sysscp=CMS %then %do; 
	%let path = %sysfunc(getoption(work));                         
	%let sasworklocation = "%substr(&path, %index(&path,%str( )))";
%end;
%mend enterpriseguide;

%enterpriseguide

/* save the current settings of XPIXELS and YPIXELS */
/* so that they can be restored later               */
%macro _sas_pushchartsize(new_xsize, new_ysize);
	%global _savedxpixels _savedypixels;
	options nonotes;
	proc sql noprint;
	select setting into :_savedxpixels
	from sashelp.vgopt
	where optname eq "XPIXELS";
	select setting into :_savedypixels
	from sashelp.vgopt
	where optname eq "YPIXELS";
	quit;
	options notes;
	GOPTIONS XPIXELS=&new_xsize YPIXELS=&new_ysize;
%mend;

/* restore the previous values for XPIXELS and YPIXELS */
%macro _sas_popchartsize;
	%if %symexist(_savedxpixels) %then %do;
		GOPTIONS XPIXELS=&_savedxpixels YPIXELS=&_savedypixels;
		%symdel _savedxpixels / nowarn;
		%symdel _savedypixels / nowarn;
	%end;
%mend;

ODS PROCTITLE;
OPTIONS DEV=ACTIVEX;
GOPTIONS XPIXELS=0 YPIXELS=0;
FILENAME EGHTMLX TEMP;
ODS HTML(ID=EGHTMLX) FILE=EGHTMLX
    ENCODING='utf-8'
    STYLE=Harvest
    STYLESHEET=(URL="file:///C:/Program%20Files/SASHome94/SASEnterpriseGuide/6.1/Styles/Harvest.css")
    ATTRIBUTES=("CODEBASE"="http://www2.sas.com/codebase/graph/v94/sasgraph.exe#version=9,4")
    NOGTITLE
    NOGFOOTNOTE
    GPATH=&sasworklocation
;
FILENAME EGRTFX TEMP;
ODS RTF(ID=EGRTFX) FILE=EGRTFX
    ENCODING='utf-8'
    STYLE=Rtf
    NOGTITLE
    NOGFOOTNOTE
;
FILENAME EGSRX TEMP;
ODS tagsets.sasreport13(ID=EGSRX) FILE=EGSRX
    STYLE=HtmlBlue
    STYLESHEET=(URL="file:///C:/Program%20Files/SASHome94/SASEnterpriseGuide/6.1/Styles/HtmlBlue.css")
    NOGTITLE
    NOGFOOTNOTE
    GPATH=&sasworklocation
    ENCODING=UTF8
    options(rolap="on")
;

/*   START OF NODE: Assign Project Library (MYDATA)   */
%LET _CLIENTTASKLABEL='Assign Project Library (MYDATA)';
%LET _CLIENTPROJECTPATH='Z:\PSYC\LDierker\JROSE01\big data courses\data management\EG demo project\my first project_1.egp';
%LET _CLIENTPROJECTNAME='my first project_1.egp';

GOPTIONS ACCESSIBLE;
LIBNAME MYDATA BASE "Z:\PSYC\LDierker\JROSE01\big data courses\data management\data sets\NHIS" ;

GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTNAME=;


/*   START OF NODE: Code For Data Set Attributes for 2013 Adult NHIS    */
%LET _CLIENTTASKLABEL='Code For Data Set Attributes for 2013 Adult NHIS ';
%LET _CLIENTPROJECTPATH='Z:\PSYC\LDierker\JROSE01\big data courses\data management\EG demo project\my first project_1.egp';
%LET _CLIENTPROJECTNAME='my first project_1.egp';
%LET _SASPROGRAMFILE=;

GOPTIONS ACCESSIBLE;
/* Insert custom code before submitted code here */


LIBNAME ECLIB000 "Z:\PSYC\LDierker\JROSE01\big data courses\data management\data sets\NHIS";

/* -------------------------------------------------------------------
   Code generated by SAS Task

   Generated on: Monday, December 01, 2014 at 11:12:07 AM
   By task: Data Set Attributes for 2013 Adult NHIS 

   Input Data: Z:\PSYC\LDierker\JROSE01\big data courses\data management\data sets\NHIS\nhisadult_2013.sas7bdat
   Server:  Local
   ------------------------------------------------------------------- */

%_eg_conditional_dropds(WORK.CONTCONTENTSFORNHISADULT_20_0000);
TITLE "Data Set Attributes Report for NHIS Adults 18-30";
FOOTNOTE;
FOOTNOTE1 "Generated by the SAS System (&_SASSERVERNAME, &SYSSCPL) on %TRIM(%QSYSFUNC(DATE(), NLDATE20.)) at %TRIM(%SYSFUNC(TIME(), TIMEAMPM12.)) by Jennifer Rose";


PROC DATASETS NOLIST NODETAILS; 
   CONTENTS DATA=ECLIB000.nhisadult_2013;

RUN;



/* Insert custom code after submitted code here */

GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;


/*   START OF NODE: Select variables and age 18-30   */
%LET _CLIENTTASKLABEL='Select variables and age 18-30';
%LET _CLIENTPROJECTPATH='Z:\PSYC\LDierker\JROSE01\big data courses\data management\EG demo project\my first project_1.egp';
%LET _CLIENTPROJECTNAME='my first project_1.egp';

GOPTIONS ACCESSIBLE;
%_eg_conditional_dropds(MYDATA.SUBSET_NHISADULT_2013);

PROC SQL;
   CREATE TABLE MYDATA.SUBSET_NHISADULT_2013(label="SUBSET_NHISADULT_2013_SAS7BD") AS 
   SELECT t1.HHX, 
          t1.SEX, 
          t1.REGION, 
          t1.MRACBPI2, 
          t1.AGE_P, 
          t1.R_MARITL, 
          t1.WRKLYR4, 
          t1.AHCDLYR1, 
          t1.AHCDLYR2, 
          t1.AHCDLYR3, 
          t1.AHCDLYR4, 
          t1.AHCDLYR5, 
          t1.ANOUSPL1, 
          t1.ANOUSPL2, 
          t1.ANOUSPL3, 
          t1.ANOUSPL4, 
          t1.ANOUSPL5, 
          t1.ANOUSPL6, 
          t1.ANOUSPL7, 
          t1.ANOUSPL8, 
          t1.ANOUSPL9, 
          t1.ALC12MNO, 
          t1.ALC12MWK, 
          t1.ALCAMT, 
          t1.ALCSTAT, 
          t1.SMKQTY, 
          t1.SMKREG, 
          t1.SMKSTAT2, 
          t1.CIGSDA1, 
          t1.VIGFREQW, 
          t1.VIGMIN, 
          t1.MODFREQW, 
          t1.MODMIN, 
          t1.STRFREQW
      FROM EC100004.nhisadult_2013 t1
      WHERE t1.AGE_P BETWEEN 18 AND 30
      ORDER BY t1.HHX;
QUIT;

GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTNAME=;


/*   START OF NODE: One-Way Frequencies   */
%LET _CLIENTTASKLABEL='One-Way Frequencies';
%LET _CLIENTPROJECTPATH='Z:\PSYC\LDierker\JROSE01\big data courses\data management\EG demo project\my first project_1.egp';
%LET _CLIENTPROJECTNAME='my first project_1.egp';

GOPTIONS ACCESSIBLE;
/* -------------------------------------------------------------------
   Code generated by SAS Task

   Generated on: Thursday, December 04, 2014 at 1:28:01 PM
   By task: One-Way Frequencies

   Input Data: Local:MYDATA.SUBSET_NHISADULT_2013
   Server:  Local
   ------------------------------------------------------------------- */

%_eg_conditional_dropds(WORK.SORT);
/* -------------------------------------------------------------------
   Sort data set Local:MYDATA.SUBSET_NHISADULT_2013
   ------------------------------------------------------------------- */

PROC SQL;
	CREATE VIEW WORK.SORT AS
		SELECT T.SEX, T.REGION, T.MRACBPI2, T.AGE_P, T.R_MARITL, T.WRKLYR4, T.AHCDLYR1, T.AHCDLYR2, T.AHCDLYR3, T.AHCDLYR4, T.AHCDLYR5, T.ANOUSPL1, T.ANOUSPL2, T.ANOUSPL3, T.ANOUSPL4, T.ANOUSPL5, T.ANOUSPL6, T.ANOUSPL7, T.ANOUSPL8, T.ANOUSPL9
		     , T.ALC12MNO, T.ALC12MWK, T.ALCAMT, T.ALCSTAT, T.SMKQTY, T.SMKREG, T.SMKSTAT2, T.CIGSDA1, T.VIGFREQW, T.VIGMIN, T.MODFREQW, T.MODMIN, T.STRFREQW
	FROM MYDATA.SUBSET_NHISADULT_2013 as T
;
QUIT;

TITLE;
TITLE1 "One-Way Frequencies";
TITLE2 "Results for 2013 Adult NHIS";
FOOTNOTE;
FOOTNOTE1 "Generated by the SAS System (&_SASSERVERNAME, &SYSSCPL) on %TRIM(%QSYSFUNC(DATE(), NLDATE20.)) at %TRIM(%SYSFUNC(TIME(), TIMEAMPM12.)) by Jennifer Rose";
PROC FREQ DATA=WORK.SORT
	ORDER=INTERNAL
;
	TABLES SEX /  SCORES=TABLE;
	TABLES REGION /  SCORES=TABLE;
	TABLES MRACBPI2 /  SCORES=TABLE;
	TABLES AGE_P /  SCORES=TABLE;
	TABLES R_MARITL /  SCORES=TABLE;
	TABLES WRKLYR4 /  SCORES=TABLE;
	TABLES AHCDLYR1 /  SCORES=TABLE;
	TABLES AHCDLYR2 /  SCORES=TABLE;
	TABLES AHCDLYR3 /  SCORES=TABLE;
	TABLES AHCDLYR4 /  SCORES=TABLE;
	TABLES AHCDLYR5 /  SCORES=TABLE;
	TABLES ANOUSPL1 /  SCORES=TABLE;
	TABLES ANOUSPL2 /  SCORES=TABLE;
	TABLES ANOUSPL3 /  SCORES=TABLE;
	TABLES ANOUSPL4 /  SCORES=TABLE;
	TABLES ANOUSPL5 /  SCORES=TABLE;
	TABLES ANOUSPL6 /  SCORES=TABLE;
	TABLES ANOUSPL7 /  SCORES=TABLE;
	TABLES ANOUSPL8 /  SCORES=TABLE;
	TABLES ANOUSPL9 /  SCORES=TABLE;
	TABLES ALC12MNO /  SCORES=TABLE;
	TABLES ALC12MWK /  SCORES=TABLE;
	TABLES ALCAMT /  SCORES=TABLE;
	TABLES ALCSTAT /  SCORES=TABLE;
	TABLES SMKQTY /  SCORES=TABLE;
	TABLES SMKREG /  SCORES=TABLE;
	TABLES SMKSTAT2 /  SCORES=TABLE;
	TABLES CIGSDA1 /  SCORES=TABLE;
	TABLES VIGFREQW /  SCORES=TABLE;
	TABLES VIGMIN /  SCORES=TABLE;
	TABLES MODFREQW /  SCORES=TABLE;
	TABLES MODMIN /  SCORES=TABLE;
	TABLES STRFREQW /  SCORES=TABLE;
RUN;
/* -------------------------------------------------------------------
   End of task code.
   ------------------------------------------------------------------- */
RUN; QUIT;
%_eg_conditional_dropds(WORK.SORT);
TITLE; FOOTNOTE;


GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTNAME=;

;*';*";*/;quit;run;
ODS _ALL_ CLOSE;
