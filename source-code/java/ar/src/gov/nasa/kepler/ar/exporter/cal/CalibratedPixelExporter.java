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

package gov.nasa.kepler.ar.exporter.cal;

import static gov.nasa.kepler.common.Cadence.CADENCE_LONG;
import static gov.nasa.kepler.common.Cadence.CADENCE_SHORT;
import static gov.nasa.kepler.common.FcConstants.MODULE_OUTPUTS;
import static gov.nasa.kepler.common.FitsConstants.*;
import static gov.nasa.kepler.dr.pixels.PixelDispatcher.cadenceNumberFromHeader;
import gov.nasa.kepler.ar.exporter.ExportOptions;
import gov.nasa.kepler.ar.exporter.FileNameFormatter;
import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.FitsUtils;
import gov.nasa.kepler.fs.api.BlobResult;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.services.AlertLogCrud;
import gov.nasa.kepler.mc.KeplerException;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.concurrent.MiniWork;
import gov.nasa.spiffy.common.concurrent.MiniWorkPool;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.Fits;
import nom.tam.fits.FitsException;
import nom.tam.fits.Header;
import nom.tam.fits.HeaderCardException;
import nom.tam.util.BufferedFile;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Exports calibrated pixels from the data store. This needs some of the
 * original files that where ingested during DR from the DMC. This updates
 * progress for every module output that it writes out. This class is not MT
 * safe.
 * 
 * @author Sean McCauliff
 * 
 */
public class CalibratedPixelExporter implements FileInfoSource {
    private static final Log log = LogFactory.getLog(CalibratedPixelExporter.class);
    
    public enum CadenceOption {
        ALL, SHORT_ONLY, LONG_ONLY;
        
        public static CadenceOption valueOf(CadenceType cadenceType) {
            switch (cadenceType) {
                case LONG:
                    return LONG_ONLY;
                case SHORT:
                    return SHORT_ONLY;
                default:
                    throw new IllegalArgumentException("Unknown type "
                        + cadenceType);
            }
        }
    }

    private static final String LC_TARGET_DEF = LCTRGDEF_KW;
    private static final String LC_TARGET_DEF_COMMENT = "long cadence target definition identifier";
    
    private static final String BK_TARGET_DEF = BKTRGDEF_KW;
    private static final String BK_TARGET_DEF_COMMENT = "background definition identifier ";
    
    private static final String BK_APERTURE = BKG_APER_KW;
    private static final String BK_APERTURE_COMMENT = "background aperture definition identifier ";
    
    private final List<OutputFileInfo> currentOutputFiles = new ArrayList<OutputFileInfo>();

    //(processing history file name) -> (ProcessingHistoryFile)
    private final Map<String, ProcessingHistoryFile> processingHistoryFiles = 
        Collections.synchronizedMap(new HashMap<String, ProcessingHistoryFile>());

    // (cosmic ray fits file name) -> (CosmicRayFitsWriter, PixelDataType, ProcessingHistoryFile)
    private final Map<String, CosmicRayFileInfo> cosmicRayFits = 
        Collections.synchronizedMap(new HashMap<String,CosmicRayFileInfo>());

    // (dummy header fits name) -> (pmrf)
    private final Map<String, Fits> dummyHeaderFitsCache = 
        Collections.synchronizedMap(new HashMap<String, Fits>());

    private final FileStoreClient fileStore;
    private final LogCrud logCrud;
    private final DataAccountabilityTrailCrud trailCrud;
    private final PipelineTaskCrud taskCrud;
    private final AlertLogCrud alertLogCrud;
    private final FcCrud fcCrud;

    /**
     * This is used to prevent more than one calibrated pixel exporter from
     * updating the same processing history file at the same time.
     */
    private final static Object processingHistoryMonitor = new Object();

