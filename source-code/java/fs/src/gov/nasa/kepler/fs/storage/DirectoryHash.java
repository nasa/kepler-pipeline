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

package gov.nasa.kepler.fs.storage;

import gov.nasa.spiffy.common.io.DirectoryWalker;
import gov.nasa.spiffy.common.io.FileFind;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.math.BigInteger;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.regex.Pattern;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;


/**
 * Given an string "id" computes the directory it should go into. The user
 * should select the maximum number of files per directory that is efficent for
 * the file system type being used and the maxinum number of total files to
 * be stored.  The hash algorithm does not gaurentee this to be tight bounds.<br>
 * Rehashing is not supported.<br>
 * Unlike other file -> directory hashing implementations this assumes the ids
 * are "short" and unique strings, and can be included as part of a file name.
 * If file names are large relative to the data the files  contain then the
 * filesystem performance can be degraded encoding these names.<br>
 * This class is MT-safe
 * 
 * @author Sean McCauliff
 * 
 */
public class DirectoryHash {

    private final ConcurrentMap<File, File> hashDirectoryCache = 
        new ConcurrentHashMap<File, File>();
    
    /** 
     * Logger for this class.
     */
    private static final Log log = LogFactory.getLog(DirectoryHash.class);
    
    /** Prefix this name before directories used to hash files into. */
    private static final String DIR_PREFIX = "hd-";

    /** Suffix this name to ids to create their file names.  This is done
     *  here so that file ids can contain only unique information.  This makes
     *  the hashing work better.
     */
    public static final String FILE_SUFFIX = ".data";

    /**
     * The number of hash directories. This should be a prime number for hashing
     * effiency.
     */
    private int nBins;

    /** The root of where these directories will reside. */
    private final File rootDir;

    /** Number of levels of directories. */
    private int nLevels;

    /** The desired maxinum number of files per directory. */
    private int maxFilesPerDir;

    /**
     * Performance data about how many collisions the hash function is
     * generating.
     * 
     * @author Sean McCauliff
     * 
     */
    public static class Performance {
        public final int[] filesPerDir;
        public final int totalCount;

        public final String message;
        
        Performance(int[] filesPerDir, int totalCount, String message) {
            this.filesPerDir = filesPerDir;
            this.totalCount = totalCount;
            this.message = message;
        }
    }

    /**
     * Initalizes a new directory hash.
     * 
     * @param nFiles The maxinum number of files per directory.
     * @param maxFilePerDir The expected maxinum number of files.
     * @param rootDir The root of the directory hash. It must not exist.
     * 
     * @exception IOException When creating directories.
     * @exception IllegalArgumentException If rootDir is invalid.
     */
    public DirectoryHash(int nFiles, int maxFilesPerDir, File rootDir)
        throws IOException, IllegalArgumentException {

        this.rootDir = rootDir;
        this.maxFilesPerDir = maxFilesPerDir;

        if (nFiles < 1) {
            throw new IllegalArgumentException(
                "Number of files must be positive.");
        }
        if (maxFilesPerDir < 2) {
            throw new IllegalArgumentException(
                "maxFilesPerDir must be greater than 1.");
        }

        nBins = (int) Math.ceil((double) nFiles / (double) maxFilesPerDir);
        BigInteger bigBins = new BigInteger(Integer.toString(nBins));
        BigInteger maxBins = new BigInteger(Integer.toString(Integer.MAX_VALUE));
        if (!bigBins.isProbablePrime(32)) { // P(prime|not prime) ~ 1/2^32
            bigBins = bigBins.nextProbablePrime();
            this.nBins = bigBins.intValue();
            if (bigBins.compareTo(maxBins) >= 0) {
                throw new IllegalArgumentException("Too many bins:" + nBins);
            }
        }
        nLevels = (int) (Math.log(nBins) / Math.log(maxFilesPerDir));

        // There is some maxinum file name length on most OSes. Just taking
        // a guess here.
        if (nLevels > 10) {
            throw new IllegalArgumentException("Too many levels:" + 10);
        }
        init();
    }

