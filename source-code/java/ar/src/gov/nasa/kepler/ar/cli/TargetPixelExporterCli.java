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

import java.io.File;
import java.io.IOException;
import java.util.Collection;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import gov.nasa.kepler.ar.archive.BackgroundPixelValue;
import gov.nasa.kepler.ar.archive.BarycentricCorrection;
import gov.nasa.kepler.ar.archive.DvaTargetSource;
import gov.nasa.kepler.ar.archive.TargetDva;
import gov.nasa.kepler.ar.archive.TargetWcs;
import gov.nasa.kepler.ar.exporter.ExporterPipelineUtils;
import gov.nasa.kepler.ar.exporter.tpixel.DefaultTargetPixelExporterSource;
import gov.nasa.kepler.ar.exporter.tpixel.TargetPixelExporter;
import gov.nasa.kepler.ar.exporter.tpixel.TargetPixelExporterSource;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.cal.CalCrud;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tad.UnifiedObservedTargetCrud;
import gov.nasa.kepler.hibernate.tps.AbstractTpsDbResult;
import gov.nasa.kepler.hibernate.tps.TpsCrud;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.DataAnomalyOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.spiffy.common.collect.ListChunkIterator;
import nom.tam.fits.FitsException;

/**
 * Command line interface for testing the target pixel exporter.
 * You should view this as unreleased code.  This is a debugging tool.
 * 
 * @author Sean McCauliff
 * 
 */
public class TargetPixelExporterCli extends MatlabExecutingCliBase {

    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(TargetPixelExporterCli.class);

    private final static int CHUNK_SIZE = 8;

    private boolean exportBackground = true;
    
    public TargetPixelExporterCli(File outputDir, CadenceType cadenceType, int externalTTableId,
                                  int ccdModule, int ccdOutput, int quarter) {
        super(outputDir, cadenceType, externalTTableId, ccdModule, ccdOutput, quarter);
    }


    public void execute() throws IOException, FitsException {

        // Look for custom targets.
        // int found =0;
        // for (; found < allKeplerIds.size(); found++) {
        // if (allKeplerIds.get(found) >= 100000000) { //more hackery
        // break;
        // }
        // }
        // allKeplerIds = allKeplerIds.subList(found, allKeplerIds.size());
        ListChunkIterator<Integer> it = new ListChunkIterator<Integer>(
            allKeplerIds.iterator(), CHUNK_SIZE);
        TargetPixelExporter exporter = new TargetPixelExporter();
        for (List<Integer> chunk : it) {
            TargetPixelExporterSource tpixelSource = createTargetPixelSource(
                chunk, targetCrud, ttable, lcTargetTable,
                cadenceTimes, lcCadenceTimes,
                mjdToCadence, lcMjdToCadence, logCrud);
            exporter.exportPixelsForTargets(tpixelSource);
        }

    }

    @Override
    protected TargetTable constructTargetTable(int externalTTableId, TargetType targetType) {
        return targetCrud.retrieveTargetTable(externalTTableId, targetType, State.UPLINKED);
    }
    
    @Override 
    protected TargetTable constructLcTargetTable() {
        return ttable;
    }
    
