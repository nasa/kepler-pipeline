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

package gov.nasa.kepler.ar;

import gov.nasa.spiffy.common.collect.ListChunkIterator;
import gov.nasa.spiffy.common.io.DirectoryWalker;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.FileVisitor;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * If there are more than maxFiles in a directory move them into
 * sub directories with fewer files.  This is not MT-safe.
 * 
 * @author Sean McCauliff
 *
 */
public class DirectorySplitter  {

    private static final Log log = LogFactory.getLog(DirectorySplitter.class);
    
    private static final Pattern numberPattern = Pattern.compile("(\\d+)");
    
    public void split(final int maxFiles, final File srcDir, final File destDir) throws IOException {
        if (maxFiles < 3) {
            throw new IllegalArgumentException("maxFiles must be greater than " +
                "or equal to 3.  Got " + maxFiles + ".");
        }
        
        if (srcDir.getAbsolutePath().indexOf(destDir.getAbsolutePath()) == 0) {
            throw new IllegalArgumentException("src dir is a sub directory of dest dir.");
        }
        
        if (destDir.getAbsolutePath().indexOf(srcDir.getAbsolutePath()) == 0) {
            throw new IllegalArgumentException("dest dir is a sub directory of src dir.");
        }
        
        final Map<File, File> srcDirToDestDir = new HashMap<File, File>();
        FileVisitor visitor = new FileVisitor() {
            @Override
            public void enterDirectory(File newdir) throws IOException,
            PipelineException {
                splitDirectory(newdir, srcDir, destDir, maxFiles, srcDirToDestDir);
            }

            @Override
            public void exitDirectory(File exitdir) throws IOException,
            PipelineException {
                //Nothing
            }

            @Override
            public boolean prune() {
                return false;
            }

            @Override
            public void visitFile(File dir, File f) throws IOException,
            PipelineException {
                //Nothing.
            }
        };

        DirectoryWalker walker = new DirectoryWalker(srcDir);
        walker.traverse(visitor);
    }
    
    /**
     * 
     * @param currentDir  The current directory under srcDir
     * @param srcRoot The root of the source files.
     * @param destRoot The root of the dest files.
     * @param maxFiles The approximate maximum number of files in a directory.
     * @param srcDirToDestDir mapping of the original source directory to the
     *  new destination directory.  This should be persistent across invocations
     *  of this method.
     *  
     * @throws IOException
     */
    private void splitDirectory(File currentDir, File srcRoot, File destRoot,
                final int maxFiles, Map<File, File> srcDirToDestDir) throws IOException {
        
        String[] fileNames = currentDir.list();
        Arrays.sort(fileNames, new KeplerFileNameComparator());
        
        List<String> allFiles = new ArrayList<String>(Arrays.asList(fileNames));
        File destDirectory = srcDirToDestDir.get(currentDir);
        if (destDirectory == null) {
            destDirectory = new File(destRoot, pathFromRoot(srcRoot, currentDir));
            FileUtil.mkdirs(destDirectory);
        }
        
        log.info("Linking files in directory \"" + currentDir + 
            "\" to \"" + destDirectory +  "\".");
        
//        destDirectory = new File(destDirectory, parsePrefix(fileNames.get(0)));
//        FileUtil.mkdirs(destDirectory);
        
        Chunk initialChunk = new Chunk(destDirectory, allFiles);
        for (Chunk c : makeChunks(initialChunk, maxFiles)) {
            FileUtil.mkdirs(c.destDirectory);
            for (String srcFileName : c.fileNames) {
                File srcFile = new File(currentDir, srcFileName);
                File destFile = new File(c.destDirectory, srcFileName);
                if (srcFile.isDirectory()) {
                    FileUtil.mkdirs(destFile);
                    srcDirToDestDir.put(srcFile, destFile);
                } else {
                    if (log.isDebugEnabled()) {
                        log.debug("Linking \"" + srcFile + "\" -> \"" + destFile + "\".");
                    }
                    FileUtil.hardlink(srcFile, destFile);
                }
            }
        }
       
    }
    
