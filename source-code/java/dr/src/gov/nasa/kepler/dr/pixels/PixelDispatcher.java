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

package gov.nasa.kepler.dr.pixels;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Maps.newHashMap;
import static com.google.common.collect.Sets.newHashSet;
import static gov.nasa.kepler.common.FitsConstants.BASELINE_KW;
import static gov.nasa.kepler.common.FitsConstants.BASENAME_KW;
import static gov.nasa.kepler.common.FitsConstants.BASERCON_KW;
import static gov.nasa.kepler.common.FitsConstants.BKG_APER_KW;
import static gov.nasa.kepler.common.FitsConstants.BKTRGDEF_KW;
import static gov.nasa.kepler.common.FitsConstants.COMPTABL_KW;
import static gov.nasa.kepler.common.FitsConstants.DCT_PURP_KW;
import static gov.nasa.kepler.common.FitsConstants.END_TIME_KW;
import static gov.nasa.kepler.common.FitsConstants.FINE_PNT_KW;
import static gov.nasa.kepler.common.FitsConstants.HUFFMAN_KW;
import static gov.nasa.kepler.common.FitsConstants.LCTRGDEF_KW;
import static gov.nasa.kepler.common.FitsConstants.LC_INTER_KW;
import static gov.nasa.kepler.common.FitsConstants.LDEPARER_KW;
import static gov.nasa.kepler.common.FitsConstants.LDE_OOS_KW;
import static gov.nasa.kepler.common.FitsConstants.MISSING_PIXEL_VALUE;
import static gov.nasa.kepler.common.FitsConstants.MMNTMDMP_KW;
import static gov.nasa.kepler.common.FitsConstants.RBASNAME_KW;
import static gov.nasa.kepler.common.FitsConstants.REQUANT_KW;
import static gov.nasa.kepler.common.FitsConstants.REV_CLCK_KW;
import static gov.nasa.kepler.common.FitsConstants.SCCONFID_KW;
import static gov.nasa.kepler.common.FitsConstants.SCRC_ERR_KW;
import static gov.nasa.kepler.common.FitsConstants.SCTRGDEF_KW;
import static gov.nasa.kepler.common.FitsConstants.SC_INTER_KW;
import static gov.nasa.kepler.common.FitsConstants.SEFI_ACC_KW;
import static gov.nasa.kepler.common.FitsConstants.SEFI_CAD_KW;
import static gov.nasa.kepler.common.FitsConstants.STARTIME_KW;
import static gov.nasa.kepler.common.FitsConstants.TARGAPER_KW;
import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.FitsUtils;
import gov.nasa.kepler.common.pi.CadenceRangeParameters;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.dr.dispatch.DispatchException;
import gov.nasa.kepler.dr.dispatch.Dispatcher;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapper;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapperFactory;
import gov.nasa.kepler.dr.dispatch.Launchable;
import gov.nasa.kepler.dr.dispatch.PipelineLauncher;
import gov.nasa.kepler.dr.pixels.FitsMetadataCache.CadenceMetadata;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.DispatchLog;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.hibernate.dr.PixelLogCrud;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.gar.RequantEntry;
import gov.nasa.kepler.hibernate.gar.RequantTable;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.ParameterSetCrud;
import gov.nasa.kepler.hibernate.pi.ParameterSetName;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.KeplerException;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.pmrf.PmrfCache;
import gov.nasa.kepler.pi.pipeline.PipelineOperations;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.DataOutputStream;
import java.io.File;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.Fits;
import nom.tam.fits.FitsException;
import nom.tam.fits.Header;
import nom.tam.fits.TableHDU;

import org.apache.commons.io.output.ByteArrayOutputStream;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Parses and stores pixel data from cadence fits files.
 * 
 * @author Todd Klaus
 * @author Miles Cote
 * 
 */
public abstract class PixelDispatcher implements Dispatcher, Launchable {

    private static final Log log = LogFactory.getLog(PixelDispatcher.class);

    protected DataSetType dataSetType;
    protected TargetType targetTableType;
    protected int cadenceType;