    protected TargetPixelExporterSource createTargetPixelSource(
        final List<Integer> keplerIds, final TargetCrud targetCrud,
        final TargetTable ttable, final TargetTable lcTargetTable,
        final TimestampSeries cadenceTimes,
        final TimestampSeries lcCadenceTimes,
        final MjdToCadence mjdToCadence, final MjdToCadence lcMjdToCadence,
        final LogCrud logCrud) {

        ExporterPipelineUtils exporterPipelineUtils = new ExporterPipelineUtils();
        final String fileTimestamp = exporterPipelineUtils.defaultFileTimestamp(cadenceTimes);
        DataAnomalyOperations anomalyOperations = new DataAnomalyOperations(
            new ModelMetadataRetrieverPipelineInstance(frontEndPipelineInstance));
        
        ConfigMapOperations configMapOps = new ConfigMapOperations();
        CompressionCrud compressionCrud = new CompressionCrud();
        CelestialObjectOperations celestialObjectOps = new CelestialObjectOperations(
            new ModelMetadataRetrieverPipelineInstance(frontEndPipelineInstance),
            true);
        GainOperations gainOps = new GainOperations();
        ReadNoiseOperations readNoiseOps = new ReadNoiseOperations();
        UnifiedObservedTargetCrud uTargetCrud = new UnifiedObservedTargetCrud();
        CalCrud calCrud = new CalCrud();
        
        TargetPixelExporterSource source = new DefaultTargetPixelExporterSource(
            anomalyOperations, configMapOps, targetCrud, compressionCrud,
            gainOps, readNoiseOps, ttable, logCrud, celestialObjectOps,
            keplerIds.get(0), keplerIds.get(keplerIds.size() - 1),
            uTargetCrud, -1, calCrud) {

            @Override
            public TimestampSeries timestampSeries() {
                return cadenceTimes;
            }
            
            @Override
            public TimestampSeries cadenceTimes() {
            	return cadenceTimes;
            }
            
            @Override
            public TimestampSeries longCadenceTimes() {
            	return cadenceTimes;
            }

            @Override
            public int startCadence() {
                return startCadence;
            }

            @Override
            public int quarter() {
                return quarter;
            }

            @Override
            public String programName() {
                return TargetPixelExporterCli.class.getSimpleName();
            }

            @Override
            public long pipelineTaskId() {
                return -1;
            }

            @Override
            public MjdToCadence mjdToCadence() {
                return mjdToCadence;
            }

            @Override
            public File exportDirectory() {
                return outputDir;
            }

            @Override
            public int endCadence() {
                return endCadence;
            }

            @Override
            public int dataReleaseNumber() {
                return -1;
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
            public Map<Pixel, BackgroundPixelValue> background(Set<Pixel> pixels) {
                if (exportBackground) {
                    return calculateBackground(pixels);
                } else {
                    return super.background(pixels);
                }
            }

            @Override
            public <T extends DvaTargetSource> Map<Integer, BarycentricCorrection> barycentricCorrection(
                Collection<T> customTargets, Map<FsId, TimeSeries> allTimeSeries) {

                return calculateBarycentricCorrections(customTargets, allTimeSeries);
            }

            @Override
            public int compressionThresholdInPixels() {
                return 0;
            }

            @Override
            public Set<String> excludeTargetsWithLabel() {
                return excludeTargetLabels;
            }

            @Override
            public <T extends DvaTargetSource> Map<Integer, TargetDva> dvaMotion(
                Collection<T> targets, Map<FsId, TimeSeries> allTimeSeries) {

                return calculateDvaMotion(targets, allTimeSeries);
            }

            @Override
            public <T extends DvaTargetSource> Map<Integer, TargetWcs> wcsCoordinates(
                Collection<T> targets, Map<FsId, TimeSeries> allTimeSeries) {

                return calculateWcsCoordinates(targets, allTimeSeries);
            }

            @Override
            public List<? extends AbstractTpsDbResult> tpsDbResults() {
                TpsCrud tpsCrud = new TpsCrud();
                return tpsCrud.retrieveTpsLiteResult(keplerIds);
            }

            @Override
            public TimestampSeries longCadenceTimestampSeries() {
                return lcCadenceTimes;
            }

            @Override
            public int longCadenceExternalTargetTableId() {
                return lcTargetTable.getExternalId();
            }

            @Override
            public MjdToCadence longCadenceMjdToCadence() {
                return lcMjdToCadence;
            }
            
            @Override
            public Date generatedAt() {
                return generatedAt;
            }

            @Override
            public String fileTimestamp() {
                return fileTimestamp;
            }

        };
        
        return source;
    }



    public static void main(String[] argv) throws Exception {

    	//80675	81008
        File outputDir = new File(".");
        CadenceType cadenceType = CadenceType.SHORT;
        int ccdModule = 17;
        int ccdOutput = 2;
        int externalTargetTableId = 56;
        int quarter  = -1;
        TargetPixelExporterCli cli = 
            new TargetPixelExporterCli(outputDir, cadenceType, externalTargetTableId,
                                       ccdModule, ccdOutput, quarter);
        // for (int m : FcConstants.modulesList) {
        // for (int o : FcConstants.outputsList) {

        cli.exportBackground = true;
        cli.execute();
        // }
        // }
    }
}
