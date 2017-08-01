/*
 *   science_data_header.cpp
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

#include <iostream.h>
#include "science_data_header.h"

science_data_header::science_data_header(void) {

	for (int i=0; i<PHOTOMETER_CONFIG_ID_LENGTH; i++) 
		PhotometerConfigurationID[i] = 0;
	firstPixelID = 0;
	numPixels = 0;
}


void science_data_header::set(unsigned char *headerBytes) {
	science_data_header(); 

	for (int i=0; i<PHOTOMETER_CONFIG_ID_LENGTH; i++) 
		PhotometerConfigurationID[i] = headerBytes[i];
	firstPixelID = (( unsigned long int) headerBytes[FIRST_PIXEL_ID_OFFSET] << 24) 
			| (( unsigned long int) headerBytes[FIRST_PIXEL_ID_OFFSET+1] << 16) 
			| (( unsigned long int) headerBytes[FIRST_PIXEL_ID_OFFSET+2] << 8) 
			| (unsigned long int ) headerBytes[FIRST_PIXEL_ID_OFFSET+3];
	numPixels = (( unsigned long int) headerBytes[NUM_PIXELS_OFFSET] << 24) 
			| (( unsigned long int) headerBytes[NUM_PIXELS_OFFSET+1] << 16) 
			| (( unsigned long int) headerBytes[NUM_PIXELS_OFFSET+2] << 8) 
			| (unsigned long int ) headerBytes[NUM_PIXELS_OFFSET+3];
	
	for (int i=0; i<SCIENCE_DATA_HEADER_SIZE; i++)
		_headerBytes[i] = headerBytes[i];
}


void science_data_header::print(char *hdr) {
	cout << hdr;
	cout << "Photometer configuration ID = " << endl;
	cout << "header bytes: ";
	cout.flags(ios::hex);
	for (int i=0; i<SCIENCE_DATA_HEADER_SIZE; i++)
		cout << ((short unsigned int) _headerBytes[i]) << " ";
	cout << endl;
	cout.flags(ios::dec);
	for (int i=0; i<PHOTOMETER_CONFIG_ID_LENGTH; i++) 
		cout << (unsigned int) PhotometerConfigurationID[i] << ", ";
	cout << "firstPixelID = " << firstPixelID;
	cout << ", numPixels = " << numPixels << endl;
}

