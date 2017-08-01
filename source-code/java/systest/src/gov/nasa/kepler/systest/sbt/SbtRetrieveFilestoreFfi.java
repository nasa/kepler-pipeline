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

package gov.nasa.kepler.systest.sbt;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.mc.fc.FfiOperations;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class SbtRetrieveFilestoreFfi extends AbstractSbt {
    public static final String SDF_FILE_NAME = "/tmp/sbt-retrieve-filestore-ffi.sdf";

    private static final double START_MJD = 54000.0;
    private static final double END_MJD = 64000.0;
    private static final String DISPATCHER_TYPE = "FFI";
    
    /**
     * The return of this method is a list of filename strings because the fits tools in matlab are simpler to use.
     * 
     */
    public List<String> retrieveFilestoreFfi(int[] ccdModules, int[] ccdOutputs) throws IOException {
        return retrieveFilestoreFfi(ccdModules, ccdOutputs, true, true);
    }
    /**
     * The return of this method is a list of filename strings because the fits tools in matlab are simpler to use.
     * 
     */
    public List<String> retrieveFilestoreFfi(int[] ccdModules, int[] ccdOutputs, boolean isCalibrated, boolean isSaveLocalCopies) throws IOException {
        List<String> ffiFilenames = new SbtRetrieveReceivedFile().retrieveReceivedFilenames(DISPATCHER_TYPE, START_MJD, END_MJD);
        List<String> localFfiFilenames = copyFfis(ffiFilenames, ccdModules.length);
        return localFfiFilenames;
    }
    
    /**
     * The return of this method is a list of filename strings because the fits tools in matlab are simpler to use.
     * 
     */
    public List<String> retrieveFilestoreFfi(double startMjd, double endMjd, int[] ccdModules, int[] ccdOutputs, boolean isCalibrated, boolean isSaveLocalCopies) throws IOException {
        List<String> ffiFilenames = new SbtRetrieveReceivedFile().retrieveReceivedFilenames(DISPATCHER_TYPE, startMjd, endMjd);
        List<String> localFfiFilenames = copyFfis(ffiFilenames, ccdModules.length);
        return localFfiFilenames;
    }
    
    private List<String> copyFfis(List<String> ffiFilenames, int channelCount) throws IOException {
        // Warn the user if it's going to be a while:
        if (ffiFilenames.size() > 100) {
            log.warn("A large number (" + ffiFilenames.size() * channelCount + ") of FFI images have been requested: this may take a while.");
        }
        
        String pwd = new java.io.File(".").getCanonicalPath();
        FfiOperations ffiOperations = new FfiOperations();
        
        // Make local copies of the FFIs:
        //
        List<String> localFfiFilenames = new ArrayList<String>();
        for (String ffiFilename : ffiFilenames) {
            String localFfiFilename = pwd + "/" + ffiFilename;
            localFfiFilenames.add(localFfiFilename);
            System.out.println("Copying FITS image to " + localFfiFilename);
            ffiOperations.copyFfiToLocal(ffiFilename, localFfiFilename);
        }

        return localFfiFilenames;
    }

    /**
     * The return of this method is a list of filename strings because the fits tools in matlab are simpler to use.
     * 
     */
    public List<String> retrieveFilestoreFfi(double startMjd, double endMjd, boolean isCalibrated, boolean isSaveLocalCopies) throws IOException {
        
        int nOutputs = FcConstants.modulesList.length * FcConstants.outputsList.length;
        int[] ccdModules = new int[nOutputs];
        int[] ccdOutputs = new int[nOutputs];
        int i = 0;
        for (int ccdOutput : FcConstants.outputsList) {
            for (int ccdModule :FcConstants.modulesList) {
                ccdModules[i] = ccdModule;
                ccdOutputs[i] = ccdOutput;
                ++i;
            }
        }

        return retrieveFilestoreFfi(startMjd, endMjd, ccdModules, ccdOutputs, isCalibrated, isSaveLocalCopies);
    }
    
    /**
     * The return of this method is a list of filename strings because the fits tools in matlab are simpler to use.
     * 
     */
    public List<String> retrieveFilestoreFfi(double startMjd, double endMjd, int[] ccdModules, int[] ccdOutputs, boolean isCalibrated) throws IOException {
        return retrieveFilestoreFfi(startMjd, endMjd, ccdModules, ccdOutputs, isCalibrated, false);
    }

    /**
     * The return of this method is a list of filename strings because the fits tools in matlab are simpler to use.
     * 
     */
    public List<String> retrieveFilestoreFfi(double startMjd, double endMjd, boolean isCalibrated) throws IOException {
        return retrieveFilestoreFfi(startMjd, endMjd, isCalibrated, false);
    }
    
    /**
     * The return of this method is a list of filename strings because the fits tools in matlab are simpler to use.
     * 
     */
    public List<String> retrieveFilestoreFfi(boolean isCalibrated, boolean isSaveLocalCopies) throws IOException {
        return retrieveFilestoreFfi(START_MJD, END_MJD, isCalibrated, isSaveLocalCopies);
    }
    
    /**
     * The return of this method is a list of filename strings because the fits tools in matlab are simpler to use.
     * 
     */
    public List<String> retrieveFilestoreFfi(boolean isCalibrated) throws IOException {
        return retrieveFilestoreFfi(isCalibrated, false);
    }
    
    /**
     * The return of this method is a list of filename strings because the fits tools in matlab are simpler to use.
     * 
     */
    public List<String> retrieveFilestoreFfi() throws IOException {
        return retrieveFilestoreFfi(true);
    }
    
    /**
     * @param args
     * @throws IOException 
     */
    public static void main(String[] args) throws IOException {
        SbtRetrieveFilestoreFfi sbt = new SbtRetrieveFilestoreFfi();
        int[] ccdModules = {2};
        int[] ccdOutputs = {1};
        double startMjd = 55184.87;
        double endMjd = 55200.0;

//        List<String> fns = sbt.retrieveFilestoreFfi(true);
        List<String> fns = sbt.retrieveFilestoreFfi(startMjd, endMjd, ccdModules, ccdOutputs, true);
        System.out.println(fns);
    }

}
