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

package gov.nasa.kepler.fs.server.xfiles;

import static gov.nasa.kepler.fs.FileStoreConstants.BLOB_DIR_NAME;
import static gov.nasa.kepler.fs.FileStoreConstants.MJD_TIME_SERIES_DIR_NAME;
import static gov.nasa.kepler.fs.FileStoreConstants.FLOAT_TYPE;
import static gov.nasa.kepler.fs.FileStoreConstants.TIME_SERIES_DIR_NAME;

import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.api.FileStoreIdNotFoundException;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.StreamedBlobResult;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.query.QueryEvaluator;
import gov.nasa.kepler.fs.storage.*;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.DataInputStream;
import java.io.File;
import java.io.IOException;
import java.util.*;

import org.antlr.runtime.RecognitionException;
import org.apache.commons.lang.ArrayUtils;

/**
 * Reads data out of RandomAccessFiles,  StreamFiles and MjdTimeSeries
 *  in a non-transactional  manner.
 * 
 * @author Sean McCauliff
 * 
 */
public class OfflineExtractor {

    private final DirectoryHashFactory streamDirectoryHashFactory;
    private final RandomAccessAllocatorFactory randAllocatorFactory;
    private final MjdTimeSeriesStorageAllocatorFactory crAllocatorFactory;
    private final File dataDir;
    private final FsIdFileSystemLocator pathLocator;


    /**
     * @param dataDirectory The root of the file store.
     * @throws Exception 
     */
    public OfflineExtractor(File dataDirectory) throws Exception {
        if (!dataDirectory.exists()) {
            throw new FileStoreException("Data directory \"" + dataDirectory
                + "\"does not exist.");
        }

        if (!dataDirectory.canRead() || !dataDirectory.canWrite()) {
            throw new FileStoreException("Data directory  \"" + dataDirectory
                + "\" is not readable.");
        }

        if (!dataDirectory.isDirectory()) {
            throw new IllegalArgumentException("Data directory \""
                + dataDirectory + "\" is not a directory.");
        }

        this.dataDir = dataDirectory;

        File fileSystemConfigFile = new File(dataDir, FileTransactionManager.FILE_SYSTEM_ROOT_CONF_FILE_NAME);
        pathLocator =
            new UserConfigurableFsIdFileSystemLocator(fileSystemConfigFile, dataDirectory.getAbsolutePath());
        
        // We are not going to be creating any new directory hashes.
        streamDirectoryHashFactory = new DirectoryHashFactory(pathLocator, new File(BLOB_DIR_NAME));
        DirectoryHashFactory forTimeSeries = new DirectoryHashFactory(pathLocator, new File(TIME_SERIES_DIR_NAME));
        randAllocatorFactory = new RandomAccessAllocatorFactory(forTimeSeries);
        
        DirectoryHashFactory forCosmicRay = new DirectoryHashFactory(pathLocator, new File(MJD_TIME_SERIES_DIR_NAME));
        crAllocatorFactory = new MjdTimeSeriesStorageAllocatorFactory(forCosmicRay);

    }

    public StreamedBlobResult readBlob(FsId fsId) throws FileStoreException,
        FileStoreIdNotFoundException, IOException {

        DirectoryHash dirHash = streamDirectoryHashFactory.findDirHash(fsId);
        if (dirHash == null) {
            throw new FileStoreIdNotFoundException(fsId);
        }

        File targetFile = dirHash.idToFile(fsId.name());
        if (!targetFile.exists()) {
            throw new FileStoreIdNotFoundException(fsId);
        }

        TransactionalStreamFile.NonTransactionalReader xsReader = new TransactionalStreamFile.NonTransactionalReader(
            targetFile);

        StreamedBlobResult rv = new StreamedBlobResult(xsReader.originator, xsReader.size,
            xsReader.in);
        return rv;
    }

    /**
     * Lists all the blobs,  time series, cosmic ray series.
     * 
     * @param startFrom The directory to start searching from. This must be a
     * subdirectory or equal to some data storage directory.
     * @return
     * @throws IOException
     * @throws PipelineException
     */
    public SortedSet<FsId> ls(File startFrom) throws Exception {

        startFrom = startFrom.getCanonicalFile();
        File canStart = startFrom.getCanonicalFile();
        for (File fileSystemRoot : pathLocator.fileSystemRoots()) {
            if (canStart.toString().startsWith(new File(fileSystemRoot, BLOB_DIR_NAME).toString())) {
                QueryEvaluator qEval = createQueryFromDirectory(fileSystemRoot, BLOB_DIR_NAME, startFrom);
                return streamDirectoryHashFactory.find(qEval, true);
            } else if (startFrom.toString().startsWith(new File(fileSystemRoot, TIME_SERIES_DIR_NAME).toString())) {
                QueryEvaluator qEval = createQueryFromDirectory(fileSystemRoot, TIME_SERIES_DIR_NAME, startFrom);
                return randAllocatorFactory.find(qEval, true);
            } else if (startFrom.toString().startsWith(new File(fileSystemRoot, MJD_TIME_SERIES_DIR_NAME).toString())) {
                QueryEvaluator qEval = createQueryFromDirectory(fileSystemRoot, MJD_TIME_SERIES_DIR_NAME, startFrom);
                return crAllocatorFactory.find(qEval, true);
            } else if (startFrom.equals(fileSystemRoot)) {
                SortedSet<FsId> rv = new TreeSet<FsId>();
                rv.addAll(ls(new File(startFrom, TIME_SERIES_DIR_NAME)));
                rv.addAll(ls(new File(startFrom, MJD_TIME_SERIES_DIR_NAME)));
                rv.addAll(ls(new File(startFrom, BLOB_DIR_NAME)));
                return rv;
            }
        }

        throw new IllegalArgumentException("Directory \"" + startFrom
            + "\" is not in the data part of the file store.");
    }
    
