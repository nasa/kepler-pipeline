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
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.mc.fs.PdqFsIdFactory;
import gov.nasa.kepler.mc.fs.PdqFsIdFactory.TimeSeriesType;

import org.junit.Test;

public class PdqFsIdFactoryTest {

    @Test
    public void getTimeSeriesTypeString() {

        assertEquals("BlackLevels", TimeSeriesType.BLACK_LEVELS.getName());
    }

    @Test
    public void getPdqTimeSeriesFsId() {

        int targetTableId = 13;
        int ccdModule = 13;
        int ccdOutput = 4;
        String expectedValue = "/pdq/" + targetTableId + '/'
            + TimeSeriesType.MEAN_FLUXES.getName();
        String expectedValue2 = "/pdq/" + targetTableId + '/'
            + TimeSeriesType.DARK_CURRENTS.getName() + '/' + ccdModule + ":"
            + ccdOutput;
        FsId fsId = PdqFsIdFactory.getPdqTimeSeriesFsId(
            TimeSeriesType.MEAN_FLUXES, targetTableId);
        assertEquals(expectedValue, fsId.toString());
        fsId = PdqFsIdFactory.getPdqTimeSeriesFsId(
            TimeSeriesType.DARK_CURRENTS, targetTableId, ccdModule, ccdOutput);
        assertEquals(expectedValue2, fsId.toString());
    }

    @Test
    public void getPdqUncertaintiesFsId() {

        int targetTableId = 13;
        int ccdModule = 13;
        int ccdOutput = 4;
        String expectedValue = "/pdq/" + targetTableId + '/'
            + TimeSeriesType.MEAN_FLUXES.getName() + ":uncertainties";
        String expectedValue2 = "/pdq/" + targetTableId + '/'
            + TimeSeriesType.DARK_CURRENTS.getName() + '/' + ccdModule + ":"
            + ccdOutput + ":uncertainties";
        FsId fsId = PdqFsIdFactory.getPdqUncertaintiesFsId(
            TimeSeriesType.MEAN_FLUXES, targetTableId);
        assertEquals(expectedValue, fsId.toString());
        fsId = PdqFsIdFactory.getPdqUncertaintiesFsId(
            TimeSeriesType.DARK_CURRENTS, targetTableId, ccdModule, ccdOutput);
        assertEquals(expectedValue2, fsId.toString());
    }
}
