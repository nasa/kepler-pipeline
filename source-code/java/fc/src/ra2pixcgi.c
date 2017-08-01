/*
 * Compile with gcc -o ra2pixcgi ra2pixcgi.c -lm.
 * Run ra2pixcgi -h to see for command line arguments.
 * 
 * Copyright 2017 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 * 
 * This file is available under the terms of the NASA Open Source Agreement
 * (NOSA). You should have received a copy of this agreement with the
 * Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
 * 
 * No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
 * WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
 * INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
 * WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
 * INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
 * FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
 * TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
 * CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
 * OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
 * OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
 * FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
 * REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
 * AND DISTRIBUTES IT "AS IS."
 *
 * Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
 * AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
 * SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
 * THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
 * EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
 * PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
 * SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
 * STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
 * PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
 * REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
 * TERMINATION OF THIS AGREEMENT.
 */

#define _GNU_SOURCE  // JLC  Jeff Crilly

#include <math.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <stdlib.h> /* needed for exit */


/* Some constants for the web version */

#define RA_SIZE 32
#define DEC_SIZE 32

#define NULL_CHAR '\0'

#define SEASON_KEY "SEASON"

#define RA_HOURS_KEY "RA_HOURS"
#define RA_MINUTES_KEY "RA_MINUTES"
#define RA_SECONDS_KEY "RA_SECONDS"


#define DEC_DEGREES_KEY "DEC_DEGREES"
#define DEC_MINUTES_KEY "DEC_MINUTES"
#define DEC_SECONDS_KEY "DEC_SECONDS"

#define RA_KEY "RA"
#define DEC_KEY "DEC"

#define RADEC_TYPE_KEY  "RA_DEC_TYPE"
#define NUM_PARAMS 4

#define TRUE 1
#define FALSE 0

typedef struct {
    char raDecType[2];

    char ra[RA_SIZE];
    char dec[DEC_SIZE];

    char raHours[RA_SIZE];
    char raMinutes[RA_SIZE];
    char raSeconds[RA_SIZE];

    char decDegrees[DEC_SIZE];
    char decMinutes[DEC_SIZE];
    char decSeconds[DEC_SIZE];

    char season[2];

} t_requestParams;

int web_mode = FALSE;

void usage() {
    printf("-s <season>  -type {d|t} { -r <ra>  -d <dec> } | { -rh <hour> -rm <minute> -rs <seconds> -dd <degrees> -dm <minutes> -ds <seconds> }\n") ;
}

/** If cmd line options are provided, then we assume we are
 *  running in web_mode, i.e. running on a web server, providing 
 *  output that will be rendered on a web page.
 *
 * getOptions parses the cmd line options, and sets values used
 * by the program.  These values are set within the "params" struct.
 */
int getOptions(int argc, char *argv[], t_requestParams *params) {
    char *opt;
    int i;
    for (i=1; i<argc; i+=2) {
        opt = argv[i];
        if (opt[0] == '-') {
            web_mode = TRUE;
            if (strcmp("-s", opt) == 0) {
                strncpy(params->season, argv[i+1], 2);
            } else if (strcmp("-r", opt) == 0) {
                strncpy(params->ra, argv[i+1], RA_SIZE);
            } else if (strcmp("-d", opt) == 0) {
                strncpy(params->dec, argv[i+1], DEC_SIZE);
            } else if (strcmp("-rh", opt) == 0) {
                strncpy(params->raHours, argv[i+1], RA_SIZE);
            } else if (strcmp("-rm", opt) == 0) {
                strncpy(params->raMinutes, argv[i+1], RA_SIZE);
            } else if (strcmp("-rs", opt) == 0) {
                strncpy(params->raSeconds, argv[i+1], RA_SIZE);
            } else if (strcmp("-dd", opt) == 0) {
                strncpy(params->decDegrees, argv[i+1], DEC_SIZE);
            } else if (strcmp("-dm", opt) == 0) {
                strncpy(params->decMinutes, argv[i+1], DEC_SIZE);
            } else if (strcmp("-ds", opt) == 0) {
                strncpy(params->decSeconds, argv[i+1], DEC_SIZE);
            } else if (strcmp("-type", opt) == 0) {
                strncpy(params->raDecType, argv[i+1], 2);
            } else {
                usage();
                exit(0);
            }
        }
    }
    return 0;
}