    public CalibratedPixelExporter(FileStoreClient fileStore,
        DataAccountabilityTrailCrud trailCrud, PipelineTaskCrud taskCrud,
        AlertLogCrud alertLogCrud, FcCrud fcCrud) {

        this.fileStore = fileStore;
        this.logCrud = new LogCrud();
        this.taskCrud = taskCrud;
        this.trailCrud = trailCrud;
        this.alertLogCrud = alertLogCrud;
        this.fcCrud = fcCrud;
    }

    
    public Map<String, ProcessingHistoryFile> processingHistoryFiles() {
        return processingHistoryFiles;
    }
    
    public Map<String, CosmicRayFileInfo> cosmicRayFits() {
        return cosmicRayFits;
    }
    
    public List<OutputFileInfo> calibratedPixelFiles() {
        return currentOutputFiles;
    }
    
    /**
     * Exports pixel fits files, cosmic ray correction files and
     * processing history.
     * 
     * @param startCadence
     * @param endCadence
     * @param outputDir
     * @param cadenceOption
     * @throws KeplerException 
     * @throws IOException 
     * @throws FitsException 
     * @throws FileStoreException 
     * @throws InterruptedException 
     */
    public void export(int startCadence, int endCadence, File outputDir, 
        CadenceOption cadenceOption) 
        throws FitsException, IOException, KeplerException, InterruptedException {

        if (!outputDir.exists() || !outputDir.isDirectory() || !outputDir.canWrite()) {
            throw new IllegalArgumentException(
                "Destination must be an existing, writable directory.");
        }

        MjdToCadence lcMjdToCadence = new MjdToCadence(
            CadenceType.LONG, new ModelMetadataRetrieverLatest());
        lcMjdToCadence.cacheInterval(startCadence, endCadence);

        if (cadenceOption == CadenceOption.ALL || cadenceOption == CadenceOption.LONG_ONLY) {
            exportLongCadenceFiles(startCadence, endCadence, outputDir,
                lcMjdToCadence);
        }
        
        if (cadenceOption == CadenceOption.ALL || cadenceOption == CadenceOption.SHORT_ONLY) {
            exportShortCadenceFiles(startCadence, endCadence, outputDir,
                lcMjdToCadence);
        }
    }

    private static Pair<Integer, Integer> minMaxCadences(List<OutputFileInfo> outputFiles) {
        int min = Integer.MAX_VALUE;
        int max = Integer.MIN_VALUE;
        
        for (OutputFileInfo outputFile : outputFiles) {
            if (outputFile.cadence() < min) {
                min = outputFile.cadence();
            }
            if (outputFile.cadence() > max) {
                max = outputFile.cadence();
            }
        }
        return Pair.of(min, max);
    }
    
    private void exportShortCadenceFiles(int startCadence, int endCadence,
        File outputDir, MjdToCadence longCadence) throws FitsException,
        IOException, KeplerException, InterruptedException {
        
        MjdToCadence shortCadence = new MjdToCadence(
            CadenceType.SHORT, new ModelMetadataRetrieverLatest());

        Pair<Integer, Integer> shortInterval = 
            logCrud.longCadenceToShortCadence(startCadence, endCadence);

        if (shortInterval == null) {
            log.warn("Missing short cadence intervals.");
            return;
        }
        
        int startShortCadence = shortInterval.left;
        int endShortCadence = shortInterval.right;

        //Yes, we want to pass in the longCadence MjdtoCadence into this
        //method.
        initPixelFiles(CADENCE_SHORT, startShortCadence,
            endShortCadence, longCadence, outputDir);
        
        Pair<Integer, Integer> actualShortCadences = 
            minMaxCadences(this.currentOutputFiles);
        
        startShortCadence = actualShortCadences.left;
        endShortCadence = actualShortCadences.right;
        
        for (int module : FcConstants.modulesList) {
            for (int output : FcConstants.outputsList) {
                log.info(
                    "Short cadence working on module " + module
                        + " output " + output + ".");
                CalibratedPixelsModOutExporter modOutExport =
                    new CalibratedPixelsModOutExporter(module, output, 
                        fileStore, this);
                modOutExport.exportPixelsForModuleOutput(CADENCE_SHORT, 
                    startShortCadence, endShortCadence, shortCadence);
            }
        }

        updateHeaders();
        writeProcessingHistory(startCadence, endCadence, outputDir);
        closeFiles();
    }

