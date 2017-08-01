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

package gov.nasa.spiffy.common.io;

import gov.nasa.spiffy.common.os.OperatingSystemType;
import gov.nasa.spiffy.common.os.ProcessUtils;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.Closeable;
import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.MappedByteBuffer;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ConcurrentSkipListSet;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import org.apache.commons.compress.archivers.ArchiveOutputStream;
import org.apache.commons.compress.archivers.tar.TarArchiveEntry;
import org.apache.commons.compress.archivers.tar.TarArchiveInputStream;
import org.apache.commons.compress.archivers.tar.TarArchiveOutputStream;
import org.apache.commons.compress.compressors.CompressorException;
import org.apache.commons.compress.compressors.CompressorInputStream;
import org.apache.commons.compress.compressors.CompressorOutputStream;
import org.apache.commons.compress.compressors.CompressorStreamFactory;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.filefilter.IOFileFilter;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import sun.nio.ch.DirectBuffer;

/**
 * Some handy methods for dealing with files or groups of files.
 * 
 * @author Sean McCauliff
 * 
 */
public class FileUtil {
    static final int BUFFER_SIZE = 1000;

    private static final Log log = LogFactory.getLog(FileUtil.class);

    private static final String TAR_EXTENSION = ".tar";
    private static final String BZIP2_TAR_EXTENSION = ".tbz2";

    private static boolean nativeLibraryInitialized = false;
    
    private static synchronized void initNativeLibrary() {
        if (!nativeLibraryInitialized) {
            try {
                System.loadLibrary("hardlink-linux");
                nativeLibraryInitialized = true;
            } catch (UnsatisfiedLinkError ule) {
                log.warn("Can't load libhardlink-linux.so");
            }
        }
    }
    /**
     * Generates a list of files whose name matches the specified pattern.
     * 
     * @param regex A regular expression pattern, see java.util.regex.Pattern
     * for syntax.
     * @param rootDir Where we should start looking, including this directory.
     * It must exist.
     * @return An empty list if no files where found, else a unique list of
     * files.
     */
    public static List<File> find(String regex, File rootDir)
        throws IOException {
        FileFind ff = new FileFind(regex);
        DirectoryWalker dw = new DirectoryWalker(rootDir);
        dw.traverse(ff);
        return ff.found();
    }

    /**
     * Generates a list of files which match the specified filter.
     * 
     * @param filter An implementation of {@link java.io.FileFilter}.
     * @param rootDir Where we should start looking, including this directory.
     * It must exist.
     * @return An empty list if no files were found, else a list of unique
     * files.
     */
    public static List<File> find(FileFilter filter, File rootDir)
        throws IOException {

        FileFilterFind visitor = new FileFilterFind(filter);
        DirectoryWalker walker = new DirectoryWalker(rootDir);
        walker.traverse(visitor);
        return visitor.found();
    }

    /**
     * Generates a set of files as quickly as possible.
     * 
     * @param rootDir where we should stat looking including this directory.
     * @return An empty set if no files where found, else a unique set of files.
     */
    public static Set<File> parallelFind(File rootDir) throws Exception {
        final Set<File> parallelFind = new ConcurrentSkipListSet<File>();

        ParallelFileVisitor lister = new ParallelFileVisitor() {

            @Override
            public boolean visit(File f) {
                parallelFind.add(f);
                return false;
            }
        };

        ExecutorService exeService = Executors.newFixedThreadPool(Runtime.getRuntime()
            .availableProcessors() * 2);
        ParallelDirectoryWalker pWalker = new ParallelDirectoryWalker(
            exeService, rootDir, lister);
        pWalker.traverse();
        exeService.shutdown();

        return parallelFind;
    }

