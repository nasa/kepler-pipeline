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

#define CADU_LENGTH 1279
#define MAX_FILE_SIZE ((unsigned long long int)(4)*1024*1024*1024 + (unsigned long long int)(100)*1024*1024) 

int main(int argc, char* const* argv) {
        /* parse command line */
        char ch;
	char *filename;
	char *pathname;

        while ((ch = getopt(argc, argv, "f:p:")) != -1) {
                switch (ch) {
                cout << "ch = " << ch << endl;
                        case 'f':
                                filename = optarg;
                                break;
                        case 'p':
                                pathname = optarg;
                                break;
                        default:
				cout << "break_cadus -p <path> -f <input file name>" << endl;
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
	strcat(outputname, "_part_01");
        cout << "reading " << inputname << endl;
        cout << "writing " << outputname << endl;


        FILE *fid = fopen(inputname, "r");
	if (fid == 0) {
		cout << "could not open " << inputname << endl;
		return (-1);
	}	
        FILE *outFid = fopen(outputname, "w");
	if (outFid == 0) {
		cout << "could not open " << outputname << endl;
		return (-1);
	}	

	int working = 1;

        unsigned char *caduBytes = new unsigned char[CADU_LENGTH];
	unsigned long long int bytesRead = 0;
	unsigned int part = 1;

	while (working) {
                size_t nRead = fread(caduBytes, sizeof(unsigned char), CADU_LENGTH, fid);
                if (nRead != CADU_LENGTH) {
                        cout << "nRead = " << nRead << " reached the end of the file (I hope)" << endl;
			working = 0;
                } else {

		fwrite(caduBytes, sizeof(unsigned char), CADU_LENGTH, outFid);

		bytesRead += nRead;
		if (bytesRead > MAX_FILE_SIZE) {
			bytesRead = 0;
			fclose(outFid);
			part++;
			char partNum[10];
			sprintf(partNum, "%02d", part);
		        strcpy(outputname, pathname);
		        strcat(outputname, "/");
		        strcat(outputname, filename);
		        strcat(outputname, "_part_");
		        strcat(outputname, partNum);
			outFid = fopen(outputname, "w");
		        cout << "writing " << outputname << endl;
		}
		}
	}
	fclose(fid);
	fclose(outFid);	
}