    private void exportLongCadenceFiles(int startCadence, int endCadence,
        File outputDir, MjdToCadence longCadence) throws FitsException,
        IOException, KeplerException, InterruptedException {
        
        initPixelFiles(CADENCE_LONG, startCadence, endCadence,
            longCadence, outputDir);

        Pair<Integer, Integer> actualCadences = minMaxCadences(currentOutputFiles);
        startCadence = actualCadences.left;
        endCadence = actualCadences.right;
        
        for (int module : FcConstants.modulesList) {
            for (int output : FcConstants.outputsList) {
                log.info(
                    "Long cadence, working on module " + module
                        + " output " + output + ".");
                
                CalibratedPixelsModOutExporter modOutExport =
                    new CalibratedPixelsModOutExporter(module, output, 
                        fileStore, this);
                modOutExport.exportPixelsForModuleOutput(CADENCE_LONG, 
                    startCadence, endCadence, longCadence);
            }
        }
        updateHeaders();
        writeProcessingHistory(startCadence, endCadence, outputDir);
        closeFiles();

        log.info("Completed long cadence [" + startCadence + 
            "," + endCadence + "] export.");
    }

    /**
     * @param exportOptions
     * @throws IOException
     * @throws PipelineException
     */
    private void writeProcessingHistory(int startCadence, int endCadence, File outputDir)
        throws IOException {
        synchronized (processingHistoryMonitor) {
            String exportStr = "Export options: Long Cadence [start, end]  = ["
                + startCadence + "," + endCadence + "]";

            for (ProcessingHistoryFile historyFile : processingHistoryFiles.values()) {
                log.info("Writing processing history file \"" + historyFile
                    + "\".");
                historyFile.write(fileStore, outputDir, exportStr);
            }
        }
    }

    /**
     * Once the pixel files are written the actual header information needs to
     * be written into all the sub headers.
     * 
     * @throws FitsException
     * @throws FileStoreException
     * @throws IOException
     * @throws InterruptedException 
     */
    private void updateHeaders() throws FitsException,
        IOException, InterruptedException {

        log.info("Updating FITS headers.");
        MiniWork<OutputFileInfo> miniWorker = new MiniWork<OutputFileInfo>() {

            @Override
            protected void doIt(OutputFileInfo outputFileInfo) throws Throwable {
                FileStoreClientFactory.getInstance().disassociateThread();

                Fits headerFits = headerFits(outputFileInfo.headerFileName());
                for (int headeri = 0; headeri < 84; headeri++) {
                    Header header = headerFits.getHDU(headeri + 1)
                        .getHeader();
                    long startOffset = outputFileInfo.headerOffsets().get(headeri);
                    outputFileInfo.output().seek(startOffset);
                    int naxis2 = outputFileInfo.naxis2().get(headeri);
                    outputFileInfo.pixelDataType()
                        .setCalibratedHeaderFields(header, naxis2);
                    FitsUtils.trimHeader(header);
                    header.write(outputFileInfo.output());
                    outputFileInfo.output().flush();
                }
            }
        };

        MiniWorkPool<OutputFileInfo> pool = 
            new MiniWorkPool<OutputFileInfo>("calibrated pixel exporter",
            currentOutputFiles, miniWorker);

        pool.performAllWork();
        
    }