    /**
     * Removes all files from the given starting point including the starting
     * point. IMPORTANT: This does not detect symlinks which could result in
     * following the link to a directory or file that you had not intended on
     * removing.
     * 
     * @param rootDir This must exist and must be a directory.
     * @throws PipelineException
     */
    public static void removeAll(File rootDir) throws IOException {
        RemoveAll ra = new RemoveAll();
        DirectoryWalker dw = new DirectoryWalker(rootDir);
        try {
            dw.traverse(ra);
        } catch (PipelineException px) {
            throw new RuntimeException("ra will not throw PipelineException.",
                px);
        }
    }

    /**
     * Creates a hardlink. Note this is not supported on Windows. This will not
     * work across different file systems.
     * 
     * @param src The existing file.
     * @param dest The name of the link.
     */
    public static void hardlink(File src, File dest) throws IOException {

        Path srcPath = src.toPath();
        Path destPath = dest.toPath();

        Files.createLink(destPath, srcPath);
    }

    /**
     * Creates a symbolic link. This is not supported on Windows. This will work
     * across different file systems (like NFS).
     * 
     * @param src The existing file
     * @param dest The name of the link.
     */
    public static void symlink(File src, File dest) throws IOException {
        Path srcPath = src.toPath();
        Path destPath = dest.toPath();

        Files.createSymbolicLink(destPath, srcPath);
    }

    /**
     * Creates a symbolic link. This is not supported on Windows. This will work
     * across different file systems (like NFS).
     * 
     * @param src The path of the source file.
     * @param dest The path of the link.
     */
    public static void forceSymlink(String src, String dest) throws IOException {

        File srcFile = new File(src);
        File symlinkFile = new File(dest);
        symlinkFile.delete();
        if (symlinkFile.exists()) {
            throw new IOException("Failed to delete original file \""
                + symlinkFile + "\".");
        }
        FileUtils.forceMkdir(symlinkFile.getParentFile());
        FileUtil.symlink(srcFile, symlinkFile);
    }

    /**
     * Syncs the OS's buffer cache with the disk. On OSs that are not Linux this
     * may not wait until the buffer cache has been flushed to disk.
     * 
     * @throws IOException
     */
    public static void sync() throws IOException {
       switch (OperatingSystemType.getInstance()) {
       case LINUX:
            initNativeLibrary();
            if (nativeLibraryInitialized) {
                nativeSync();
            } else {
                execSync();
            }
            break;
       case MAC_OS_X:
       default:
            execSync();
       }
    }

    /**
     * @param symlink When true this calls ln with "-s" to create a symbolic
     * link.
     */
    private static void execLn(File src, File dest, boolean symlink)
        throws IOException {

        if (dest.exists()) {
            throw new IllegalArgumentException("Dest file \"" + dest
                + "\" exists.");
        }

        Process proc = null;
        String errStr = symlink ? "symlink" : "hardlink";
        try {
            String[] argv = symlink ? new String[] { "ln", "-s",
                src.toString(), dest.toString() } : new String[] { "ln",
                src.toString(), dest.toString() };

            proc = Runtime.getRuntime()
                .exec(argv);

            int exitValue = proc.waitFor();
            if (exitValue != 0) {
                StringBuilder bldr = new StringBuilder();
                InputStream stdout = proc.getInputStream();
                InputStream err = proc.getErrorStream();
                readAll(bldr, stdout);
                readAll(bldr, err);

                throw new IOException(errStr + "failed with error code: "
                    + exitValue + "." + bldr);
            }
        } catch (InterruptedException ie) {
            throw new IOException("Interrupted while waiting for " + errStr
                + " to complete.");
        } finally {
            ProcessUtils.closeProcess(proc);
        }
    }

    static void execSync() throws IOException {
        Process proc = null;
        try {
            proc = Runtime.getRuntime()
                .exec(new String[] { "sync" });
            int exitValue = proc.waitFor();
            if (exitValue != 0) {
                StringBuilder bldr = new StringBuilder();
                InputStream stdout = proc.getInputStream();
                InputStream err = proc.getErrorStream();
                readAll(bldr, stdout);
                readAll(bldr, err);

                throw new IOException("sync failed with error code: "
                    + exitValue + "." + bldr);
            }
        } catch (InterruptedException ie) {
            throw new IOException("Interrupted exception while waiting for "
                + "sync to complete.");
        } finally {
            ProcessUtils.closeProcess(proc);
        }
    }