    protected int startCadence = Integer.MAX_VALUE;
    protected int endCadence = Integer.MIN_VALUE;

    protected TimeSeriesBuffer timeSeriesBuffer = null;
    protected PmrfCache pmrfCache = null;
    protected FitsMetadataCache fitsMetadataCache;

    private Map<String, PixelLog> filenameToPixelLogMap;

    private Pair<Short, Set<Integer>> externalIdRequantValueSetPair;

    protected Set<String> ignoredFilenames;

    protected boolean overwriteGaps = false;

    private final PixelLogCrud pixelLogCrud;

    private String sourceDirectory;
    private DispatchLog dispatchLog;

    public PixelDispatcher() {
        this(new LogCrud());
    }

    PixelDispatcher(PixelLogCrud pixelLogCrud) {
        this.pixelLogCrud = pixelLogCrud;
    }

    @Override
    public void dispatch(Set<String> filenames, String sourceDirectory,
        DispatchLog dispatchLog, DispatcherWrapper dispatcherWrapper) {
        this.sourceDirectory = sourceDirectory;
        this.dispatchLog = dispatchLog;

        List<String> targetFilenames = newArrayList();
        List<String> collateralFilenames = newArrayList();
        List<String> backgroundFilenames = newArrayList();
        for (String fitsFileName : filenames) {
            try {
                if (fitsFileName.contains(DispatcherWrapperFactory.LONG_CADENCE_TARGET)
                    || fitsFileName.contains(DispatcherWrapperFactory.SHORT_CADENCE_TARGET)) {
                    targetFilenames.add(fitsFileName);
                } else if (fitsFileName.contains(DispatcherWrapperFactory.LONG_CADENCE_COLLATERAL)
                    || fitsFileName.contains(DispatcherWrapperFactory.SHORT_CADENCE_COLLATERAL)) {
                    collateralFilenames.add(fitsFileName);
                } else if (fitsFileName.contains(DispatcherWrapperFactory.LONG_CADENCE_BACKGROUND)) {
                    backgroundFilenames.add(fitsFileName);
                } else {
                    throw new DispatchException(
                        "Unknown suffix for filename = " + fitsFileName);
                }
            } catch (Exception e) {
                dispatcherWrapper.throwExceptionForFile(fitsFileName, e);
            }
        }

        dataSetType = DataSetType.Target;
        targetTableType = TargetType.valueOf(CadenceType.valueOf(cadenceType));
        processDataSet(targetFilenames);

        dataSetType = DataSetType.Collateral;
        targetTableType = TargetType.valueOf(CadenceType.valueOf(cadenceType));
        processDataSet(collateralFilenames);

        dataSetType = DataSetType.Background;
        targetTableType = TargetType.BACKGROUND;
        processDataSet(backgroundFilenames);

        new PipelineLauncher().launchIfEnabled(this, dispatchLog);
    }

    @Override
    public void augmentPipelineParameters(TriggerDefinition triggerDefinition) {
        Map<ClassWrapper<Parameters>, ParameterSetName> pipelineParameterSetNames = triggerDefinition.getPipelineParameterSetNames();

        ParameterSetName cadenceRangeParameterSetName = pipelineParameterSetNames.get(new ClassWrapper<Parameters>(
            CadenceRangeParameters.class));
        ParameterSetName cadenceTypeParameterSetName = pipelineParameterSetNames.get(new ClassWrapper<Parameters>(
            CadenceTypePipelineParameters.class));

        ParameterSetCrud parameterSetCrud = new ParameterSetCrud();
        ParameterSet paramSet = parameterSetCrud.retrieveLatestVersionForName(cadenceRangeParameterSetName);
        CadenceRangeParameters cadenceRangeParameters = paramSet.parametersInstance();
        cadenceRangeParameters.setStartCadence(startCadence);
        cadenceRangeParameters.setEndCadence(endCadence);

        CadenceTypePipelineParameters cadenceTypeParameters = new CadenceTypePipelineParameters(
            CadenceType.valueOf(cadenceType));

        PipelineOperations pipelineOperations = new PipelineOperations();
        pipelineOperations.updateParameterSet(cadenceRangeParameterSetName,
            cadenceRangeParameters, false);
        pipelineOperations.updateParameterSet(cadenceTypeParameterSetName,
            cadenceTypeParameters, false);
    }