    /**
     * Get the pixel logs and figure out which output files are needed. Write
     * the initial header for each of these output files.
     * @throws KeplerException 
     */
    private void initPixelFiles(int cadenceType, int startCadence,
        int endCadence, MjdToCadence lcMjdToCadence, File outputDir) 
        throws FitsException, IOException, KeplerException {

        if (cadenceType != CADENCE_LONG && cadenceType != CADENCE_SHORT) {
            throw new IllegalArgumentException("Invalid cadence type "
                + cadenceType);
        }

        // These are FITS files that do not have any pixels in them, but
        // are correctly formatted for export.
        List<PixelLog> pixelHeaderFileNames = logCrud.retrievePixelLog(
            cadenceType, startCadence, endCadence);

        if (pixelHeaderFileNames.size() == 0) {
            log.warn("Insufficent FITS header files were found for cadence "
                + (cadenceType == CADENCE_LONG ? "long" : "short") + "["
                + startCadence + "," + endCadence + "]");
            return;
        }

        processingHistoryFiles.clear();
        currentOutputFiles.clear();
        cosmicRayFits.clear();

        Map<String, TargetAndApertureIdMap> tnaMapCache = 
            new HashMap<String, TargetAndApertureIdMap>();

        for (PixelLog pixelLog : pixelHeaderFileNames) {
            PixelDataType pixelDataType = PixelDataType.valueOf(pixelLog);
            Fits headerFits = headerFits(pixelLog.getFitsFilename());
            Pair<Fits, String> pmrf = pixelDataType.pmrfFits(headerFits,
                fileStore);

            Fits dummyHeaderFits = dummyHeaderFitsForPmrf(pixelLog, pmrf);

            File outputFile = new File(outputDir, pixelLog.getFitsFilename());

            BufferedFile output = new BufferedFile(
                outputFile.getAbsolutePath(), "rw");

            BasicHDU initialHdu = headerFits.getHDU(0);
            Header initialHeader = initialHdu.getHeader();
            if (cadenceType == Cadence.CADENCE_SHORT) {
                //Fix long cadence target table number.  See KSOC-281
                fixLongCadenceKeywords(pixelLog, initialHeader);
            }
            fixOtherKeywords(initialHeader);
            
            int longCadenceNumber = 
                cadenceNumberFromHeader(initialHeader, Cadence.CADENCE_LONG);
            FitsUtils.trimHeader(initialHeader);
            initialHdu.write(output);
            
            log.info("Created pixel output file \"" + outputFile + "\".");

            OutputFileInfo info = 
                new OutputFileInfo(dummyHeaderFits, 
                pixelLog.getFitsFilename(), longCadenceNumber,pixelDataType,
                pixelLog, output,
                pmrf.left, pmrf.right, lcMjdToCadence);

            output.flush();
            currentOutputFiles.add(info);

            if (!processingHistoryFiles.containsKey(info.processingHistoryFileName())) {
                createProcessingHistoryFile(info);
            }

            String cosmicRayFitsName = cosmicRayFitsWriterName(pixelLog);
            if (!cosmicRayFits.containsKey(cosmicRayFitsName)) {

                createCosmicRayFile(outputDir, tnaMapCache, pixelDataType,
                    info, cosmicRayFitsName);
            } else if (!info.pixelDataType().isCollateral()) {
                TargetAndApertureIdMap tnaMap = tnaMapCache.get(info.targetAndApertureMapKey());
                tnaMap.addVisiblePmrf(info.pmrf(), info.pmrfName());
            }
        }

        Collections.sort(currentOutputFiles, new Comparator<OutputFileInfo>() {

            public int compare(OutputFileInfo o1, OutputFileInfo o2) {
                int diff = o1.pixelDataType()
                    .ordinal() - o2.pixelDataType()
                    .ordinal();
                if (diff != 0) {
                    return diff;
                }
                diff = o1.cadence() - o2.cadence();
                return diff;
            }

        });

    }

