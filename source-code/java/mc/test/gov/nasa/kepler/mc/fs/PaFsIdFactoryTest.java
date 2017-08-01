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

package gov.nasa.kepler.mc.fs;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.BlobSeriesType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CentroidTimeSeriesType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CentroidType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CosmicRayMetricType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.MetricTimeSeriesType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.ThrusterActivityType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.TimeSeriesType;

import java.util.Map;
import java.util.Set;

import org.junit.Test;

/**
 * FS unit tests for PA file store ids.
 * 
 * @author Forrest Girouard (fgirouard)
 */
public class PaFsIdFactoryTest {

    @Test
    public void getMatlabBlobFsId() {

        int ccdModule = 13;
        int ccdOutput = 3;
        BlobSeriesType blobType = BlobSeriesType.BACKGROUND;
        long pipelineTaskId = System.currentTimeMillis();

        String expectedValue = PaFsIdFactory.PA_PATH + blobType.getName() + '/'
            + ccdModule + PixelFsIdFactory.SEP + ccdOutput
            + PixelFsIdFactory.SEP + pipelineTaskId;
        FsId fsId = PaFsIdFactory.getMatlabBlobFsId(blobType, ccdModule,
            ccdOutput, pipelineTaskId);
        assertEquals(expectedValue, fsId.toString());

        expectedValue = PaFsIdFactory.PA_PATH + blobType.getName() + '/'
            + (ccdModule + 1) + PixelFsIdFactory.SEP + (ccdOutput - 1)
            + PixelFsIdFactory.SEP + pipelineTaskId;
        fsId = PaFsIdFactory.getMatlabBlobFsId(blobType, ccdModule + 1,
            ccdOutput - 1, pipelineTaskId);
        assertEquals(expectedValue, fsId.toString());
    }

    @Test
    public void getFluxTimeSeriesFsId() {
        int keplerId = 123456;
        CadenceType cadenceType = CadenceType.LONG;
        TimeSeriesType timeSeriesType = TimeSeriesType.RAW_FLUX;
        FluxType fluxType = FluxType.SAP;
        String expectedValue = PaFsIdFactory.PA_TARGETS_PATH
            + fluxType.getName() + timeSeriesType.getName() + '/'
            + cadenceType.getName() + '/' + keplerId;

        FsId fsId = PaFsIdFactory.getTimeSeriesFsId(timeSeriesType, fluxType,
            cadenceType, keplerId);
        assertEquals(expectedValue, fsId.toString());
    }

    @Test
    public void getCentroidTimeSeriesFsId() {
        int keplerId = 123456;
        FluxType fluxType = FluxType.SAP;
        CadenceType cadenceType = CadenceType.LONG;
        CentroidTimeSeriesType timeSeriesType = CentroidTimeSeriesType.CENTROID_ROWS;
        String expectedValue = PaFsIdFactory.PA_CENTROIDS_PATH
            + timeSeriesType.getName() + '/' + cadenceType.getName() + '/'
            + keplerId;

        FsId fsId = PaFsIdFactory.getCentroidTimeSeriesFsId(timeSeriesType,
            cadenceType, keplerId);
        assertEquals(expectedValue, fsId.toString());

        timeSeriesType = CentroidTimeSeriesType.CENTROID_ROWS_UNCERTAINTIES;
        expectedValue = PaFsIdFactory.PA_CENTROIDS_PATH + fluxType.getName()
            + '/' + timeSeriesType.getName() + '/' + cadenceType.getName()
            + '/' + keplerId;

        fsId = PaFsIdFactory.getCentroidTimeSeriesFsId(fluxType,
            timeSeriesType, cadenceType, keplerId);
        assertEquals(expectedValue, fsId.toString());

        CentroidType centroidType = CentroidType.PRF;
        timeSeriesType = CentroidTimeSeriesType.CENTROID_COLS;
        expectedValue = PaFsIdFactory.PA_CENTROIDS_PATH + fluxType.getName()
            + '/' + centroidType.getName() + '/' + timeSeriesType.getName()
            + '/' + cadenceType.getName() + '/' + keplerId;

        fsId = PaFsIdFactory.getCentroidTimeSeriesFsId(fluxType, centroidType,
            timeSeriesType, cadenceType, keplerId);
        assertEquals(expectedValue, fsId.toString());
    }