    private void processDataSet(List<String> fileNames) {
        log.info("dataSetType = " + dataSetType);
        log.info("targetTableType = " + targetTableType);
        log.info("file count = " + fileNames.size());

        if (filenameToPixelLogMap != null) {
            flush();
            DatabaseServiceFactory.getInstance()
                .evictAll(filenameToPixelLogMap.values());
        }

        filenameToPixelLogMap = new HashMap<String, PixelLog>();
        ignoredFilenames = new HashSet<String>();

        IntervalMetricKey metricKey = null;
        try {
            metricKey = IntervalMetric.start();

            log.info("extracting and storing cadence meta data");
            extractAndStoreCadenceMetaData(fileNames);

        } finally {
            IntervalMetric.stop("dr.dispatch.pixel.cadenceMetaData."
                + dataSetType + ".process", metricKey);
        }

        try {
            metricKey = IntervalMetric.start();

            log.info("extracting and storing time series data");
            extractAndStoreTimeSeriesData(fileNames, sourceDirectory);

        } finally {
            IntervalMetric.stop("dr.dispatch.pixel.timeSeriesData."
                + dataSetType + ".process", metricKey);
        }
    }

    protected void flush() {
        DatabaseServiceFactory.getInstance()
            .flush();
    }

    private void extractAndStoreCadenceMetaData(List<String> fileNames) {
        log.info("Extracting and storing cadence metadata");

        try {
            fitsMetadataCache = new FitsMetadataCache();

            TreeSet<PixelLog> pixelLogsByCadenceNumber = new TreeSet<PixelLog>(
                new Comparator<PixelLog>() {
                    @Override
                    public int compare(PixelLog o1, PixelLog o2) {
                        if (o1.getCadenceNumber() < o2.getCadenceNumber()) {
                            return -1;
                        } else if (o1.getCadenceNumber() == o2.getCadenceNumber()) {
                            return 0;
                        } else {
                            return 1;
                        }
                    }
                });

            Map<Integer, String> cadenceNumberToFilenameMap = newHashMap();
            int previousCadenceNumber = -1;
            String previousFilename = null;
            for (String fitsFileName : fileNames) {
                String fitsPath = sourceDirectory + File.separatorChar
                    + fitsFileName;
                Fits fits = new Fits(fitsPath);
                BasicHDU primaryHdu = fits.getHDU(0);
                Header primaryHduHeader = primaryHdu.getHeader();
                String datasetName = fitsFileName.substring(0,
                    fitsFileName.indexOf("_"));

                String dctPurpValue = FitsUtils.safeGetStringField(
                    primaryHduHeader, DCT_PURP_KW);

                int cadenceNumber = cadenceNumberFromHeader(primaryHduHeader,
                    cadenceType);

                // Check for duplicate cadence numbers.
                String previousFilenameWithSameCadence = cadenceNumberToFilenameMap.get(cadenceNumber);
                if (previousFilenameWithSameCadence != null) {
                    throw new DispatchException(
                        "Each cadenceNumber must exist in at most one file per data type.  "
                            + previousFilenameWithSameCadence
                            + " has cadenceNumber = " + cadenceNumber + " and "
                            + fitsFileName + " also has cadenceNumber = "
                            + cadenceNumber);
                } else {
                    cadenceNumberToFilenameMap.put(cadenceNumber, fitsFileName);
                }

                // Check for out of order cadences.
                if (cadenceNumber < previousCadenceNumber) {
                    throw new DispatchException(
                        "The DMC has confirmed that cadence numbers will be listed in increasing order in the nm.  "
                            + "Detected filename "
                            + previousFilename
                            + " with cadence number "
                            + previousCadenceNumber
                            + " and then detected filename "
                            + fitsFileName
                            + " with cadence number " + cadenceNumber + ".");
                }

                if (cadenceNumber < startCadence) {
                    startCadence = cadenceNumber;
                }

                if (cadenceNumber > endCadence) {
                    endCadence = cadenceNumber;
                }

                String pmrfFilenameKeyword = PmrfCache.getPmrfFilenameKeyword(
                    dataSetType, targetTableType);
                String pmrfFilename = FitsUtils.getHeaderStringValueChecked(
                    primaryHdu.getHeader(), pmrfFilenameKeyword);

                CadenceMetadata metadata = new CadenceMetadata(cadenceNumber,
                    pmrfFilename);
                fitsMetadataCache.putMetadata(fitsFileName, metadata);

                PixelLog pixelLog = new PixelLog();
                pixelLog.setDispatchLog(dispatchLog);
                pixelLog.setDataSetType(dataSetType);
                pixelLog.setCadenceNumber(cadenceNumber);
                pixelLog.setCadenceType(cadenceType);
                pixelLog.setDatasetName(datasetName);
                pixelLog.setFitsFilename(fitsFileName);

                int scConfigId = FitsUtils.getHeaderIntValueChecked(
                    primaryHduHeader, SCCONFID_KW);
                pixelLog.setSpacecraftConfigId(scConfigId);

                pixelLog.setMjdStartTime(FitsUtils.getHeaderDoubleValueChecked(
                    primaryHduHeader, STARTIME_KW));
                pixelLog.setMjdEndTime(FitsUtils.getHeaderDoubleValueChecked(
                    primaryHduHeader, END_TIME_KW));
                pixelLog.setMjdMidTime((pixelLog.getMjdStartTime() + pixelLog.getMjdEndTime()) / 2);

                pixelLog.setLcTargetTableId((short) FitsUtils.getHeaderIntValueChecked(
                    primaryHduHeader, LCTRGDEF_KW));
                pixelLog.setScTargetTableId((short) FitsUtils.getHeaderIntValueChecked(
                    primaryHduHeader, SCTRGDEF_KW));
                pixelLog.setBackTargetTableId((short) FitsUtils.getHeaderIntValueChecked(
                    primaryHduHeader, BKTRGDEF_KW));
                pixelLog.setTargetApertureTableId((short) FitsUtils.getHeaderIntValueChecked(
                    primaryHduHeader, TARGAPER_KW));
                pixelLog.setBackApertureTableId((short) FitsUtils.getHeaderIntValueChecked(
                    primaryHduHeader, BKG_APER_KW));
                pixelLog.setCompressionTableId((short) FitsUtils.getHeaderIntValueChecked(
                    primaryHduHeader, COMPTABL_KW));

                if (CadenceType.valueOf(cadenceType) == CadenceType.SHORT) {
                    setMissingTableIds(pixelLog, pixelLog.getScTargetTableId());
                }

                pixelLog.setDataRequantizedForDownlink(FitsUtils.getHeaderBooleanValueChecked(
                    primaryHduHeader, REQUANT_KW));
                pixelLog.setDataEntropicCompressedForDownlink(FitsUtils.getHeaderBooleanValueChecked(
                    primaryHduHeader, HUFFMAN_KW));
                pixelLog.setDataOriginatedAsBaselineImage(FitsUtils.getHeaderBooleanValueChecked(
                    primaryHduHeader, BASELINE_KW));
                pixelLog.setBaselineImageRootname(FitsUtils.getHeaderStringValueChecked(
                    primaryHduHeader, BASENAME_KW));
                pixelLog.setBaselineCreatedFromResidualBaselineImage(FitsUtils.getHeaderBooleanValueChecked(
                    primaryHduHeader, BASERCON_KW));
                pixelLog.setResidualBaselineImageRootname(FitsUtils.getHeaderStringValueChecked(
                    primaryHduHeader, RBASNAME_KW));

                pixelLog.setSefiAcc(FitsUtils.getHeaderBooleanValueChecked(
                    primaryHduHeader, SEFI_ACC_KW));
                pixelLog.setSefiCad(FitsUtils.getHeaderBooleanValueChecked(
                    primaryHduHeader, SEFI_CAD_KW));
                pixelLog.setLdeOos(FitsUtils.getHeaderBooleanValueChecked(
                    primaryHduHeader, LDE_OOS_KW));
                pixelLog.setFinePnt(FitsUtils.getHeaderBooleanValueChecked(
                    primaryHduHeader, FINE_PNT_KW));
                pixelLog.setMmntmDmp(FitsUtils.getHeaderBooleanValueChecked(
                    primaryHduHeader, MMNTMDMP_KW));
                pixelLog.setLdeParEr(FitsUtils.getHeaderBooleanValueChecked(
                    primaryHduHeader, LDEPARER_KW));
                pixelLog.setScrcErr(FitsUtils.getHeaderBooleanValueChecked(
                    primaryHduHeader, SCRC_ERR_KW));

                boolean excludePixelLog = false;
                if (primaryHduHeader.containsKey(REV_CLCK_KW)) {
                    boolean reverseClockingInEffect = FitsUtils.getHeaderBooleanValueChecked(
                        primaryHduHeader, REV_CLCK_KW);
                    excludePixelLog = handleReverseClocking(fitsPath,
                        reverseClockingInEffect, pixelLog, dctPurpValue,
                        fitsFileName);
                }

                if (!excludePixelLog) {
                    // Delete old pixelLog.
                    pixelLogCrud.deletePixelLog(dataSetType, cadenceType,
                        cadenceNumber);

                    // Create new pixelLog.
                    pixelLogCrud.createPixelLog(pixelLog);

                    // Add pixelLog to the map.
                    filenameToPixelLogMap.put(fitsFileName, pixelLog);

                    // Check that cadence numbers and mjs are consistent.
                    validatePixelLog(pixelLogsByCadenceNumber, pixelLog);
                    pixelLogsByCadenceNumber.add(pixelLog);

                    storeFitsHeaders(fitsFileName, fits);

                    previousCadenceNumber = cadenceNumber;
                    previousFilename = fitsFileName;
                }

                fits.getStream()
                    .close();
            }

            log.info("startCadence = " + startCadence);
            log.info("endCadence = " + endCadence);
        } catch (Exception e) {
            throw new DispatchException(
                "failed to extract and store fits metadata", e);
        }
    }

