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

import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.TicToc;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.DispatchLog;
import gov.nasa.kepler.hibernate.dr.FileLog;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;

public class SbtRetrieveReceivedFile extends AbstractSbt {
    public static final String SDF_FILE_NAME = "/tmp/sbt-retrieve-received-file.sdf";
    private static final boolean REQUIRES_DATABASE = true;
    private static final boolean REQUIRES_FILESTORE = true;
    
    public static class SbtReceivedFileContainer implements Persistable {
        public List<SbtReceivedFile> sbtReceivedFiles = new ArrayList<SbtReceivedFile>();

        public SbtReceivedFileContainer(List<SbtReceivedFile> sbtReceivedFiles) {
            this.sbtReceivedFiles = sbtReceivedFiles;
        }
    }

    public static class SbtReceivedFile implements Persistable {
        public double mjdSocIngestTime;
        public String filename;
        public String dispatcherType;
        
        public SbtReceivedFile() {
        }
        
        public SbtReceivedFile(double mjdSocIngestTime, String filename, DispatchLog.DispatcherType dispatcherTypeEnum) {
            this.mjdSocIngestTime = mjdSocIngestTime;
            this.filename = filename;
            this.dispatcherType = dispatcherTypeEnum.getName();
        }
    }
    
    public SbtRetrieveReceivedFile() {
        super(REQUIRES_DATABASE, REQUIRES_FILESTORE);
    }

    public String retrieveReceivedFile(String dispatcherType) throws Exception {
        return retrieveReceivedFile(dispatcherType, SbtRetrieveAvailableDataRanges.START_MJD, SbtRetrieveAvailableDataRanges.END_MJD);
    }
    
    public String retrieveReceivedFile(String dispatcherType, double startMjd, double endMjd) throws Exception {
        if (! validateDatastores()) {
            return "";
        }

        TicToc.tic("Retrieving received file list...");
        List<SbtReceivedFile> sbtReceivedFiles = retrieveReceivedFileData(dispatcherType, startMjd, endMjd);
        TicToc.toc();
        
        SbtReceivedFileContainer container = new SbtReceivedFileContainer(sbtReceivedFiles);
        return makeSdf(container, SDF_FILE_NAME);
    }
    
    public List<SbtReceivedFile> retrieveReceivedFileData(DispatchLog.DispatcherType dispatcherTypeEnum, double startMjd, double endMjd) {
        LogCrud logCrud = new LogCrud(DatabaseServiceFactory.getInstance());
        
        // Get the file logs:
        //
        List<FileLog> fileLogs = logCrud.retrieveAllFileLogs(dispatcherTypeEnum);

        // Loop over the file logs, adding the data to the output list if it is within the requested MJD range:
        //
        List<SbtReceivedFile> sbtReceivedFiles = new ArrayList<SbtReceivedFile>();
        for (FileLog fileLog : fileLogs) {
            double mjdSocIngestTime  = ModifiedJulianDate.dateToMjd(fileLog.getDispatchLog().getReceiveLog().getSocIngestTime());
            
            boolean isAfterStart = mjdSocIngestTime >= startMjd;
            boolean isBeforeEnd = mjdSocIngestTime <= endMjd;
            if (isAfterStart && isBeforeEnd) {
                sbtReceivedFiles.add(new SbtReceivedFile(mjdSocIngestTime, fileLog.getFilename(), dispatcherTypeEnum));
            }
        }
        return sbtReceivedFiles;
    }
    
    public List<SbtReceivedFile> retrieveReceivedFileData(String dispatcherType, double startMjd, double endMjd) {
        return retrieveReceivedFileData(DispatchLog.DispatcherType.valueOf(dispatcherType), startMjd, endMjd);
    }
    
    public List<String> retrieveReceivedFilenames(String dispatcherType, double startMjd, double endMjd) {
        List<SbtReceivedFile> fileData = retrieveReceivedFileData(dispatcherType, startMjd, endMjd);
        List<String> filenames = new ArrayList<String>();
        for (SbtReceivedFile sbtReceivedFile : fileData) {
            filenames.add(sbtReceivedFile.filename);
        }
        return filenames;
    }
    
    public static void main(String[] args) throws Exception {
        SbtRetrieveReceivedFile sbt = new SbtRetrieveReceivedFile();
        sbt.retrieveReceivedFile("FFI");
        sbt.retrieveReceivedFile("LONG_CADENCE_PIXEL");
        sbt.retrieveReceivedFile("LONG_CADENCE_PIXEL", 55000, 56000);
    }
}
