OPTIONS LS=132 PS=53 NOCENTER;

*****************************************************************;
* SF12V2-1.SAS
* SAS CODE FOR SCORING 12-ITEM HEALTH SURVEY VERSION 2.0
* WRITTEN BY K. SPRITZER, 6/23/2003
* MODIFIED: 6/28/2004
*****************************************************************;

/* INPUT TEST DATA */
/* INCLUDES SOME OUT OF RANGE DATA FOR TESTING */
DATA TEMP1; 
INPUT I1-I12;
CARDS;
1 1 1 1 1 1 1 1 1 1 1 1 
1 1 3 3 3 3 3 3 3 3 3 3 
1 1 . 3 3 3 3 3 3 3 3 3 
5 5 1 1 1 . . . . . . . 
;
RUN;


DATA TEMP1; 
/** RENAME ITEMS TO CONFORM TO SURVEY **/
SET TEMP1(RENAME=(
I1  =I1 
I2  =I2A   
I3  =I2B   
I4  =I3A  
I5  =I3B  
I6  =I4A  
I7  =I4B  
I8  =I5   
I9  =I6A  
I10 =I6B  
I11 =I6C  
I12 =I7));
RUN;  
*****************************************************************;
** CODE OUT-OF-RANGE VALUES TO MISSING;
*****************************************************************;
DATA TEMP1; SET TEMP1;

ARRAY PT5 I1 I3A I3B I4A I4B I5 I6A I6B I6C I7;
DO OVER PT5;
IF PT5 NOT IN (1,2,3,4,5) THEN PT5=.;
END;

ARRAY PT3 I2A I2B;
DO OVER PT3;
IF PT3 NOT IN (1,2,3) THEN PT3=.;
END;
RUN;
***************************************************************************;

***************************************************************************;
DATA TEMP1; SET TEMP1;
***************************************************************************;
** WHEN NECESSARY, REVERSE CODE ITEMS SO A HIGHER SCORE MEANS BETTER HEALTH;
***************************************************************************;
IF I1=1 THEN I1=5.0; ELSE
IF I1=2 THEN I1=4.4; ELSE
IF I1=3 THEN I1=3.4; ELSE
IF I1=4 THEN I1=2.0; ELSE
IF I1=5 THEN I1=1.0;

I5=6-I5;
I6A=6-I6A;
I6B=6-I6B;

** CREATE SCALES;

PF=I2A+I2B;
RP=I3A+I3B;
BP=I5;
GH=I1;
VT=I6B;
SF=I7;
RE=I4A+I4B;
MH=I6A+I6C;

PF=100*(PF-2)/4;
RP=100*(RP-2)/8;
BP=100*(BP-1)/4;
GH=100*(GH-1)/4;
VT=100*(VT-1)/4;
SF=100*(SF-1)/4;
RE=100*(RE-2)/8;
MH=100*(MH-2)/8;

RUN;
              
DATA TEMP1; SET TEMP1;
 
*** 1) TRANSFORM SCORES TO Z-SCORES; ******* ;
***    US GENERAL POPULATION MEANS AND SD'S ARE USED HERE ******* ;
***    (NOT AGE/GENDER BASED) *********************************** ;
              
   PF_Z = (PF - 81.18122) / 29.10588 ;
   RP_Z = (RP - 80.52856) / 27.13526 ;
   BP_Z = (BP - 81.74015) / 24.53019 ;
   GH_Z = (GH - 72.19795) / 23.19041 ;
   VT_Z = (VT - 55.59090) / 24.84380 ;
   SF_Z = (SF - 83.73973) / 24.75775 ;
   RE_Z = (RE - 86.41051) / 22.35543 ;
   MH_Z = (MH - 70.18217) / 20.50597 ;


*** 2) CREATE PHYSICAL AND MENTAL HEALTH COMPOSITE SCORES: **********;
***    MULTIPLY Z-SCORES BY VARIMAX-ROTATED FACTOR SCORING **********;
***    COEFFICIENTS AND SUM THE PRODUCTS ****************************;

   AGG_PHYS = (PF_Z * 0.42402) + 
              (RP_Z * 0.35119) + 
              (BP_Z * 0.31754) +
              (GH_Z * 0.24954) + 
              (VT_Z * 0.02877) + 
              (SF_Z * -.00753) +
              (RE_Z * -.19206) + 
              (MH_Z * -.22069) ;
              
              
   AGG_MENT = (PF_Z * -.22999) + 
              (RP_Z * -.12329) + 
              (BP_Z * -.09731) +
              (GH_Z * -.01571) + 
              (VT_Z * 0.23534) + 
              (SF_Z * 0.26876) +
              (RE_Z * 0.43407) + 
              (MH_Z * 0.48581) ;


*** 3) TRANSFORM COMPOSITE AND SCALE SCORES TO T-SCORES: ****** ;

   AGG_PHYS = 50 + (AGG_PHYS * 10);
   AGG_MENT = 50 + (AGG_MENT * 10);

   LABEL AGG_PHYS="NEMC PHYSICAL HEALTH T-SCORE - SF12";
   LABEL AGG_MENT="NEMC MENTAL HEALTH T-SCORE - SF12";

   PF_T = 50 + (PF_Z * 10) ;
   RP_T = 50 + (RP_Z * 10) ;
   BP_T = 50 + (BP_Z * 10) ;
   GH_T = 50 + (GH_Z * 10) ;
   VT_T = 50 + (VT_Z * 10) ;
   RE_T = 50 + (RE_Z * 10) ;
   SF_T = 50 + (SF_Z * 10) ;
   MH_T = 50 + (MH_Z * 10) ;

   LABEL PF_T="NEMC PHYSICAL FUNCTIONING T-SCORE";
   LABEL RP_T="NEMC ROLE LIMITATION PHYSICAL T-SCORE";
   LABEL BP_T="NEMC PAIN T-SCORE";
   LABEL GH_T="NEMC GENERAL HEALTH T-SCORE";
   LABEL VT_T="NEMC VITALITY T-SCORE";
   LABEL RE_T="NEMC ROLE LIMITATION EMOTIONAL T-SCORE";
   LABEL SF_T="NEMC SOCIAL FUNCTIONING T-SCORE";
   LABEL MH_T="NEMC MENTAL HEALTH T-SCORE";

RUN;

/* TEST PRINTS */
/*
PROC PRINT DATA=TEMP1;
VAR PF PF_T  
    RP RP_T  
    BP BP_T 
    GH GH_T 
    VT VT_T 
    SF SF_T 
    RE RE_T 
    MH MH_T 
    AGG_PHYS AGG_MENT;
FORMAT
    PF PF_T  
    RP RP_T  
    BP BP_T 
    GH GH_T 
    VT VT_T 
    SF SF_T 
    RE RE_T 
    MH MH_T 
    AGG_PHYS AGG_MENT 6.2;    
RUN;
*/

TITLE1 "SF12 V2 - OVERALL DESCRIPTIVE STATISTICS ON SCALE SCORES"; RUN;
PROC MEANS DATA=TEMP1; 
VAR PF PF_T  
    RP RP_T  
    BP BP_T 
    GH GH_T 
    VT VT_T 
    SF SF_T 
    RE RE_T 
    MH MH_T 
    AGG_PHYS AGG_MENT;
RUN;