    private void createCosmicRayFile(File outputDir,
        Map<String, TargetAndApertureIdMap> tnaMapCache,
        PixelDataType pixelDataType, OutputFileInfo info,
        String cosmicRayFitsName) throws FitsException, IOException {
        File crFitsFile = new File(outputDir, cosmicRayFitsName);
        CosmicRayFitsWriter writer = createCosmicRayFitsWriter(info,
            crFitsFile, tnaMapCache);
        ProcessingHistoryFile processingHistory = 
            processingHistoryFiles.get(info.processingHistoryFileName());
        CosmicRayFileInfo cosmicRayFileInfo = 
            new CosmicRayFileInfo(writer, pixelDataType, processingHistory);

        cosmicRayFits.put(cosmicRayFitsName, cosmicRayFileInfo);
    }

    private void createProcessingHistoryFile(OutputFileInfo info) {

        ProcessingHistoryFile historyFile = new ProcessingHistoryFile(
            info.processingHistoryFileName(), 
            trailCrud, taskCrud,
            alertLogCrud, fcCrud);

        processingHistoryFiles.put(info.processingHistoryFileName(),
            historyFile);

        log.info("Created processing history file \"" + historyFile
            + "\".");
    }

    /**
     * The MOC does not set these FITS keywords  in the short cadence FITS headers
     * as they should so here we put them into the out going FITS headers.
     * 
     * @param pixelLog DR puts the fixed value here.
     * @param initialHeader  The initial header for the out going FITS file.
     * @throws HeaderCardException
     */
    private void fixLongCadenceKeywords(PixelLog pixelLog, Header initialHeader)
        throws HeaderCardException {
        initialHeader.addValue(LC_TARGET_DEF, pixelLog.getLcTargetTableId(), LC_TARGET_DEF_COMMENT);
        initialHeader.addValue(BK_TARGET_DEF, pixelLog.getBackTargetTableId(), BK_TARGET_DEF_COMMENT);
        initialHeader.addValue(BK_APERTURE, pixelLog.getBackApertureTableId(), BK_APERTURE_COMMENT);
    }
    
    private void fixOtherKeywords(Header initialHeader) throws HeaderCardException {
        initialHeader.addValue(ORIGIN_KW, 
            ORIGIN_VALUE, ORIGIN_COMMENT);
        //This is an attempt to have the next comments inserted at the end.
        Iterator<?> it = initialHeader.iterator();
        while (it.hasNext()) {
            it.next();
        }
        initialHeader.insertComment("SOC Data Release");
        initialHeader.addValue(DATA_REL_KW,DATA_REL_VALUE, DATA_REL_COMMENT);
        initialHeader.addValue(QUARTER_KW, QUARTER_VALUE, QUARTER_COMMENT);
    }

    private Fits dummyHeaderFitsForPmrf(PixelLog pixelLog,
        Pair<Fits, String> pmrf) throws FitsException {
        Fits dummyHeaderFits = null;
        if (dummyHeaderFitsCache.containsKey(pmrf.right)) {
            dummyHeaderFits = dummyHeaderFitsCache.get(pmrf.right);
        } else {
            dummyHeaderFits = headerFits(pixelLog.getFitsFilename());
            dummyHeaderFitsCache.put(pmrf.right, dummyHeaderFits);
        }
        return dummyHeaderFits;
    }

    private void closeFiles() throws IOException {
        for (OutputFileInfo info : currentOutputFiles) {
            info.output().close();
        }
        for (CosmicRayFileInfo rayInfo : cosmicRayFits.values()) {
            FileUtil.close(rayInfo.writer);
        }
    }

    private Fits headerFits(String fitsFileName) throws
        FitsException {

        FsId headerFileId = DrFsIdFactory.getPixelFitsHeaderFile(fitsFileName);
        if (log.isDebugEnabled()) {
            log.debug("Fetching FITS Pixel Headers from \"" + headerFileId
                + "\".");
        }
        BlobResult headerFileData = fileStore.readBlob(headerFileId);
        ByteArrayInputStream bin = new ByteArrayInputStream(
            headerFileData.data());
        Fits pixelExportFits = new Fits(bin);
        pixelExportFits.read();
        return pixelExportFits;
    }

