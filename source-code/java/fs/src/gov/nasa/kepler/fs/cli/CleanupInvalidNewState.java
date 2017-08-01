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

import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.server.index.DiskNodeIO;
import gov.nasa.kepler.fs.server.index.KeyValueIO;
import gov.nasa.kepler.fs.server.index.TreeNodeFactory;
import gov.nasa.kepler.fs.server.index.AbstractDiskNodeIO.CacheNodeKey;
import gov.nasa.kepler.fs.server.index.DiskNodeIO.BtreeFileVersion;
import gov.nasa.kepler.fs.server.index.blinktree.BLinkNode;
import gov.nasa.kepler.fs.server.index.blinktree.BLinkTree;
import gov.nasa.kepler.fs.server.index.blinktree.InternalNode;
import gov.nasa.kepler.fs.server.index.blinktree.LeafNode;
import gov.nasa.kepler.fs.server.index.blinktree.NodeLockFactory;
import gov.nasa.kepler.fs.storage.FsIdInfo;
import gov.nasa.kepler.fs.storage.RandomAccessAllocator.RandomAccessKeyValueIo;
import gov.nasa.spiffy.common.collect.LruCache;

import java.io.File;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.MissingOptionException;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import static gov.nasa.kepler.fs.storage.AbstractStorageAllocator.BTREE_NODE_SIZE;

public class CleanupInvalidNewState {

    private static final Log log = LogFactory.getLog(CleanupInvalidNewState.class);
    
    @SuppressWarnings("static-access")
    private static final Option fixOption = 
        OptionBuilder.withDescription("fix bad new states")
        .withLongOpt("fix")
        .isRequired(false)
        .create("f");
    
    @SuppressWarnings("static-access")
    private static final Option indexFileOption = 
        OptionBuilder.withDescription("index file name")
        .withLongOpt("index-file")
        .isRequired(true)
        .hasArg(true)
        .create("i");
    

    private static final Options options = new Options() {{
        addOption(indexFileOption);
        addOption(fixOption);
    }};
    
    private static void printHelp() {
        HelpFormatter helpFormatter = new HelpFormatter();
        helpFormatter.printHelp(80, "./runjava clean-index-file-new-state ", "", options, "", true);
    }
    
    /**
     * @param argv
     */
    public static void main(String[] argv) throws Exception {

        if (argv.length == 0) {
            printHelp();
            System.exit(-1);
        }
        
        GnuParser gnuParser = new GnuParser();
        CommandLine commandLine = null;
        try {
            commandLine = gnuParser.parse(options, argv);
        } catch (MissingOptionException mox) {
            printHelp();
            throw mox;
        }
        
        boolean fix = commandLine.hasOption(fixOption.getOpt());
        String indexFileName = commandLine.getOptionValue(indexFileOption.getOpt());
        File indexFile = new File(indexFileName);
        
        LruCache<CacheNodeKey, BLinkNode<FsId, FsIdInfo>> destCache = 
            new LruCache<CacheNodeKey, BLinkNode<FsId, FsIdInfo>>(256);
        
        KeyValueIO<FsId, FsIdInfo> keyValueIo = new RandomAccessKeyValueIo();
        NodeLockFactory lockFactory = new NodeLockFactory();
        TreeNodeFactory<FsId, FsIdInfo, BLinkNode<FsId, FsIdInfo>> destNodeFactory = 
            BLinkNode.nodeFactory(lockFactory, FsId.comparator);
        
        DiskNodeIO<FsId, FsIdInfo, BLinkNode<FsId,FsIdInfo>> nodeIo =
            new DiskNodeIO<FsId, FsIdInfo, BLinkNode<FsId,FsIdInfo>>(
                keyValueIo, indexFile, BTREE_NODE_SIZE, destCache, destNodeFactory,
                BtreeFileVersion.VERSION_1);
        
        final int leafM = LeafNode.leafM(keyValueIo, BTREE_NODE_SIZE);
        final int internalM = InternalNode.internalM(keyValueIo, BTREE_NODE_SIZE);
        
        BLinkTree<FsId, FsIdInfo> index = 
            new BLinkTree<FsId, FsIdInfo>(nodeIo, leafM,
                internalM, FsId.comparator, lockFactory);
        
        Set<FsId> badIds = new HashSet<FsId>();
        for (Map.Entry<FsId, FsIdInfo> indexEntry : index) {
            FsIdInfo fileIds = indexEntry.getValue();
            if (!fileIds.isNew()) {
                continue;
            }
            
            badIds.add(indexEntry.getKey());
        }
        
        for (FsId id : badIds) {
            log.error("FsId \"" + id + "\" has invalid isNew=true.");
            if (fix) {
                index.delete(id);
            }
        }
        
        if (fix) {
            nodeIo.flushPendingModifications();
        }
        
    }

}
