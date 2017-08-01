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
import gov.nasa.kepler.ar.exporter.flux2.DefaultFluxExporterSource;
import gov.nasa.kepler.ar.exporter.flux2.FluxExporter2;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.pdc.PdcCrud;
import gov.nasa.kepler.hibernate.tps.AbstractTpsDbResult;
import gov.nasa.kepler.hibernate.tps.TpsCrud;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;

import java.io.File;
import java.io.IOException;
import java.util.*;

import nom.tam.fits.FitsException;


/**
 * Runs the flux exporter from the command line. This is not a tool to be used
 * by ops.  This is for debugging.
 * 
 * @author Sean McCauiff
 *
 */
public class FluxExporter2Cli extends MatlabExecutingCliBase {

    
    private final PdcCrud pdcCrud = new PdcCrud();
    
    public FluxExporter2Cli(File outputDir, CadenceType cadenceType, int externalTTableId,
                            int ccdModule, int ccdOutput, int quarter) {
        super(outputDir, cadenceType, externalTTableId, ccdModule, ccdOutput, quarter);
    }


    public void export() throws IOException, FitsException {
    
        FluxExporter2 fluxExporter = new FluxExporter2();
        final int k2Campaign = -1;
        DefaultFluxExporterSource exporterSource = 
            new DefaultFluxExporterSource(
                 anomalyOps, configMapOps, targetCrud, compressionCrud,
                 gainOps, readNoiseOps, ttable, logCrud, celestialObjectOps,
                 allKeplerIds.get(0), allKeplerIds.get(allKeplerIds.size() - 1),
                 uTargetCrud, pdcCrud, k2Campaign) {
            
            @Override
            public <T extends DvaTargetSource> Map<Integer, TargetWcs> wcsCoordinates(
                Collection<T> targets, Map<FsId, TimeSeries> allTimeSeries) {

                return calculateWcsCoordinates(targets, allTimeSeries);
            }
            
            @Override
            public List<? extends AbstractTpsDbResult> tpsDbResults() {
                TpsCrud tpsCrud = new TpsCrud();
                return tpsCrud.retrieveTpsLiteResult(allKeplerIds);
            }
            
            @Override
            public TimestampSeries timestampSeries() {
                return cadenceTimes;
            }
            
            @Override
            public int startCadence() {
                return startCadence;
            }
            
            @Override
            public int quarter() {
                return -1;
            }
            
            @Override
            public String programName() {
                return "FluxExporter2Cli";
            }
            
            @Override
            public long pipelineTaskId() {
                return -1L;
            }
            
            @Override
            public MjdToCadence mjdToCadence() {
                return mjdToCadence;
            }
            
            @Override
            public TimestampSeries longCadenceTimestampSeries() {
                return lcCadenceTimes;
            }
            
            @Override
            public MjdToCadence longCadenceMjdToCadence() {
                return lcMjdToCadence;
            }
            
            @Override
            public int longCadenceExternalTargetTableId() {
                return lcTargetTable.getExternalId();
            }
            
            @Override
            public Date generatedAt() {
                return generatedAt;
            }
            
            @Override
            public String fileTimestamp() {
                return fileTimestamp;
            }
            
            @Override
            public File exportDirectory() {
                return outputDir;
            }
            
            @Override
            public Set<String> excludeTargetsWithLabel() {
                return excludeTargetLabels;
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
            public <T extends DvaTargetSource> Map<Integer, TargetDva> dvaMotion(
                Collection<T> targets, Map<FsId, TimeSeries> allTimeSeries) {

                return calculateDvaMotion(targets, allTimeSeries);
            }
            
            @Override
            public <T extends DvaTargetSource> Map<Integer, BarycentricCorrection> barycentricCorrection(
                Collection<T> customTargets, Map<FsId, TimeSeries> allTimeSeries) {

                return calculateBarycentricCorrections(customTargets, allTimeSeries);
            }
        };
        fluxExporter.exportLightCurves(exporterSource);

    }
    
    
    public static void main(String[] argv) throws Exception {
        File exportDir = new File(".");
        int ccdModule = 7;
        int ccdOutput = 3;
        int ttableExternalId = 44;
        int quarter = -1;
        CadenceType cadenceType = CadenceType.LONG;
        
        FluxExporter2Cli cli = 
            new FluxExporter2Cli(exportDir, cadenceType, ttableExternalId, ccdModule, ccdOutput, quarter);
        cli.export();
        
    }
}
