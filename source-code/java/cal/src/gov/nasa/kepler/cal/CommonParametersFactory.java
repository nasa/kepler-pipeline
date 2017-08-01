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

package gov.nasa.kepler.cal;

import gov.nasa.kepler.cal.ffi.FfiModOut;
import gov.nasa.kepler.cal.ffi.FfiReader;
import gov.nasa.kepler.cal.io.CalCosmicRayParameters;
import gov.nasa.kepler.cal.io.CalHarmonicsIdentificationParameters;
import gov.nasa.kepler.cal.io.CalModuleParameters;
import gov.nasa.kepler.cal.io.CommonParameters;
import gov.nasa.kepler.cal.io.HuffmanTable;
import gov.nasa.kepler.cal.io.LdeUndershootId;
import gov.nasa.kepler.cal.io.TwoDBlackId;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.fc.FlatFieldModel;
import gov.nasa.kepler.fc.GainModel;
import gov.nasa.kepler.fc.LinearityModel;
import gov.nasa.kepler.fc.ReadNoiseModel;
import gov.nasa.kepler.fc.TwoDBlackModel;
import gov.nasa.kepler.fc.UndershootModel;
import gov.nasa.kepler.fc.flatfield.FlatFieldOperations;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.linearity.LinearityOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.fc.twodblack.TwoDBlackOperations;
import gov.nasa.kepler.fc.undershoot.UndershootOperations;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.cm.PlannedTarget.TargetLabel;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetriever;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.mc.GapFillModuleParameters;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.PouModuleParameters;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.gar.RequantTable;
import gov.nasa.kepler.tad.operations.TargetOperations;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Set;

import nom.tam.fits.FitsException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.Lists;

/**
 * Generate the cal common parameters.  This class is not final so that
 * one can create test classes.
 * 
 * @author Sean McCauliff
 *
 */
public class CommonParametersFactory {

    private static final Log log = LogFactory.getLog(CommonParametersFactory.class);
    
    private static final class CoveringTargetTables {
        public final TargetTableLog lcTargetTableLog;
        public final TargetTableLog scTargetTableLog;
        public final TargetTableLog bkTargetTableLog;
        
        public CoveringTargetTables(TargetTableLog lcTargetTable,
            TargetTableLog scTargetTable, TargetTableLog bkTargetTable) {
            super();
            this.lcTargetTableLog = lcTargetTable;
            this.scTargetTableLog = scTargetTable;
            this.bkTargetTableLog = bkTargetTable;
        }
    }
    
    /**
     * This is stuff that gets lazly created and we store the resulting object here so
     * we don't need to create another one.  These data members
     * are not stored in the main class so we don't accidently
     * access them.
     *
     */
    private static final class Memorized {
        MjdToCadence lcMjdToCadence;
        MjdToCadence scMjdToCadence;
    }
    
    private CalModuleParameters calModuleParameters = new CalModuleParameters();
    private CalCosmicRayParameters calCosmicRayParameters = new CalCosmicRayParameters();
    private PouModuleParameters pouParameters =       new PouModuleParameters();
    private GapFillModuleParameters gapFillParameters = new GapFillModuleParameters();
    private CalHarmonicsIdentificationParameters harmonicsParameters = new CalHarmonicsIdentificationParameters();
    
    /** This gets set to the latest retriever since we are kind of starting at the
     * beginning of the pipeline and the defaults for this class are to make it as
     * painless as possible to just generate some inputs.  You might need 
     * the dynablack pipeline instance in order to make sure this uses the
     * same as dynablack.
     */
    private ModelMetadataRetriever modelMetadataRetriever = 
        new ModelMetadataRetrieverLatest();
    
    /** cache */
    private Memorized m = new Memorized();
    
    public void setParameters(CalModuleParameters calModuleParameters,
        CalCosmicRayParameters calCosmicRayParameters,
        PouModuleParameters pouParameters,
        CalHarmonicsIdentificationParameters harmonicsParameters,
        GapFillModuleParameters gapFillParameters) {
        
        this.calModuleParameters = calModuleParameters;
        this.calCosmicRayParameters = calCosmicRayParameters;
        this.pouParameters = pouParameters;
        this.gapFillParameters = gapFillParameters;
        this.harmonicsParameters = harmonicsParameters;
    }
    