    private List<Chunk> makeChunks(final Chunk startChunk, final int maxFiles) {
        List<Chunk> newChunks = new ArrayList<Chunk>();
        
        //Don't create more than maxFiles directories in this directory.
        final int nNewDir = Math.min(maxFiles, (int) Math.ceil(startChunk.size() / (double) maxFiles));
        final int chunkSize = (int) Math.ceil(startChunk.size() / (double) nNewDir);
        
        List<String> nextChunk = null;
        for (ListChunkIterator<String> it = 
                new ListChunkIterator<String>(startChunk.fileNames.iterator(), chunkSize);
            it.hasNext();
            ) {
            
            List<String> currentChunk = null;
            if (nextChunk != null) {
                currentChunk = nextChunk;
                nextChunk = null;
            } else {
                currentChunk = it.next();
            }
            
            if (currentChunk.size() == 0) {
                continue;
            }
            
          
            if (it.hasNext()) {
                nextChunk = keepPrefixesTogether(it, currentChunk);
            }
            File chunkDestDirectory = new File(startChunk.destDirectory, parsePrefix(currentChunk.get(0)));
            newChunks.add(new Chunk(chunkDestDirectory, currentChunk));
        }
        
        if (nextChunk != null && nextChunk.size() != 0) {
            File chunkDestDirectory = new File(startChunk.destDirectory, parsePrefix(nextChunk.get(0)));
            newChunks.add(new Chunk(chunkDestDirectory, nextChunk));
        }
        
        //Number of chunks did not change.
        if (newChunks.size() == 1) {
            return Collections.singletonList(startChunk);
        }
        
        List<Chunk> rv = new ArrayList<Chunk>();
        for (Chunk c : newChunks) {
            rv.addAll(makeChunks(c, maxFiles));
        }
        return rv;
    }

    private List<String> keepPrefixesTogether(ListChunkIterator<String> it,
        List<String> currentChunk) {
        List<String> nextChunk;
        do {
            nextChunk = it.next();
            
            //Don't break across file prefixes
            String lastFnamePrefix = parsePrefix(currentChunk.get(currentChunk.size() - 1));
            Iterator<String> nextIt = nextChunk.iterator();
            while (nextIt.hasNext()) {
                String nextFname = nextIt.next();
                if (!lastFnamePrefix.equals(parsePrefix(nextFname))) {
                    break;
                }
                currentChunk.add(nextFname);
                nextIt.remove();
            }
        } while (nextChunk.size() == 0 && it.hasNext());
        return nextChunk;
    }
    
    private String pathFromRoot(File rootDir, File currentDir) {
        return currentDir.getAbsolutePath().substring(rootDir.getAbsolutePath().length());
    }
    
    private static String parsePrefix(String s) {
        if (!s.startsWith("kplr")) {
            int dotIndex = s.indexOf('.');
            if (dotIndex != -1) {
                return s.substring(0, dotIndex);
            }
            return s;
        } else {
            int endIndex=4;
            for (; endIndex < s.length(); endIndex++) {
                char c = s.charAt(endIndex);
                if (!(Character.isDigit(c) && c != '.')) {
                    break;
                }
            }
            return s.substring(0, endIndex);
        }

    }
    
    private static final long parseFirstNumber(String s) {
        Matcher m = numberPattern.matcher(s);
        if (!m.find()) {
            return -1;
        }
        return Long.parseLong(m.group(1));
    }
    
    private static final class Chunk {
        private final File destDirectory;
        private List<String> fileNames;
        
        /**
         * @param destDirectory
         * @param fileNames
         */
        public Chunk(File destDirectory, List<String> fileNames) {
            super();
            this.destDirectory = destDirectory;
            this.fileNames = fileNames;
        }

        public int size() {
            return fileNames.size();
        }
    }
    
    private static final class KeplerFileNameComparator implements Comparator<String> {

        @Override
        public int compare(String o1, String o2) {
            if (!(o1.startsWith("kplr") && o2.startsWith("kplr"))) {
                return o1.compareTo(o2);
            }
            
            long n1 = parseFirstNumber(o1);
            long n2 = parseFirstNumber(o2);
            if (n1 < n2) {
                return -1;
            } else if (n1 > n2) {
                return 1;
            } else {
                return 0;
            }
        }
        
       
    }
}
