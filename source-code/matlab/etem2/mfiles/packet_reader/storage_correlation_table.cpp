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
#include <string.h>
#include <unistd.h>

#include "storage_correlation_table.h"

sct_table_entry::sct_table_entry(void) {
	logVtcSeconds = 0;
	logVtcSubSeconds = 0;
	dataVtcSeconds = 0;
	dataVtcSubSeconds = 0;
	apID = packetID = 0;
	dataOffset = 0;
	dataLength = 0;
}

void sct_table_entry::set(unsigned char *bytes, int n){
	entryNumber = n;
	
	logVtcSeconds = ((unsigned long int)bytes[0]) << 24 | ((unsigned long int)bytes[1]) << 16
			 | ((unsigned long int)bytes[2]) << 8 | (unsigned long int)bytes[3];
	logVtcSubSeconds = bytes[LOG_VTC_SUB_SEC_OFFSET];
	dataVtcSeconds = ((unsigned long int)bytes[8]) << 24 | ((unsigned long int)bytes[9]) << 16
			 | ((unsigned long int)bytes[10]) << 8 | (unsigned long int)bytes[11];
	logVtcSubSeconds = bytes[DATA_VTC_SUB_SEC_OFFSET];
	apID = bytes[APID_OFFSET];
	packetID = bytes[PACKETID_OFFSET];
	dataOffset = ((unsigned long int)bytes[15]) << 24 | ((unsigned long int)bytes[16]) << 16
			 | ((unsigned long int)bytes[17]) << 8 | (unsigned long int)bytes[18];
	dataLength = ((unsigned long int)bytes[19]) << 24 | ((unsigned long int)bytes[20]) << 16
			 | ((unsigned long int)bytes[21]) << 8 | (unsigned long int)bytes[22];
}

void sct_table_entry::print(char *hdr){
	cout << "entryNumber = " << entryNumber << endl;
	cout << "logVtcSeconds = " << logVtcSeconds << endl;
	cout << "logVtcSubSeconds = " << (unsigned int) logVtcSubSeconds << endl;
	cout << "dataVtcSeconds = " << dataVtcSeconds << endl;
	cout << "logVtcSubSeconds = " << (unsigned int) logVtcSubSeconds << endl;
	cout << "apID = " << (unsigned int) apID << endl;
	cout << "packetID = " << (unsigned int) packetID << endl;
	cout << "dataOffset = " << dataOffset << endl;
	cout << "dataLength = " << dataLength << endl;
}

//-------------------------------------------------------
//-------------------------------------------------------

storage_correlation_table::storage_correlation_table(void) {
	table = NULL;
	nEntries = 0;
}

storage_correlation_table::~storage_correlation_table(void) {
	if (table != NULL) {
		delete[] table;
	}
}

void storage_correlation_table::init_table(int n) {
	table = new sct_table_entry[n];
	nEntries = n;
}

void storage_correlation_table::read_table(char *filename, int nEntries) {
	FILE *fid = fopen(filename, "r");
	if (fid == NULL) {
		cout << "problem opening " << filename << endl;
		return;
	}
	unsigned char *entryBytes = new unsigned char[STC_ENTRY_SSR_SIZE];
	
	if (table != NULL) {
		delete[] table;
		table = NULL;
	}
	init_table(nEntries);
	
	for (int entry=0; entry<nEntries; entry++) {
		size_t nRead = fread(entryBytes, sizeof(unsigned char), STC_ENTRY_SSR_SIZE, fid);
		
		if (nRead != STC_ENTRY_SSR_SIZE) {
			cout << "nRead = " << nRead << " reached the end of the file (I hope)" << endl;
			break;
		}

		table[entry].set(entryBytes, entry);
		cout << "--- read entry " << entry << ":" << endl;
		table[entry].print();
	}
	fclose(fid);
}

void storage_correlation_table::correct_table(char *filename, int nEntries) {
	FILE *fid = fopen(filename, "r");
	char outname[2000];
	strcpy(outname, filename);
	strcat(outname, ".new");
	cout << "writing " << outname << endl;
	FILE *fidOut = fopen(outname, "w");
	
	if (fid == NULL) {
		cout << "problem opening " << filename << endl;
		return;
	}
	if (fidOut == NULL) {
		cout << "problem opening " << filename << endl;
		return;
	}
	unsigned char *entryBytes = new unsigned char[STC_ENTRY_SSR_SIZE];
	
	if (table != NULL) {
		delete[] table;
		table = NULL;
	}
	init_table(nEntries);
	
	for (int entry=0; entry<nEntries; entry++) {
		size_t nRead = fread(entryBytes, sizeof(unsigned char), STC_ENTRY_SSR_SIZE, fid);
		
		if (nRead != STC_ENTRY_SSR_SIZE) {
			cout << "nRead = " << nRead << " reached the end of the file (I hope)" << endl;
			break;
		}

		table[entry].set(entryBytes, entry);
		// write out this entry if it has a legal pktID
		if (table[entry].packetID >= 100 && table[entry].packetID <= 104) { // error has 255
			size_t nWrite = fwrite(entryBytes, sizeof(unsigned char), STC_ENTRY_SSR_SIZE, fidOut);
			if (nWrite != STC_ENTRY_SSR_SIZE)
				cout << "didn't write STC_ENTRY_SSR_SIZE bytes: nWrite = " << nWrite << endl;
		} else
			cout << "filtered out entry " << entry << endl;
	}
	fclose(fid);
	fclose(fidOut);
}

void storage_correlation_table::print(char *hdr){

	for (int entry=0; entry<nEntries; entry++) {
		cout << "--- entry " << entry << ":" << endl;
		table[entry].print();

        unsigned long int lastLogTime = 0;
        unsigned long int lastDataTime = 0;
        unsigned long int lastOffset = 0;

        if (table[entry].logVtcSeconds < lastLogTime) {
            cout << "XXXXXXXXXXXXXXXXXX error: entry " << entry << " logVtcSeconds did not increment" << endl;
        	break;
        }
        if (table[entry].dataVtcSeconds < lastDataTime) {
            cout << "XXXXXXXXXXXXXXXXXX error: entry " << entry << " dataVtcSeconds did not increment" << endl;
         	break;
        }
        if (table[entry].dataOffset < lastOffset) {
            cout << "XXXXXXXXXXXXXXXXXX error: entry " << entry << " dataOffset did not increment" << endl;
	       	break;
        }
        lastLogTime = table[entry].logVtcSeconds;
        lastDataTime = table[entry].dataVtcSeconds;
        lastOffset = table[entry].dataOffset;
		
		if (table[entry].apID != LONG_CADENCE_APID) {
            cout << "XXXXXXXXXXXXXXXXXX error: entry " << entry << " apID " << (unsigned int) table[entry].apID << " is not long cadence" << endl;
	       	break;
		}
		
		if (!(table[entry].packetID == BASELINE_PKTID || table[entry].packetID == RESIDUAL_PKTID || table[entry].packetID == ENCODED_PKTID )) {
            cout << "XXXXXXXXXXXXXXXXXX error: entry " << entry << " packetID " << (unsigned int) table[entry].packetID << " is not a legal value" << endl;
	       	break;
		}
	}
}