    /**
     * Set this if you want to get the data anomaly flags from a known state
     * like the same one that dynablack used.
     * @param newMMR
     */
    public void setModelMetadataRetriever(ModelMetadataRetriever newMMR) {
        this.modelMetadataRetriever = newMMR;
    }
    
    /**
     * TODO:  What to do when the cadence is type FFI
     * @param cadenceType
     * @param userStartCadence  the cadence requested by the end user.
     * this may be changed depending on the actual start and end
     * cadences of the target table.
     * @param userEndCadence the cadence requested by the end user.
     * this may be changed depending on the actual start and end
     * cadences of the target table.
     * @param ccdModule
     * @param ccdOutput
     * @param blobOutputDir this directory should exist
     * @return the common parameters.  This does not return null.
     * @throws ParseException 
     * @throws FitsException 
     * @throws IOException 
     * @throws PipelineException if target tables can not be found.
     */
    public CommonParameters create(CadenceType cadenceType, int userStartCadence,
        int userEndCadence, int ccdModule, int ccdOutput, File blobOutputDir) throws ParseException, IOException, FitsException {
        

        CoveringTargetTables coveringTargetTables = 
            retrieveTargetTables(cadenceType, userStartCadence, userEndCadence);
        
        boolean hasData = true;
        if (coveringTargetTables == null) {
            log.warn("Can't find target table for user specified cadence interval [" + 
                userStartCadence + "," + userEndCadence + "]");
            hasData = false;
            coveringTargetTables = figureOutTargetTables(cadenceType, userStartCadence, userEndCadence);
        }
        
        TargetTableLog ttableLog = (cadenceType == CadenceType.LONG) ? 
            coveringTargetTables.lcTargetTableLog :
            coveringTargetTables.scTargetTableLog;

        final TargetTable ttable = ttableLog.getTargetTable();
        final TargetTable bkgTtable = coveringTargetTables.bkTargetTableLog.getTargetTable();
        final TargetTable lcTargetTable = coveringTargetTables.lcTargetTableLog.getTargetTable();
        
        int startCadence = useStartCadence(userStartCadence, ttableLog);
        int endCadence = useEndCadence(userEndCadence, ttableLog);
        int season = ttableLog.getTargetTable().getObservingSeason();
        log.info("startCadence: " + startCadence);
        log.info("endCadence: " + endCadence);
        log.info("season: " + season);
        
        TimestampSeries cadenceTimes = retrieveCadenceTimes(cadenceType, startCadence, endCadence);
        
        int[] quarters = getRollTimeOps().mjdToQuarter(new double[] { cadenceTimes.startMjd(), cadenceTimes.endMjd()} );
        if (quarters[0] != quarters[1]) {
            throw new PipelineException("Unit of work spans quarters.  The quarter for mjd " +
                cadenceTimes.startMjd() +
                " is " + quarters[0] + ", the quarter for mjd " + cadenceTimes.endMjd() + 
                " is " + quarters[1] + ".");
        }
        
      //TODO:  FFI cadence type
        String cadenceTypeStr = (cadenceType == CadenceType.SHORT) ?
            "SHORT" : "LONG";
        
        if (!hasData) {
            return new CommonParameters(ttable, lcTargetTable, bkgTtable,
                ccdModule, ccdOutput, cadenceTypeStr, season, quarters[0],
                calModuleParameters,
                calCosmicRayParameters, pouParameters, harmonicsParameters,
                gapFillParameters, cadenceTimes);
        }
        
        
        double startMjd = cadenceTimes.startMjd();
        double endMjd = cadenceTimes.endMjd();
        
        GainModel gainModel = getGainOps().retrieveGainModel(startMjd, endMjd);
        FlatFieldModel flatFieldModel = getFlatFieldOps().retrieveFlatFieldModel(
            startMjd, endMjd, ccdModule, ccdOutput);
        TwoDBlackModel twoDBlackModel = getTwoDBlackOps().retrieveTwoDBlackModel(
            startMjd, endMjd, ccdModule, ccdOutput);

        LinearityModel linearityModel = getLinearityOps().retrieveLinearityModel(
            ccdModule, ccdOutput, startMjd, endMjd);

        UndershootModel undershootModel = getUndershootOps().retrieveUndershootModel(
            startMjd, endMjd);

        ReadNoiseModel readNoiseModel = 
            getReadNoiseOps().retrieveReadNoiseModel(startMjd, endMjd);
        
        List<RequantTable> requantTables = retrieveRequantTables(cadenceTimes);
        List<HuffmanTable> huffmanTables = retrieveHuffmanTables(cadenceTimes);
        List<ConfigMap> configMaps = retrieveConfigMaps(lcTargetTable);
        
        List<TwoDBlackId> twoDBlackIds = retrieveTwoDBlackIds(ttableLog.getTargetTable(), ccdModule, ccdOutput);
        if (cadenceType == CadenceType.LONG) {
            twoDBlackIds.addAll(retrieveTwoDBlackIds(bkgTtable, ccdModule, ccdOutput));
        }
        
        List<LdeUndershootId> ldeUndershootIds = retrieveLdeUndershootIds(ttableLog.getTargetTable(), ccdModule, ccdOutput);
        if (cadenceType == CadenceType.LONG) {
            ldeUndershootIds.addAll(retrieveLdeUndershootIds(bkgTtable, ccdModule, ccdOutput));
        }
        
        Pair<Integer, Integer> longCadences = (cadenceType != CadenceType.LONG) ?
            getLogCrud().shortCadenceToLongCadence(startCadence, endCadence): 
            Pair.of(startCadence, endCadence);
        
        if (longCadences == null) {
            throw new IllegalStateException("Missing covering long cadences.");
        }
        
        BlobFileSeries dynaBlackBlobs = new BlobFileSeries();
        if (calModuleParameters.dynablackIsEnabled()) {
            BlobSeries<String> dynaBlackBlobStr =
                getBlobOps(blobOutputDir).retrieveDynamicTwoDBlackBlobFileSeries(
                ccdModule, ccdOutput, longCadences.left, longCadences.right);
            dynaBlackBlobs = createBlobFileSeries(dynaBlackBlobStr);
        }
        BlobFileSeries oneDBlackBlobs = new BlobFileSeries();
        if (cadenceType == CadenceType.SHORT) {
            
            BlobSeries<String> lcOneDBlackBlobs =
                getBlobOps(blobOutputDir).retrieveCalOneDBlackFitBlobFileSeries(ccdModule,
                ccdOutput, CadenceType.LONG, longCadences.left, longCadences.right);
            oneDBlackBlobs = createBlobFileSeries(lcOneDBlackBlobs);
        }
        BlobFileSeries smearBlobs = new BlobFileSeries();
        if (cadenceType == CadenceType.SHORT) {
            BlobSeries<String> lcSmearBlobs = 
                getBlobOps(blobOutputDir).retrieveSmearBlobFileSeries(ccdModule,
                    ccdOutput, CadenceType.LONG, longCadences.left, longCadences.right);
            smearBlobs = createBlobFileSeries(lcSmearBlobs);
        }
        
        List<FfiModOut> ffiModOut = Lists.newArrayList();
        if (calModuleParameters.isEnableFfiInform()) {
            TargetTable ffiTargetTable = 
                coveringTargetTables.lcTargetTableLog.getTargetTable();
            Pair<Double, Double> ttableStartEndTimes = 
                getLogCrud().
                retrieveActualObservationTimeForTargetTable(ffiTargetTable.getExternalId(), ffiTargetTable.getType());
            double ttableStartMjd = ttableStartEndTimes.left;
            double endQuarterMjd = 
                getRollTimeOps().retrieveRollTime(ttableStartEndTimes.right).getMjd();
            FfiFinder ffiFinder = createFfiFinder();
            List<FsId> ffiIds = ffiFinder.find(ttableStartMjd, endQuarterMjd,
                ccdModule, ccdOutput);
            if (ffiIds.isEmpty()) {
                throw new IllegalStateException("Expected non-empty list of ffis.");
            }
            FfiReader ffiReader = createFfiReader();
            for (FsId ffiId : ffiIds) {
                ffiModOut.add(ffiReader.readFFiModOut(ffiId));
            }
        }
        return new CommonParameters(ttable, lcTargetTable, bkgTtable,
            ccdModule, ccdOutput, cadenceTypeStr,
            calModuleParameters, calCosmicRayParameters, pouParameters,
            harmonicsParameters, gapFillParameters,
            cadenceTimes, gainModel, flatFieldModel, twoDBlackModel,
            linearityModel, undershootModel, readNoiseModel,
            twoDBlackIds, ldeUndershootIds,
            configMaps, requantTables, huffmanTables,
            season, quarters[0], oneDBlackBlobs, dynaBlackBlobs, smearBlobs,
            ffiModOut);
        
    }

