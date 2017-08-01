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

package gov.nasa.kepler.mc.fc;

import gov.nasa.kepler.common.DateUtils;
import gov.nasa.kepler.fc.EphemerisFiles;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.dr.FileLog;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.pi.worker.WorkerTaskRequestDispatcher;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.Date;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.io.FileUtils;

/**
 * This class checks that the file in the cache directory has the same name as
 * the most recent epehemeris file in filestore. If not, the old file is removed
 * from the cache and replaced with the latest from filestore.
 * 
 * See EphemerisDispatcherTest for test cases.
 * 
 * @author Miles Cote
 */
public class EphemerisOperations {

    public static final String FC_SPICE_FILES_DIR_PROP_NAME = "fc.spiceFilesDir";

    public static final String SPACECRAFT_EPHEMERIS_SUFFIX = "_kplr.bsp";
    public static final String PLANETARY_EPHEMERIS_PREFIX = "de";
    public static final String PLANETARY_EPHEMERIS_SUFFIX = ".bsp";
    public static final String LEAP_SECONDS_SUFFIX = ".tls";

    public static synchronized EphemerisFiles getLatestEphemerisFiles() {

        Pair<File,Boolean> spiceFilesDirData = getSpiceFilesDir();
        File spiceFilesDir = spiceFilesDirData.left;
        boolean useFullPath = spiceFilesDirData.right;
        
        EphemerisFiles ephemerisFiles = null;
        ephemerisFiles = getLatestEphemerisFilesFromFilestore(spiceFilesDir, useFullPath);

        return ephemerisFiles;
    }

    /**
     * Determine where the spice files should be created.
     * If the calling thread is for a task that will execute remotely,
     * then the spice files should be created in the task directory and
     * EphemerisFiles.spiceDir should be set to '.'. If not, then the
     * spice files should be created in the directory specified by
     * the FC_SPICE_FILES_DIR_PROP_NAME property.
     * 
     * @return
     */
    private static Pair<File,Boolean> getSpiceFilesDir(){
        File spiceFilesDir = null;
        boolean useFullPath = true;
        
        if(WorkerTaskRequestDispatcher.currentTaskIsRemote()){
            /* For a remote task, create the ephemeris files in the working directory 
             * for the task and set EphemerisFiles.spiceDir to '.' */
            
            spiceFilesDir = WorkerTaskRequestDispatcher.currentContext().getCurrentTaskWorkingDir();
            useFullPath = false;
        }else{
            Configuration configService = ConfigurationServiceFactory.getInstance();

            String spiceFilesDirPath = configService.getString(FC_SPICE_FILES_DIR_PROP_NAME);

            if (spiceFilesDirPath == null) {
                throw new PipelineException("Required property: "
                    + FC_SPICE_FILES_DIR_PROP_NAME
                    + " is not defined.  Check your kepler.properties");
            }

            spiceFilesDir = new File(spiceFilesDirPath);

            if (!spiceFilesDir.exists()) {
                try {
                    FileUtils.forceMkdir(spiceFilesDir);
                } catch (IOException e) {
                    throw new PipelineException("File specified by "
                        + FC_SPICE_FILES_DIR_PROP_NAME
                        + " does not exist and can't be created: " + spiceFilesDir);
                }
            }
        }
        return Pair.of(spiceFilesDir, useFullPath);
    }
    
    private static EphemerisFiles getLatestEphemerisFilesFromFilestore(
        File spiceFilesDir, boolean useFullPath) {
        try {
            FileUtils.forceMkdir(spiceFilesDir);
        } catch (IOException e) {
            throw new PipelineException(
                "Unable to make directory.  spiceFilesDir = " + spiceFilesDir,
                e);
        }

        EphemerisFiles ephemerisFiles = new EphemerisFiles();
        
        ephemerisFiles.setSpacecraftEphemerisFilename(retrieveLatestEphemerisFile(
            spiceFilesDir, DispatcherType.SPACECRAFT_EPHEMERIS).getName());
        ephemerisFiles.setPlanetaryEphemerisFilename(retrieveLatestEphemerisFile(
            spiceFilesDir, DispatcherType.PLANETARY_EPHEMERIS).getName());
        ephemerisFiles.setLeapSecondsFilename(retrieveLatestEphemerisFile(
            spiceFilesDir, DispatcherType.LEAP_SECONDS).getName());

        if(useFullPath){
            ephemerisFiles.setSpiceDir(spiceFilesDir.getAbsolutePath());
        }else{
            ephemerisFiles.setSpiceDir(".");
        }

        return ephemerisFiles;
    }

    private static File retrieveLatestEphemerisFile(File spiceFilesDir,
        DispatcherType dispatcherType) {
        LogCrud logCrud = new LogCrud(DatabaseServiceFactory.getInstance());
        FileLog latestFileLog = logCrud.retrieveLatestFileLog(dispatcherType);

        if (latestFileLog == null) {
            throw new PipelineException("no ephemeris files available");
        }
        String filename = latestFileLog.getFilename();

        File latestFile = new File(spiceFilesDir, filename);

        File metadataFile = getMetadataFile(spiceFilesDir, dispatcherType,
            latestFileLog.getDispatchLog()
                .getReceiveLog()
                .getSocIngestTime());

        if (!metadataFile.exists()) {
            FsId fsId = DrFsIdFactory.getFile(dispatcherType, filename);
            FileStoreClient fsClient = FileStoreClientFactory.getInstance();
            fsClient.readBlob(fsId, latestFile);

            try {
                metadataFile.createNewFile();
            } catch (IOException e) {
                throw new PipelineException(
                    "Unable to create ephemeris metadata file.  metadataFile = "
                        + metadataFile, e);
            }
        }

        return latestFile;
    }

    private static File getMetadataFile(File spiceFilesDir,
        DispatcherType dispatcherType, Date socIngestTime) {

        return new File(spiceFilesDir, dispatcherType + "--ingested-at--"
            + DateUtils.READABLE_LOCAL_FORMAT.format(socIngestTime));
    }

}
