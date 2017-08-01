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
import java.util.Date;

import nom.tam.fits.FitsException;
import gov.nasa.kepler.ar.exporter.BlackAlgorithmUtils;
import gov.nasa.kepler.ar.exporter.RollingBandUtils;
import gov.nasa.kepler.ar.exporter.collateral.CollateralPixelExporter;
import gov.nasa.kepler.ar.exporter.collateral.CollateralPixelExporterSource;
import gov.nasa.kepler.ar.exporter.collateral.DefaultCollateralPixelExporterSource;
import gov.nasa.kepler.cm.TargetSelectionOperations;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.KeplerSocVersion;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.hibernate.cal.BlackAlgorithm;
import gov.nasa.kepler.hibernate.cal.CalCrud;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.pmrf.CollateralPmrfTable.Duplication;
import gov.nasa.kepler.mc.pmrf.PmrfOperations;

/**
 * A program for testing the collateral pixel exporter.
 * 
 * @author Sean McCauliff
 *
 */
public class CollateralPixelExporterCli {

    private int startCadence = 168220;
    private int endCadence = 208029;
    private int ccdModule = 2;
    private int ccdOutput = 1;
    private int quarter = 2;
    private CadenceType cadenceType = CadenceType.SHORT;
    private int targetTableId = 25;
    
    
    public static void main(String[] argv) throws Exception {
        CollateralPixelExporterCli cli = 
            new CollateralPixelExporterCli();
        cli.execute();
    }
    
    private void execute() throws FitsException, IOException {
        
        CollateralPixelExporter collateralPixelExporter = 
            new CollateralPixelExporter();
        
        MjdToCadence mjdToCadence = new MjdToCadence(cadenceType, null);
        final TimestampSeries timestampSeries = mjdToCadence.cadenceTimes(startCadence, endCadence);
        ConfigMapOperations configMapOps = new ConfigMapOperations();
        PmrfOperations pmrfOps = new PmrfOperations(Duplication.NOT_ALLOWED);
        ReadNoiseOperations readNoiseOps = new ReadNoiseOperations();
        GainOperations gainOps = new GainOperations();
        CompressionCrud compressionCrud = new CompressionCrud();
        TargetSelectionOperations targetSelectionOps =
            new TargetSelectionOperations();
        TargetCrud targetCrud = new TargetCrud();
        final RollingBandUtils rollingBandUtils = new RollingBandUtils(ccdModule, ccdOutput, startCadence, endCadence);
        final TargetTable ttable = 
            targetCrud.retrieveUplinkedTargetTable(targetTableId, TargetType.valueOf(cadenceType));
        
        final Date generatedAt = new Date();
        final CalCrud calCrud = new CalCrud();
        
        CollateralPixelExporterSource exporterSource = 
            new DefaultCollateralPixelExporterSource(mjdToCadence,
                configMapOps, ttable, pmrfOps, readNoiseOps,
                gainOps, compressionCrud, targetSelectionOps) {

                @Override
                public int ccdModule() {
                    return ccdModule;
                }

                @Override
                public int ccdOutput() {
                    return ccdOutput;
                }

                @Override
                public int endCadence() {
                    return endCadence;
                }

                @Override
                public int startCadence() {
                    return startCadence;
                }

                @Override
                public File exportDir() {
                    return new File(".");
                }

                @Override
                public long pipelineTaskId() {
                    return -1L;
                }

                @Override
                public int dataRelease() {
                    return -1;
                }

                @Override
                public int quarter() {
                    return quarter;
                }

                @Override
                public String defaultFileTimestamp() {
                    return null;
                }
                
                @Override
                public Date generatedAt() {
                    return generatedAt;
                }

                @Override
                public String subversionRevision() {
                    return KeplerSocVersion.getRevision();
                }

                @Override
                public String subversionUrl() {
                    return KeplerSocVersion.getUrl();
                }

                @Override
                public double startStartMjd() {
                    return timestampSeries.startTimestamps[0];
                }

                @Override
                public double endEndMjd() {
                    return timestampSeries.endTimestamps[endCadence - startCadence];
                }

                @Override
                public int k2Campaign() {
                    return -1;
                }

                @Override
                public int targetTableId() {
                    return ttable.getExternalId();
                }

                @Override
                public RollingBandUtils rollingBandUtils() {
                    return rollingBandUtils;
                }

                @Override
                public BlackAlgorithm blackAlgorithm() {
                    return BlackAlgorithmUtils
                        .blackAlgorithm(calCrud, ccdModule, ccdOutput, startCadence, endCadence, cadenceType);
                }
            
        };
             
        collateralPixelExporter.export(exporterSource);
    }
}
