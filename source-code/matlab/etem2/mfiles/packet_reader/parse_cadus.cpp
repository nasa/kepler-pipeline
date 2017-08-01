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
#include <math.h>

#define CADU_LENGTH 1279
#define SYNC_MARKER 0X1ACFFC1D

int main(int argc, char* const* argv) {
    unsigned char *caduBytes = new unsigned char[CADU_LENGTH];
    char *filename;
    char ch;
    while ((ch = getopt(argc, argv, "f:")) != -1) {
        switch (ch) {
        	cout << "ch = " << ch << endl;
			case 'f':
        			filename = optarg;
        			break;
			case 'h':
			default:
        			cout << "parse_cadus -f <filename>" << endl;
        			return (0);
        			break;
        }
    }
	
    FILE *fid = fopen(filename, "r");
	int working = 1;
	int caduCount = 0;
	unsigned long int syncMarker = 0;
	while (working) {
        size_t nRead = fread(caduBytes, sizeof(unsigned char), CADU_LENGTH, fid);
#if 0
	// corrupt a sync word to test error id
	if (caduCount == 47000)
		caduBytes[2] = caduBytes[3] + 10;
#endif
        if (nRead != CADU_LENGTH) {
            cout << "nRead = " << nRead << " reached the end of the file (I hope)" << endl;
			working = 0;
        } else {
			*(((unsigned char*)&syncMarker)) = caduBytes[3];
			*(((unsigned char*)&syncMarker)+1) = caduBytes[2];
			*(((unsigned char*)&syncMarker)+2) = caduBytes[1];
			*(((unsigned char*)&syncMarker)+3) = caduBytes[0];
			if (syncMarker != SYNC_MARKER) {
				cout.flags(ios::hex);
				cout << "sync marker " << syncMarker;
				cout.flags(ios::dec);
				cout  << " is wrong, cadu #" << caduCount << endl;
				working = 0;
			} else {
				caduCount++;
			}
		}
	}
	cout << "total # of cadus processed = " << caduCount << endl;
	fclose(fid);
}
