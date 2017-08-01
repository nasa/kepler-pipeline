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

package gov.nasa.kepler.fs.cli;

import static gov.nasa.kepler.fs.FileStoreConstants.SERVER_LOCK_NAME;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.server.xfiles.OfflineExtractor;
import gov.nasa.spiffy.common.concurrent.ServerLock;
import gov.nasa.spiffy.common.lang.DefaultSystemProvider;
import gov.nasa.spiffy.common.lang.SystemProvider;

import java.io.File;
import java.util.Set;

/**
 * Lists all the FsIds in the specified directory.
 * @author Sean McCauliff
 *
 */
public class Ls {

    private final SystemProvider system;
    private File listDir;
    private File fsDataDir;
    
    Ls(SystemProvider system) {
        this.system = system;
    }
    
    private void printUsage() {
        system.out().println("java -cp ... gov.nasa.kepler.fs.cli.Ls -d <dataDir> <lsdir>");
        system.out().println("\t -d <dataDir> The root directory of the file store.");
        system.out().println("Where <lsdir> should be some directory which " +
                "contains blobs or time series.");
        
    }
    
    void parse(String[] argv)  {
        if (argv.length != 3) {
            system.out().println("Must specify directory.");
            printUsage();
            system.exit(-1);
        }
        for (int i=0; i < argv.length; i++) {
            if (argv[i].equals("-d")) {
                fsDataDir = new File(argv[++i]);
            } else {
                listDir = new File(argv[i]);
            }
        }

        if (fsDataDir == null) {
            system.err().println("Data directory must be specified.");
            printUsage();
            system.exit(1);
            throw new IllegalArgumentException("Data directory must be specified.");
        }
        
        if (listDir == null) {
            system.err().println("Listing directory must be specified.");
            printUsage();
            system.exit(1);
            throw new IllegalArgumentException("Listing directory must be specified.");
        }
    }
    
    void execute() throws Exception {
        File serverLockFile = new File(fsDataDir, SERVER_LOCK_NAME);
        ServerLock serverLock = new ServerLock(serverLockFile);
        serverLock.tryLock("ls cli");
        
        try {
            OfflineExtractor extractor = new OfflineExtractor(fsDataDir);
            Set<FsId> ids = extractor.ls(listDir);
            for (FsId id : ids) {
                system.out().println(id);
            }
        } finally {
            serverLock.releaseLock();
        }
    }
    
    /**
     * @param args
     */
    public static void main(String[] argv) throws Exception {
        Ls ls = new Ls(new DefaultSystemProvider());
        ls.parse(argv);
        ls.execute();
    }

}
