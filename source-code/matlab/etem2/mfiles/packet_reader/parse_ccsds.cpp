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

#include "ccsds_header.h"
#include "dmc_file_maker.h"
#include "science_data_header.h"

static void print_usage(void);

static void print_usage(void) {
	cout << "usage: parse_ccsds [options] <filename>" << endl;
	cout << "options:" << endl;
	cout << "-f <filename>" << endl;
	cout << "-e : do not stop on bad packets (default: stop)" << endl;
	cout << "-a : print all packets (default: do not print all)" << endl;
	cout << "-c <nPackets>: number of packets read (default: 1e9)" << endl;
	cout << "-o <path>: path to output files for DMC (default: do not output files)" << endl;
	cout << "-s : turn on silent mode so there is no ouput unless there is an error (default off)" << endl;
	cout << "-v : print full headers (default: off)" << endl;
}

int main(int argc, char* const* argv) {
	unsigned char *headerBytes = new unsigned char[CCSDS_HEADER_SIZE];
	unsigned char *scienceHeaderBytes = new unsigned char[SCIENCE_DATA_HEADER_SIZE];
	int stopOnError = 1;
	int allPackets = 0;
	int verbose = 0;
	int silent = 0;
	unsigned long int maxCount = (unsigned long int) 1e9;
	char *filename;
	char *outputPath = NULL;
	int returnStatus = 0;
	unsigned int numLongCadencePixels = 0;
	unsigned int numShortCadencePixels = 0;
	unsigned int numFfiCadencePixels = 0;
	unsigned int pixelCounter = 0;

	if (argc < 2) {
		print_usage();
		return (-1);
	}
	
	/* parse command line */
	char ch;
	while ((ch = getopt(argc, argv, "eac:vf:o:s")) != -1) {
		switch (ch) {
		cout << "ch = " << ch << endl;
			case 'e':
				stopOnError = 0;
				break;
			case 'c':
				sscanf(optarg, "%d", &maxCount);
				break;
			case 'a':
				allPackets = 1;
				break;
			case 'v':
				verbose = 1;
				break;
			case 'f':
				filename = optarg;
				break;
			case 'o':
				outputPath = optarg;
				break;
			case 's':
				silent = 1;
				break;
			case 'h':
			default:
				print_usage();
				return (0);
				break;
		}
	}
	if (!silent)
		cout << "reading " << filename << endl;

	FILE *fid = fopen(filename, "r");
		
	ccsds_header header;
	ccsds_header nextHeader;
	dmc_file_maker dmcMaker;
	science_data_header scienceHeader;
	bool atDataSetStart = true;
	bool atDataSetEnd = false;
	bool lastPacket = false;
	
	for (int count=0; count < maxCount; count++) {
		size_t nRead = fread(headerBytes, sizeof(unsigned char), CCSDS_HEADER_SIZE, fid);
		if (nRead != CCSDS_HEADER_SIZE) {
			if (!silent)
				cout << "nRead = " << nRead << " reached the end of the file (I hope)" << endl;
			break;
		}
		int status = fseek(fid, -CCSDS_HEADER_SIZE, SEEK_CUR);
					
		header.set(headerBytes);
		
		// it's the start of a ccsds header, so go look for the science header
		status = fseek(fid, CCSDS_HEADER_SIZE, SEEK_CUR);
		nRead = fread(scienceHeaderBytes, sizeof(unsigned char), SCIENCE_DATA_HEADER_SIZE, fid);
		if (nRead != SCIENCE_DATA_HEADER_SIZE) {
			if (!silent)
				cout << "science data header nRead = " << nRead << " reached the end of the file (I hope)" << endl;
			break;
		}
		status = fseek(fid, -(CCSDS_HEADER_SIZE + SCIENCE_DATA_HEADER_SIZE), SEEK_CUR);
		scienceHeader.set(scienceHeaderBytes);
		
		fseek(fid, header.packetLength, SEEK_CUR);
		// look for the next packet's header
		nRead = fread(headerBytes, sizeof(unsigned char), CCSDS_HEADER_SIZE, fid);
		status = fseek(fid, -CCSDS_HEADER_SIZE, SEEK_CUR);
		if (nRead == CCSDS_HEADER_SIZE)
			nextHeader.set(headerBytes);
		else
			lastPacket = true;
			
		// if wer're at the start of a packet initialize the pixel counter
		if (atDataSetStart) { 
			pixelCounter = 0;
		}
		pixelCounter += scienceHeader.numPixels;
		
		// if this is the last packet in a data set process the number of pixels counted
//		if (header.packetLength != CCSDS_PACKET_LENGTH) { 
//		if (header.packet_type_changed()) { 
		if (header.packet_timestamp_changed(nextHeader) || header.packet_type_changed(nextHeader) || lastPacket) { 
			atDataSetEnd = true;
			switch (header.applicationProcessID) {
				case LONG_CADENCE_APID:
					if (numLongCadencePixels == 0) 
						numLongCadencePixels = pixelCounter;
					else if (numLongCadencePixels != pixelCounter) {
						cout << "!!!!!!!!!!!!!!!!!!!!! number of long pixels has changed: numLongCadencePixels = " 
							<< numLongCadencePixels << ", pixelCounter = " << pixelCounter << endl;
						return (false);
					}
					break;
				case SHORT_CADENCE_APID:
					if (numShortCadencePixels == 0) 
						numShortCadencePixels = pixelCounter;
					else if (numShortCadencePixels != pixelCounter) {
						cout << "!!!!!!!!!!!!!!!!!!!!! number of short pixels has changed: numShortCadencePixels = " 
							<< numShortCadencePixels << ", pixelCounter = " << pixelCounter << endl;
						return (false);
					}
					break;
				case FFI_CADENCE_APID:
					if (numFfiCadencePixels == 0) 
						numFfiCadencePixels = pixelCounter;
					else if (numFfiCadencePixels != pixelCounter) {
						cout << "!!!!!!!!!!!!!!!!!!!!! number of FFI pixels has changed: numFfiCadencePixels = " 
							<< numFfiCadencePixels << ", pixelCounter = " << pixelCounter << endl;
						return (false);
					}
					break;

				default:
					cout << "pixel counter: applicationProcessID = " << header.applicationProcessID << " is invalid" << endl;
					return (false);
					break;
			}	
		} else
			atDataSetEnd = false;	
		
		if (!silent)
			header.count_packets();
			
//		if ((atDataSetStart || header.packetLength != CCSDS_PACKET_LENGTH || allPackets) && !silent) { 
		if ((atDataSetStart || atDataSetEnd || allPackets) && !silent) { 
			char *hdr = new char[200];
			sprintf(hdr, "\n>>>>>>>>> packet count = %d:", count);
			if (verbose)
				header.print_full(hdr);
			else
				header.print(hdr);

			scienceHeader.print();
		}
		
		if (outputPath != NULL)
			dmcMaker.copy_data(header, fid, outputPath);
			
//		if (header.packetLength != CCSDS_PACKET_LENGTH && !silent) { 
		if (atDataSetEnd && !silent) { 
			cout << "=======" << endl;
			header.count_data_sets();
		}
		if (stopOnError)
			if (!header.validate()) {
				cout << "count " << count << ": something's wrong, exiting..." << endl;
				returnStatus = -1;
				break;
			}
//		if (header.packetLength != CCSDS_PACKET_LENGTH) {
		if (atDataSetEnd) {
			atDataSetStart = true;
			atDataSetEnd = false;
		} else {
			atDataSetStart = false;
		}
		
	}
	
	fclose(fid);
	dmcMaker.close_file();
	
	if (!silent) {
		header.print_counts();
		cout << "# of long pixels: " << numLongCadencePixels << endl;
		cout << "# of short pixels: " << numShortCadencePixels << endl;
		cout << "# of ffi pixels: " << numFfiCadencePixels << endl;
	}

	return (returnStatus);
}