    static native void nativeLink(String srcAbsolutePathName,
        String destAbsolutePathName, boolean symlink) throws IOException;

    static native void nativeSync();

    /**
     * Assumes ASCII in the input stream.
     * 
     * @param bldr
     * @param in
     * @throws IOException
     */
    public static void readAll(Appendable bldr, InputStream in)
        throws IOException {
        for (int byteValue = in.read(); byteValue != -1; byteValue = in.read()) {
            char c = (char) byteValue;
            bldr.append(c);
        }
    }

    public static void cleanDir(String path) throws IOException {
        cleanDir(new File(path));
    }

    /**
     * @param dir This may be null in which case this does nothing.
     */
    public static void cleanDir(File dir) throws IOException {
        if (dir == null) {
            return;
        }

        if (dir.exists()) {
            FileUtils.forceDelete(dir);
        }
        FileUtils.forceMkdir(dir);
    }

    /**
     * Copies all files in the sourceDir to the destDir.
     */
    public static int copyFiles(String sourceDir, String destDir)
        throws IOException {

        return copyFiles(new File(sourceDir), new File(destDir));
    }

    public static int copyFiles(File sourceDir, File destDir,
        IOFileFilter[] filters) throws IOException {

        int copied = 0;
        if (filters != null) {
            for (IOFileFilter filter : filters) {
                copied += copyFiles(sourceDir, destDir, filter);
            }
        } else {
            copied += copyFiles(sourceDir, destDir);
        }
        return copied;
    }

    public static int copyFiles(File src, File dest) throws IOException {
        return copyFiles(src, dest, CopyOp.COPY, null, true);
    }

    public static int copyFiles(File src, File dest, CopyOp copyOp)
        throws IOException {
        return copyFiles(src, dest, copyOp, null, true);
    }

    public static int copyFiles(File src, File dest, IOFileFilter ioFilter)
        throws IOException {
        return copyFiles(src, dest, CopyOp.COPY, ioFilter, true);
    }

    public static int copyFiles(File src, File dest, IOFileFilter ioFilter,
        boolean includeAll) throws IOException {
        return copyFiles(src, dest, CopyOp.COPY, ioFilter, includeAll);
    }

    /**
     * Similar to the UNIX "cp" command. If src is a directory then this will
     * recursively copy all the files and directories into dest. Unlike cp full
     * copies of files need not be performed, instead hard links or symbolic
     * links can be made. Links will not overwrite existing files and an
     * exception will be thrown if happens. Directories are never linked so it
     * is mostly safe to rm -fr the resulting copy directory.
     * 
     * @param src This must exist. If src is a directory then it is recursively
     * copied into dest. If src is a file then a copy of the file is made.
     * @param dest The place to copy files into.
     * @param copyOp This must be specified by default it is COPY.
     * @param fileFilter This may be null to indicate no filtering is to take
     * place.
     * @return The number of files/directories copied (or linked).
     * @throws IOException
     */
    public static int copyFiles(File src, File dest, CopyOp copyOp,
        IOFileFilter fileFilter) throws IOException {
        return copyFiles(src, dest, copyOp, fileFilter, true);
    }

