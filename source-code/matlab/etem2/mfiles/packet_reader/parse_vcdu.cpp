/*
 *  parse_vcdu.cpp
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
#include <math.h>

#include "vcdu_header.h"
#include "ccsds_header.h"
#include "file_utilities.h"

static void print_usage(void);
int get_ccsds_header(FILE *fid, size_t offset, ccsds_header& ccsdsHeader, vcdu_header& vcduHeader);

static void print_usage(void) {
        cout << "usage: parse_vcdu [options] <filename>" << endl;
        cout << "options:" << endl;
        cout << "-f <filename>" << endl;
        cout << "-e : do not stop on bad packets (default: stop)" << endl;
        cout << "-a : print all packets (default: do not print all)" << endl;
        cout << "-c <nPackets>: number of packets read (default: 1e9)" << endl;
        cout << "-s : turn on silent mode so there is no ouput unless there is an error (default off)" << endl;
        cout << "-v : print full headers (default: off)" << endl;
}

int main(int argc, char* const* argv) {
    unsigned char *vcduHeaderBytes = new unsigned char[VCDU_HEADER_SIZE];
    int stopOnError = 1;
    int allPackets = 0;
    int verbose = 0;
    int silent = 0;
    unsigned long int maxCount = (unsigned long int) 1e9;
    char *filename;
    unsigned long int sctOffset = 0;
    unsigned long int sctLength = 0;

    if (argc < 2) {
        print_usage();
        return (-1);
    }

    /* parse command line */
    char ch;
    while ((ch = getopt(argc, argv, "eac:vf:s")) != -1) {
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
    if (!silent) {
        cout << endl << endl << ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" << endl;
        cout << ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" << endl;
        cout << "reading " << filename << endl;
    }

    FILE *fid = fopen(filename, "r");
    FILE *sctFid = fopen("sctMap", "w");

    ccsds_header ccsdsHeader;
    vcdu_header vcduHeader;
    char *hdr = new char[200];
	unsigned long long int currentTimestamp = 0;
	unsigned char currentPacketID = 0;
	unsigned short int currentApId = 0;
	unsigned long long int currentHeaderOffset = 0;
	unsigned int LcEncodedSequenceCount = 0;
	unsigned int LcBaselineSequenceCount = 0;
	unsigned int LcResidualSequenceCount = 0;
	unsigned int scEncodedSequenceCount = 0;
	unsigned int scBaselineSequenceCount = 0;
	unsigned int scResidualSequenceCount = 0;
	unsigned int sctEntryCount = 0;
	unsigned long int lastVcduCounter = -1;	


    for (int count=0; count < maxCount; count++) {
        // first read the vcdu header bytes
        size_t nRead = fread_and_rewind(vcduHeaderBytes, sizeof(unsigned char), VCDU_HEADER_SIZE, fid, 0);
        if (nRead != VCDU_HEADER_SIZE) {
                if (!silent)
                        cout << "nRead = " << nRead << " reached the end of the file (I hope)" << endl;
                break;
        }
        // set the header object
        vcduHeader.set(vcduHeaderBytes);
		
		// test increment test
//		if (count == 1000)
//			vcduHeader.vcduCounter = lastVcduCounter;
		if (lastVcduCounter != -1)
			if (vcduHeader.vcduCounter != lastVcduCounter + 1 && vcduHeader.vcduCounter > 0) {
				cout << "vcdu counter not incrementing correctly: vcduHeader.vcduCounter = "
					<< vcduHeader.vcduCounter << " lastVcduCounter = " << lastVcduCounter
					<< " packet count = " << count << endl;
//				exit (-1); // don't exit when checking a file with gaps
			} 
		lastVcduCounter = vcduHeader.vcduCounter;

        // print the vcdu header if appropriate and get any ccsds header that may be available
        if (vcduHeader.firstHeaderPointer != NO_CCSDS_HEADER || allPackets) { 
            if (!silent) {
                // make a nice label for printing the vcdu header
                sprintf(hdr, "\n>>>>>>>>> packet count = %d:", count);
                if (verbose)
                        vcduHeader.print_full(hdr);
                else
                        vcduHeader.print(hdr);
                if (vcduHeader.firstHeaderPointer > VCDU_PAYLOAD_LENGTH 
                        && vcduHeader.firstHeaderPointer != NO_CCSDS_HEADER && vcduHeader.firstHeaderPointer != FILL_DATA) {
                        cout << "oops!  This VCDU's firstHeaderPointer points past the payload!" << endl;
                        cout << "This seems to be harmless, so I'm continuing" << endl;
                }
            }

                // read ccsds header if it exists
        	if (vcduHeader.firstHeaderPointer != NO_CCSDS_HEADER && vcduHeader.firstHeaderPointer != FILL_DATA) { 
                // it's possible that this vcdu packet contains more than one ccsds header
                // so maintain an offset that keeps track of the offset of the next header to be read
                // the first header is vcduHeader.firstHeaderPointer bytes into the payload
                int ccsdsHeaderOffset = VCDU_HEADER_SIZE + vcduHeader.firstHeaderPointer;
                // now get ccsds headers until we've read more than the size of a vcdu payload
				int headerCounter = 0;
                while (ccsdsHeaderOffset <= VCDU_PACKET_LENGTH) {
					int firstHeader = 0;
            		int status = get_ccsds_header(fid, ccsdsHeaderOffset, ccsdsHeader, vcduHeader);
            		if (!status)
                    		break;

					if (ccsdsHeader.applicationProcessID == LONG_CADENCE_APID) {
						switch (ccsdsHeader.packetID) { 
							case BASELINE_PKTID:
								if (ccsdsHeader.sequencePacketCount != LcBaselineSequenceCount + 1 && LcBaselineSequenceCount < 16383) {
								cout << "dropped packet? LcBaselineSequenceCount = " << LcBaselineSequenceCount << " ccsdsHeader.sequencePacketCount = " <<
									ccsdsHeader.sequencePacketCount << endl;
							}
							LcBaselineSequenceCount = ccsdsHeader.sequencePacketCount;
							break;
							case RESIDUAL_PKTID:
								if (ccsdsHeader.sequencePacketCount != LcResidualSequenceCount + 1 && LcResidualSequenceCount < 16383) {
								cout << "dropped packet? LcResidualSequenceCount = " << LcResidualSequenceCount << " ccsdsHeader.sequencePacketCount = " <<
									ccsdsHeader.sequencePacketCount << endl;
							}
							LcResidualSequenceCount = ccsdsHeader.sequencePacketCount;
							break;

							case ENCODED_PKTID:
								if (ccsdsHeader.sequencePacketCount != LcEncodedSequenceCount + 1 && LcEncodedSequenceCount < 16383) {
								cout << "dropped packet? LcEncodedSequenceCount = " << LcEncodedSequenceCount << " ccsdsHeader.sequencePacketCount = " <<
									ccsdsHeader.sequencePacketCount << endl;
							}
							LcEncodedSequenceCount = ccsdsHeader.sequencePacketCount;
							break;

							default:
							break;
						}

					}
					if (ccsdsHeader.applicationProcessID == SHORT_CADENCE_APID) {
						switch (ccsdsHeader.packetID) { 
							case BASELINE_PKTID:
								if (ccsdsHeader.sequencePacketCount != scBaselineSequenceCount + 1 && scBaselineSequenceCount < 16383) {
								cout << "dropped packet? scBaselineSequenceCount = " << scBaselineSequenceCount << " ccsdsHeader.sequencePacketCount = " <<
									ccsdsHeader.sequencePacketCount << endl;
							}
							scBaselineSequenceCount = ccsdsHeader.sequencePacketCount;
							break;
							case RESIDUAL_PKTID:
								if (ccsdsHeader.sequencePacketCount != scResidualSequenceCount + 1 && scResidualSequenceCount < 16383) {
								cout << "dropped packet? scResidualSequenceCount = " << scResidualSequenceCount << " ccsdsHeader.sequencePacketCount = " <<
									ccsdsHeader.sequencePacketCount << endl;
							}
							scResidualSequenceCount = ccsdsHeader.sequencePacketCount;
							break;

							case ENCODED_PKTID:
								if (ccsdsHeader.sequencePacketCount != scEncodedSequenceCount + 1 && scEncodedSequenceCount < 16383) {
								cout << "dropped packet? scEncodedSequenceCount = " << scEncodedSequenceCount << " ccsdsHeader.sequencePacketCount = " <<
									ccsdsHeader.sequencePacketCount << endl;
							}
							scEncodedSequenceCount = ccsdsHeader.sequencePacketCount;
							break;

							default:
							break;
						}

					}


					// is this a new header?
					if (ccsdsHeader.timeStamp != currentTimestamp || ccsdsHeader.applicationProcessID != currentApId || ccsdsHeader.packetID != currentPacketID) {
						// this is a new header
						// write out the storage correlation table entry for this header
						cout << "checking IDs: currentApId = " << currentApId << ", currentPacketID = " << (unsigned int) currentPacketID << endl;
						if (currentApId == LONG_CADENCE_APID || currentApId == FFI_CADENCE_APID) {
							cout << "setting sct entry offset = " << currentHeaderOffset << endl;
							fprintf(sctFid, "entry %d: %d, %d, %d, %d\n", sctEntryCount, currentApId, currentPacketID, currentHeaderOffset, sctLength);
							sctEntryCount++;
						}
						sctLength = 0;
						firstHeader = 1;
						currentTimestamp = ccsdsHeader.timeStamp;
						currentApId = ccsdsHeader.applicationProcessID;
						currentPacketID = ccsdsHeader.packetID;
						currentHeaderOffset = sctOffset;
						cout << "set current data to: currentApId = " << currentApId << ", currentPacketID = " << (unsigned int) currentPacketID << endl;
					}
					// advance SCT offsets for this packet
                    // remember, the packetLength in the class is the length of the full ccsds packet including the header
					ccsdsHeaderOffset += ccsdsHeader.packetLength;
                    sctOffset += (unsigned long int) ceil(((double)ccsdsHeader.packetLength + 4.)/16);
					sctLength += (unsigned long int) ceil(((double)ccsdsHeader.packetLength + 4.)/16);

                	if (!silent && (allPackets || firstHeader)) {
						if (firstHeader) {
                            cout << "=======" << endl;
                            ccsdsHeader.count_data_sets();
						}
                        if (verbose)
                            ccsdsHeader.print_full("ccsds hdr:");
                        else
                            ccsdsHeader.print("ccsds hdr:");
                	}
                	ccsdsHeader.count_packets();

                	if (ccsdsHeader._headerBytes[0] == 0X5a) {
                        if (!silent)
                            cout << "----------- found fill padding in place of the ccsds header, count = " << count << " -----------" << endl;
                	} else if (!ccsdsHeader.validate()) {
                        cout << "^^^^^^ count " << count << ": something's wrong with the CCSDS packet, exiting..." << endl << endl;
                        if (stopOnError)
                            return (-1);
                	}
            	}
            } else if (vcduHeader.firstHeaderPointer == FILL_DATA)  {
                if (!silent)
                    cout << "--------- fill data, count = " << count << " -----------" << endl;
            } else if ((stopOnError && vcduHeader.firstHeaderPointer != NO_CCSDS_HEADER) && !silent) {
                cout << "^^^^^^ something's wrong, exiting..." << endl;
                break;
            }
        }

        fseek(fid, VCDU_PACKET_LENGTH, SEEK_CUR);
    }
    if (!silent) {
        cout << endl << endl;
        ccsdsHeader.print_counts();
    }

    // calling fclose(fid) causes problems on a linux system
//      fclose(fid);

    return (0);
}

