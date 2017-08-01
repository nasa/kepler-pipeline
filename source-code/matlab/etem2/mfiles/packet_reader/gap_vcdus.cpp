/*
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

#include <stdio.h>
#include <iostream.h>
#include <unistd.h>
#include <string.h>

#include "vcdu_header.h"
#include "file_utilities.h"

#define MAX_GAPS 20 

static unsigned long int gapStart[MAX_GAPS];
static unsigned long int gapEnd[MAX_GAPS];
static int nGaps = 0;

int not_a_gap(int vcduCount);

int not_a_gap(int vcduCount) {
	for (int i=0; i<nGaps; i++) {
		if (vcduCount >= gapStart[i] && vcduCount <= gapEnd[i])
			return 0;
	}
	return 1;
}

int main(int argc, char* const* argv) {
        /* parse command line */
        char ch;
	char *filename;
	char *pathname;
	char *gapFilename;

        while ((ch = getopt(argc, argv, "f:p:g:")) != -1) {
                switch (ch) {
                cout << "ch = " << ch << endl;
                        case 'g':
                                gapFilename = optarg;
                                break;
                        case 'f':
                                filename = optarg;
                                break;
                        case 'p':
                                pathname = optarg;
                                break;
                        default:
				cout << "break_vcdus -p <path> -f <input file name>" << endl;
                                return (0);
                                break;
                }
        }

	char inputname[2000];
	char outputname[2000];

	strcpy(inputname, pathname);
	strcat(inputname, "/");
	strcat(inputname, filename);

	strcpy(outputname, pathname);
	strcat(outputname, "/");
	strcat(outputname, filename);
	strcat(outputname, "_gapped");
    cout << "reading " << inputname << endl;
    cout << "writing " << outputname << endl;


    FILE *fid = fopen(inputname, "r");
	if (fid == 0) {
		cout << "could not open " << inputname << endl;
		return (-1);
	}	
    FILE *gapFid = fopen(gapFilename, "r");
	if (gapFid == 0) {
		cout << "could not open " << gapFilename << endl;
		return (-1);
	}	
    FILE *outFid = fopen(outputname, "w");
	if (outFid == 0) {
		cout << "could not open " << outputname << endl;
		return (-1);
	}	
	
	// read gaps
	int gapCount = 0;
	int working = 1;
	while (working) {
		int scanStatus = fscanf(gapFid, "%d, %d\n", &gapStart[gapCount], &gapEnd[gapCount]);
		if (scanStatus == EOF) {
			cout << "reached end of file" << endl;
			working = 0;
		} else {
			cout << "gap #" << gapCount << " start:" << gapStart[gapCount] << " end:" << gapEnd[gapCount] << endl;
			gapCount += 1;
		}
	}
	nGaps = gapCount;
	cout << "nGaps = " << nGaps << endl;

	working = 1;

   vcdu_header vcduHeader;
    unsigned char *vcduBytes = new unsigned char[VCDU_PACKET_LENGTH];
    unsigned char *vcduHeaderBytes = new unsigned char[VCDU_HEADER_SIZE];
	unsigned long long int bytesRead = 0;
	unsigned int part = 1;
	unsigned long int vcduCount = 0;
	bool inAGap = false;
 
	while (working) {
        size_t nRead = fread(vcduBytes, sizeof(unsigned char), VCDU_PACKET_LENGTH, fid);
        if (nRead != VCDU_PACKET_LENGTH) {
            cout << "nRead = " << nRead << " reached the end of the file (I hope)" << endl;
			working = 0;
        } else {
			for (int i=0; i<VCDU_HEADER_SIZE; i++)
				vcduHeaderBytes[i] = vcduBytes[i];
        	vcduHeader.set(vcduHeaderBytes);
				
//			if (not_a_gap(vcduHeader.vcduCounter)) {
			if (not_a_gap(vcduCount)) {
				if (inAGap) {
					cout << "ending gap vcdu # " << vcduHeader.vcduCounter - 1 << endl;
					cout << "ending gap counter # " << vcduCount - 1 << endl;
					inAGap = false;
				}
				fwrite(vcduBytes, sizeof(unsigned char), VCDU_PACKET_LENGTH, outFid);
			} else {
				if (!inAGap) {
					cout << "starting gap vcdu # " << vcduHeader.vcduCounter << endl;
					cout << "starting gap counter # " << vcduCount << endl;
					inAGap = true;
				}
			}
			vcduCount++;
		}
	}
	fclose(fid);
	fclose(outFid);	
}