    private QueryEvaluator createQueryFromDirectory(File fileSystemRoot, String typeName, File userDirectory) throws IOException, RecognitionException {
        File dataTypeRoot = new File(fileSystemRoot, typeName).getCanonicalFile();;
        if (dataTypeRoot.equals(userDirectory)) {
            return null;
        }
        
        StringBuilder fsIdQueryStr = new StringBuilder();
        String fsIdPath = userDirectory.getCanonicalPath().substring(dataTypeRoot.toString().length());
        if (fsIdPath.charAt(0) != '/') {
            fsIdPath = "/" + fsIdPath;
        }
        FsId testFsId = new FsId(fsIdPath, "_");
        fsIdQueryStr.append(testFsId.path()).append("*");
        return new QueryEvaluator(fsIdQueryStr.toString());
    }

    /**
     * Reads an entire time series fsid.
     * 
     * @param fsId
     * @return
     * @throws FileStoreException
     * @throws FileStoreIdNotFoundException
     * @throws IOException
     * @throws InterruptedException 
     */
    @SuppressWarnings("unchecked")
    public TimeSeries readTimeSeries(FsId fsId) throws FileStoreException,
        FileStoreIdNotFoundException, IOException, InterruptedException{

        RandomAccessAllocator allocator =  randAllocatorFactory.findAllocator(fsId);
        if (allocator == null) {
            throw new FileStoreIdNotFoundException(fsId);
        }

        if (!allocator.hasSeries(fsId)) {
            throw new FileStoreIdNotFoundException(fsId);

        }

        TransactionalRandomAccessFile.NonTransactionalReader reader = null;
        try {
            RandomAccessStorage resources = allocator.randomAccessStorage(fsId);
            reader = TransactionalRandomAccessFile.readFile(resources);

            boolean isFloat = reader.dataType == FLOAT_TYPE;

            if (reader.valid.intervals().size() == 0) {
                if (isFloat) {
                    return new FloatTimeSeries(fsId, ArrayUtils.EMPTY_FLOAT_ARRAY,
                        TimeSeries.NOT_EXIST_CADENCE,
                        TimeSeries.NOT_EXIST_CADENCE, Collections.EMPTY_LIST,
                        Collections.EMPTY_LIST, false);
                } else {
                    return new IntTimeSeries(fsId, ArrayUtils.EMPTY_INT_ARRAY,
                        TimeSeries.NOT_EXIST_CADENCE,
                        TimeSeries.NOT_EXIST_CADENCE, Collections.EMPTY_LIST,
                        Collections.EMPTY_LIST, false);
                }
            }

            List<SimpleInterval> valid = new ArrayList<SimpleInterval>();
            for (SimpleInterval v : reader.valid.intervals()) {
                valid.add(new SimpleInterval(v.start() >> 2, v.end() >> 2));
            }

            List<TaggedInterval> originators = new ArrayList<TaggedInterval>();
            for (TaggedInterval o : reader.originators.intervals()) {
                originators.add(new TaggedInterval(o.start() >> 2,
                    o.end() >> 2, o.tag()));
            }

            // TODO: This reads all the gaps. This might not be the best thing
            // to do.
            DataInputStream din = new DataInputStream(reader.in);
            long startTimeSeries = valid.get(0).start();
            long endTimeSeries = valid.get(valid.size() - 1).end();
            int seriesLength = (int) (endTimeSeries - startTimeSeries) + 1;

            if (isFloat) {
                float[] data = new float[seriesLength];
                for (int i = 0; i < seriesLength; i++) {
                    data[i] = din.readFloat();
                }
                FloatTimeSeries rv = new FloatTimeSeries(fsId, data,
                    (int) startTimeSeries, (int) endTimeSeries, valid,
                    originators, true);
                rv.fillGaps(0.0f);
                return rv;
            } else {
                int[] data = new int[seriesLength];
                for (int i = 0; i < seriesLength; i++) {
                    data[i] = din.readInt();
                }
                IntTimeSeries rv = new IntTimeSeries(fsId, data,
                    (int) startTimeSeries, (int) endTimeSeries, valid,
                    originators, true);
                rv.fillGaps(0);
                return rv;
            }
        } finally {
            if (reader != null) {
                FileUtil.close(reader.in);
            }
        }
    }
    
    
    /**
     * Reads an entire CosmicRaySeries for one FsId.
     * 
     * @param id
     * @return
     * @throws IOException
     * @throws FileStoreException
     * @throws ClassNotFoundException
     * @throws InterruptedException 
     */
    public FloatMjdTimeSeries readCosmicRaySeries(FsId id)
        throws IOException, FileStoreException, ClassNotFoundException, InterruptedException {
        
        MjdTimeSeriesStorageAllocator allocator = 
            crAllocatorFactory.findAllocator(id, false);
        
        if (allocator == null) {
            throw new FileStoreIdNotFoundException(id);
        }
        
        RandomAccessStorage storage = allocator.randomAccessStorage(id, false);
        if (storage == null) {
            throw new FileStoreIdNotFoundException(id);
        }
        
        TransactionalMjdTimeSeriesFile.MjdTimeSeriesReader reader =
            TransactionalMjdTimeSeriesFile.readFile(storage);
        
        FloatMjdTimeSeries series = reader.readSeries();
        
        return series;
        
    }

}
