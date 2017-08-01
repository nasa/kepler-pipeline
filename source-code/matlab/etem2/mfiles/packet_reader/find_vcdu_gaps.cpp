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

int main(int argc, char* const* argv) {
        /* parse command line */
        char ch;
	char *filename;
	char *pathname;
	char *gapFilename;

        while ((ch = getopt(argc, argv, "f:")) != -1) {
                switch (ch) {
                cout << "ch = " << ch << endl;
                        case 'f':
                                filename = optarg;
                                break;
                        default:
				cout << "find_vcdu_gaps -f <input file name>" << endl;
                                return (0);
                                break;
                }
        }

    cout << "reading " << filename << endl;


    FILE *fid = fopen(filename, "r");
	if (fid == 0) {
		cout << "could not open " << filename << endl;
		return (-1);
	}	
 	

	int working = 1;

    unsigned char *vcduBytes = new unsigned char[VCDU_PACKET_LENGTH];
    unsigned char *vcduHeaderBytes = new unsigned char[VCDU_HEADER_SIZE];
	unsigned long long int bytesRead = 0;
	unsigned int part = 1;
	unsigned long int lastVcduCount = -1;
    vcdu_header vcduHeader;

	while (working) {
        size_t nRead = fread_and_rewind(vcduHeaderBytes, sizeof(unsigned char), VCDU_HEADER_SIZE, fid, 0);
        if (nRead != VCDU_HEADER_SIZE) {
            cout << "nRead = " << nRead << " reached the end of the file (I hope)" << endl;
			working = 0;
        } else {
        	// set the header object
        	vcduHeader.set(vcduHeaderBytes);

			if (lastVcduCount == -1) {
				cout << "first vcdu counter = " << vcduHeader.vcduCounter << endl;
			} else if (lastVcduCount != vcduHeader.vcduCounter - 1) {
				cout << "gap starting at vcdu " << lastVcduCount + 1 << " ending at " << vcduHeader.vcduCounter - 1 << endl;
			}
			lastVcduCount = vcduHeader.vcduCounter;

			fseek(fid, VCDU_PACKET_LENGTH, SEEK_CUR);
		}
	}
	cout << "last vcdu counter = " << lastVcduCount << endl;
	fclose(fid);
}

