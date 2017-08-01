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

import static gov.nasa.kepler.mc.fs.CalFsIdFactory.CAL_CRS_PATH;
import static gov.nasa.kepler.mc.fs.PixelFsIdFactory.CADENCE_TYPE;
import static gov.nasa.kepler.mc.fs.PixelFsIdFactory.CCD_MODULE;
import static gov.nasa.kepler.mc.fs.PixelFsIdFactory.CCD_OUTPUT;
import static gov.nasa.kepler.mc.fs.PixelFsIdFactory.COLLATERAL_TYPE;
import static gov.nasa.kepler.mc.fs.PixelFsIdFactory.OFFSET;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.PixelFsIdFactory;
import gov.nasa.kepler.mc.fs.CalFsIdFactory.MetricsTimeSeriesType;

import java.util.Map;
import java.util.Set;

import org.junit.Test;

public class CalFsIdFactoryTest {

    @Test
    public void getCosmicRaySeriesFsId() throws Exception {
        int module = 3;
        int output = 4;
        int offset = 15;
        CollateralType collateralType = CollateralType.MASKED_SMEAR;
        CadenceType cadenceType = CadenceType.LONG;

        FsId id = CalFsIdFactory.getCosmicRaySeriesFsId(collateralType,
            cadenceType, module, output, offset);
        String expected = CAL_CRS_PATH + collateralType.getName() + "/"
            + cadenceType.name() + PixelFsIdFactory.SEP + module
            + PixelFsIdFactory.SEP + output + PixelFsIdFactory.SEP + offset;
        assertEquals(expected, id.toString());

        // System.out.println(expected);

        Map<String, Object> idParse = CalFsIdFactory.parseCosmicRaySeriesFsId(id);
        assertEquals(cadenceType, idParse.get(CADENCE_TYPE));
        assertEquals(module, idParse.get(CCD_MODULE));
        assertEquals(output, idParse.get(CCD_OUTPUT));
        assertEquals(offset, idParse.get(OFFSET));
        assertEquals(collateralType, idParse.get(COLLATERAL_TYPE));
    }

    @Test
    public void ancillaryPipelineData() {
        int ccdModule = 13;
        int ccdOutput = 2;

        Set<String> mnemonics = CalFsIdFactory.getAncillaryPipelineDataMnemonics();
        assertNotNull(mnemonics);
        assertTrue(mnemonics.size() > 0);
        for (String mnemonic : mnemonics) {
            FsId fsId = CalFsIdFactory.getAncillaryPipelineDataFsId(mnemonic,
                CadenceType.LONG, ccdModule, ccdOutput);
            assertNotNull(fsId);
        }
        FsId fsId = CalFsIdFactory.getAncillaryPipelineDataUncertaintiesFsId(
            MetricsTimeSeriesType.BLACK_LEVEL.toString(), CadenceType.LONG, ccdModule,
            ccdOutput);
        assertNotNull(fsId);
    }

}