int get_ccsds_header(FILE *fid, size_t offset, ccsds_header& ccsdsHeader, vcdu_header& vcduHeader) {
        unsigned char ccsdsHeaderBytes[CCSDS_HEADER_SIZE];
        int status = 1;

        // we now look for the ccsds header at the locaation given by the firstHeaderPointer.  
        // It's possible the ccsds header spans vcdu packets, which could occur if 
        // offset > VCDU_PACKET_LENGTH - CCSDS_HEADER_SIZE (since the offset includes the vcdu header)
        if (offset <= VCDU_PACKET_LENGTH - CCSDS_HEADER_SIZE) {
                size_t nRead = fread_and_rewind(ccsdsHeaderBytes, sizeof(unsigned char), CCSDS_HEADER_SIZE, fid, offset);
                // we're now pointing at the start of the current packet
                if (nRead != CCSDS_HEADER_SIZE) {
                        cout << "reached the end of the file (I hope)" << endl;
                        status = 0;
                }
        } else {
 				cout << "ccsds header spans two vcdus!" << endl;
               // we get the bytes that are in this vcdu packet
                int numHeaderBytes = VCDU_PACKET_LENGTH - offset;
                size_t nRead = fread_and_rewind(ccsdsHeaderBytes, sizeof(unsigned char), numHeaderBytes, fid, offset);
                // we're now pointing at the start of the current packet
                if (nRead != numHeaderBytes) {
                        cout << "reached the end of the file (I hope)" << endl;
                        status = 0;
                }

                // now seek to the next vcdu packet and read the rest of the ccsds header, skipping over the next vcdu header
                nRead = fread_and_rewind(&ccsdsHeaderBytes[numHeaderBytes], sizeof(unsigned char), 
                        CCSDS_HEADER_SIZE - numHeaderBytes, fid, VCDU_PACKET_LENGTH + VCDU_HEADER_SIZE);
                // we're again pointing at the start of the current packet
                if (nRead != CCSDS_HEADER_SIZE - numHeaderBytes) {
                        cout << "reached the end of the file (I hope)" << endl;
                        status = 0;
                }
        }
        ccsdsHeader.set(ccsdsHeaderBytes);
        return status;
}

