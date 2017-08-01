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

package gov.nasa.kepler.ar.cli;

import gov.nasa.kepler.ar.archive.*;
import gov.nasa.kepler.ar.exporter.ExporterPipelineUtils;
import gov.nasa.kepler.ar.exporter.FrontEndPipelineMetadata;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.pa.PaCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.UnifiedObservedTargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.DataAnomalyOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.pi.module.MatlabMcrExecutable;
import gov.nasa.kepler.pi.module.io.MatlabBinFileUtils;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.File;
import java.util.*;

import com.google.common.collect.ImmutableSet;

/**
 * Stuff you probably want if you are going to have a CLI that executes matlab
 * executables.
 * 
 * @author Sean McCauliff
 *
 */
abstract class MatlabExecutingCliBase  implements PipelineProcessExecutor<ArchiveInputs, ArchiveOutputs> {

    private int exeSequenceNumber = 0;
    protected final int ccdModule;
    protected final int ccdOutput;
    protected final CadenceType cadenceType;
    protected final int startCadence;
    protected final int endCadence;
    protected final int lcStartCadence;
    protected final int lcEndCadence;
    protected final MjdToCadence mjdToCadence;
    protected final MjdToCadence lcMjdToCadence;
    protected final FrontEndPipelineMetadata frontEndPipelineMetadata = new FrontEndPipelineMetadata();
    protected final PipelineInstance frontEndPipelineInstance;
    protected final TimestampSeries cadenceTimes;
    protected final TimestampSeries lcCadenceTimes;
    protected final TargetTable ttable;
    protected final TargetTable lcTargetTable;
    protected final List<Integer> allKeplerIds;
    private final BlobOperations blobOps;
    private final ArchiveMatlabProcessSource archiveSource;
    protected final File outputDir;
    protected final ExporterPipelineUtils exporterPipelineUtils = new ExporterPipelineUtils();
    protected final String fileTimestamp;
    protected final DataAnomalyOperations anomalyOps;
    protected final ConfigMapOperations configMapOps = new ConfigMapOperations();
    protected final CelestialObjectOperations celestialObjectOps;
    protected final CompressionCrud compressionCrud = new CompressionCrud();
    protected final GainOperations gainOps = new GainOperations();
    protected final ReadNoiseOperations readNoiseOps = new ReadNoiseOperations();
    protected final PaCrud paCrud = new PaCrud();
    protected final Date generatedAt = new Date();
    protected final TargetCrud targetCrud = new TargetCrud();
    protected final LogCrud logCrud = new LogCrud();
    protected final UnifiedObservedTargetCrud uTargetCrud;
    protected final int quarter;
    protected final Set<String> excludeTargetLabels = ImmutableSet.of("ARTIFACT_REMOVAL");

    
    
    protected MatlabExecutingCliBase(File outputDir, CadenceType cadenceType,
        int externalTTableId, int ccdModule, int ccdOutput, int quarter) {
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.cadenceType = cadenceType;
        this.outputDir = outputDir;
        this.quarter = quarter;
        
        blobOps = new BlobOperations(outputDir);
        
        TargetType targetType = cadenceType == CadenceType.LONG ? TargetType.LONG_CADENCE
            : TargetType.SHORT_CADENCE;

        Pair<Integer, Integer> actual = 
            logCrud.retrieveActualCadenceTimeForTargetTable(externalTTableId, targetType);
        startCadence = actual.left;
        endCadence = actual.right;

        frontEndPipelineInstance = frontEndPipelineMetadata.getPipelineInstance(
            cadenceType, startCadence, endCadence);

        Pair<Integer, Integer> lcCadences = (cadenceType == CadenceType.SHORT) ? logCrud.shortCadenceToLongCadence(
            startCadence, endCadence) : actual;
        lcStartCadence = lcCadences.left;
        lcEndCadence = lcCadences.right;

        ModelMetadataRetrieverPipelineInstance modelMetadataRetriever = 
            new ModelMetadataRetrieverPipelineInstance(frontEndPipelineInstance);
        
        mjdToCadence = new MjdToCadence(cadenceType, modelMetadataRetriever);
        lcMjdToCadence = (cadenceType == CadenceType.SHORT) ? 
            new MjdToCadence(CadenceType.LONG, modelMetadataRetriever) : 
                mjdToCadence;
        
        cadenceTimes = 
            mjdToCadence.cadenceTimes(startCadence, endCadence);
        lcCadenceTimes = (cadenceType == CadenceType.SHORT) ? 
            lcMjdToCadence.cadenceTimes(lcStartCadence, lcEndCadence) :
                cadenceTimes;

        TargetCrud targetCrud = new TargetCrud();
        ttable = constructTargetTable(externalTTableId, targetType);
        lcTargetTable = constructLcTargetTable();

        allKeplerIds = 
            targetCrud.retrieveObservedKeplerIds(ttable, ccdModule, ccdOutput);
        
        this.archiveSource = createArchiveMatlabProcessSource();
        
        
        fileTimestamp = exporterPipelineUtils.defaultFileTimestamp(cadenceTimes);
        anomalyOps = new DataAnomalyOperations(
            new ModelMetadataRetrieverPipelineInstance(frontEndPipelineInstance));
        
        celestialObjectOps = new CelestialObjectOperations(
            new ModelMetadataRetrieverPipelineInstance(frontEndPipelineInstance),
            false /* exclude custom targets*/);
        
        uTargetCrud = new UnifiedObservedTargetCrud();
    }
    
    
    protected TargetTable constructTargetTable(int externalTTableId, TargetType targetType) {
        return targetCrud.retrieveUplinkedTargetTable(externalTTableId, targetType);
    }
    