    /**
     * 
     * @param src This must exist. If src is a directory then it is recursively
     * copied into dest. If src is a file then a copy of the file is made.
     * @param dest The place to copy files into.
     * @param copyOp This must be specified by default it is COPY.
     * @param fileFilter This may be null to indicate no filtering is to take
     * place.
     * @param includeAll If fileFilter is not null, true indicates that all src
     * directories (but not necessarily their contents) should be copied to
     * dest, in other words, empty directories not matching the fileFilter will
     * be created.
     * @return
     * @throws IOException
     */
    public static int copyFiles(File src, File dest, CopyOp copyOp,
        IOFileFilter fileFilter, boolean includeAll) throws IOException {
        if (!src.exists()) {
            throw new IllegalArgumentException("Source file/directory \"" + src
                + "\"does not exist.");
        }

        if (src.isDirectory()) {
            if (dest.isFile()) {
                throw new IllegalArgumentException(
                    "Can not copy src directory \"" + src
                        + "\" into existing destination file \"" + dest + "\".");
            }

            DirectoryWalker dwalker = new DirectoryWalker(src);
            FileCopyVisitor fcopy = new FileCopyVisitor(src, dest, copyOp,
                fileFilter, includeAll);
            dwalker.traverse(fcopy);
            return fcopy.filesCopies();
        }

        File destFile = dest;
        if (dest.exists() && dest.isDirectory()) {
            destFile = new File(dest, src.getName());
        }

        switch (copyOp) {
            case COPY:
                org.apache.commons.io.FileUtils.copyFile(src, destFile);
                break;
            // Actually this will fail if the link already exists.
            case HARD_SHALLOW:
                hardlink(src, destFile);
                break;
            // Actually this will fail if the link already exists.
            case SYMBOLIC_SHALLOW:
                symlink(src, destFile);
                break;
            default:
                throw new IllegalStateException("Unhandled case.");
        }

        return 1;
    }

    /**
     * Copies {@code src} to {@code dest} recursively while preserving sparse
     * files. Both {@code src} and {@code dest} are directories that already
     * exist. Only the contents of {@code src} are copied to {@code dest}.
     * 
     * @param src the source directory
     * @param dest the destination directory
     * @throws IOException if there is a problem accessing the files
     * @throws InterruptedException if the thread performing the copy is
     * interrupted
     */
    public static void copySparseFiles(File src, File dest) throws IOException,
        InterruptedException {

        if (!src.isDirectory() || !src.canRead()) {
            throw new IllegalArgumentException(String.format(
                "src %s must be a readable directory", src.toString()));
        }
        if (!dest.isDirectory() || !dest.canWrite()) {
            throw new IllegalArgumentException(String.format(
                "dest %s must be a writable directory", dest.toString()));
        }

        List<String> args = new ArrayList<String>();
        args.add("/bin/cp");
        args.add("-pr");
        for (File file : src.listFiles()) {
            args.add(file.getAbsolutePath());
        }
        args.add(dest.getPath());

        int cpResult = Runtime.getRuntime()
            .exec(args.toArray(new String[0]))
            .waitFor();
        if (cpResult != 0) {
            log.error(String.format(
                "Could not copy contents of %s to %s; reason unknown",
                src.toString(), dest.toString()));
        }
    }

    /**
     * Calls {@code close} method on given non-null instances of
     * {@code Closeable} ignoring {@code IOException}s.
     * 
     * @param closeable object upon which to invoke {@code close} method. This
     * may be null in which case it is ignored.
     */
    public static void close(Closeable closeable) {
        if (closeable != null) {
            try {
                closeable.close();
            } catch (IOException ignored) {
            }
        }
    }

    public static int countLines(File file) throws IOException {
        BufferedReader reader = new BufferedReader(new FileReader(file));
        int lineCount = 0;

        String oneLine = reader.readLine();
        while (oneLine != null) {
            lineCount++;
            oneLine = reader.readLine();
        }

        reader.close();

        return lineCount;
    }

    public static String getSuffix(File file) {
        return getSuffix(file.getName());
    }

    public static String getSuffix(String filename) {

        String suffix = "";
        int beginIndex = filename.indexOf('.');
        if (beginIndex != -1) {
            suffix = filename.substring(beginIndex);
        }
        return suffix;
    }

    public static String getBasename(File file) {
        return getBasename(file.getName());
    }

    public static String getBasename(String filename) {

        String basename = filename;
        int endIndex = filename.indexOf('.');
        if (endIndex != -1) {
            basename = filename.substring(0, endIndex);
        }
        return basename;
    }

