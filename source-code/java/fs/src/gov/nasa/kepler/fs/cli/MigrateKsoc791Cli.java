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

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import gov.nasa.spiffy.common.io.DirectoryWalker;
import gov.nasa.spiffy.common.io.FileFind;
import gov.nasa.spiffy.common.io.FileVisitor;
import gov.nasa.spiffy.common.lang.DefaultSystemProvider;
import gov.nasa.spiffy.common.lang.SystemProvider;
import gov.nasa.spiffy.common.pi.PipelineException;

/**
 * Searches for index files.  Moves btree with a T=0 to a btree with T=69.
 * 
 * @author Sean McCauliff
 *
 */
public class MigrateKsoc791Cli {

    private static final Log log = LogFactory.getLog(MigrateKsoc791Cli.class);
    
    private final SystemProvider system;
    private File rootDir;
    
    MigrateKsoc791Cli(SystemProvider system) {
        this.system = system;
    }
    
    void parse(String[] argv) {
        if (argv.length != 1) {
            exitWithError("Missing directory specification.");
        }
        
        rootDir = new File(argv[0]);
        if (!rootDir.exists()) {
            exitWithError("Root directory \"" + rootDir + "\" does not exist.");
        }
        
        if (!rootDir.isDirectory()) {
            exitWithError("Root directory \"" + rootDir + "\" is not a directory.");
        }
        
        if (!rootDir.canRead()) {
            exitWithError("Root directory \"" + rootDir + "\" is not readable.");
        }
    }
    
    
    void execute() throws IOException {
        final List<File> indexFiles = new ArrayList<File>();
        FileVisitor visitor = new FileVisitor() {

            boolean prune = false;
            
            @Override
            public void enterDirectory(File newDir) throws IOException,
                PipelineException {
                if (newDir.getName().startsWith("hd-")) {
                    prune = true;
                }
            }

            @Override
            public void exitDirectory(File exitdir) throws IOException,
                PipelineException {
                //This does nothing.
            }

            @Override
            public boolean prune() {
                boolean old = prune;
                prune= false;
                return old;
            }

            @Override
            public void visitFile(File dir, File f) throws IOException,
                PipelineException {
                
                if (f.getName().equals("idindex")) {
                    indexFiles.add(f);
                }
            }
            
        };
        
        DirectoryWalker dirWalker = new DirectoryWalker(rootDir);
        dirWalker.traverse(visitor);
        
        
        log.info("Found " + indexFiles.size() + " index files.");
        
        MigrateKsoc791 migrator = new MigrateKsoc791();
        for (File indexFile : indexFiles) {
            log.info("Migrating index file \"" + indexFile + "\".");
            File newIndexFile = new File(indexFile.getParentFile(), "idindex.t69");
            migrator.migrate(indexFile, newIndexFile);
        }
        log.info("Migration complete.");
    }
    
    
    private void exitWithError(String errorMessage) {
        system.err().println(errorMessage);
        printHelp();
        system.exit(-1);
        throw new IllegalArgumentException(errorMessage);
    }
    
    private void printHelp() {
        system.err().println("Specify root directory to start recursively looking for index files.");
    }
    
    public static void main(String[] argv) throws Exception {
        MigrateKsoc791Cli cli = new MigrateKsoc791Cli(new DefaultSystemProvider());
        cli.parse(argv);
        cli.execute();
    }
}