    protected TargetTable constructLcTargetTable() {
        return targetCrud.retrieveLongCadenceTargetTable(ttable).get(0);
    }
    
    private ArchiveMatlabProcessSource createArchiveMatlabProcessSource() {
        ArchiveMatlabProcessSource source = new ArchiveMatlabProcessSource() {

            @Override
            public int startCadence() {
                return startCadence;
            }

            @Override
            public int endCadence() {
                return endCadence;
            }

            @Override
            public ConfigMapOperations configMapOps() {
                return new ConfigMapOperations();
            }

            @Override
            public int ccdOutput() {
                return ccdOutput;
            }

            @Override
            public int ccdModule() {
                return ccdModule;
            }

            @Override
            public CadenceType cadenceType() {
                return cadenceType;
            }

            @Override
            public TimestampSeries cadenceTimes() {
                return cadenceTimes;
            }

            @Override
            public BlobOperations blobOps() {
                return blobOps;
            }

            @Override
            public void addOriginator(long pipelineTaskId) {
                // This does nothing.
            }

            @Override
            public LogCrud logCrud() {
                return new LogCrud();
            }

            @Override
            public RaDec2PixOperations raDec2PixOps() {
                return new RaDec2PixOperations();
            }

            @Override
            public TimestampSeries longCadenceTimes() {
                return lcCadenceTimes;
            }

        };

        return source;
    }
    
    
    protected Map<Pixel, BackgroundPixelValue> calculateBackground(
        final Set<Pixel> pixels) {

        ArchiveMatlabProcess archive = new ArchiveMatlabProcess(true);
        return archive.calculateBackground(archiveSource, this, pixels)
        .backgroundToMap();
    }

    protected <T extends DvaTargetSource> Map<Integer, BarycentricCorrection> calculateBarycentricCorrections(
        final Collection<T> observedTargets,
        Map<FsId, TimeSeries> allTimeSeries) {

        ArchiveMatlabProcess archive = new ArchiveMatlabProcess(true);
        return archive.calculateBarycentricCorrections(archiveSource, this,
                                                       observedTargets, allTimeSeries)
                                                       .barycentricCorrectionToMap();
    }

    protected <T extends DvaTargetSource> Map<Integer, TargetWcs> calculateWcsCoordinates(                                                                        
        final Collection<T> targets, Map<FsId, TimeSeries> allTimeSeries) {

        ArchiveMatlabProcess archive = new ArchiveMatlabProcess(true);
        return archive.calculateWcs(archiveSource, this, targets, allTimeSeries)
        .targetsWcs();
    }

    protected <T extends DvaTargetSource> Map<Integer, TargetDva> calculateDvaMotion(
        final Collection<T> observedTargets,
        Map<FsId, TimeSeries> allTimeSeries) {
        
        ArchiveMatlabProcess archive = new ArchiveMatlabProcess(true);
        return archive.calculateDva(archiveSource, this, observedTargets,
                                    allTimeSeries)
                                    .targetsDva();
    }

    /**
     * This implementation might be replaced with something that the pipeline
     * already uses.
     */
     @Override
     public void exec(ArchiveOutputs aout, ArchiveInputs ain) {
        try {
            File taskWorkingDir = outputDir.getAbsoluteFile();
            String exeName = "ar";

            exeSequenceNumber++;

            MatlabBinFileUtils.clearStaleErrorState(taskWorkingDir, exeName,
                                                    exeSequenceNumber);
            MatlabBinFileUtils.serializeInputsFile(ain, taskWorkingDir,
                                                   exeName, exeSequenceNumber);

            MatlabMcrExecutable matlabExe = new MatlabMcrExecutable("ar",
                                                                    taskWorkingDir, 3000);
            matlabExe.execAlgorithm(exeSequenceNumber);

            MatlabBinFileUtils.deserializeOutputsFile(aout, taskWorkingDir,
                                                      exeName, exeSequenceNumber);
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
     }
}
