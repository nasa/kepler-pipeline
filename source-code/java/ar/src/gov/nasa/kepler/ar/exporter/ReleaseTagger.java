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


package gov.nasa.kepler.ar.exporter;

import static gov.nasa.kepler.common.FitsConstants.*;

import gov.nasa.spiffy.common.concurrent.MiniWork;
import gov.nasa.spiffy.common.concurrent.MiniWorkPool;
import gov.nasa.spiffy.common.io.DirectoryWalker;
import gov.nasa.spiffy.common.io.FileVisitor;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import nom.tam.fits.FitsException;
import nom.tam.fits.Header;
import nom.tam.fits.HeaderCardException;
import nom.tam.util.BufferedFile;

/**
 * Tags files in specified directory with release tag.
 * 
 * @author Sean McCauliff
 *
 */
public class ReleaseTagger  {

    private static final Log log = LogFactory.getLog(ReleaseTagger.class);
    
    private final boolean force;
    private final FileNameFormatter fnameFormatter = new FileNameFormatter();
    private final String quarter;
    private final String dataRelease;
    private final AtomicInteger filesProcessed = new AtomicInteger();
    
    /**
     * 
     * @param force when true assign tags that have been assigned already.
     * @param dataRel Data release string.  This may be null, if no replacement
     * is desired.
     * @param quarter Quarter string.  This may be null, if no replacement is
     * desired.
     */
    public ReleaseTagger(boolean force, String quarter, String dataRelease) {
        this.force = force;
        this.quarter = quarter;
        this.dataRelease = dataRelease;
    }
    
    /**
     * Traverse files in the specified directory.
     * @param rootDirectory
     * @throws IOException 
     * @throws InterruptedException 
     */
    public void tag(File rootDirectory) throws IOException, InterruptedException {
        final List<File> processFiles = new ArrayList<File>();
        
        DirectoryWalker dirWalker = new DirectoryWalker(rootDirectory);
        dirWalker.traverse(new FileVisitor() {
            
            @Override
            public void visitFile(File dir, File f) throws IOException,
                PipelineException {
                if (f.isDirectory()) {
                    return;
                }
                
                
                String fname = f.getName();
                if (fnameFormatter.isCadencePixelName(fname) ||
                    fnameFormatter.isCosmicRayName(fname) ||
                    fnameFormatter.isFluxName(fname) ||
                    fnameFormatter.isCalFfi(fname)) {
                    processFiles.add(f);
                }
            }
            
            /**
            * This does nothing.
            */
           @Override
           public void enterDirectory(File newdir) throws IOException,
               PipelineException {
               log.info("Entered directory \"" + newdir + "\".");
           }

           /**
            * This does nothing.
            */
           @Override
           public void exitDirectory(File exitdir) throws IOException,
               PipelineException {
               //This does nothing.
           }

           /**
            * This does nothing.
            */
           @Override
           public boolean prune() {
               return false;
           }
        });
        
        MiniWork<File> miniWork = new MiniWork<File>() {

            @Override
            protected void doIt(File f) throws Throwable {
                String fname = f.getName();
                if (fnameFormatter.isCadencePixelName(fname) ||
                    fnameFormatter.isCosmicRayName(fname) ||
                    fnameFormatter.isCalFfi(fname)) {

                    logProcessed();
                    try {
                        BufferedFile bufferedFile = new BufferedFile(f, "rw");
                        Header primaryHeader = Header.readHeader(bufferedFile);
                        replace(primaryHeader, f, QUARTER_KW, QUARTER_VALUE, QUARTER_COMMENT, quarter);
                        replace(primaryHeader, f, DATA_REL_KW, DATA_REL_VALUE, DATA_REL_COMMENT, dataRelease);
                        bufferedFile.seek(0);
                        primaryHeader.write(bufferedFile);
                        bufferedFile.close();
                    } catch (FitsException e) {
                        throw new PipelineException(e);
                    }
                    
                } else if (fnameFormatter.isFluxName(fname)) {
                    logProcessed();
                    try {
                        BufferedFile bufferedFile = new BufferedFile(f, "rw");
                        //read past the primary header
                        Header.readHeader(bufferedFile);
                        long pos = bufferedFile.getFilePointer();
                        Header extensionHeader = Header.readHeader(bufferedFile);
                        replace(extensionHeader, f, QUARTER_KW, QUARTER_VALUE, QUARTER_COMMENT, quarter);
                        replace(extensionHeader, f, DATA_REL_KW, DATA_REL_VALUE, DATA_REL_COMMENT, dataRelease);
                        bufferedFile.seek(pos);
                        extensionHeader.write(bufferedFile);
                        bufferedFile.close();
                    } catch (FitsException e) {
                        throw new PipelineException(e);
                    }
                }
            }
            
        };
        
        MiniWorkPool<File> pool = 
            new MiniWorkPool<File>("release tagger", processFiles, miniWork);
        pool.performAllWork();
    }

    
    private void logProcessed() {
        int nProcessed = filesProcessed.getAndIncrement();
        if (( nProcessed + 1 )% 1000 == 0) {
            log.info("Processed " + nProcessed + "files.");
        }
    }
    
    private void replace(Header header, File f, String keyword, 
        String unassignedValue, String keywordComment, String newValue) 
        throws HeaderCardException {
        
        if (newValue == null) {
            return;
        }
        
        if (!header.containsKey(keyword)) {
            throw new IllegalArgumentException("File \"" + f +
                "\" does not contain expected keyword \"" + keyword + "\"");
        }
        if (!force && !header.getStringValue(keyword).equals(unassignedValue)) {
            throw new IllegalArgumentException("File \"" + f + "\" has already been tagged.");
        }
            
        header.addValue(keyword, newValue, keywordComment);
    }
    
    
}