    protected int useStartCadence(int userStartCadence, TargetTableLog ttableLog) {
        int startCadence = Math.max(userStartCadence, ttableLog.getCadenceStart());
        return startCadence;
    }
    
    protected int useEndCadence(int userEndCadence, TargetTableLog ttableLog) {
        int endCadence = Math.min(userEndCadence, ttableLog.getCadenceEnd());
        return endCadence;
    }
    
    /**
     * If you have found your way here then something wrong has happened.  Your
     * cadences were never delivered and so there is no mapping between target
     * tables and cadences.
     * 
     * @param cadenceType
     * @param userStartCadence 
     * @param userEndCadence 
     * @return
     */
    private CoveringTargetTables figureOutTargetTables(CadenceType cadenceType,
        int userStartCadence, int userEndCadence) {

        Pair<Integer, Integer> closest = 
            getLogCrud().retrieveClosestCadenceToCadence(userStartCadence, cadenceType);
        if (closest.left == null || closest.right == null) {
            throw new PipelineException("Specified cadences [" +
                userStartCadence + "," + userEndCadence +
                "] are not associated with pixel logs.  " +
                "Attempts to find better covering cadenes have failed." +
                "  Likely you have specified a cadence interval" +
                " that falls off the edge of the known data."); 
        }
        
        return retrieveTargetTables(cadenceType, closest.left, closest.right);
    }

