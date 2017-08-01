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

#include <iostream>
#include <stdio.h>
#include <time.h>
#include <errno.h>
#include <sched.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/mman.h>
#include <stdlib.h>
#include <string.h>

#define SLEEP_OFFSET 90000
#define SECONDS_TO_NANOSECONDS 1000000000ULL
#define RT_SCHEDULER SCHED_RR

using namespace std;


inline unsigned long long int fuse(struct itimerspec & itspec) {
    unsigned long long int asNanos = 
	static_cast<unsigned long long int>(itspec.it_value.tv_sec) *
	SECONDS_TO_NANOSECONDS;
   
    return asNanos + static_cast<unsigned long long int>(itspec.it_value.tv_nsec);
}

ostream& operator<<(ostream& out, const struct itimerspec &itspec) {
    out << "itspec.it_value.tv_sec " << itspec.it_value.tv_sec
	<< " itspec.it_value.tv_nsec " << itspec.it_value.tv_nsec
	<< " itspec.it_interval.tv_sec " << itspec.it_interval.tv_sec
	<< " itspec.it_interval.tv_nsec " << itspec.it_interval.tv_nsec;
    return out;
}

/**
 * This tests the linux nanosecond sleep.
 * compile with -lrt and -std=c++0x
 */
int main(int argc, char** argv) {
    //cerr << "Test cerr." << endl;
    cerr << sizeof(unsigned long long int) << endl;

#ifdef USE_REALTIME
    if (mlockall(MCL_CURRENT | MCL_FUTURE)) {
        perror("Failed to lock memory.");
	exit(1);
    }

    int minRealTimePriority = sched_get_priority_min(RT_SCHEDULER);
    struct sched_param rtSchedulerParameters;
    rtSchedulerParameters.sched_priority = minRealTimePriority;
    if (sched_setscheduler(getpid(), RT_SCHEDULER, &rtSchedulerParameters)) {
	perror("Failed to set real time priority.");
	exit(1);
    } 
#endif //USE_REALTIME

    struct timespec waitTime;
    waitTime.tv_sec = 0;
    waitTime.tv_nsec = 250000 - SLEEP_OFFSET;

    timer_t timer;
    if (timer_create(CLOCK_REALTIME, NULL, &timer)) {
        perror("Error creating timer.\n");
        exit(1);
    }

    struct itimerspec initialTimerValue;
    initialTimerValue.it_interval.tv_sec = 0;
    initialTimerValue.it_interval.tv_nsec = 0;
    initialTimerValue.it_value.tv_sec = 1000000;
    if (timer_settime(timer, 0 /* flags */, &initialTimerValue, NULL)) {
      	cerr << "Failed to initialize timer." << endl;
    }
   
    struct itimerspec start;
    struct itimerspec end;
    
    int nIterations = 100000;
    unsigned long long int* durations = new unsigned long long int[nIterations];
    memset(durations, 0, sizeof(unsigned long long int) * nIterations);
    for (int i=0; i < nIterations; i++) {
	if (timer_gettime(timer, &start)) {
            cerr << "Failed to get timer value." << endl;
    	}
        if (nanosleep(&waitTime, NULL)) {
	    cerr << "Failed to sleep." << endl;
        }
        if (timer_gettime(timer, &end)) {
            cerr << "Failed to get end time timer value." << endl;
        }
	//This is a timer that counts down.
	//sometimes this is negative in which case there has been
	//an overflow of the nanosecond part of the timer.
        durations[i] = fuse(start) - fuse(end);
	if (durations[i] > SECONDS_TO_NANOSECONDS) {
            cerr << "likely bad duration start/stop: " << fuse(start) << " / " << fuse(end) << endl;
	}
       	//cout <<  duration << " start: " << start << " end: " << end << endl;
    }

    for (int i=0; i < nIterations; i++) {
        cout << durations[i] << endl;
    }
   
}