    /**
     * Like File.mkdirs() except this throws an exception if it was unable to
     * create the directory and does not throw an exception when a directory
     * already exists. This method is safe to call when multiple processes are
     * creating the same directory.
     * 
     * @param dirs
     * @throws IOException
     */
    public static void mkdirs(File dirs) throws IOException {
        if (dirs.exists() && !dirs.isDirectory()) {
            throw new IOException(String.format(
                "Can not create directory \"%s\" "
                    + "because a file with that name exists.", dirs));
        }
        if (dirs.exists()) {
            return;
        }

        if (dirs.mkdirs()) {
            return;
        }

        // Check for errors after failure rather than before just incase
        // there is a race condition with another thread.
        if (!dirs.exists()) {
            throw new IOException(String.format(
                "Failed to create directory \"%s\".", dirs));
        }
    }

    /**
     * Creates a compressed archive of the given file and places it in the same
     * directory as {@code file}. The archive is compressed with bzip2. The name
     * of the returned file will have a ".tbz2" extension.
     * <p>
     * See {@link #createArchive(File, OutputStream)} for a description of the
     * archive.
     * 
     * @param file the source file
     * @return the file object that represents the compressed archive
     * @throws IOException if there were any problems opening or reading the
     * given file or its descendants
     */
    public static File createCompressedArchive(File file) throws IOException {
        File archive = new File(file.getParent(), file.getName()
            + BZIP2_TAR_EXTENSION);

        // Set up the output stream.
        OutputStream outputStream = new BufferedOutputStream(
            new FileOutputStream(archive));
        CompressorOutputStream compressorOutputStream;
        try {
            compressorOutputStream = new CompressorStreamFactory().createCompressorOutputStream(
                CompressorStreamFactory.BZIP2, outputStream);
        } catch (CompressorException e) {
            throw new PipelineException(
                "Received an unexpected exception while creating compressor output stream",
                e);
        }
        createArchive(file, compressorOutputStream);

        return archive;
    }

    /**
     * Creates an archive of the given file and places it in the same directory
     * as {@code file}. The name of the returned file will have a ".tar"
     * extension.
     * <p>
     * See {@link #createArchive(File, OutputStream)} for a description of the
     * archive.
     * 
     * @param file the source file
     * @return the file object that represents the compressed archive
     * @throws IOException if there were any problems opening or reading the
     * given file or its descendants
     */
    public static File createArchive(File file) throws IOException {

        File archive = new File(file.getParent(), file.getName()
            + TAR_EXTENSION);
        BufferedOutputStream outputStream = new BufferedOutputStream(
            new FileOutputStream(archive));
        createArchive(file, outputStream);

        return archive;
    }

    /**
     * Creates an archive of the given file and places it in the given output
     * stream.
     * <p>
     * The file is archived with tar. The entries in the archive will be
     * relative to {@code file}, including {@code file}. For example, if
     * {@code file} is {@code /a/b/c} and contains {@code d}, the archive will
     * contain the entry {@code c/d}. Symbolic links are not preserved. Files
     * are limited to 2 GB.
     * 
     * @param file the source file
     * @param outputStream the archive output stream
     * @throws IOException if there were any problems opening or reading the
     * given file or its descendants
     */
    public static void createArchive(File file, OutputStream outputStream)
        throws IOException {

        TarArchiveOutputStream tarOutputStream = new TarArchiveOutputStream(
            outputStream);
        tarOutputStream.setLongFileMode(TarArchiveOutputStream.LONGFILE_GNU);

        // Loop through the files recursively found in file and add to archive.
        FileVisitor visitor = new TarArchiveVisitor(file.getParentFile(),
            tarOutputStream);
        new DirectoryWalker(file).traverse(visitor);

        // Close output stream.
        tarOutputStream.finish();
        tarOutputStream.close();
    }

    /**
     * Extracts the compressed archive.
     * 
     * @param outputDir existing directory into which archive is to be extracted
     * @param sourceFile the compressed source archive
     * 
     * @throws IOException if there were any problems opening or reading the
     * given file or extracting its contents
     */
    public static void extractCompressedArchive(File outputDir, File sourceFile)
        throws IOException {

        extractCompressedArchive(outputDir, new FileInputStream(sourceFile));
    }

