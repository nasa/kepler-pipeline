/*
 *  dmc_file_maker.cpp
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

#include <stdio.h>
#include <iostream.h>
#include <unistd.h>

#include "dmc_file_maker.h"
#include "ccsds_header.h"

dmc_file_maker::dmc_file_maker(void) {
	fileIsOpen = false;
	outputFid = NULL;
	dataSetType = NOT_DEFINED;
	timeIncrement = 0;
	lastTimeIncrement = 0;
	
	seconds = 0;
	minutes = 0;
	hours = 0;
	days = 120; // sometime in late spring
	year = 2009;
}

// The DMC wants packets of fixed length = CCSDS_PACKET_LENGTH so create data of this 
// length and fill them with whatever data is available.

// copy_data creates an array of length CCSDS_PACKET_LENGTH, fills it with the available data
// and writes it to the output file
void dmc_file_maker::copy_data(ccsds_header& header, FILE *inputFid, char *outputPath) {
	unsigned char *bytesToWrite = new unsigned char[CCSDS_PACKET_LENGTH];
	// initialize bytesToWrite to all 0
	for (int i=0; i<CCSDS_PACKET_LENGTH; i++)
		bytesToWrite[i] = 0;
	
	// if header.sequencePacketCount == 0 this is the beginning of a data set
	if (!header.sequencePacketCount) {
		// if a file is already open, close it
		if (fileIsOpen)
			close_file();	
		// open a new file
		open_file(header, outputPath);
	}
	
	// read the bytes to copy
	// inputFid points to the beginning of a ccsds packet
	// we want the ccsds header and the payload - this number of bytes is given in 
	// header.packetLength
	int nBytesToRead = header.packetLength;
//	header.print_full("about to read:");
	int nBytes = fread(bytesToWrite, sizeof(unsigned char), nBytesToRead, inputFid);
	if (nBytes != nBytesToRead) {
		cout << "didn't read enough bytes in the input ccsds packet" << endl;
	}
	// rewind to point back at the beginning of the ccsds file
	fseek(inputFid, -nBytesToRead, SEEK_CUR);
	
	// write the bytes to the curently open file
	nBytes = fwrite(bytesToWrite, sizeof(unsigned char), CCSDS_PACKET_LENGTH, outputFid);
}

void dmc_file_maker::open_file(ccsds_header& header, char *outputPath) {
	char *extension = new char(3);
	
	switch(header.applicationProcessID) {
		// set the parameters appropriate to this data set
		case LONG_CADENCE_APID:
			switch(header.packetID) {
				case BASELINE_PKTID:
					dataSetType = LONG_BASELINE;
					extension = "lcb";
					timeIncrement = 0; // minutes zero because this is always followed by a short cadence at the same time
					break;
				case RESIDUAL_PKTID:
					dataSetType = LONG_BASELINE_RESIDUAL;
					extension = "lcr";
					timeIncrement = 0; // minutes, zero because this follows a baseline for the same time
					break;
				case ENCODED_PKTID:
					dataSetType = LONG_RESIDUAL;
					extension = "lcs";
					timeIncrement = 0; // minutes zero because this is always followed by a short cadence at the same time
					break;
				default: 
					cout << "dmc_file_maker::open_file: bad packetID in long ccsds header" << endl;
					return;
					break;
			}
			break;
			
		case SHORT_CADENCE_APID:
			switch(header.packetID) {
				case BASELINE_PKTID:
					dataSetType = SHORT_BASELINE;
					extension = "scb";
					timeIncrement = 1; // minutes
					break;
				case RESIDUAL_PKTID:
					dataSetType = SHORT_BASELINE_RESIDUAL;
					extension = "scr";
					timeIncrement = 0; // minutes, zero because this follows a baseline for the same time
					break;
				case ENCODED_PKTID:
					dataSetType = SHORT_RESIDUAL;
					extension = "scs";
					timeIncrement = 1; // minutes
					break;
				default: 
					cout << "dmc_file_maker::open_file: bad packetID in short ccsds header" << endl;
					return;
					break;
			}
			break;
			
			default: 
				cout << "dmc_file_maker::open_file: bad applicationProcessID in ccsds header" << endl;
				break;
	}
	
	// now compute the time stamp using the time increment from the last data sets
	minutes = minutes + lastTimeIncrement;
	while (minutes >= 60) {
		minutes -= 60;
		hours += 1;
	}
	while (hours >= 24) {
		hours -= 24;
		days += 1;
	}
	while (days >= 365) {
		days -= 365;
		year += 1;
	}
	lastTimeIncrement = timeIncrement;
	
	// construct the filename
	char *filename = new char[200];
	sprintf(filename, "%s/kplr%04d%03d%02d%02d%02da.%s", outputPath, year, days, hours, minutes, seconds, extension);
	cout << "output filename = " << filename << endl;
	
	outputFid = fopen(filename, "w");
	fileIsOpen = 1;
}

void dmc_file_maker::close_file(void) {
	if (outputFid != NULL) {
		fclose(outputFid);
		outputFid = NULL;
		fileIsOpen = 0;
	}
}




