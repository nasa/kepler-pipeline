/**
 * $Source$
 * $Date: 2017-07-27 10:04:13 -0700 (Thu, 27 Jul 2017) $
 * 
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
package gov.nasa.kepler.fs.client;

import static gov.nasa.kepler.fs.FileStoreConstants.*;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.client.util.DiskFileStoreClient;
import gov.nasa.kepler.fs.client.util.RAMFileStoreDriver;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.spiffy.common.lang.BooleanThreadLocal;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.IOException;
import java.security.NoSuchAlgorithmException;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This code is used to instantiate a FileStoreClient.
 *
 * @author Jason Brittain jbrittain@mail.arc.nasa.gov
 * @author Sean McCauliff
 */
public class FileStoreClientFactory {

    private static final Log log = LogFactory.getLog(FileStoreClientFactory.class);
    
    private static FileStoreClient instance = null;
    private static final ThreadLocal<Boolean> notUsingService = 
        new BooleanThreadLocal(Boolean.FALSE);
 

    /**
     * Reset the factory back to its initial state.
     *
     */
    public static synchronized void reset() {
        instance = null; 
    }
    
    public static synchronized void setInstance(FileStoreClient client ) {

        log.info(String.format("Setting file store client instance to %s.",
            client));
        if (client == null) {
            instance = null;
        } else {
            instance = (FileStoreClient) FileStoreClientInvocationHandler.newInstance(client);
        }
    }
    
    /**
     * Use getInstance() instead of this one.
     * 
     * @param config
     * @return
     * @throws PipelineException
     */
    public static synchronized FileStoreClient getInstance(Configuration config) 
        {
        
        if (notUsingService.get()) {
            throw new PipelineException("A transaction was started but the " +
                                                            "FileStore was not included.");
        }
        
        if  (instance != null) {
            if (log.isDebugEnabled()) {
                log.debug(String.format(
                    "Using existing FileStore client %s.",
                    instance));
            }
            return instance;
        }
        
        // Get configuration settings and use them.
        String driverName = config.getString(FS_DRIVER_NAME_PROPERTY);
        if (driverName == null) {
            throw new FileStoreException("No FileStore driver name specified.  " +
                    "Set the " +
                FS_DRIVER_NAME_PROPERTY + " configuration property.");
        }
        
        if (log.isDebugEnabled()) {
            log.debug(String.format("Creating %s FileStore client.",
                driverName));
        }
        try {
            if (driverName.equals("ram")) {
                instance = new RAMFileStoreDriver(config);
            } else if (driverName.equals("fstp")) {
            	String fstpUrl = config.getString(FS_FSTP_URL, FS_FSTP_URL_DEFAULT);
                instance = new FstpClient(fstpUrl);
            } else if (driverName.equals("local") || driverName.equals("fstp-local")) {
                instance =  LocalFstpClient.newInstance(config);
            } else if (driverName.equals("disk")) {
                instance = new DiskFileStoreClient();
            }
        } catch (IOException ioe) {
            throw new PipelineException("Nested exception.", ioe);
        } catch (NoSuchAlgorithmException nsae) {
            throw new PipelineException("Nested exception.", nsae);
        } catch (ClassNotFoundException cnfe) {
            throw new PipelineException("Nested exception.", cnfe);
        } catch (Exception e) {
            throw new PipelineException("Nested exception.", e);
        }
        
        instance = (FileStoreClient) FileStoreClientInvocationHandler.newInstance(instance);
        return instance;
    }
    
    public static synchronized FileStoreClient getInstance() 
        {
        
        Configuration configuration = ConfigurationServiceFactory.getInstance();
        return getInstance(configuration);
    }

    /**
     * Marks the current thread as being involved in a transaction, but not
     * utilizing this service.
     *
     */
    public static synchronized void markNotUsingService() {
        notUsingService.set(true);
    }
    
    public static synchronized void clearNotUsingService() {
        notUsingService.set(false);
    }
    
}
