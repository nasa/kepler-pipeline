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

package gov.nasa.kepler.aft.misc;

import static gov.nasa.kepler.fs.FileStoreConstants.FS_LISTEN_PORT;
import gov.nasa.kepler.fs.server.Server;
import gov.nasa.kepler.fs.server.ShutdownExecutor;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.security.NoSuchAlgorithmException;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class overrides the {@code shutdownExecutor} method in order to avoid
 * the {@code System.exit()} call. Also, the {@code shutdownListeners} method is
 * invoked on shutdown.
 * 
 * @author Forrest Girouard
 */
public class AftFileStoreServer extends Server {

    private static final Log log = LogFactory.getLog(AftFileStoreServer.class);

    public AftFileStoreServer(int port, boolean localonly)
        throws NoSuchAlgorithmException, ClassNotFoundException {
        super(port, localonly);
    }

    /**
     * Avoid call to {@code System.exit()} made by superclass.
     */
    @Override
    protected ShutdownExecutor shutdownExecutor() {
        return new ShutdownExecutor() {

            @Override
            public void doShutdown(int exitCode) {
                shutdownListeners();
            }
        };
    }

    public static void startupServer() throws Exception {

        Configuration configuration = ConfigurationServiceFactory.getInstance();
        int port = configuration.getInt(FS_LISTEN_PORT);
        AftFileStoreServer server = new AftFileStoreServer(port, false);

        try {
            server.setInitDatabaseService(false);
            server.initialize();
        } catch (PipelineException px) {
            log.warn("Unable to initialize the StatusMessageBroadcaster.");
        }

        server.start();
        try {
            server.getMainThread()
                .join();
        } catch (InterruptedException ie) {
            // ok.
        }
    }
}
