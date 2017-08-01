/*
 *   ccsds_header.cpp
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
#include "ccsds_header.h"

ccsds_header::ccsds_header(void) {

	versionNumber = 0;
	type = 0;
	headerFlag = 0;
	applicationProcessID = 0;
	sequenceFlags = 0;
	sequencePacketCount = 0;
	packetLength = 0;
	timeStamp = 0;
	packetID = 0;
	destinationApID = 0;
	packetDestinationID = 0;
	firstTime = 0;
	
	longCadenceBaselineCount = 0;
	longCadenceResidualBaselineCount = 0;
	longCadenceResidualCount = 0;
	shortCadenceBaselineCount = 0;
	shortCadenceResidualBaselineCount = 0;
	shortCadenceResidualCount = 0;
	ffiCount = 0;
	
	longCadenceBaselinePacketCount = 0;
	longCadenceResidualBaselinePacketCount = 0;
	longCadenceResidualPacketCount = 0;
	shortCadenceBaselinePacketCount = 0;
	shortCadenceResidualBaselinePacketCount = 0;
	shortCadenceResidualPacketCount = 0;
	ffiPacketCount = 0;
	
	scEncodedNumber = 0;
	
	currentApProcId = 0;
	currentPacketId = 0;
	currentTimeStamp = 0;
	
}

char *get_apID_string(int apID);
char *get_packetID_string(int apID);

char *get_apID_string(int apID) {
	if (apID >= 40 && apID <= 42) {
		char *idString[] = { "long cadence", "short cadence", "FFI" };
		return (idString[apID - 40]);
	}
	return ("bad apID");
}

char *get_packetID_string(int apID, int packetID) {
	if (apID == 40 || apID == 41) {
		char *idString[] = { "baseline", "residual baseline", "encoded", "raw", "requantized" };
		if (packetID >= 100 && packetID <= 104)
			return (idString[packetID - 100]);
		else
			return ("bad packetID");
	} else if (apID == 42) {
		char *retStr = new char[200];
		if (packetID >= 100 && packetID <= 124) {
			sprintf(retStr, "module %d", packetID - 100);
			return (retStr);
		} else
			return ("bad packetID");
	}
	return ("bad apID");
}


void ccsds_header::set(unsigned char *headerBytes) {
	ccsds_header(); 
	versionNumber = headerBytes[0] >> 5;
	type = (headerBytes[0] >> 4) & 0X01;
	headerFlag = (headerBytes[0] >> 3) & 0X01;
	applicationProcessID = ((unsigned short int ) (headerBytes[0] & 0X07)) << 8 | (unsigned short int ) headerBytes[1];
	sequenceFlags = headerBytes[2] >> 6;
	sequencePacketCount = ((unsigned short int ) (headerBytes[2] & 0X3F)) << 8 | (unsigned short int ) headerBytes[3];
	packetLength = (((unsigned short int ) headerBytes[4] << 8) | (unsigned short int) headerBytes[5]) + PRIMARY_HEADER_SIZE;
	timeStamp = (( unsigned long long int) headerBytes[6] << 32) | (( unsigned long long int) headerBytes[7] << 24) 
			| (( unsigned long long int) headerBytes[8] << 16) | (( unsigned long long int) headerBytes[9] << 8) 
			| (unsigned long long int ) headerBytes[10];
	timeStampSeconds = (( unsigned long long int) headerBytes[6] << 24) | ((unsigned long long int) headerBytes[7] << 16) 
			| (( unsigned long long int) headerBytes[8] << 8) | (( unsigned long long int) headerBytes[9]);
	timeStampMilliSeconds = (unsigned long long int ) headerBytes[10];
	timeStampFloat = (double)timeStampSeconds + 0.004096*(double)timeStampMilliSeconds;
	if (firstTime == 0)
		firstTime = timeStampFloat;
	packetID = headerBytes[11];
	destinationApID = headerBytes[12];
	packetDestinationID = headerBytes[13];
	
	for (int i=0; i<CCSDS_HEADER_SIZE; i++)
		_headerBytes[i] = headerBytes[i];

}

bool ccsds_header::packet_type_changed(ccsds_header& newHeader) {
	if (newHeader.applicationProcessID != applicationProcessID 
		|| newHeader.packetID != packetID) { // if they've changed
//		cout << "packet type changed" << endl;
		return (true);
	} else {
		return (false);
	}
}

bool ccsds_header::packet_timestamp_changed(ccsds_header& newHeader) {
	if (newHeader.timeStamp != timeStamp) { // if they've changed
//		cout << "timeStamp changed" << endl;
		return (true);
	} else {
		return (false);
	}
}

void ccsds_header::print_full(char *hdr) {
	
	cout << hdr << endl;
	cout << "header bytes: ";
	cout.flags(ios::hex);
	for (int i=0; i<CCSDS_HEADER_SIZE; i++)
		cout << ((short unsigned int) _headerBytes[i]) << " ";
	cout << endl;
	cout.flags(ios::dec);
	cout << get_apID_string(applicationProcessID) << " " << get_packetID_string(applicationProcessID, packetID) << endl;
	cout << "versionNumber = " << (unsigned int) versionNumber << endl;
	cout << "type = " << (unsigned int) type << endl;
	cout << "headerFlag = " << (unsigned int) headerFlag << endl;
	cout << "applicationProcessID = " << applicationProcessID << endl;
	cout << "sequenceFlags = " << (unsigned int) sequenceFlags << endl;
	cout << "sequencePacketCount = " << sequencePacketCount << endl;
	cout << "packetLength = " << packetLength << endl;
	cout << "timeStamp = " << timeStamp << " = " << timeStampFloat - firstTime << endl;
	cout << "packetID = " << (unsigned int) packetID << endl;
	cout << "destinationApID = " << (unsigned int) destinationApID << endl;
	cout << "packetDestinationID = " << (unsigned int) packetDestinationID << endl;
}

void ccsds_header::print(char *hdr) {
	cout << hdr << endl;
	cout << get_apID_string(applicationProcessID) << " " << get_packetID_string(applicationProcessID, packetID);
	cout << ", applicationProcessID = " << (unsigned int) applicationProcessID << ", packetID = " << (unsigned int) packetID << endl;
	cout << "sequencePacketCount = " << sequencePacketCount;
	cout << ", packetLength = " << packetLength << endl;
	cout.precision(17);
	cout << "timeStamp = " << timeStamp << " = " << timeStampFloat - firstTime << ", firstTime = " << firstTime << endl;
	cout << "seconds = " << timeStampSeconds << ", milliseconds = " << timeStampMilliSeconds << " = "  << 0.004096*timeStampMilliSeconds << endl;
}

void ccsds_header::print_type_and_timestamp(char *hdr) {
	cout << get_apID_string(applicationProcessID) << " " << get_packetID_string(applicationProcessID, packetID);
	cout.precision(17);
	cout << " timeStamp = " << timeStamp << endl;
}

bool ccsds_header::validate(char *hdr) {
	switch(applicationProcessID) {
		case LONG_CADENCE_APID:
		case SHORT_CADENCE_APID:
		case FFI_CADENCE_APID:
		case FILL_PACKET_APID:
			break;
			
		default:
			cout << "applicationProcessID = " << applicationProcessID << " is invalid" << endl;
			return (false);
			break;
	}

	switch(packetID) {
		case BASELINE_PKTID:
		case RESIDUAL_PKTID:
		case ENCODED_PKTID:
		case RAW_PKTID:
		case REQUANTIZED_PKTID:
		case 0X5A:
			break;
			
		default:
			if (!((packetID >= 102 && packetID <= 104) || (packetID >= 106 && packetID <= 120) || (packetID >= 122 && packetID <= 124))) {
				cout << "packetID = " << packetID << " is invalid" << endl;
				return (false);
				break;
			}
	}
	
	if (versionNumber != 0) {
		cout << "versionNumber = " << versionNumber << " is invalid, should be zero" << endl;
		return (false);
	}
	if (type != 0) {
		cout << "type = " << type << " is invalid, should be zero" << endl;
		return (false);
	}
	if (sequenceFlags != 3) {
		cout << "sequenceFlags = " << sequenceFlags << " is invalid, should be 3" << endl;
		return (false);
	}
	if (packetLength > CCSDS_PACKET_LENGTH) {
		cout << "packetLength = " << packetLength << " is invalid, should be <= CCSDS_PACKET_LENGTH" << endl;
		return (false);
	}
#if 0
	if (destinationApID != 0) {
		cout << "destinationApID = " << destinationApID << " is invalid, should be zero" << endl;
		return (false);
	}
	if (packetDestinationID != 0) {
		cout << "packetDestinationID = " << packetDestinationID << " is invalid, should be zero" << endl;
		return (false);
	}
#endif
	
	return (true);
}

void ccsds_header::count_packets(void) {
	switch(applicationProcessID) {
		case LONG_CADENCE_APID:
			switch(packetID) {
				case BASELINE_PKTID:
					longCadenceBaselinePacketCount++;
					break;
				case RESIDUAL_PKTID:
					longCadenceResidualBaselinePacketCount++;
					break;
				case ENCODED_PKTID:
					longCadenceResidualPacketCount++;
					break;
				case RAW_PKTID:
				case REQUANTIZED_PKTID:
				default:
					break;
			}
			break;
			
		case SHORT_CADENCE_APID:
			switch(packetID) {
				case BASELINE_PKTID:
					shortCadenceBaselinePacketCount++;
					break;
				case RESIDUAL_PKTID:
					shortCadenceResidualBaselinePacketCount++;
					break;
				case ENCODED_PKTID:
					shortCadenceResidualPacketCount++;
					break;
				case RAW_PKTID:
				case REQUANTIZED_PKTID:
				default:
					break;
			}
			break;
			
		case FFI_CADENCE_APID:
			switch(packetID) {
				case RAW_PKTID:
					ffiPacketCount++;
					break;
				case BASELINE_PKTID:
				case RESIDUAL_PKTID:
				case ENCODED_PKTID:
				case REQUANTIZED_PKTID:
				default:
					break;
			}
			break;
			
		default:
			break;
	}
}			

void ccsds_header::count_data_sets(void) {
	switch(applicationProcessID) {
		case LONG_CADENCE_APID:
			if (scEncodedNumber != 0) {cout << "QQQQ # of prior short cadence encoded " << scEncodedNumber << endl;}
			scEncodedNumber = 0;
			switch(packetID) {
				case BASELINE_PKTID:
					longCadenceBaselineCount++;
					cout << "QQQQ long baseline" << endl;
					break;
				case RESIDUAL_PKTID:
					longCadenceResidualBaselineCount++;
					cout << "QQQQ long residual baseline" << endl;
					break;
				case ENCODED_PKTID:
					longCadenceResidualCount++;
					cout << "QQQQ long encoded" << endl;
					break;
				case RAW_PKTID:
				case REQUANTIZED_PKTID:
				default:
					break;
			}
			break;
			
		case SHORT_CADENCE_APID:
			switch(packetID) {
				case BASELINE_PKTID:
					shortCadenceBaselineCount++;
					if (scEncodedNumber != 0) {cout << "QQQQ # of prior short cadence encoded " << scEncodedNumber << endl;}
					cout << "QQQQ short baseline" << endl;
					scEncodedNumber = 0;
					break;
				case RESIDUAL_PKTID:
					shortCadenceResidualBaselineCount++;
					if (scEncodedNumber != 0) {cout << "QQQQ # of prior short cadence encoded " << scEncodedNumber << endl;}
					cout << "QQQQ short residual baseline" << endl;
					scEncodedNumber = 0;
					break;
				case ENCODED_PKTID:
					shortCadenceResidualCount++;
					scEncodedNumber++;
					break;
				case RAW_PKTID:
				case REQUANTIZED_PKTID:
				default:
					if (scEncodedNumber != 0) {cout << "QQQQ# of prior short cadence encoded " << scEncodedNumber << endl;}
					scEncodedNumber = 0;
					break;
			}
			break;
			
		case FFI_CADENCE_APID:
			switch(packetID) {
				case RAW_PKTID:
					ffiCount++;
					break;
				case BASELINE_PKTID:
				case RESIDUAL_PKTID:
				case ENCODED_PKTID:
				case REQUANTIZED_PKTID:
				default:
					break;
			}
			break;
			
		default:
			break;
	}
}			

void ccsds_header::print_counts(char *hdr) {
	
	cout << longCadenceBaselinePacketCount << " long cadence baseline packets" << endl;
	cout << longCadenceResidualBaselinePacketCount << " long cadence residual baseline packets" << endl;
	cout << longCadenceResidualPacketCount << " long cadence residual packets" << endl;
	cout << shortCadenceBaselinePacketCount << " short cadence baseline packets" << endl;
	cout << shortCadenceResidualBaselinePacketCount << " short cadence residual baseline packets" << endl;
	cout << shortCadenceResidualPacketCount << " short cadence residual packets" << endl;
	cout << ffiPacketCount << " FFI packets" << endl;
	cout << endl;
	cout << longCadenceBaselineCount << " long cadence baselines" << endl;
	cout << longCadenceResidualBaselineCount << " long cadence residual baselines" << endl;
	cout << longCadenceResidualCount << " long cadence residuals" << endl;
	cout << shortCadenceBaselineCount << " short cadence baselines" << endl;
	cout << shortCadenceResidualBaselineCount << " short cadence residual baselines" << endl;
	cout << shortCadenceResidualCount << " short cadence residuals" << endl;
	cout << ffiCount << " FFIs" << endl;
}
