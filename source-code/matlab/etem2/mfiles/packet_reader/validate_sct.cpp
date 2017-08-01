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

#include "storage_correlation_table.h"

#define N_CADENCES 50000

static void print_usage(void);

static void print_usage(void) {
	cout << "usage: validate_sct [options] <filename>" << endl;
	cout << "options:" << endl;
	cout << "-f <sct filename>" << endl;
	cout << "-e : do not stop on error (default: stop)" << endl;
	cout << "-c <nPackets>: number of packets read (default: 1e9)" << endl;
	cout << "-s : turn on silent mode so there is no ouput unless there is an error (default off)" << endl;
}

int main(int argc, char* const* argv) {
	int stopOnError = 1;
	int silent = 0;
	int correct = 0;
	unsigned long int maxCount = (unsigned long int) 1e9;
	char *filename;

	if (argc < 2) {
		print_usage();
		return (-1);
	}
	
	/* parse command line */
	char ch;
	while ((ch = getopt(argc, argv, "hec:f:sk")) != -1) {
		switch (ch) {
		cout << "ch = " << ch << endl;
			case 'e':
				stopOnError = 0;
				break;
			case 'c':
				sscanf(optarg, "%d", &maxCount);
				break;
			case 'f':
				filename = optarg;
				break;
			case 's':
				silent = 1;
				break;
			case 'k':
				correct = 1;
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

	storage_correlation_table sct;
	if (correct) {
		sct.correct_table(filename, N_CADENCES);
	} else {
		sct.read_table(filename, N_CADENCES);
		if (!silent) {
//			sct.print();
		}
	}
		
}

