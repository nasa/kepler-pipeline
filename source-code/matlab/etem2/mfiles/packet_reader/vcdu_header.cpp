/*
 *  vcdu_header.cpp
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
#include "vcdu_header.h"

vcdu_header::vcdu_header(void) {

	versionNumber = 0;
	spacecraftID = 0;
	virtualChannelID = 0;
	vcduCounter = 0;
	replayFlag = 0;
	firstHeaderPointer = 0;
	for (int i=0; i<VCDU_HEADER_SIZE; i++)
		_headerBytes[i] = 0;
}


void vcdu_header::set(unsigned char *headerBytes) {
	vcdu_header(); 
	versionNumber = (headerBytes[0] & 0XC0) >> 6;
	spacecraftID = (headerBytes[0] & 0X3F) << 2 | (headerBytes[1] & 0XC0) >> 6;
	virtualChannelID = headerBytes[1] & 0X3F;
	vcduCounter = (( unsigned long int) headerBytes[2] << 16) | (( unsigned long int) headerBytes[3] << 8) 
			| (unsigned long int ) headerBytes[4];
	replayFlag = (headerBytes[5] & 0XA0) >> 7;
	firstHeaderPointer = ((unsigned short int ) (headerBytes[6] & 0X07)) << 8 | (unsigned short int ) headerBytes[7];
		
	for (int i=0; i<VCDU_HEADER_SIZE; i++)
		_headerBytes[i] = headerBytes[i];
}

void vcdu_header::print_full(char *hdr) {
	
	cout << hdr << endl;
	cout << "header bytes: ";
	cout.flags(ios::hex);
	for (int i=0; i<VCDU_HEADER_SIZE; i++)
		cout << ((short unsigned int) _headerBytes[i]) << " ";
	cout << endl;
	cout.flags(ios::dec);
	cout << "versionNumber = " << (unsigned int) versionNumber << endl;
	cout << "spacecraftID = " << (unsigned int) spacecraftID << endl;
	cout << "virtualChannelID = " << (unsigned int) virtualChannelID << endl;
	cout << "vcduCounter = " << vcduCounter << endl;
	cout << "replayFlag = " << (unsigned int) replayFlag << endl;
	cout << "firstHeaderPointer = " << firstHeaderPointer << endl;
}

void vcdu_header::print(char *hdr) {
	cout << hdr << endl;
	cout << "vcduCounter = " << vcduCounter;
	cout << ", firstHeaderPointer = " << firstHeaderPointer << endl;
}