    protected BlobFileSeries createBlobFileSeries(BlobSeries<String> strBlobSeries) {
        return new BlobFileSeries(strBlobSeries);
    }

    private List<LdeUndershootId> retrieveLdeUndershootIds(TargetTable targetTable, int ccdModule, int ccdOutput) {
        Set<String> labels = Collections.singleton(TargetLabel.PPA_LDE_UNDERSHOOT.toString());

        Map<Integer, List<Pixel>> pixelAddresses =
        getTargetOps().getAperturePixelsForLabeledTargets(getTargetCrud(),
            targetTable, ccdModule, ccdOutput, labels);

        List<LdeUndershootId> rv = new ArrayList<LdeUndershootId>();
        for (Map.Entry<Integer, List<Pixel>> undershootId : pixelAddresses.entrySet()) {
            int[] rows = new int[undershootId.getValue().size()];
            int[] cols = new int[rows.length];
            int pi=0;
            for (Pixel p : undershootId.getValue()) {
                rows[pi] = p.getRow();
                cols[pi] = p.getColumn();
                pi++;
            }
            
            rv.add(new LdeUndershootId(rows, cols, undershootId.getKey()));
        }

        return rv;
    }
    
    private List<TwoDBlackId> retrieveTwoDBlackIds(TargetTable targetTable, int ccdModule, int ccdOutput) {
        Set<String> labels = Collections.singleton(TargetLabel.PPA_2DBLACK.toString());
        
        Map<Integer, List<Pixel>> pixelAddresses =
        getTargetOps().getAperturePixelsForLabeledTargets(getTargetCrud(),
            targetTable, ccdModule, ccdOutput, labels);
        
        List<TwoDBlackId> rv = new ArrayList<TwoDBlackId>();
        for (Map.Entry<Integer, List<Pixel>> blackId : pixelAddresses.entrySet()) {
            int[] rows = new int[blackId.getValue().size()];
            int[] cols = new int[rows.length];
            int pi=0;
            for (Pixel p : blackId.getValue()) {
                rows[pi] = p.getRow();
                cols[pi] = p.getColumn();
                pi++;
            }
            
            rv.add(new TwoDBlackId(rows, cols, blackId.getKey()));
        }

        return rv;
    }
    