    protected boolean handleReverseClocking(String fitsPath,
        boolean reverseClockingInEffect, PixelLog pixelLog,
        String dctPurpValue, String fitsFileName) {
        if (reverseClockingInEffect) {
            throw new IllegalArgumentException(
                "cadenceFitsFiles cannot be reverse clock cadences."
                    + "\n  file: " + fitsPath + "\n  " + REV_CLCK_KW
                    + ": " + reverseClockingInEffect);
        }

        return false;
    }

    private void setMissingTableIds(PixelLog pixelLog, short scTargetTableId) {
        TargetCrud targetCrud = new TargetCrud();
        TargetTable scTargetTable = targetCrud.retrieveUplinkedTargetTable(
            scTargetTableId, TargetType.SHORT_CADENCE);

        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
        TargetListSet scTls = targetSelectionCrud.retrieveTargetListSetByTargetTable(scTargetTable);

        if (scTls != null) {
            TargetListSet lcTls = scTls.getAssociatedLcTls();

            pixelLog.setLcTargetTableId((short) lcTls.getTargetTable()
                .getExternalId());
            pixelLog.setBackTargetTableId((short) lcTls.getBackgroundTable()
                .getExternalId());
            pixelLog.setBackApertureTableId((short) lcTls.getBackgroundTable()
                .getMaskTable()
                .getExternalId());
        }
    }

