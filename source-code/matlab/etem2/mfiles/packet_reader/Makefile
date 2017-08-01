#
# Copyright 2017 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration.
# All Rights Reserved.
# 
# This file is available under the terms of the NASA Open Source Agreement
# (NOSA). You should have received a copy of this agreement with the
# Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
# 
# No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
# WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
# INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
# WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
# INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
# FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
# TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
# CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
# OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
# OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
# FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
# REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
# AND DISTRIBUTES IT "AS IS."
#
# Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
# AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
# SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
# THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
# EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
# PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
# SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
# STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
# PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
# REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
# TERMINATION OF THIS AGREEMENT.
#
CFLAGS = -g -I. -Wno-deprecated -D_FILE_OFFSET_BITS=64

LIB = 
LFLAGS = 

CC = g++

SRCS = parse_ccsds.cpp ccsds_header.cpp parse_vcdu.cpp vcdu_header.cpp dmc_file_maker.cpp \
file_utilities.cpp science_data_header.cpp break_cadus.cpp parse_cadus.cpp gap_cadus.cpp gap_vcdus.cpp \
find_vcdu_gaps.cpp parse_rp_file.cpp print_ccsds_timestamps.cpp

INCLUDES = ccsds_header.h vcdu_header.h dmc_file_maker.h file_utilities.h science_data_header.h 
OBJS = $(SRCS:.cpp=.o)

SCT_SRCS = validate_sct.cpp storage_correlation_table.cpp
SCT_INCLUDES = storage_correlation_table.h 
SCT_OBJS = $(SCT_SRCS:.cpp=.o)

all : parse_ccsds parse_vcdu validate_sct break_cadus parse_cadus gap_cadus gap_vcdus find_vcdu_gaps parse_rp_file print_ccsds_timestamps

parse_ccsds : $(OBJS) $(INCLUDES)
	$(CC) $(CFLAGS) -o parse_ccsds parse_ccsds.o dmc_file_maker.o ccsds_header.o science_data_header.o $(LFLAGS) $(LIBS)

print_ccsds_timestamps : $(OBJS) $(INCLUDES)
	$(CC) $(CFLAGS) -o print_ccsds_timestamps print_ccsds_timestamps.o ccsds_header.o $(LFLAGS) $(LIBS)

parse_vcdu : $(OBJS) $(INCLUDES)
	$(CC) $(CFLAGS) -o parse_vcdu parse_vcdu.o vcdu_header.o ccsds_header.o file_utilities.o $(LFLAGS) $(LIBS)

break_cadus : $(OBJS)
	$(CC) $(CFLAGS) -o break_cadus break_cadus.o $(LFLAGS) $(LIBS)

gap_cadus : gap_cadus.o
	$(CC) $(CFLAGS) -o gap_cadus gap_cadus.o $(LFLAGS) $(LIBS)

gap_vcdus : gap_vcdus.o
	$(CC) $(CFLAGS) -o gap_vcdus gap_vcdus.o vcdu_header.o $(LFLAGS) $(LIBS)

find_vcdu_gaps : find_vcdu_gaps.o
	$(CC) $(CFLAGS) -o find_vcdu_gaps find_vcdu_gaps.o vcdu_header.o file_utilities.o $(LFLAGS) $(LIBS)

parse_cadus : $(OBJS)
	$(CC) $(CFLAGS) -o parse_cadus parse_cadus.o $(LFLAGS) $(LIBS)

parse_rp_file : $(OBJS)
	$(CC) $(CFLAGS) -o parse_rp_file parse_rp_file.o $(LFLAGS) $(LIBS)

validate_sct : $(SCT_OBJS) $(SCT_INCLUDES)
	$(CC) $(CFLAGS) -o validate_sct validate_sct.o storage_correlation_table.o $(LFLAGS) $(LIBS)

.cpp.o: $(INCLUDES) $(SCT_INCLUDES)
	$(CC) $(CFLAGS) -c $<

clean: 
	rm -rf *.o parse_ccsds parse_vcdu validate_sct break_cadus parse_cadus gap_cadus parse_rp_file find_vcdu_gaps gap_vcdus print_ccsds_timestamps

