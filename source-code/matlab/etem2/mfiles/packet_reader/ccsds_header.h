/*
 *  ccsds_header.h
 *  
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
#ifndef _CCSDS_HEADER_H
#define _CCSDS_HEADER_H

#define CCSDS_HEADER_SIZE 14
#define CCSDS_PACKET_LENGTH 16380
#define PRIMARY_HEADER_SIZE 7

#define LONG_CADENCE_APID 40
#define SHORT_CADENCE_APID 41
#define FFI_CADENCE_APID 42
#define FILL_PACKET_APID 2047

#define BASELINE_PKTID 100
#define RESIDUAL_PKTID 101
#define ENCODED_PKTID 102
#define RAW_PKTID 103
#define REQUANTIZED_PKTID 104

class ccsds_header;

class ccsds_header {
	public:

	unsigned char versionNumber;
	unsigned char type;
	unsigned char headerFlag;
	unsigned short int applicationProcessID;
	unsigned short int currentApProcId;
	unsigned char sequenceFlags;
	unsigned short int sequencePacketCount;
	unsigned short int packetLength;
	unsigned long long int timeStamp;
	unsigned long long int currentTimeStamp;
	unsigned long long int timeStampSeconds;
	unsigned long long int timeStampMilliSeconds;
	double timeStampFloat;
	double firstTime;
	unsigned char packetID;
	unsigned char currentPacketId;
	unsigned char destinationApID;
	unsigned char packetDestinationID;
	unsigned char _headerBytes[CCSDS_HEADER_SIZE];
	
	unsigned int longCadenceBaselineCount;
	unsigned int longCadenceResidualBaselineCount;
	unsigned int longCadenceResidualCount;
	unsigned int shortCadenceBaselineCount;
	unsigned int shortCadenceResidualBaselineCount;
	unsigned int shortCadenceResidualCount;
	unsigned int ffiCount;
	
	unsigned int longCadenceBaselinePacketCount;
	unsigned int longCadenceResidualBaselinePacketCount;
	unsigned int longCadenceResidualPacketCount;
	unsigned int shortCadenceBaselinePacketCount;
	unsigned int shortCadenceResidualBaselinePacketCount;
	unsigned int shortCadenceResidualPacketCount;
	unsigned int ffiPacketCount;
	
	unsigned int scEncodedNumber;
	
	ccsds_header(void);
	~ccsds_header(void) {}
	
	void set(unsigned char *headerBytes);
	void print_full(char *hdr = "");
	void print(char *hdr = "");
	void print_type_and_timestamp(char *hdr = "");
	bool validate(char *hdr = "");
	void count_packets(void);
	void count_data_sets(void);
	void print_counts(char *hdr = "");
	bool packet_type_changed(ccsds_header& newHeader);
	bool packet_timestamp_changed(ccsds_header& newHeader);
};

#endif