    private List<RequantTable> retrieveRequantTables(
        TimestampSeries cadenceTimes) {
        List<gov.nasa.kepler.hibernate.gar.RequantTable> hRequantTables = getCompressionCrud().retrieveRequantTables(
            cadenceTimes.startMjd(), cadenceTimes.endMjd());

        List<RequantTable> rv = new ArrayList<RequantTable>(hRequantTables.size());
        for (gov.nasa.kepler.hibernate.gar.RequantTable hRequant : hRequantTables) {
            Pair<Double, Double> startEndTimes = getCompressionCrud().retrieveStartEndTimes(
                hRequant.getExternalId());
            RequantTable persistableRequant = createPersistableRequantTable(hRequant, startEndTimes.left);

            rv.add(persistableRequant);
        }

        if (rv.size() == 0) {
            throw new ModuleFatalProcessingException("Missing requant table.");
        }

        return rv;
    }
    
    protected RequantTable createPersistableRequantTable(gov.nasa.kepler.hibernate.gar.RequantTable hRequantTable, double startMjd) {
        return new RequantTable(hRequantTable, startMjd);
    }

    private List<HuffmanTable> retrieveHuffmanTables(TimestampSeries cadenceTimes) {
        List<gov.nasa.kepler.hibernate.gar.HuffmanTable> hHuffmanTable = getCompressionCrud().retrieveHuffmanTables(
            cadenceTimes.startMjd(), cadenceTimes.endMjd());

        List<HuffmanTable> rv = new ArrayList<HuffmanTable>(hHuffmanTable.size());
        for (gov.nasa.kepler.hibernate.gar.HuffmanTable hht : hHuffmanTable) {
            Pair<Double, Double> startEndTime = getCompressionCrud().retrieveStartEndTimes(
                hht.getExternalId());
            HuffmanTable persistableTable = createPersistableHuffmanTable(hht, startEndTime.left);
            rv.add(persistableTable);
        }

        if (rv.size() == 0) {
            throw new ModuleFatalProcessingException("Missing huffman table.");
        }
        return rv;
    }
    
    protected HuffmanTable createPersistableHuffmanTable(gov.nasa.kepler.hibernate.gar.HuffmanTable hHuffmanTable, double startMjd) {
       return new HuffmanTable(hHuffmanTable, startMjd);
    }

    protected List<ConfigMap> retrieveConfigMaps(TargetTable lcTargetTable) {

        if (lcTargetTable.getType() != TargetType.LONG_CADENCE) {
            throw new IllegalArgumentException("Expected long cadence target table, but got " + lcTargetTable);
        }
        
        List<ConfigMap> cMaps = getConfigMapOps().retrieveConfigMaps(lcTargetTable);
        if (cMaps == null || cMaps.size() == 0) {
            throw new ModuleFatalProcessingException("Need at least one spacecraft config id map, but found none.");
        }

        return cMaps;

    }
    
    private TimestampSeries retrieveCadenceTimes(CadenceType cadenceType,
        int startCadence, int endCadence) {

        MjdToCadence.TimestampSeries tsSeries =
            getMjdToCadence(cadenceType).cadenceTimes(startCadence, endCadence, false);
        return tsSeries;

    }

    /**
     * 
     * @param cadenceType
     * @param startCadence
     * @param endCadence
     * @return null if we don't find the target tables we need
     */
    private CoveringTargetTables retrieveTargetTables(CadenceType cadenceType, int startCadence, int endCadence) {
        
        Pair<TargetTableLog, TargetTableLog> lcTargetTableLogs;
        TargetTableLog scTargetTableLog = null;
        if (cadenceType == CadenceType.LONG) {
            lcTargetTableLogs = longCadenceTargetTableLogs(startCadence, endCadence);
            if (lcTargetTableLogs == null) {
                return null;
            }
        } else {
            scTargetTableLog = shortCadenceTargetTableLogs(startCadence, endCadence);
            if (scTargetTableLog == null) {
                return null;
            }
            Pair<Integer, Integer> lcStartEnd = 
                getLogCrud().shortCadenceToLongCadence(startCadence, endCadence);
            lcTargetTableLogs = longCadenceTargetTableLogs(lcStartEnd.left, lcStartEnd.right);
            if (lcTargetTableLogs == null) {
                return null;
            }
        }
        return new CoveringTargetTables(lcTargetTableLogs.left, scTargetTableLog, lcTargetTableLogs.right);
    }
    