    /**
     * Extracts the compressed archive.
     * 
     * @param outputDir existing directory into which archive is to be extracted
     * @param sourceStream the compressed source archive
     * 
     * @throws IOException if there were any problems opening or reading the
     * given file or extracting its contents
     */
    public static void extractCompressedArchive(File outputDir,
        InputStream sourceStream) throws IOException {

        InputStream inputStream = new BufferedInputStream(sourceStream);
        CompressorInputStream compressorInputStream = null;
        try {
            compressorInputStream = new CompressorStreamFactory().createCompressorInputStream(inputStream);
        } catch (CompressorException e) {
            throw new PipelineException(
                "Received an unexpected exception while creating compressor input stream",
                e);
        }

        extractArchive(outputDir, compressorInputStream);
    }

    /**
     * Extract archive from the given {@code inputStream} into the given
     * {@code outputDir}.
     * 
     * @param outputDir existing directory into which archive is to be extracted
     * @param archive the source archive
     * 
     * @throws IOException if there were any problems opening or reading the
     * given file or extracting its contents
     */
    public static void extractArchive(File outputDir, File archive)
        throws IOException {

        BufferedInputStream inputStream = new BufferedInputStream(
            new FileInputStream(archive));
        extractArchive(outputDir, inputStream);
    }

    /**
     * Extract archive from the given {@code inputStream} into the given
     * {@code outputDir}.
     * 
     * @param outputDir existing directory into which archive is to be extracted
     * @param inputStream the source archive
     * 
     * @throws IOException if there were any problems opening or reading the
     * given file or extracting its contents
     */
    public static void extractArchive(File outputDir, InputStream inputStream)
        throws IOException {

        if (outputDir == null) {
            throw new NullPointerException("outputDir can't be null");
        }
        if (!outputDir.isDirectory()) {
            throw new IOException("outputDir must be an existing directory");
        }

        TarArchiveInputStream tarInputStream = new TarArchiveInputStream(
            inputStream);
        try {
            TarArchiveEntry tarEntry = tarInputStream.getNextTarEntry();
            while (tarEntry != null) {
                File outputFile = new File(outputDir, tarEntry.getName());
                if (tarEntry.isDirectory()) {
                    FileUtil.mkdirs(outputFile);
                } else {
                    FileUtil.mkdirs(outputFile.getParentFile());
                    OutputStream outputStream = new BufferedOutputStream(
                        new FileOutputStream(outputFile));

                    byte[] content = new byte[BUFFER_SIZE];
                    for (int bytesRead = tarInputStream.read(content); bytesRead != -1; bytesRead = tarInputStream.read(content)) {
                        outputStream.write(content, 0, bytesRead);
                    }
                    outputStream.close();
                }
                setMode(outputFile, tarEntry.getMode());

                tarEntry = tarInputStream.getNextTarEntry();
            }
        } finally {
            tarInputStream.close();
        }
    }

    /**
     * Gets the mode of the given file. The File object must correspond to a
     * file that exists on disk.
     * <p>
     * The File class cannot discern between the difference classes of users, so
     * this function just returns 04s, 0222, or 0111 depending on whether this
     * application can read, write, or execute the given file. If finer grained
     * permissions are needed, the PosixFileAttributes class of NIO-2 (Java 7)
     * can be used. Or even Runtime.exec("ls -l ...").
     * 
     * @param file file whose modes need updating
     * @param mode permission mask
     * @throws IllegalStateException if {@code file} does not exist
     */
    public static int getMode(File file) {
        if (!file.exists()) {
            throw new IllegalStateException(file + " must exist");
        }

        int mask = 0;
        if (file.canRead()) {
            mask |= 0444;
        }
        if (file.canWrite()) {
            mask |= 0222;
        }
        if (file.canExecute()) {
            mask |= 0111;
        }

        return mask;
    }

