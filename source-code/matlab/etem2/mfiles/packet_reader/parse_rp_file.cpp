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

#include <iostream.h>
#define TIMESTAMP_SIZE 5
#define PHOTOMETER_CONFIG_ID_SIZE 8
#define RP_HEADER_SIZE (TIMESTAMP_SIZE + PHOTOMETER_CONFIG_ID_SIZE)
#define PIXEL_DATA_SIZE 4
#define PHOTOMETER_CONFIG_ID_LENGTH 8

int main(int argc, char* const* argv) {
        /* parse command line */
    char ch;
	char *filename;

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

    unsigned char *rpHeaderBytes = new unsigned char[RP_HEADER_SIZE];
    unsigned char *pixelBytes = new unsigned char[PIXEL_DATA_SIZE];
	unsigned long long int timeStamp;
	unsigned long long int timeStampSeconds;
	unsigned long long int timeStampMilliSeconds;
	unsigned char PhotometerConfigurationID[PHOTOMETER_CONFIG_ID_LENGTH];
	double timeStampFloat;
	int nPixels = 0;
	int working = 1;

	while (working) {
        size_t nRead = fread(rpHeaderBytes, sizeof(unsigned char), RP_HEADER_SIZE, fid);
        if (nRead != RP_HEADER_SIZE) {
            cout << "nRead = " << nRead << " reached the end of the file (I hope)" << endl;
			working = 0;
        } else {
			timeStamp = (( unsigned long long int) rpHeaderBytes[0] << 32) | ((unsigned long long int) rpHeaderBytes[1] << 24) 
					| (( unsigned long long int) rpHeaderBytes[2] << 16) | ((unsigned long long int) rpHeaderBytes[3] << 8) 
					| (unsigned long long int ) rpHeaderBytes[4];
			timeStampSeconds = (( unsigned long long int) rpHeaderBytes[0] << 24) | ((unsigned long long int) rpHeaderBytes[1] << 16) 
					| (( unsigned long long int) rpHeaderBytes[2] << 8) | ((unsigned long long int) rpHeaderBytes[3]);
			timeStampMilliSeconds = (unsigned long long int ) rpHeaderBytes[4];
			timeStampFloat = (double)timeStampSeconds + 0.004096*(double)timeStampMilliSeconds;
			
			for (int i=0; i<PHOTOMETER_CONFIG_ID_SIZE; i++) 
				PhotometerConfigurationID[i] = rpHeaderBytes[TIMESTAMP_SIZE + i];
				
			cout << "timeStamp = " << timeStamp << " = " << timeStampFloat << endl;
			cout << "seconds = " << timeStampSeconds << ", milliseconds = " << timeStampMilliSeconds << " = "  << 0.004096*timeStampMilliSeconds << endl;

			cout << "photometer config ID: " ;
			for (int i=0; i<PHOTOMETER_CONFIG_ID_LENGTH; i++) 
				cout << (unsigned int) PhotometerConfigurationID[i] << ", ";
			cout << endl;
			
			while (working) {
        		size_t nRead = fread(pixelBytes, sizeof(unsigned char), PIXEL_DATA_SIZE, fid);
        		if (nRead != PIXEL_DATA_SIZE) {
            		cout << "nRead = " << nRead << " reached the end of the file (I hope)" << endl;
					working = 0;
				} else {
					nPixels++;
				}
			}
		}
		cout << "# of pixels: " << nPixels << endl;
		fclose(fid);
	}
}