    /**
     * 
     * @throws PipelineException For the usual reasons.
     * @return a pair of (long cadence target table log, short cadence target table log) 
     * or null if data is missing.
     */
    private Pair<TargetTableLog, TargetTableLog> longCadenceTargetTableLogs(int startCadence, int endCadence) {
        List<TargetTableLog> targetTableLogs = 
            getTargetCrud().retrieveTargetTableLogs(TargetType.LONG_CADENCE, startCadence, endCadence);
        
        if (targetTableLogs == null || targetTableLogs.size() == 0) {
            log.warn(" Long cadence target tables missing for specified cadence interval.");
            return null;
        }

        if (targetTableLogs.size() > 1) {
            throw new ModuleFatalProcessingException(
                " Found " + targetTableLogs.size() + 
                " target tables for specified cadence interval.");
        }
        
        TargetTableLog lcLog = targetTableLogs.get(0);
        List<TargetTableLog> bkgLogList = 
            getTargetCrud().retrieveTargetTableLogs(TargetType.BACKGROUND,
                lcLog.getCadenceStart(), lcLog.getCadenceEnd());
        if (bkgLogList.size() != 1) {
            throw new ModuleFatalProcessingException(
                " Long cadence target table must have exactly one background" 
                    + " target table but this only found "
                    + bkgLogList.size() + ".");
        }

        return Pair.of(lcLog, bkgLogList.get(0));
    }

    /**
     * 
     * @throws PipelineException
     * @return The target table log for the corresponding short cadences.
     * 
     */
    private TargetTableLog shortCadenceTargetTableLogs(int startCadence, int endCadence) {
        List<TargetTableLog> scLogs = 
            getTargetCrud().retrieveTargetTableLogs(TargetType.SHORT_CADENCE, startCadence, endCadence);

        if (scLogs == null || scLogs.isEmpty()) {
            log.warn("Short cadence target tables missing for specified cadence interval.");
            return null;
        }
        
        if (scLogs.size() > 1) {
            throw new ModuleFatalProcessingException(
                "Found " + scLogs.size() + " target tables for specified cadence interval.");
        }
        
        return scLogs.get(0);
    }
    
    protected TargetOperations getTargetOps() {
        return new TargetOperations();
    }
    
    protected TargetCrud getTargetCrud() {
        return new TargetCrud();
    }
    

    protected GainOperations getGainOps() {
        return new GainOperations();
    }
   
    protected LinearityOperations getLinearityOps() {
        return new LinearityOperations();
    }

    protected ReadNoiseOperations getReadNoiseOps() {
        return new ReadNoiseOperations();
    }

    protected TwoDBlackOperations getTwoDBlackOps() {
        return new TwoDBlackOperations();
    }

    protected UndershootOperations getUndershootOps() {
        return new UndershootOperations();
    }
    
    protected FlatFieldOperations getFlatFieldOps() {
        return new FlatFieldOperations();
    }
    
    protected CompressionCrud getCompressionCrud() {
        return new CompressionCrud();
    }

    protected ConfigMapOperations getConfigMapOps() {
        return new ConfigMapOperations();
    }
    
    protected BlobOperations getBlobOps(File blobOutputDir) {
        return new BlobOperations(blobOutputDir);
    }
    
    protected LogCrud getLogCrud() {
        return new LogCrud();
    }
    
    private MjdToCadence getMjdToCadence(CadenceType cadenceType) {
        switch (cadenceType) {
            case LONG: 
                if (m.lcMjdToCadence == null) {
                    m.lcMjdToCadence = createMjdToCadence(cadenceType);
                }
                return m.lcMjdToCadence;
            case SHORT:
                if (m.scMjdToCadence == null) {
                    m.scMjdToCadence = createMjdToCadence(cadenceType);
                }
                return m.scMjdToCadence;
            default:
                throw new IllegalStateException("cadenceType " + cadenceType);
        }
    }
    
    protected MjdToCadence createMjdToCadence(CadenceType cadenceType) {
        return new MjdToCadence(cadenceType, modelMetadataRetriever);
    }
    
    protected FfiFinder createFfiFinder() {
        return new FfiFinder(FileStoreClientFactory.getInstance());
    }
    
    protected FfiReader createFfiReader() {
        return new FfiReader();
    }
    
    protected RollTimeOperations getRollTimeOps() {
        return new RollTimeOperations();
    }
    
}
