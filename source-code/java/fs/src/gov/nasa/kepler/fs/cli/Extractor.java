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

import gov.nasa.kepler.fs.FileStoreConstants;
import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.StreamedBlobResult;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.server.xfiles.OfflineExtractor;
import gov.nasa.spiffy.common.concurrent.ServerLock;
import gov.nasa.spiffy.common.lang.DefaultSystemProvider;
import gov.nasa.spiffy.common.lang.SystemProvider;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;


/**
 * Offline data extraction tool.
 * 
 * @author Sean McCauliff
 *
 */
public class Extractor {

    private enum OpType {
        TS_OP, BLOB_OP, CR_OP
    }
    
    private final SystemProvider system;
    private OpType opType;
    private File fsDataDir;
    private File outputDir = new File(".");
    private final List<FsId> ids = new ArrayList<FsId>();
    
    Extractor(SystemProvider system) {
        this.system = system;
    }
    
    private void printUsage() {
        system.out().println("java -cp ... gov.nasa.kepler.fs.cli.Extractor  [-o <output dir> ] -f <root data dir> <-b|-t> <fsid>+");
        system.out().println("\t-d <root data dir> - The file store data directory.");
        system.out().println("\t-b - FsIds are blobs.");
        system.out().println("\t-t - FsIds are time series.");
        system.out().println("\t-c - FsIds are cosmic ray series.");
        system.out().println("\t-o <output dir> - Directory to use when writing blobs.");
        system.out().println("Blob originators are written to stdout.  Blob " +
                "files are written to cwd/<FsId>.");
        system.out().println("Time series are written to stdout.");
    }
    
    void parse(String[] argv) {
        int i=0;
        
        for (; i < argv.length; i++) {
            if (argv[i].equals("-f")) {
                fsDataDir = new File(getArg(argv,++i, "file name."));
            } else if (argv[i].equals("-b")) {
                assignOp(OpType.BLOB_OP);
            } else if (argv[i].equals("-t")) {
               assignOp(OpType.TS_OP);
            } else if (argv[i].equals("-c")) {
                assignOp(OpType.CR_OP);
            } else if (argv[i].equals("-o")) {
                outputDir = new File(getArg(argv, ++i, "output dir name."));
                outputDir.mkdirs();
                if (!outputDir.isDirectory()) {
                    throw new IllegalArgumentException("Output directory \"" +
                        outputDir + "\" is not a directory.");
                }
            } else if (argv[i].startsWith("-")) {
                system.err().println("Unknown option \"" + argv[i] + "\".");
                printUsage();
                system.exit(1);
                throw new IllegalArgumentException("Unknown option \"" + 
                    argv[i] + "\".");
            } else {
                break;
            }
        }
        
        for (; i < argv.length; i++) {
            ids.add(new FsId(argv[i]));
        }
        
        if (ids.size() == 0) {
            system.err().println("Must specify ids.");
            printUsage();
            system.exit(1);
            throw new IllegalArgumentException("Must specify ids.");
        }
        
       
       if (opType == null) {
           system.err().println("Must specify an extraction type.");
           printUsage();
           system.exit(1);
           throw new IllegalArgumentException("Must specify an extraction type.");
       }
       
       if (fsDataDir == null || !fsDataDir.exists()) {
           system.err().println("You must specify a file store root directory.");
           printUsage();
           system.exit(1);
           throw new IllegalArgumentException("Must specify file store root directory.");
       }
       
    }

    private void assignOp(OpType opType) {
        if (this.opType == null) {
            this.opType = opType;
        } else {
            system.err().println("Can only specify one kind of extraction type.");
            printUsage();
            system.exit(1);
            throw new IllegalArgumentException("Can only specify one kind of extraction type.");
        }
    }
    
    void execute() throws Exception {
        File serverLockFile = new File(this.fsDataDir, FileStoreConstants.SERVER_LOCK_NAME);
        ServerLock serverLock = new ServerLock(serverLockFile);
        serverLock.tryLock("extractor cli");
        try {
            switch (opType) {
                case BLOB_OP: extractBlob(); break;
                case TS_OP: extractTs(); break;
                case CR_OP: extractCosmicRay(); break;
                default:
                    throw new AssertionError("Unhandled case.");
            }
        } finally {
            serverLock.releaseLock();
        }
    }
    
    private void extractCosmicRay() throws Exception {
        
        OfflineExtractor extractor = new OfflineExtractor(fsDataDir);
        
        for (FsId id: this.ids) {
            FloatMjdTimeSeries crs = extractor.readCosmicRaySeries(id);
            system.out().println(crs.toPipeString());
        }
    }

    private void extractBlob() throws Exception {
        byte[] buf = new byte[1024*512];
        OfflineExtractor extractor = new OfflineExtractor(fsDataDir);
        for (FsId id : this.ids) {
            StreamedBlobResult sblob = extractor.readBlob(id);
            system.out().println(id + " " + sblob.originator());
            File blobDir = new File(outputDir, id.path().substring(1));
            blobDir.mkdirs();
            File outputFile = new File(blobDir, id.name());
            FileOutputStream fout = new FileOutputStream(outputFile);
            InputStream in = sblob.stream();
            while (true) {
                int nBytes = in.read(buf);
                if (nBytes <0) {
                    break;
                }
                fout.write(buf, 0, nBytes);
            }
            
            fout.close();
            in.close();
        }
    }
    
    private void extractTs() throws Exception {
        
        OfflineExtractor extractor = new OfflineExtractor(fsDataDir);
 
        for (FsId id: this.ids) {
            TimeSeries ts = extractor.readTimeSeries(id);
            system.out().println(ts.toPipeString());
        }
    }
    
    private String getArg(String[] argv, int i, String errMsg) {
        if (i >= argv.length) {
            throw new IllegalArgumentException("Missing " + errMsg);
        }
        return argv[i];
    }
    
    /**
     * @param args
     */
    public static void main(String[] argv) throws Exception {
        Extractor extractor = new Extractor(new DefaultSystemProvider());
        extractor.parse(argv);
        extractor.execute();
    }

}