    @Test
    public void getEncircledEnergyTimeSeriesFsId() {
        int ccdModule = 13;
        int ccdOutput = 2;
        MetricTimeSeriesType timeSeriesType = MetricTimeSeriesType.ENCIRCLED_ENERGY;
        String expectedValue = PaFsIdFactory.PA_METRICS_PATH
            + timeSeriesType.getName() + '/' + ccdModule + PixelFsIdFactory.SEP
            + ccdOutput;

        FsId fsId = PaFsIdFactory.getMetricTimeSeriesFsId(timeSeriesType,
            ccdModule, ccdOutput);
        assertEquals(expectedValue, fsId.toString());
    }

    @Test
    public void getCosmicRayMetricFsId() {
        int ccdModule = 13;
        int ccdOutput = 2;
        TargetType targetTableType = TargetType.BACKGROUND;
        CosmicRayMetricType timeSeriesType = CosmicRayMetricType.MEAN_ENERGY;
        String expectedValue = PaFsIdFactory.PA_CR_METRICS_PATH + ccdModule
            + PixelFsIdFactory.SEP + ccdOutput + PixelFsIdFactory.SEP
            + targetTableType.shortName() + PixelFsIdFactory.SEP
            + timeSeriesType.getName();

        FsId fsId = PaFsIdFactory.getCosmicRayMetricFsId(timeSeriesType,
            targetTableType, ccdModule, ccdOutput);
        assertEquals(expectedValue, fsId.toString());
    }

    @Test
    public void getCosmicRaySeriesFsId() {
        int ccdModule = 13;
        int ccdOutput = 2;
        int row = 512;
        int column = 515;
        TargetType targetTableType = TargetType.BACKGROUND;

        String expectedValue = PaFsIdFactory.PA_CRS_PATH
            + targetTableType.shortName() + '/' + ccdModule + '/' + ccdOutput
            + '/' + row + PixelFsIdFactory.SEP + column;

        FsId fsId = PaFsIdFactory.getCosmicRaySeriesFsId(targetTableType,
            ccdModule, ccdOutput, row, column);
        assertEquals(expectedValue, fsId.toString());

        Map<String, Object> idParse = PaFsIdFactory.parseCosmicRaySeriesFsId(fsId);
        assertEquals(targetTableType,
            idParse.get(PixelFsIdFactory.TARGET_TABLE_TYPE));
        assertEquals(ccdModule, idParse.get(PixelFsIdFactory.CCD_MODULE));
    }

    @Test
    public void ancillaryPipelineData() {
        int ccdModule = 13;
        int ccdOutput = 2;

        Set<String> mnemonics = PaFsIdFactory.getAncillaryPipelineDataMnemonics();
        assertNotNull(mnemonics);
        assertTrue(mnemonics.size() > 0);
        for (String mnemonic : mnemonics) {
            FsId fsId = PaFsIdFactory.getAncillaryPipelineDataFsId(mnemonic,
                ccdModule, ccdOutput);
            assertNotNull(fsId);
            fsId = PaFsIdFactory.getAncillaryPipelineDataUncertaintiesFsId(
                mnemonic, ccdModule, ccdOutput);
            assertNotNull(fsId);
        }
    }

    @Test
    public void getThrusterActivityFsId() {
        String expectedValue = PaFsIdFactory.PA_PATH
            + "DefiniteThrusterActivity/" + CadenceType.LONG.getName();

        FsId fsId = PaFsIdFactory.getThrusterActivityFsId(CadenceType.LONG,
            ThrusterActivityType.DEFINITE_THRUSTER_ACTIVITY);
        assertEquals(expectedValue, fsId.toString());
    }
}