    public static int cadenceNumberFromHeader(Header primaryHduHeader,
        int cadenceType) throws KeplerException {
        try {
            int cadenceNumber;
            if (cadenceType == Cadence.CADENCE_LONG) {
                cadenceNumber = FitsUtils.getHeaderIntValueChecked(
                    primaryHduHeader, LC_INTER_KW);
            } else {
                cadenceNumber = FitsUtils.getHeaderIntValueChecked(
                    primaryHduHeader, SC_INTER_KW);
            }

            return cadenceNumber;
        } catch (FitsException e) {
            throw new KeplerException("Unable to get cadence number from header.", e);
        }
    }

    protected void validatePixelLog(TreeSet<PixelLog> pixelLogsByCadenceNumber,
        PixelLog pixelLog) {

        PixelLog lower = pixelLogsByCadenceNumber.lower(pixelLog);
        if (lower != null) {
            if (lower.getMjdStartTime() >= pixelLog.getMjdStartTime()) {
                throw new PipelineException(
                    "Mjds must increase with cadence number." + "\n  fitsFile "
                        + lower.getFitsFilename() + " has cadenceNumber "
                        + lower.getCadenceNumber() + " and startMjd "
                        + lower.getMjdStartTime() + "." + "\n  fitsFile "
                        + pixelLog.getFitsFilename() + " has cadenceNumber "
                        + pixelLog.getCadenceNumber() + " and startMjd "
                        + pixelLog.getMjdStartTime() + ".");
            }

            if (lower.getMjdEndTime() >= pixelLog.getMjdEndTime()) {
                throw new PipelineException(
                    "Mjds must increase with cadence number." + "\n  fitsFile "
                        + lower.getFitsFilename() + " has cadenceNumber "
                        + lower.getCadenceNumber() + " and endMjd "
                        + lower.getMjdEndTime() + "." + "\n  fitsFile "
                        + pixelLog.getFitsFilename() + " has cadenceNumber "
                        + pixelLog.getCadenceNumber() + " and endMjd "
                        + pixelLog.getMjdEndTime() + ".");
            }
        }

        PixelLog higher = pixelLogsByCadenceNumber.higher(pixelLog);
        if (higher != null) {
            if (higher.getMjdStartTime() <= pixelLog.getMjdStartTime()) {
                throw new PipelineException(
                    "Mjds must increase with cadence number." + "\n  fitsFile "
                        + higher.getFitsFilename() + " has cadenceNumber "
                        + higher.getCadenceNumber() + " and startMjd "
                        + higher.getMjdStartTime() + "." + "\n  fitsFile "
                        + pixelLog.getFitsFilename() + " has cadenceNumber "
                        + pixelLog.getCadenceNumber() + " and startMjd "
                        + pixelLog.getMjdStartTime() + ".");
            }

            if (higher.getMjdEndTime() <= pixelLog.getMjdEndTime()) {
                throw new PipelineException(
                    "Mjds must increase with cadence number." + "\n  fitsFile "
                        + higher.getFitsFilename() + " has cadenceNumber "
                        + higher.getCadenceNumber() + " and endMjd "
                        + higher.getMjdEndTime() + "." + "\n  fitsFile "
                        + pixelLog.getFitsFilename() + " has cadenceNumber "
                        + pixelLog.getCadenceNumber() + " and endMjd "
                        + pixelLog.getMjdEndTime() + ".");
            }
        }
    }

