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

import gov.nasa.kepler.common.TicToc;
import gov.nasa.kepler.hibernate.dr.DispatchLog;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;

public class SbtRetrieveAllReceivedFiles extends AbstractSbt {
    public static final String SDF_FILE_NAME = "/tmp/sbt-retrieve-all-received-file.sdf";
    private static final boolean REQUIRES_DATABASE = true;
    private static final boolean REQUIRES_FILESTORE = true;
    
    public static class SbtAllReceivedFiles implements Persistable {
        public List<SbtRetrieveReceivedFile.SbtReceivedFile> allFiles = new ArrayList<SbtRetrieveReceivedFile.SbtReceivedFile>();
        
        public SbtAllReceivedFiles() {
        }
    }
    
    public SbtRetrieveAllReceivedFiles() {
        super(REQUIRES_DATABASE, REQUIRES_FILESTORE);
    }

    public String retrieveAllReceivedFiles() throws Exception {
        return retrieveAllReceivedFiles(SbtRetrieveAvailableDataRanges.START_MJD, SbtRetrieveAvailableDataRanges.END_MJD);
    }
    
    public String retrieveAllReceivedFiles(double startMjd, double endMjd) throws Exception {
        if (! validateDatastores()) {
            return "";
        }
        
        TicToc.tic("Retrieving all received file lists...");

        SbtRetrieveReceivedFile sbtRetrieveReceivedFile = new SbtRetrieveReceivedFile();
        SbtAllReceivedFiles sbtAllReceivedFiles = new SbtAllReceivedFiles();
        
        for (DispatchLog.DispatcherType dispatcherType : DispatchLog.DispatcherType.values()) {
            List<SbtRetrieveReceivedFile.SbtReceivedFile> files = sbtRetrieveReceivedFile.retrieveReceivedFileData(dispatcherType, startMjd, endMjd);
            for (SbtRetrieveReceivedFile.SbtReceivedFile file : files) {
                sbtAllReceivedFiles.allFiles.add(file);
            }
        }
        
        TicToc.toc();
        return makeSdf(sbtAllReceivedFiles, SDF_FILE_NAME);
    }
     
    public static void main(String[] args) throws Exception {
        SbtRetrieveAllReceivedFiles sbt = new SbtRetrieveAllReceivedFiles();
        sbt.retrieveAllReceivedFiles();
        sbt.retrieveAllReceivedFiles(55000, 56000);
    }
}