    /**
     * Reads in an existing hash.
     * 
     * @param rootDir An existing directory hash.
     * @param nBins The number of bins used to create the orignal.
     * @param maxFilesPerDir The maximum number of files per directory.
     * This also limits the numer of sub hash directories that are used.
     * @throws IOException When reading directories.
     * @throws IllegalArgumentException If rootDir is invalid.
     */
    DirectoryHash(File rootDir, int nBins, int nLevels, int maxFilesPerDir)
        throws IOException, IllegalArgumentException {

        this.rootDir = rootDir;
        this.nBins = nBins;
        this.nLevels = nLevels;
        this.maxFilesPerDir = maxFilesPerDir;
    }

    /**
     * Intalizes the root of the directory hash
     * 
     * @param rootDir The directory used to hash files into. It must not exist.
     */
    private void init() throws IOException, IllegalArgumentException {

        if (nBins < 2) {
            throw new IllegalArgumentException("Insufficent number of bins.");
        }

        for (int i = 0; i < nBins; i++) {
            File binDir = directoryForBin(i);
            binDir.mkdirs();
            if (!binDir.exists()) {
                throw new IOException("Could not create hash directory \"" +
                    binDir + "\".");
            }
        }
    }

    /**
     * Generates the File representing the bin directory where data files should
     * go given the bin index.
     * 
     * @param binId The id of the bin, [0,nBins)
     * @return A File representing a directory. This may not exist.
     */
    private File directoryForBin(int binId) {
        StringBuilder directoryPath = new StringBuilder();
        int remainder = binId;
        for (int i = 0; i < (nLevels - 1); i++) {
            directoryPath.append(DIR_PREFIX);
            directoryPath.append(remainder % maxFilesPerDir);
            directoryPath.append(File.separatorChar);
            remainder = remainder / maxFilesPerDir;
        }
        directoryPath.append(DIR_PREFIX);
        directoryPath.append(remainder);

        File directory = new File(rootDir, directoryPath.toString());
        File cachedDirectory = hashDirectoryCache.get(directory);
        if (cachedDirectory == null) {
            hashDirectoryCache.putIfAbsent(directory, directory);
            cachedDirectory = hashDirectoryCache.get(directory);
        }
        return cachedDirectory;
    }

    /**
     * Validate an existing directory hash structure.
     * 
     * @param fake When true this does not fix anything only logs changes that
     * would be made.
     */
    public void recover(boolean fake) throws IOException {
        if (!rootDir.exists()) {
            throw new IllegalArgumentException("Directory \"" + rootDir
                + "\" does not exist.");
        }
        if (!rootDir.isDirectory()) {
            throw new IllegalArgumentException("File \"" + rootDir
                + "\" is not a directory.");
        }

        for (int i = 0; i < nBins; i++) {
            File binDir = directoryForBin(i);
            if (binDir.exists()) {
                continue;
            }

            log
                .error("Directory hash bin \""
                    + binDir
                    + "\" does not exist.  Recreating directory.  Data may have been lost.");
            if (!fake) {
                if (!binDir.mkdirs()) {
                    throw new IOException("Unable to make directory \""
                        + binDir + "\".");
                }
            }
        }
    }

    /**
     * This value may differ from the number passed to the constructor. This is
     * needed to reconstitute the hash algorithm after initialization.
     * 
     * @return The actual number of bins.
     */
    int getNumberBins() {
        return nBins;
    }

    /**
     * This is the number of levels of directories used by the hash. This is
     * needed to reconstitute the hash algorithm after initalization.
     * 
     * @return A positive integer.
     */
    int getNumberLevels() {
        return nLevels;
    }

    File rootDir() {
        return rootDir;
    }
    
    /**
     * 
     * 
     * @param id the id for the file in question. The assumption is that the id
     * is already unique.
     * @return The corrisponding to this id. This may not exist.
     */
    public File idToFile(String id) {
        int hash = toBin(id);
        File hashDir = directoryForBin(hash);
        return new File(hashDir, id + FILE_SUFFIX);
    }

    private int toBin(String id) {
        // NOTE: This will not work for hashing large numbers of files where #
        // files ~ 2^32
        int hash = id.hashCode();
        //int hash = hashFunction(id);
        if (hash < 0) {
            hash = hash & 0x7FFFFFFF;
        }
        hash = hash % nBins;
        return hash;
    }
    
    /**
     * 
     * @param id
     * @return  The directory for the specified id.
     */
    public File directoryForId(String id) {
        int hash = toBin(id);
        return directoryForBin(hash);
    }