    protected void storeFitsHeaders(String fitsFileName, Fits fits)
        throws Exception {
        BasicHDU[] hdus = fits.read(); // make sure all HDUs are read
        for (int i = 1; i < hdus.length; i++) {
            TableHDU hdu = (TableHDU) hdus[i];
            hdu.deleteRows(0);
        }

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        DataOutputStream dos = new DataOutputStream(baos);
        fits.write(dos);
        dos.close();

        FsId fitsFsId = DrFsIdFactory.getPixelFitsHeaderFile(fitsFileName);
        FileStoreClient fsClient = FileStoreClientFactory.getInstance(ConfigurationServiceFactory.getInstance());
        fsClient.writeBlob(fitsFsId, 0, baos.toByteArray());
    }

    protected abstract void extractAndStoreTimeSeriesData(
        List<String> fileNames, String sourceDirectory);

    protected void processCadenceForModuleOutput(CadenceFitsPair fitsFiles,
        int ccdModule, int ccdOutput) {
        IntervalMetricKey oneCadenceKey = null;
        try {
            oneCadenceKey = IntervalMetric.start();

            IntervalMetricKey fitsLoadKey = null;
            try {
                fitsLoadKey = IntervalMetric.start();
            } finally {
                IntervalMetric.stop(
                    "dr.dispatch.pixel.oneCadence.fitsLoadModOut", fitsLoadKey);
            }

            int rowCount = fitsFiles.getRowCountForCurrentModuleOutput();

            IntervalMetricKey fitsReadRowsKey = null;
            try {
                fitsReadRowsKey = IntervalMetric.start();
                for (int rowIndex = 0; rowIndex < rowCount; rowIndex++) {
                    TimeSeriesEntry timeSeriesEntry = fitsFiles.readRow(rowIndex);

                    int rawPixelValue = timeSeriesEntry.getValue();
                    if (rawPixelValue != MISSING_PIXEL_VALUE) {
                        PixelLog pixelLog = filenameToPixelLogMap.get(fitsFiles.getFitsFileName());
                        if (pixelLog != null) {
                            Set<Integer> requantValueSet = getRequantValueSet(pixelLog.getCompressionTableId());

                            if (pixelLog.isDataRequantizedForDownlink()) {
                                if (!requantValueSet.contains(rawPixelValue)) {
                                    throw new PipelineException(
                                        "Pixel values must exist in the requant table."
                                            + "\n  compressionExternalId: "
                                            + pixelLog.getCompressionTableId()
                                            + "\n  fitsFile: "
                                            + fitsFiles.getFitsFileName()
                                            + "\n  cadenceNumber: "
                                            + fitsFiles.getCadenceNumber()
                                            + "\n  channel: "
                                            + FcConstants.getChannelNumber(
                                                ccdModule, ccdOutput)
                                            + "\n  rowInBinaryTable: "
                                            + rowIndex + "\n  pixelValue: "
                                            + rawPixelValue);
                                }
                            } else {
                                if (rawPixelValue > FcConstants.REQUANT_TABLE_MAX_VALUE
                                    || rawPixelValue < FcConstants.REQUANT_TABLE_MIN_VALUE) {
                                    throw new PipelineException(
                                        "Pixel values must be in the valid range for requant table values."
                                            + "\n  requantTableMaxValue: "
                                            + FcConstants.REQUANT_TABLE_MAX_VALUE
                                            + "\n  requantTableMinValue: "
                                            + FcConstants.REQUANT_TABLE_MIN_VALUE
                                            + "\n  fitsFile: "
                                            + fitsFiles.getFitsFileName()
                                            + "\n  cadenceNumber: "
                                            + fitsFiles.getCadenceNumber()
                                            + "\n  channel: "
                                            + FcConstants.getChannelNumber(
                                                ccdModule, ccdOutput)
                                            + "\n  rowInBinaryTable: "
                                            + rowIndex + "\n  pixelValue: "
                                            + rawPixelValue);
                                }
                            }
                        }
                    }

                    timeSeriesBuffer.addValue(timeSeriesEntry);
                }
            } finally {
                IntervalMetric.stop(
                    "dr.dispatch.pixel.oneCadence.fitsReadRowsModOut",
                    fitsReadRowsKey);
            }
        } finally {
            IntervalMetric.stop("dr.dispatch.pixel.oneCadence.process",
                oneCadenceKey);
        }
    }

    private Set<Integer> getRequantValueSet(short compressionTableId) {
        if (externalIdRequantValueSetPair == null
            || externalIdRequantValueSetPair.left != compressionTableId) {
            CompressionCrud compressionCrud = new CompressionCrud();
            RequantTable requantTable = compressionCrud.retrieveUplinkedRequantTable(compressionTableId);

            if (requantTable == null) {
                throw new PipelineException(
                    "The requant table must exist and must be uplinked.  No uplinked requant table found for externalId "
                        + compressionTableId + ".");
            }

            Set<Integer> requantValueSet = newHashSet();
            for (RequantEntry entry : requantTable.getRequantEntries()) {
                requantValueSet.add(entry.getRequantFlux());
            }

            externalIdRequantValueSetPair = Pair.of(compressionTableId,
                requantValueSet);
        }

        return externalIdRequantValueSetPair.right;
    }

}
