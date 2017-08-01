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
#include <unistd.h>
#include <sys/types.h>
#include <string.h>
#include <fcntl.h>

#define _GNU_SOURCE
#define __USE_GNU
#include <dlfcn.h>

static int (*real_close_implementation)(int fd);

#ifdef SNOOP_LOG
static unsigned int interceptCount_g;
#endif 

/**
 * Uses GCC specific stuff to initialize this when loaded in a shared library.
 */
__attribute__((constructor)) void dlinit() {
    real_close_implementation = (int (*)(int)) dlsym(RTLD_NEXT, "close");
#ifdef SNOOP_LOG
    interceptCount_g = 0;
#endif
}


#define BUF_SIZE 256

int close(int fd) {
    fsync(fd);
    if (real_close_implementation == NULL) {
        fprintf(stderr, "Failed to intercept close().  Exiting.\n");
        _exit(-10);
    }
#ifdef SNOOP_LOG
    char procFName[BUF_SIZE];
    snprintf(procFName, BUF_SIZE, "/proc/self/fd/%d", fd);
    char targetFName[BUF_SIZE];
    readlink(procFName, targetFName, BUF_SIZE);
    char snoopLogFName[BUF_SIZE];
    snprintf(snoopLogFName, BUF_SIZE, "/tmp/closeintercept.%d.log", getpid());
    int snoopLogFd = open(snoopLogFName, O_RDWR  | O_CREAT | O_APPEND,  S_IRUSR | S_IWUSR );
    if (snoopLogFd >= 0) {
        char logBuf[BUF_SIZE];
        snprintf(logBuf, BUF_SIZE, 
            "Intercept %d %s\n", ++interceptCount_g, targetFName);
        write(snoopLogFd, logBuf, strlen(logBuf));
        real_close_implementation(snoopLogFd);
    }
#endif //SNOOP_LOG
    return real_close_implementation(fd);
}