    /**
     * @see gov.nasa.kepler.ar.exporter.TableExporter#uiDisplayName()
     */
    public String uiDisplayName() {
        return "Calibrated Pixel Exporter";
    }

    /**
     * @see gov.nasa.kepler.ar.exporter.TableExporter#lengthOfTask(gov.nasa.kepler.ar.exporter.ExportOptions)
     */
    public int lengthOfTask(ExportOptions exportOptions) {
        return MODULE_OUTPUTS
            * (exportOptions.endCadence() - exportOptions.startCadence() + 1)
            * PixelDataType.values().length;
    }

    private static String cosmicRayFitsWriterName(PixelLog pixelLog) {
        Pattern pat = Pattern.compile("kplr([^_]+).*");
        Matcher matcher = pat.matcher(pixelLog.getFitsFilename());
        if (!matcher.matches()) {
            throw new IllegalStateException("Bad Fits file name \""
                + pixelLog.getFitsFilename() + "\" for pixelLog.");
        }

        String lastCadenceTime = matcher.group(1);
        boolean isShortCadence = pixelLog.getCadenceType() == CADENCE_SHORT;
        boolean isCollateral = pixelLog.getDataSetType() == DataSetType.Collateral;
        FileNameFormatter fnameFormatter = new FileNameFormatter();
        String fname = fnameFormatter.cosmicRayName(isShortCadence,
            isCollateral, lastCadenceTime);
        return fname;
    }

    /**
     * Creates CosmicRayFitsWriters for Collateral and Visible pixels.
     * 
     * @param info
     * @param outputFile
     * @param tnaMapCache Don't want to duplicate maps so this is a place to
     * keep all of the unique ones. This is indexed by pmrfName.
     * @return
     * @throws FitsException
     * @throws IOException
     */
    private static CosmicRayFitsWriter createCosmicRayFitsWriter(OutputFileInfo info,
        File outputFile, Map<String, TargetAndApertureIdMap> tnaMapCache)
        throws FitsException, IOException {

        PixelLog pixelLog = info.pixelLog();
        short bkgAperTableId = pixelLog.getBackApertureTableId();
        short bkgTargetDef = pixelLog.getBackTargetTableId();
        short lcTargetDef = pixelLog.getLcTargetTableId();
        short scTargetDef = pixelLog.getScTargetTableId();
        short tarApertureDef = pixelLog.getTargetApertureTableId();
        short compresTableId = pixelLog.getCompressionTableId();
        int cadence = pixelLog.getCadenceNumber();

        TargetAndApertureIdMap targetIdMap = null;
        if (pixelLog.getDataSetType() != PixelLog.DataSetType.Collateral) {
            targetIdMap = tnaMapCache.get(info.targetAndApertureMapKey());
            if (targetIdMap == null) {
                targetIdMap = new TargetAndApertureIdMap();
                tnaMapCache.put(info.targetAndApertureMapKey(), targetIdMap);
            }
            targetIdMap.addVisiblePmrf(info.pmrf(), info.pmrfName());
        }

        BufferedFile output = new BufferedFile(outputFile.toString(), "rw");
        CosmicRayFitsWriter.DataType fitsDataType = pixelLog.getCadenceType() == CADENCE_SHORT ? CosmicRayFitsWriter.DataType.SHORT
            : CosmicRayFitsWriter.DataType.LONG;

        CosmicRayFitsWriter fitsWriter = new CosmicRayFitsWriter(cadence,
            fitsDataType, lcTargetDef, scTargetDef, bkgTargetDef,
            tarApertureDef, bkgAperTableId, compresTableId, output,
            outputFile.getName(), targetIdMap);

        log.info("Created cosmic ray correction table file \"" + outputFile
            + "\".");

        return fitsWriter;
    }
    

}
