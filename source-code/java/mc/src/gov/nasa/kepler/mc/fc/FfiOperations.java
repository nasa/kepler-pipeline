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

import gov.nasa.kepler.fs.api.BlobResult;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.dr.FileLog;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.configuration.Configuration;

public class FfiOperations {

    private DatabaseService dbService = null;
    private LogCrud logCrud;

	private Configuration config = null;

	/**
	 * FfiOperations default constructor.
	 * 
	 * This constructor loads the FC kepler.properties files and
	 * sets a configuration instance.
	 * @throws PipelineException 
	 *
	 */
    public FfiOperations() {
        dbService = DatabaseServiceFactory.getInstance();
        logCrud = new LogCrud(dbService);
        config = ConfigurationServiceFactory.getInstance();
    }
    
	public FfiOperations(DatabaseService dbService) {
	    this.dbService = dbService;
        logCrud = new LogCrud(dbService);
        config = ConfigurationServiceFactory.getInstance();
	}
    

    /**
     * Used for testing.
     */
    public Configuration getConfig() {
        return config;
    }
    
    /**
     * Return a list of all FFI names; this will be used for display in FFI Overview.
     * 
     * @return List of FFI names (string)
     * @throws PipelineException
     */
    public List<String> getFfiList() {
        List<FileLog> fileLogs = logCrud.retrieveAllFileLogs(DispatcherType.FFI);
        List<String> ffiNames = new ArrayList<String>();
        //System.out.println(fileLogs.toString() + " " + ffiNames.toString());
        
        for (FileLog fileLog : fileLogs) {
            ffiNames.add(fileLog.getFilename());
        }
        
        return ffiNames;
    }

	
	/**
	 * Returns the FITS file from the filestore that corresponds
	 * to the input argument "name". 
	 * 
	 * @param name The name of the FITS file.
	 * @return A BlobResult containing the FITS file.
	 * @throws PipelineException
	 */
	public BlobResult getFfiBlob(String name) {
        FsId fsId = DrFsIdFactory.getFile(DispatcherType.FFI, name);
        FileStoreClient fsClient = FileStoreClientFactory.getInstance(config);
        BlobResult ffiBlob = fsClient.readBlob(fsId);
    
        return ffiBlob;
	}

	/**
	 * Write an FFI to a local file.
	 * TODO: to be expanded to retrieve the most recent FFI when that CRUD class is complete.
	 * 
	 * @param ffiFsName
	 * @param localFile
	 * @throws PipelineException
	 * @throws IOException
	 */
    public void copyFfiToLocal(String ffiName, File localFile) throws IOException {
        FsId fsId = DrFsIdFactory.getFile(DispatcherType.FFI, ffiName);
        FileStoreClient fsClient = FileStoreClientFactory.getInstance(config);
        try {
            fsClient.beginLocalFsTransaction();
            @SuppressWarnings("unused")
            long result = fsClient.readBlob(fsId, localFile);
            fsClient.commitLocalFsTransaction();
        } finally {
            fsClient.rollbackLocalFsTransactionIfActive();
        }
	}
    
    public void copyFfiToLocal(String ffiName, String localFilename) throws IOException {
        File file = new File(localFilename);
        copyFfiToLocal(ffiName, file);
    }

}
