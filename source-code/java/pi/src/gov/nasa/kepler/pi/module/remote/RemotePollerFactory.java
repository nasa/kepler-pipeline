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

package gov.nasa.kepler.pi.module.remote;

import gov.nasa.kepler.pi.module.remote.sup.SupPortal;

import java.util.HashMap;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class acts as a factory for RemotePoller objects.
 * This ensures that all worker threads that are communicating with the
 * same remote cluster will share the same RemotePoller in order to 
 * minimize the number of ssh connections.
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class RemotePollerFactory {
    private static final Log log = LogFactory.getLog(RemotePollerFactory.class);

    /**
     * This Map contains a RemotePoller for each remote cluster configuration used by this worker.
     * Normally, this Map will only contain a single entry since all threads for a given worker will
     * probably be pointing to the same remote cluster. However, the remote cluster configuration
     * is part of the pipeline configuration and it's possible to run multiple pipelines on the same worker,
     * with each pipeline pointing to a different remote cluster. Therefore, for completeness, we don't
     * assume that all worker threads want the same RemotePoller.
     */
    private static Map<String,RemotePoller> pollers = new HashMap<String,RemotePoller>();
    
    /** Private to prevent instantiation */
    private RemotePollerFactory() {
    }

    public static synchronized RemotePoller getInstance(String remoteHost, String remoteUser, String remoteStateDirPath){
        String key = remoteHost + ":" + remoteUser + ":" + remoteStateDirPath;
        
        RemotePoller poller = pollers.get(key);
        
        if(poller == null){
            log.info("Starting new poller for: " + key);
            SupPortal supPortal = new SupPortal(remoteHost, remoteUser);
            poller = new RemotePoller(supPortal, remoteStateDirPath);
            poller.start();
            pollers.put(key, poller);
        }
        return poller;
    }
}