/**
 * getSeason - get the season from the params struct
 */
int getSeason(t_requestParams *params) {
    if (params->season[0] == NULL_CHAR) return -1;
    return atoi(params->season);
}

/**
 * getRaDecType - get the way ra/dec is input (decimal or time) from the params struct
 */
char getRaDecType(t_requestParams *params) {
    if (params->raDecType[0] == NULL_CHAR) return NULL_CHAR;
   /**/ return tolower(params->raDecType[0]);  /* commmented out for Mac since error message about prototype DGK 8/05 */
}


/**
 * doTranslation is an adaptation of the ra2pix.c "main" function which
 * Dave originally wrote.
 * To support the web version, the code below is intermixed with "web_mode"
 * tests.  When web_mode is true, the program does not prompt interactively
 * for input; instead the program uses the values in params.
 *
 * TODO: A cleaner way to implement this is to seperate out the
 * interactive user input and validation from the coversion code.
 * Such an approach could use the params structure to pass the
 * parsed info to doTranslation().
 */
char *doTranslation(t_requestParams *params) {

        char buf[1024];
        static char resultMsg[1024];

	double rot_3=290.66666667; /* 3-rot corresponds to FOV at RA 19h 22m 40s changed 9/8/04 */
	double rot_2=-44.5; /* 2-rot corresponds to FOV Dec at 44d 30m 00s Note minus sign
								since +dec corresponds to -rot changed 9/8/04 */
	double rot_1; /* depends on season */
	int season_int;
	double first_roll=110.; /* Spacecraft Roll angle for summer. Replaces use of season 9/10/04 */
						/*	double season[4]={123.0,213.0,303.0,33.0}; /* the season determines the last rotation angle */
											   /* summer =0, fall =1, winter =2, spring =3, 
											   changed 9/8/04 */
	double clocking_angle=13.; /* add to spacecraft roll and n*90 deg to get FPAA roll=rot_1 9/10/04 */
								
/*	double rot_3=293.9583333; /* 3-rot corresponds to FOV at RA 19h 35m 55s */
/*	double rot_2=-34.6666667; /* 2-rot corresponds to FOV Dec at 34d 40m 00s Note minus sign
								since +dec corresponds to -rot */
/*	double season[4]={119.5,209.5,299.5,29.5}; /* the season determines the last rotation angle */
											   /* summer =0, fall =1, winter =2, spring =3, */

	int i, check;
	char ang; /* units for entering angle d ot */
	
	double srac,crac,sdec,cdec,srotc,crotc;
	double DCM11,DCM12,DCM13,DCM21,DCM22,DCM23,DCM31,DCM32,DCM33; /* direction cosine matrix */	
	
	int chn_num[10][10] ={0,0,56,55,36,35,16,15, 0,0,		/* array of channel numbers */
				  		  0,0,53,54,33,34,13,14, 0,0,
						75,74,60,59,40,39,17,20, 1,4,
						76,73,57,58,37,38,18,19, 2,3,
						79,78,63,62,44,43,21,24, 5,8,		/* note layout of matrix mimics  */
						80,77,64,61,41,42,22,23, 6,7,
						83,82,67,66,46,45,26,25, 9,12,		/* actual physical layout of chn numbers */
						84,81,68,65,47,48,27,28,10,11,		/* on FPA */
						 0, 0,70,69,50,49,30,29, 0,0,
						 0, 0,71,72,51,52,31,32, 0,0	};

    double chip_trans[42][3]={
             /* starting values are obtained from DFM.PHT.019a for the field=1 of each module
                 then they are adjusted so that the corners of the modules match the
                 field positions 5,6,8,9 DFM gives angles as azim,azim (u,v) need azim, elev (u,w)
                 Convert second azim v to w using tan w=tan v * cos u  Done in z option code below

                 These are the 3-2-1 transform values for the 46 chips=  (channel+1)/2
                 transform is from center of FPA to center of the module  for each chip (DCA)
                 transformed coor will have valid long values negative 0  to -1.1321 deg
                 lat will be +/- 1.2161 deg lng corresponds to rows, lat  to columns*/

                 /* z'-rot   Y'-rot    X'-rot Y-angle  X'-angle   module_rotation
                  where tan X'= tan X * cos Y  since CodeV uses  (azim,azim) coor and need (azim,elev) coor   */
                  5.71881,   2.84513, 180.14080,    /* mod  2, chip 1   chn 1 & 2    zoom 5 */
                  5.71881,   2.84513,   0.14080,    /* mod  2, chip 2   chn 3 & 4    */
                  5.71893,   0.00000, 180.00000,    /* mod  3, chip 3   chn 5 & 6    zoom 3 */
                  5.71893,   0.00000,   0.00000,    /* mod  3, chip 4   chn 7 & 8    */
                  5.71881,  -2.84513, 179.85920,    /* mod  4, chip 5   chn 9 & 10   zoom 5 */
                  5.71881,  -2.84513,  -0.14080,    /* mod  4, chip 6   chn 11 & 12  */
                  /* get next by doing 90 degree rotation of zoom coor */ 
                  /* sin Y''=sin Y * cos X' , sin X''=sin X' / cos Y''   provides 90 coor rotation */
                  2.85934,   5.71174,  90.14400,    /* mod  6, chip 7   chn 13 & 14  zoom 5+90deg rot */
                  2.85934,   5.71174, 270.14400,    /* mod  6, chip 8   chn 15 & 16  */
                  2.85942,   2.85586, 180.07160,    /* mod  7, chip 9   chn 17 & 18  zoom 4 */
                  2.85942,   2.85586,   0.07160,    /* mod  7, chip 10  chn 19 & 20  */
                  2.85945,   0.00000, 180.00000,    /* mod  8, chip 11  chn 21 & 22  zoom 2 */
                  2.85945,   0.00000,   0.00000,    /* mod  8, chip 12  chn 23 & 24  */
                  2.85942,  -2.85587, 269.92900,    /* mod  9, chip 13  chn 25 & 26  zoom 4 */
                  2.85942,  -2.85587,  89.92900,    /* mod  9, chip 14  chn 27 & 28  */
                  2.85934,  -5.71174, 269.85600,    /* mod 10, chip 15  chn 29 & 30  zoom 5+90deg rot */
                  2.85934,  -5.71174,  89.85600,    /* mod 10, chip 16  chn 31 & 32  */
                  0.00000,   5.71893,  90.00000,    /* mod 11, chip 17  chn 33 & 34  zoom 3 */
                  0.00000,   5.71893, 270.00000,    /* mod 11, chip 18  chn 35 & 36  */
                  0.00000,   2.85945,  90.00000,    /* mod 12, chip 19  chn 37 & 38  zoom 2 */
                  0.00000,   2.85945, 270.00000,    /* mod 12, chip 20  chn 39 & 40  */
                  0.00000,   0.00000,  90.00000,    /* mod 13, chip 21  chn 41 & 42  zoom 1 */
                  0.00000,   0.00000, 270.00000,    /* mod 13, chip 22  chn 43 & 44  */
                  0.00000,  -2.85945, 270.00000,    /* mod 14, chip 23  chn 45 & 46  zoom 2 */
                  0.00000,  -2.85945,  90.00000,    /* mod 14, chip 24  chn 47 & 48  */
                  0.00000,  -5.71893, 270.00000,    /* mod 15, chip 25  chn 49 & 50  zoom 3 */
                  0.00000,  -5.71893,  90.00000,    /* mod 15, chip 26  chn 51 & 52  */
                 -2.85934,   5.71174,  89.85600,    /* mod 16, chip 27  chn 53 & 54  zoom 5+90 deg rot */
                 -2.85934,   5.71174, 269.85600,    /* mod 16, chip 28  chn 55 & 56  */
                 -2.85942,   2.85587,  89.92900,    /* mod 17, chip 29  chn 57 & 58  zoom 4 */
                 -2.85942,   2.85587, 269.92900,    /* mod 17, chip 30  chn 59 & 60  */
                 -2.85945,   0.00000,   0.00000,    /* mod 18, chip 31  chn 61 & 62  zoom 2 */
                 -2.85945,   0.00000, 180.00000,    /* mod 18, chip 32  chn 63 & 64  */
                 -2.85942,  -2.85586,   0.07160,    /* mod 19, chip 33  chn 65 & 66  zoom 4 */
                 -2.85942,  -2.85586, 180.07160,    /* mod 19, chip 34  chn 67 & 68  */
                 -2.85934,  -5.71174, 270.14400,    /* mod 20, chip 35  chn 69 & 70  zoom 5+90deg rot */
                 -2.85934,  -5.71174,  90.14400,    /* mod 20, chip 36  chn 71 & 72  */
                 -5.71881,   2.84513,  -0.14080,    /* mod 22, chip 37  chn 73 & 74  zoom 5 */
                 -5.71881,   2.84513, 179.85920,    /* mod 22, chip 38  chn 75 & 76  */
                 -5.71893,   0.00000,   0.00000,    /* mod 23, chip 39  chn 77 & 78  zoom 3 */
                 -5.71893,   0.00000, 180.00000,    /* mod 23, chip 40  chn 79 & 80  */
                 -5.71881,  -2.84513,   0.14080,    /* mod 24, chip 41  chn 81 & 82  zoom 5 */
                 -5.71881,  -2.84513, 180.14080,    /* mod 24, chip 42  chn 83 & 84  */
                 /* for FGS reference position is 6, an outside corner of  the chip ,
                     not the center of the module */
                 /* FGS 1 and 4 are 90 deg rot of 2 and 3 with  appropriate sign changes
                      also added 0.0064 to y in 2&3 and to x in 1&4 to  shift by 12 pixels */
                /*  4.92625,    4.79173,    90.21,  */      /* mod 1,  fgs 1,  chn 85 added 3/4/05 season 0 */
                /*  4.80933,   -4.90900,   179.79,  */      /* mod 5,  fgs  2, chn 86 added 3/4/05 season 3 */
                /* -4.80933,    4.90900,    -0.21,  */      /* mod 21, fgs 3,  chn 87 added 3/4/05 season 1 */
                /* -4.92625,   -4.79173,   270.21   */     /* mod 25, fgs 4,  chn 88 added 3/4/05 season 2 */
             };
	
	double chip_offset[42][3]={ /* chip offsets
						first term is rotation in degrees added to last rotation in chip_trans[][]
						second term is half gap width from module center in pixels, a row offset
						last term is a column offset in pixels
						*/
						0.00000, 38.884, 0.0, /* chip  1 */  /* changed all from 39.0 to 38.884 DGK 8/15/05 */
						0.00000, 38.884, 0.0, /* chip  2 */
						0.00000, 38.884, 0.0, /* chip  3 */
						0.00000, 38.884, 0.0, /* chip  4 */
						0.00000, 38.884, 0.0, /* chip  5 */
						0.00000, 38.884, 0.0, /* chip  6 */
						0.00000, 38.884, 0.0, /* chip  7 */
						0.00000, 38.884, 0.0, /* chip  8 */
						0.00000, 38.884, 0.0, /* chip  9 */
						0.00000, 38.884, 0.0, /* chip 10 */
						0.00000, 38.884, 0.0, /* chip 11 */
						0.00000, 38.884, 0.0, /* chip 12 */
						0.00000, 38.884, 0.0, /* chip 13 */
						0.00000, 38.884, 0.0, /* chip 14 */
						0.00000, 38.884, 0.0, /* chip 15 */
						0.00000, 38.884, 0.0, /* chip 16 */
						0.00000, 38.884, 0.0, /* chip 17 */
						0.00000, 38.884, 0.0, /* chip 18 */
						0.00000, 38.884, 0.0, /* chip 19 */
						0.00000, 38.884, 0.0, /* chip 20 */
						0.00000, 38.884, 0.0, /* chip 21 */
						0.00000, 38.884, 0.0, /* chip 22 */
						0.00000, 38.884, 0.0, /* chip 23 */
						0.00000, 38.884, 0.0, /* chip 24 */
						0.00000, 38.884, 0.0, /* chip 25 */
						0.00000, 38.884, 0.0, /* chip 26 */
						0.00000, 38.884, 0.0, /* chip 27 */
						0.00000, 38.884, 0.0, /* chip 28 */
						0.00000, 38.884, 0.0, /* chip 29 */
						0.00000, 38.884, 0.0, /* chip 30 */
						0.00000, 38.884, 0.0, /* chip 31 */
						0.00000, 38.884, 0.0, /* chip 32 */
						0.00000, 38.884, 0.0, /* chip 33 */
						0.00000, 38.884, 0.0, /* chip 34 */
						0.00000, 38.884, 0.0, /* chip 35 */
						0.00000, 38.884, 0.0, /* chip 36 */
						0.00000, 38.884, 0.0, /* chip 37 */
						0.00000, 38.884, 0.0, /* chip 38 */
						0.00000, 38.884, 0.0, /* chip 39 */
						0.00000, 38.884, 0.0, /* chip 40 */
						0.00000, 38.884, 0.0, /* chip 41 */
						0.00000, 38.884, 0.0  /* chip 42 */
						};
	double DCM11c[42], DCM12c[42], DCM13c[42], 
		   DCM21c[42], DCM22c[42], DCM23c[42], 
		   DCM31c[42], DCM32c[42], DCM33c[42];	
	
	int chn_i, chn_j, chn_n, chip_n;
	double p_row, p_coln;
	double cosa,cosb,cosg,lp,mp,np, lpm,mpm,npm, lng,lat,latp, lngm, latm, lngr;
	
	double pi=3.141592654, tpi=2.*pi, pi2=pi/2., dtr=pi/180., rtd=180./pi;
	
	double tra,tdec;/* target Ra and Dec in degrees and then radians ; Changed from float to double 8/17/05 DGK */
	float hr, fmin,sec,dd,mm,ss;
	double trar, tdecr; 
	double plate_scale=3.9753235; /* arc sec per pixel  Updated 8/17/05 DGK */
	

	time_t systime;
	systime=time(NULL);
	printf("RA2pix version 1.6\n%s  ",ctime(&systime));

	/*
	for(i=0;i<5;i++) {
		for(j=0;j<10;j++){
			 printf("%i %i %i\n",i-5,j-5,chn_num[i][j]); 
		}}
		*/
	
	/* season_int=-1; // JLC - not needed. */
        season_int = getSeason(params);
	while (season_int<0 || season_int>3){
		printf("Pick season, summer =0, fall =1 winter =2, spring =3 : ");
		scanf("%d",&season_int);
		}

	/* Calculate the Direction Cosine Matrix to transform from RA and Dec to FPA coordinates */
	
	/*rot_1=season[season_int];*/
	rot_1=first_roll+clocking_angle+season_int*90.; /* changed 9/10/04 */
	if(rot_1 > 360.) rot_1=rot_1-360.;
	
	
	printf("Using FOV center at RA=%f Dec=%f and Rot angle=%f\n",rot_3,-rot_2,rot_1);
	printf("Note the spacecraft roll angle is %f since FPA clocking is %f deg larger than s/c\n",
		rot_1-clocking_angle, clocking_angle);
		
	rot_1=rot_1+180.; /* Need to account for 180 deg rotation of field due to imaging of mirror */
	srac=sin(rot_3*dtr); /* sin phi 3 rotation */
	crac=cos(rot_3*dtr); /* cos phi */
	sdec=sin(rot_2*dtr); /* sin theta 2 rotation Note 2 rotation is negative of dec in right hand sense */
	cdec=cos(rot_2*dtr); /* cos theta */
	srotc=sin(rot_1*dtr); /* sin psi 1 rotation */
	crotc=cos(rot_1*dtr); /* cos psi */
	
	
	/* DCM for a 3-2-1 rotation, Wertz p764 */
	DCM11=cdec*crac;
	DCM12=cdec*srac;
	DCM13=-sdec;
	DCM21=-crotc*srac+srotc*sdec*crac;
	DCM22=crotc*crac+srotc*sdec*srac;
	DCM23=srotc*cdec;
	DCM31=srotc*srac+crotc*sdec*crac;
	DCM32=-srotc*crac+crotc*sdec*srac;
	DCM33=crotc*cdec;
	
	/* CALCULATE DCM for each chip relative to center of FOV */
	for (i=0;i<42;i++){ /* step through each chip */
		/*fprintf(stderr,"%d %f %f %f\n",i,chip_trans[i][0],chip_trans[i][1],chip_trans[i][2]); */
		srac=sin(chip_trans[i][0]*dtr); /* sin phi 3 rotation */
		crac=cos(chip_trans[i][0]*dtr); /* cos phi */
		sdec=sin(chip_trans[i][1]*dtr); /* sin theta 2 rotation */
		cdec=cos(chip_trans[i][1]*dtr); /* cos theta */
		srotc=sin((chip_trans[i][2]+chip_offset[i][0])*dtr); /* sin psi 1 rotation includes rotation offset */
		crotc=cos((chip_trans[i][2]+chip_offset[i][0])*dtr); /* cos psi */
		
		/* DCM for a 3-2-1 rotation, Wertz p762 */
		DCM11c[i]=cdec*crac;
		DCM12c[i]=cdec*srac;
		DCM13c[i]=-sdec;
		DCM21c[i]=-crotc*srac+srotc*sdec*crac;
		DCM22c[i]=crotc*crac+srotc*sdec*srac;
		DCM23c[i]=srotc*cdec;
		DCM31c[i]=srotc*srac+crotc*sdec*crac;
		DCM32c[i]=-srotc*crac+crotc*sdec*srac;
		DCM33c[i]=crotc*cdec;
		}
	

        ang = getRaDecType(params);

        if (ang == NULL_CHAR) {
	
            printf("\nSelect units for RA and DEC. Type d for decimal or t for time: ");
            scanf("%c",&ang);
            check=0;

            while(check==0) {
		if(ang!='d' && ang!='t') {
                    printf("\nPlease type either a d or a t and a carriage return: ");
                    scanf("%c",&ang);
		} else
                    check=1;
            }
            if(ang=='t'){
                printf("\nWhen entering negative declination between 0 and -1 deg\n");
                printf("You need to attach the - sign a nonzero value, either the min or sec\n");
            }
        }

	tra=1.; /* so can enter while loop */
	while (tra>=0.) {

            if ( web_mode ) {
                if(ang=='d') { /* ang in degrees */
                    tra = atof(params->ra);
                    tdec = atof(params->dec);

                    if(tra<-180. || tra>360. || tdec<-90. || tdec>90.) {
                        return "\nAngles out of range. Reenter both: ";
                    }

                } else if (ang == 't') {/* ang in time  */

                    hr = atof(params->raHours);
                    fmin = atof(params->raMinutes);
                    sec = atof(params->raSeconds);

                    dd = atof(params->decDegrees);
                    mm = atof(params->decMinutes);
                    ss = atof(params->decSeconds);


                    tra=15.*(fabs(hr)+(fabs(fmin)+fabs(sec)/60.)/60.);
                    if(hr<0. || fmin<0. || sec<0.) tra = -tra;
                    tdec=fabs(dd)+(fabs(mm)+fabs(ss)/60.)/60.;
                    if(dd<0. || mm<0. || ss<0.) tdec=-tdec;

                    if(tra<-180. || tra>360. || tdec<-90. || tdec>90.) {
                        return "\nRA or Dec out of range. Reenter both: ";
                    }
                }

            } else { /* if Interactive mode then... */

		if(ang=='d') {
                    printf("\nEnter RA and dec in degrees: ");
                    scanf("%lf %lf",&tra, &tdec);  /* change to double so changed to %lf 8/17/05 DGK */
                    check=0;
                    while(check==0){
                        if(tra<-180. || tra>360. || tdec<-90. || tdec>90.) {
                            printf("\nAngles out of range. Reenter both: ");
                            scanf("%lf %lf",&tra, &tdec); /* change to double so changed to %lf 8/17/05 DGK */
                        } else
                            check=1;
                    }
                } else {/* ang in time  */
                    check=0;
                    printf("\nEnter RA and Dec in hh mm ss and deg min sec: ");
                    scanf("%f %f %f   %f %f %f", &hr, &fmin, &sec, &dd, &mm, &ss);
                    while(check==0){
                        tra=15.*(fabs(hr)+(fabs(fmin)+fabs(sec)/60.)/60.);
                        if(hr<0. || fmin<0. || sec<0.) tra = -tra;
                        tdec=fabs(dd)+(fabs(mm)+fabs(ss)/60.)/60.;
                        if(dd<0. || mm<0. || ss<0.) tdec=-tdec;

                        if(tra<-180. || tra>360. || tdec<-90. || tdec>90.) {
                            printf("\nRA or Dec out of range. Reenter both: ");
                            scanf("%f %f %f   %f %f %f", &hr, &fmin, &sec, &dd, &mm, &ss);
                        } else {
                            check=1;
                        }
                    }
                } /* have input now do conversion */

            } /* end if web_mode */

/*		printf("\nEnter target RA and Dec in deg (neg. RA ends loop): ");
		scanf("%lf %lf",&tra,&tdec); /* change to double so changed to %lf 8/17/05 DGK */
		/*printf("%f %f\n", tra, tdec);*/
/*		if(tra<0.) break; /* ends loop */

		
            /* convert tra and tdec to direction cosines */
            trar=(double)tra*dtr; /* tra in radians */
            tdecr=(double)tdec*dtr; /* tdec in radians */
            cosa=cos(trar)*cos(tdecr);
            cosb=sin(trar)*cos(tdecr);
            cosg=sin(tdecr);
		
            /* now do coor transformation get direction cosines in FPA coor*/
            lp=DCM11*cosa+DCM12*cosb+DCM13*cosg;
            mp=DCM21*cosa+DCM22*cosb+DCM23*cosg;
            np=DCM31*cosa+DCM32*cosb+DCM33*cosg;
		
            /* convert dir cosines to longitude and lat in FPA coor system */
            lat=asin(np)*rtd; /* transformed lat +Z' in deg */
            lng=atan2(mp,lp)*rtd; /* transformed long +Y' in deg */

            if ( web_mode ) {
                sprintf(buf,"FPA: lng=%f lat=%f  ",lng,lat);
                strcat(resultMsg, buf);
            } else {
                fprintf(stderr,"FPA: lng=%f lat=%f  ",lng,lat);
            }

            /* find which chn this falls onto */
            chn_i=floor(lat/1.430)+5;
            chn_j=floor(lng/1.430)+5;
            /*fprintf(stderr,"lat i=%d lng j=%d\n",chn_i,chn_j);*/
            if(chn_i<0 || chn_i>9 || chn_j<0 || chn_j>9) {
                if ( web_mode ) {
                    sprintf(buf,"Coordinate well out of the FOV ***\n");
                    strcat(resultMsg, buf);
                } else {
                    fprintf(stderr,"Coordinate well out of the FOV ***\n");
                }
	
            } else {
		
                chn_n=chn_num[chn_i][chn_j]; /* channel number */
                chip_n=(chn_n+1)/2-1;  /* chip number index, -1 since DCMc array index is 0-41 */

                /* can now transform to module coordinates Use direction cosine in FPA coor*/
                /* now do transformation to module chip coor*/
                lpm=DCM11c[chip_n]*lp+DCM12c[chip_n]*mp+DCM13c[chip_n]*np;
                mpm=DCM21c[chip_n]*lp+DCM22c[chip_n]*mp+DCM23c[chip_n]*np;
                npm=DCM31c[chip_n]*lp+DCM32c[chip_n]*mp+DCM33c[chip_n]*np;

                /* define chip coor as: rotation about the center of the module(field flattener lens) &
                   angular row and column from this center
                   then column 1100 is angle zero and decreases up and down with increasing angle
                   towards readout amp on each corner
                   and row 1024 starts after a gap of 39 pixels decreasing with increasing angle */
			
                latm=asin(npm);/* transformed lat +Z' to chip coor in radians */
                lngm=atan2(mpm,lpm)*rtd*3600.; /* transformed long +Y' to chip coor in arc sec */
                lngr=lngm*cos(latm); /* correct for cos effect going from spherical to rectangular coor 
                                        one deg of long at one deg of lat is smaller than one deg at zero lat
                                        by cos(lat) , amounts to 1/2 arc sec=1/8 pix */
                latm=latm*rtd*3600.; /* latm in arc sec */
		
                /* now convert to row and column */
                p_row=1024.0-lngr/plate_scale + chip_offset[chip_n][1];

                latp=latm/plate_scale - chip_offset[chip_n][2]; /* +/-latitude in pixels on chip */
                if(latp>=0.0)
                    p_coln=1100.0-latp;
                else
                    p_coln=1100.0+latp;
				
                /* get correct chn_n, since initial chn_n was a close guess */
                if(latp<0.0) /* then falls on top half of chip */
                    chn_n=(int)((chn_n+1)/2) *2;
                /* if +latp side of chip chn_n is even*/
                else
                    chn_n=(int)((chn_n-1)/2) *2+1;
                /*   if -latp side of chip chn_n is odd */		
			 
		
                if ( web_mode ) {
                    sprintf(buf, "chn=%2d row=%6.1f coln=%6.1f", chn_n,p_row,p_coln);
                    strcat(resultMsg, buf);
                } else {
                   /* printf("chip long=%9.5f lat=%9.5f chip=%2d ",lngr/3600.,latm/3600.,chip_n+1); 
                 		/* change lngm to lngr and latp to latm, moved line from just above if(web_mode) DGK 8/17/05 */
                  printf("chn=%2d row=%8.3f coln=%8.3f", chn_n,p_row,p_coln);/* change precision from %6.1f to %8.3f 8/17/05 DGK */
                }
		
                if(p_row<0. || p_coln<0. || p_row>1024. || p_coln>1100.) {

                    if ( web_mode ) {
                        sprintf(buf, "   ***\n");
                        strcat(resultMsg, buf);
                    } else {
                        printf("   ***\n");
                    }
                } else {
                    if ( web_mode ) {
                        strcat(resultMsg,"\n");
                    } else {
                        printf("\n");
                    }
                }
            }              
            if ( web_mode ) return resultMsg; /* break out of the loop if we are not in interactive mode */
	}	
	fprintf(stderr,"Finished\n");

		
	return 0;
}	

/**
 * Initialize the param struct with zeros.
 */		
void initParams(t_requestParams *params) {
    params->raDecType[0] = '\0';
    params->ra[0] = '\0';
    params->dec[0] = '\0';
    params->raHours[0] = '\0';
    params->raMinutes[0] = '\0';
    params->raSeconds[0] = '\0';
    params->decDegrees[0] = '\0';
    params->decMinutes[0] = '\0';
    params->decSeconds[0] = '\0';
    params->season[0] = '\0';
}
		

int main(int argc, char **argv) {
    t_requestParams params;
    char *result;

    initParams(&params);

    if (getOptions(argc, argv, &params) == -1) {
        exit(0);
    }

    result = doTranslation(&params);

    printf(result);
}