    public String fileToId(File f) {
        if (!f.getName().endsWith(FILE_SUFFIX)) {
            throw new IllegalArgumentException("File has not been hashed.");
        }
        String name = f.getName();
        return name.substring(0, name.length() - FILE_SUFFIX.length());
    }

    /**
     * 
     * @return A list of ids that this hash knows about.  Returns an empty
     * set if there are none.
     * @throws PipelineException 
     */
    public Set<String> findAllIds() throws IOException {
        final Set<String> rv = new HashSet<String>();
        FileFind ff = new FileFind(".+" + Pattern.quote(FILE_SUFFIX)) {
            boolean prune = false;
            
            public void enterDirectory(File newDir) {
                if (!newDir.getName().startsWith("hd-") && !newDir.equals(rootDir)) {
                    prune = true;
                }
            }

            public void visitFile(File dir, File f) throws IOException {
                if (pattern.matcher(f.getName()).matches()) {
                    rv.add(fileToId(f));
                }
            }
            
            public boolean prune() {
                boolean rv = prune;
                prune = false;
                return rv;
            }
        };
        DirectoryWalker dw = new DirectoryWalker(rootDir);
        try {
            dw.traverse(ff);
        } catch (PipelineException px) {
            throw new RuntimeException("ff.visitFile() will not throw this.", px);
        }
        return rv;
    }


    /**
     * Removes this directory hash and all the data stored within it.
     * @throws IOException
     */
    public void delete() throws IOException {
        for (int i=0; i < this.maxFilesPerDir; i++) {
            File hashDirectory = new File(rootDir, DIR_PREFIX+i);
            if (!hashDirectory.exists()) {
                continue;
            }
            FileUtil.removeAll(hashDirectory);
        }
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        
        if (!(o instanceof DirectoryHash)) {
            return false;
        }
        
        DirectoryHash other = (DirectoryHash) o;
        return other.rootDir.equals(rootDir);
    }
    
    @Override
    public int hashCode() {
        return rootDir.hashCode();
    }
    
    /**
     * Compute the hashing collision performance. This may take some time as it
     * accesses every binned directory.
     * 
     * @return A human readable string that describes how efficent the binning
     * is.
     */
    public Performance collisionPerformance() {
        int minFilesPerDir = Integer.MAX_VALUE;
        int maxFilesPerDir = 0;
        int totalFiles = 0;
        int[] filesPerDir = new int[nBins];

        
        for (int i = 0; i < nBins; i++) {
            File d = this.directoryForBin(i);
            final AtomicInteger count = new AtomicInteger(0);
            d.list(new FilenameFilter() {

                public boolean accept(File dir, String name) {
                    if (name.endsWith(FILE_SUFFIX)) {
                        count.incrementAndGet();
                    }
                    return false;
                }
            });
            
            //int count = d.list().length;
            minFilesPerDir = Math.min(minFilesPerDir, count.get());
            maxFilesPerDir = Math.max(maxFilesPerDir, count.get());
            filesPerDir[i] = count.get();
            totalFiles += count.get();
        }

        double mean = (double) totalFiles / (double) nBins;
        double sd = 0.0;
        double chiSquared = 0.0;
        double expectedFilesPerDir = (double) totalFiles / (double) nBins;
        for (int nFiles : filesPerDir) {
            double diff = (nFiles - mean);
            double diffSq = diff * diff;
            sd += diffSq;
            double x = nFiles - expectedFilesPerDir;
            chiSquared += (x * x) / expectedFilesPerDir;
        }

        sd = Math.sqrt(sd * (1.0 / (double) filesPerDir.length));
        Arrays.sort(filesPerDir);
        int median = filesPerDir[filesPerDir.length / 2];
        StringBuilder sb = new StringBuilder();
        sb.append("tot: ");
        sb.append(totalFiles);
        sb.append(" max/dir: ");
        sb.append(maxFilesPerDir);
        sb.append(" min/dir: ");
        sb.append(minFilesPerDir);
        sb.append(" mean: ");
        sb.append(mean);
        sb.append(" median: ");
        sb.append(median);
        sb.append(" sd: ");
        sb.append(sd);
        sb.append(" chi^2: ");
        sb.append(chiSquared);
        Performance p = new Performance(filesPerDir, totalFiles, sb.toString());
        return p;
    }
    
    public static String toFileName(String id) {
        return id + FILE_SUFFIX;
    }
}
