/*
 * Copyright 2017 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 * 
 * NASA acknowledges the SETI Institute's primary role in authoring and
 * producing the Kepler Data Processing Pipeline under Cooperative
 * Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
 * NNX11AI14A, NNX13AD01A & NNX13AD16A.
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

//
// [pos vel] = keplerStateVector(dates, 'SIRTF', 'sun', 'J2000', 'spk_030825_060828_091231.bsp', 'de405.bsp', 'cook_01.tls');

#include <exception>
#include <string>
#include <string.h>

#include "mex.h"
#include "SpiceUsr.h"

using std::exception;
using std::string;

#define SPICE_MEX_ERR(msg) \
if (failed_c()) { \
    do_failure_exit(leap, spk, de405, (msg)); \
}

void do_failure_exit(const char *reason) {
    SpiceChar smsg[2048]; 
    SpiceChar lmsg[10000]; 
    getmsg_c("short", 2048, smsg);
    getmsg_c("long", 10000, lmsg);
    reset_c();
    printf("FAILURE in keplerStateVector: %s\nMESSAGE:    %s\nMESSAGELONG: %s", reason, smsg, lmsg);
    throw exception();
}

void do_failure_exit(const char *file1, const char *file2, const char *file3, const char *reason) {
    unload_c(file1);
    unload_c(file2);
    unload_c(file3);
    do_failure_exit(reason);
}

void do_failure_exit(const char *file1, const char *file2, const char *reason) {
    unload_c(file1);
    unload_c(file2);
    do_failure_exit(reason);
}

void do_failure_exit(const char *file1, const char *reason) {
    unload_c(file1);
    do_failure_exit(reason);
}

//Length of buffer for string parameters.
#define BUF_LEN 256

/* Example inputs.    
 * strcpy(argsBuffer[1], "99");
 * strcpy(argsBuffer[2], "sun");
 * strcpy(argsBuffer[3], "J2000");
 * strcpy(argsBuffer[4], "spk_030825_060828_091231.bsp"); 
 * strcpy(argsBuffer[5], "de405.bsp");
 * strcpy(argsBuffer[6], "cook_01.tls");
 */

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

    // Set the default SPICE error action to be report-and-continue:
    //
    int lenout = 2048; // Size of error-message string buffer.
    erract_c("SET", lenout, "RETURN"); // set SPICE error action to return (not exit)
    errdev_c("SET", lenout, "errlog.txt"); // set SPICE error action to return (not exit)
    errprt_c("SET", lenout, "ALL");    // set SPICE error report to verbose 

    // Declare SPICE inputs 
    //

    char argsBuffer[7][BUF_LEN];
    // N.B. argsBuffer[0] is handled below.
    char* targ  = argsBuffer[1];
    char* obs   = argsBuffer[2];
    char* frame = argsBuffer[3];
    char* spk   = argsBuffer[4];
    char* de405 = argsBuffer[5];
    char* leap  = argsBuffer[6];
    const char* abcorr = "NONE";

    // Read in the input arguments that were specified (all args are required
    //   to be strings-- this simplifies the MATLAB-C++ interface): 
    //
    if (nrhs != 7) {
        mexPrintf("Usage: keplerStateVector(UTC,target_name,observer_name,frame,SP_kernel_file,leap_second_file,de405_file)\n");
        do_failure_exit("bad args");
    }

    for (int ii = 1; ii < nrhs; ++ii) {
        if (! mxIsChar(prhs[ii])) {
            mexErrMsgTxt("keplerStateVector: Arguments must be strings");
            return;
        }
        if (mxGetString(prhs[ii], argsBuffer[ii], BUF_LEN-1)) {
            mexErrMsgTxt("keplerStateVector: failed to get string with mxGetString().");
            return;
        }
    }

    int nRowsUtc = mxGetM(prhs[0]);
    int nColsUtc = mxGetN(prhs[0]);

    // The UTCs need to be read out separately b/c they're strings, and can't use the mxGetString() function..
    //
    string allUtcs = mxArrayToString(prhs[0]);

    // Create a pointer to the mex output data
    double *posOutput(0), *velOutput(0), *deltaEtOutput(0);
    if (nlhs >= 1) {
        // position: (will come from state[0-2])
        plhs[0] = mxCreateDoubleMatrix(nColsUtc, 3, mxREAL);
        posOutput = mxGetPr(plhs[0]);
        bzero(posOutput, sizeof(double) * nColsUtc * 3);
    }
    if (nlhs >= 2) {
        // velocity: (will come from state[3-5])
        plhs[1] = mxCreateDoubleMatrix(nColsUtc, 3, mxREAL);
        velOutput = mxGetPr(plhs[1]);
        bzero(velOutput, sizeof(double) * nColsUtc * 3);
    }
    if (nlhs == 3) {
        // utc-tdb correction from delet
        plhs[2] = mxCreateDoubleMatrix(nColsUtc, 1, mxREAL); 
        deltaEtOutput = mxGetPr(plhs[2]);
        bzero(deltaEtOutput, sizeof(double) * nColsUtc);
    }
    
    if (nlhs > 3) {
        mexErrMsgTxt("keplerStateVector: too many output arguments, expected 0-3.");
        return;
    }


    // Load the leapseconds file into the kernel pool, so we can convert the
    //   UTC time strings to ephemeris seconds past J2000.  Then load the
    //   binary SPK file containing the ephemeris data.
    //
    furnsh_c(leap); // load leapseconds file
    if (failed_c()) {
        do_failure_exit("fail load leap"); // run failure routine if the load failed
    }

    furnsh_c(spk); // load spice kernel
    if (failed_c()) {
        do_failure_exit(leap, "fail load spk"); // run failure routine if the load failed
    }

    furnsh_c(de405); // load planetary ephemeris file
    if (failed_c()) {
        do_failure_exit(leap, spk, "fail load de405"); // run failure routine if the load failed
    }

    // Compute the state vector 'state' of 'targ' from 'obs' at 'et' in 
    //   the 'frame' reference frame and aberration correction 'abcorr'.
    //   The array 'state' is { posX, posY, posZ, velX, velY, velZ }.
    //
    for (unsigned int utcInputIndex = 0; utcInputIndex < nColsUtc; ++utcInputIndex) {
        unsigned int indx = utcInputIndex * nRowsUtc;
        string tmpString = allUtcs.substr(indx, nRowsUtc);
        const char *currentUtc = tmpString.c_str();

        double ephemerisTime = 0;
        
	    // Convert the UTC time strings into DOUBLE PRECISION ETs.
        str2et_c(currentUtc, &ephemerisTime); 
        SPICE_MEX_ERR("Failed to run str2et_c() (string UTC time to ephemeris time).");

        //Get the difference between UTC and ephemeris time
        double utcEphemerisTimeDelta = 0;
        deltet_c(ephemerisTime, "ET", &utcEphemerisTimeDelta);
        SPICE_MEX_ERR("Failed to run deltet().  (calculate the delta for UTC to ephemeris time).");
        double positionAndVelocity[6];
        bzero(positionAndVelocity, 6 * sizeof(double));
        double lightTime = 0;
        // calculate state vector using spice kernels
        spkezr_c(targ, ephemerisTime, frame, abcorr, obs, positionAndVelocity, &lightTime); 
        SPICE_MEX_ERR("Failed run spkezr_c().");

        // Copy the state vector into the output mex arrays:
        for (unsigned int vectorElement = 0; vectorElement < 3; ++vectorElement) {
            if (posOutput != 0) {
                posOutput[utcInputIndex + vectorElement*nColsUtc] = 
                    positionAndVelocity[vectorElement];
            }
            if (velOutput != 0) {
                velOutput[utcInputIndex + vectorElement*nColsUtc] =
                    positionAndVelocity[vectorElement+3];
            }
        }
        if (deltaEtOutput != 0) {
            deltaEtOutput[utcInputIndex] = utcEphemerisTimeDelta;
        }
    }

    unload_c(leap);
    SPICE_MEX_ERR("Failed to unload leap."); 

    unload_c(spk);
    if (failed_c()) {
        do_failure_exit(spk, de405, "Failed to unload spk.");
    }

    unload_c(de405);
    if (failed_c()) {
        do_failure_exit(de405, "Failed unload de405.");
    }
}
