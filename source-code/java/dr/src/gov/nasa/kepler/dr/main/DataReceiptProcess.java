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

package gov.nasa.kepler.dr.main;

import gov.nasa.kepler.dr.dispatch.FileWatcher;
import gov.nasa.kepler.dr.dispatch.HighPriorityFileWatcher;
import gov.nasa.kepler.dr.dispatch.LowPriorityFileWatcher;
import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.services.process.AbstractPipelineProcess;
import gov.nasa.kepler.services.process.ProcessStatusReporter;
import gov.nasa.spiffy.common.concurrent.ServerLock;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Main entry point for the Data Receipt process
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class DataReceiptProcess extends AbstractPipelineProcess {

    public static final String NAME = "Data Receipt";

    private static final String DR_PROCESS_LOCK_FILENAME = "dr-process-lock.tmp";

    private static final Log log = LogFactory.getLog(DataReceiptProcess.class);

    private ServerLock serverLock;
    
    public DataReceiptProcess() {
        super(NAME);
    }

    public void go() {
        try {
            initialize();

            Configuration config = ConfigurationServiceFactory.getInstance();

            updateProcessState(ProcessStatusReporter.State.WAITING_FOR_FS);
            verifyFilestoreConnectivity();
            updateProcessState(ProcessStatusReporter.State.INITIALIZING);

            lockFile(config);

            log.info("Initializing FileStore...");
            FileStoreClientFactory.getInstance(config);

            log.info("Starting HighPriorityFileWatcher");
            HighPriorityFileWatcher highPriorityFileWatcher = new HighPriorityFileWatcher();
            highPriorityFileWatcher.start();

            log.info("Starting LowPriorityFileWatcher");
            LowPriorityFileWatcher lowPriorityFileWatcher = new LowPriorityFileWatcher();
            lowPriorityFileWatcher.start();

            updateProcessState(ProcessStatusReporter.State.RUNNING);
        } catch (Exception e) {
            throw new PipelineException("Unable to initialize data receipt.  ", e);
        }
    }

    /**
     * Verify that the filestore is reachable
     */
    private void verifyFilestoreConnectivity() {
        int retryCount = 0;

        while (true) {
            try {
                FileStoreClientFactory.getInstance().ping();
                return;
            } catch (FileStoreException e2) {
                try {
                    if (retryCount < 12 * 5) {
                        log.warn("Can't connect to the filestore, sleeping for 5 secs...");
                        Thread.sleep(5000);
                    } else {
                        log.warn("Can't connect to the filestore, sleeping for 60 secs...");
                        Thread.sleep(60000);
                    }
                } catch (InterruptedException ignore) {
                }
            }
            retryCount++;
        }
    }

    /** Lock file so that only one data receipt process can use the
     * incoming directory.
     */
    private void lockFile(Configuration config) throws IOException {
        File lockFile = new File(config.getString(FileWatcher.INCOMING_DIR_PROP),
            DR_PROCESS_LOCK_FILENAME);
        serverLock = new ServerLock(lockFile);

        serverLock.tryLock(getProcessInfo().toString());
    }

    /**
     * @param args
     * @throws IOException
     * @throws PipelineException
     * @throws Exception
     */
    public static void main(String[] args) throws IOException,
        PipelineException {
        DataReceiptProcess dr = new DataReceiptProcess();
        dr.go();
    }
}
