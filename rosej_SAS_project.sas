/* ----------------------------------------
Code exported from SAS Enterprise Guide
DATE: Saturday, December 27, 2014     TIME: 5:16:46 PM
PROJECT: my first project create project
PROJECT PATH: Z:\PSYC\LDierker\JROSE01\healthcare data sets\MEPS\my first project create project.egp
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
%LET _CLIENTPROJECTPATH='Z:\PSYC\LDierker\JROSE01\healthcare data sets\MEPS\my first project create project.egp';
%LET _CLIENTPROJECTNAME='my first project create project.egp';

GOPTIONS ACCESSIBLE;
LIBNAME MYDATA BASE "Z:\PSYC\LDierker\JROSE01\big data courses\data management\data sets\NHIS" ;

GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTNAME=;


/*   START OF NODE: Select variables and age 18-30   */
%LET _CLIENTTASKLABEL='Select variables and age 18-30';
%LET _CLIENTPROJECTPATH='Z:\PSYC\LDierker\JROSE01\healthcare data sets\MEPS\my first project create project.egp';
%LET _CLIENTPROJECTNAME='my first project create project.egp';

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
          t1.VIGFREQW, 
          t1.VIGMIN, 
          t1.MODFREQW, 
          t1.MODMIN, 
          t1.STRFREQW, 
          t1.CIGDAMO, 
          t1.BMI
      FROM EC100027.nhisadult_2013 t1
      WHERE t1.AGE_P BETWEEN 18 AND 30
      ORDER BY t1.HHX;
QUIT;

GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTNAME=;


/*   START OF NODE: Data Set Attributes   */
%LET _CLIENTTASKLABEL='Data Set Attributes';
%LET _CLIENTPROJECTPATH='Z:\PSYC\LDierker\JROSE01\healthcare data sets\MEPS\my first project create project.egp';
%LET _CLIENTPROJECTNAME='my first project create project.egp';

GOPTIONS ACCESSIBLE;
/* -------------------------------------------------------------------
   Code generated by SAS Task

   Generated on: Saturday, December 27, 2014 at 5:14:03 PM
   By task: Data Set Attributes

   Input Data: Local:MYDATA.SUBSET_NHISADULT_2013
   Server:  Local
   ------------------------------------------------------------------- */

%_eg_conditional_dropds(WORK.CONTContentsForSUBSET_NHISADULT_);
TITLE;
FOOTNOTE;
FOOTNOTE1 "Generated by the SAS System (&_SASSERVERNAME, &SYSSCPL) on %TRIM(%QSYSFUNC(DATE(), NLDATE20.)) at %TRIM(%SYSFUNC(TIME(), TIMEAMPM12.)) by Jennifer Rose";
PROC FORMAT;
   VALUE _EG_VARTYPE 1="Numeric" 2="Character" OTHER="unknown";
RUN;

PROC DATASETS NOLIST NODETAILS; 
   CONTENTS DATA=MYDATA.SUBSET_NHISADULT_2013 OUT=WORK.SUCOUT1;

RUN;

DATA WORK.CONTContentsForSUBSET_NHISADULT_(LABEL="Contents Details for SUBSET_NHISADULT_2013");
   SET WORK.SUCOUT1;
RUN;

PROC DELETE DATA=WORK.SUCOUT1;
RUN;

%LET _LINESIZE=%SYSFUNC(GETOPTION(LINESIZE));

PROC SQL;
CREATE VIEW WORK.SCVIEW AS 
	SELECT DISTINCT memname LABEL="Table Name", 
			memlabel LABEL="Label", 
			memtype LABEL="Type", 
			crdate LABEL="Date Created", 
			modate LABEL="Date Modified", 
			nobs LABEL="Number of Obs.", 
			charset LABEL="Char. Set", 
			protect LABEL="Password Protected", 
			typemem LABEL="Data Set Type" FROM WORK.CONTContentsForSUBSET_NHISADULT_
	ORDER BY memname ; 

CREATE TABLE WORK.SCTABLE AS
	SELECT * FROM WORK.SCVIEW
		WHERE memname='SUBSET_NHISADULT_2013';
QUIT;

TITLE "Tables on &_SASSERVERNAME"; 
PROC REPORT DATA=WORK.SCTABLE; 
   DEFINE  MEMLABEL / DISPLAY WIDTH=&_LINESIZE; 
   COLUMN memname memlabel memtype crdate modate nobs charset protect typemem; 
RUN;QUIT;

PROC SORT DATA=WORK.CONTContentsForSUBSET_NHISADULT_ OUT=WORK.CONTContentsForSUBSET_NHISADULT_;
   BY memname name;
RUN;

OPTIONS NOBYLINE;
TITLE 'Variables in Table: #BYVAL(memname)'; 

PROC SQL;
DROP TABLE WORK.SCTABLE;
CREATE TABLE WORK.SCTABLE AS
	SELECT * FROM WORK.CONTContentsForSUBSET_NHISADULT_
		WHERE memname='SUBSET_NHISADULT_2013';
QUIT;

PROC REPORT DATA=WORK.SCTABLE NOWINDOWS; 
   FORMAT TYPE _EG_VARTYPE.; 
   DEFINE LABEL / DISPLAY WIDTH=&_LINESIZE; 
   LABEL NAME="Name" LABEL="Label" TYPE="Type" LENGTH="Length" INFORMAT="Informat" FORMAT="Format"; 
   BY memname NOTSORTED;  
   COLUMN name varnum type format label length;  
 QUIT;  

PROC SQL;
	DROP TABLE WORK.SCTABLE;
	DROP VIEW WORK.SCVIEW;
QUIT;

PROC CATALOG CATALOG=WORK.FORMATS;
   DELETE _EG_VARTYPE / ENTRYTYPE=FORMAT;
RUN;
OPTIONS BYLINE;
/* -------------------------------------------------------------------
   End of task code.
   ------------------------------------------------------------------- */
RUN; QUIT;
TITLE; FOOTNOTE;


GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTNAME=;

;*';*";*/;quit;run;
ODS _ALL_ CLOSE;