    /**
     * Sets the given modes on the given file. The File object must correspond
     * to a file that already exists on disk.
     * <p>
     * The File class cannot discern between group and other, so this method
     * will use the group permission to set both of them. If finer grained
     * permissions are needed, the PosixFileAttributes class of NIO-2 (Java 7)
     * can be used. Or even Runtime.exec("chmod ...").
     * 
     * @param file file whose modes need updating
     * @param mode permission mask
     * @throws IllegalStateException if {@code file} does not exist
     */
    public static void setMode(File file, int mode) {
        if (!file.exists()) {
            throw new IllegalStateException(file + " must exist");
        }

        // TODO This functionality must already exist out there!
        file.setReadable(false, false);
        if (file.setReadable((mode & 0400) != 0, (mode & 0040) == 0) == false) {
            log.warn("Could not set read permissions on " + file);
        }
        file.setWritable(false, false);
        if (file.setWritable((mode & 0200) != 0, (mode & 0020) == 0) == false) {
            log.warn("Could not set write permissions on " + file);
        }
        file.setExecutable(false, false);
        if (file.setExecutable((mode & 0100) != 0, (mode & 0010) == 0) == false) {
            log.warn("Could not set execute permissions on " + file);
        }
    }

    /**
     * This use classes that are internal to the Sun/Oracle Java implementation
     * to unmap a memory mapped file. A memory mapped byte buffer does not have
     * an unmap method for some reason. The Sun/Oracle implementation of the
     * memory mapped byte buffer relies on GC to garbage collect the mmap which
     * it may never do leading to false OOM conditions.
     * 
     * @param buffer
     */
    public static void unmap(MappedByteBuffer buffer) {
        sun.misc.Cleaner cleaner = ((DirectBuffer) buffer).cleaner();
        cleaner.clean();
    }

    private static class TarArchiveVisitor implements FileVisitor {

        private final ArchiveOutputStream tarOutputStream;
        private final String stripPrefix;

        public TarArchiveVisitor(File stripPrefixFile,
            ArchiveOutputStream tarOutputStream) {
            stripPrefix = stripPrefixFile.getAbsolutePath();
            this.tarOutputStream = tarOutputStream;
        }

        @Override
        public void enterDirectory(File dir) throws IOException,
            PipelineException {
        }

        @Override
        public void exitDirectory(File dir) throws IOException,
            PipelineException {
        }

        @Override
        public void visitFile(File dir, File file) throws IOException,
            PipelineException {

            TarArchiveEntry entry = new TarArchiveEntry(file,
                getRelativeFilename(file));
            entry.setSize(file.length());
            entry.setMode(getMode(file));
            tarOutputStream.putArchiveEntry(entry);

            InputStream inputStream = new BufferedInputStream(
                new FileInputStream(file));

            byte[] bytes = new byte[BUFFER_SIZE];
            for (int bytesRead = inputStream.read(bytes); bytesRead != -1; bytesRead = inputStream.read(bytes)) {
                tarOutputStream.write(bytes, 0, bytesRead);
            }

            inputStream.close();

            tarOutputStream.closeArchiveEntry();
        }

        private String getRelativeFilename(File file) {

            // Ensure that filename starts with the given prefix.
            String filename = file.getAbsolutePath();
            if (filename.length() < stripPrefix.length()) {
                throw new IllegalStateException(String.format(
                    "Filename %s is shorter than its expected prefix %s",
                    filename, stripPrefix));
            }
            for (int i = 0; i < stripPrefix.length(); i++) {
                if (filename.charAt(i) != stripPrefix.charAt(i)) {
                    throw new IllegalStateException(
                        String.format(
                            "Filename %s does not start with the expected prefix %s",
                            filename, stripPrefix));
                }
            }

            int offset = stripPrefix.length();
            if (filename.charAt(offset) == File.separatorChar) {
                offset++;
            }

            return filename.substring(offset);
        }

        @Override
        public boolean prune() {
            return false;
        }
    }
}
