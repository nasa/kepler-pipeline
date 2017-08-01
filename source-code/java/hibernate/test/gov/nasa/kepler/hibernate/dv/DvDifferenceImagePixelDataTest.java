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

package gov.nasa.kepler.hibernate.dv;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests the {@link DvDifferenceImagePixelData} class.
 * 
 * @author Bill Wohler
 */
public class DvDifferenceImagePixelDataTest {

    private static final Log log = LogFactory.getLog(DvDifferenceImagePixelDataTest.class);

    static final int CCD_ROW = 242;
    static final int CCD_COLUMN = 442;
    private static final DvQuantity MEAN_FLUX_IN_TRANSIT = new DvQuantity(1.0F,
        2.0F);
    private static final DvQuantity MEAN_FLUX_OUT_OF_TRANSIT = new DvQuantity(
        2.0F, 3.0F);
    private static final DvQuantity MEAN_FLUX_DIFFERENCE = new DvQuantity(3.0F,
        4.0F);
    private static final DvQuantity MEAN_FLUX_FOR_TARGET_TABLE = new DvQuantity(
        4.0F, 5.0F);

    private DvDifferenceImagePixelData differenceImagePixelData;

    @Before
    public void createExpectedDifferenceImagePixelData() {
        differenceImagePixelData = createDifferenceImagePixelData(CCD_ROW,
            CCD_COLUMN, MEAN_FLUX_IN_TRANSIT, MEAN_FLUX_OUT_OF_TRANSIT,
            MEAN_FLUX_DIFFERENCE, MEAN_FLUX_FOR_TARGET_TABLE);
    }

    private DvDifferenceImagePixelData createDifferenceImagePixelData(
        int ccdRow, int ccdColumn, DvQuantity meanFluxInTransit,
        DvQuantity meanFluxOutOfTransit, DvQuantity meanFluxDifference,
        DvQuantity meanFluxForTargetTable) {

        return new DvDifferenceImagePixelData(ccdRow, ccdColumn,
            meanFluxInTransit, meanFluxOutOfTransit, meanFluxDifference,
            meanFluxForTargetTable);
    }

    @Test
    public void testConstructor() {
        // Create simply to get code coverage.
        new DvDifferenceImagePixelData();

        testDifferenceImagePixelData(differenceImagePixelData);
    }

    static void testDifferenceImagePixelData(
        DvDifferenceImagePixelData differenceImagePixelData) {

        assertEquals(CCD_ROW, differenceImagePixelData.getCcdRow());
        assertEquals(CCD_COLUMN, differenceImagePixelData.getCcdColumn());
        assertEquals(MEAN_FLUX_IN_TRANSIT,
            differenceImagePixelData.getMeanFluxInTransit());
        assertEquals(MEAN_FLUX_OUT_OF_TRANSIT,
            differenceImagePixelData.getMeanFluxOutOfTransit());
        assertEquals(MEAN_FLUX_DIFFERENCE,
            differenceImagePixelData.getMeanFluxDifference());
        assertEquals(MEAN_FLUX_FOR_TARGET_TABLE,
            differenceImagePixelData.getMeanFluxForTargetTable());
    }

    @Test
    public void testEquals() {
        // Include all don't-care fields here.
        DvDifferenceImagePixelData dipd = createDifferenceImagePixelData(
            CCD_ROW, CCD_COLUMN, MEAN_FLUX_IN_TRANSIT,
            MEAN_FLUX_OUT_OF_TRANSIT, MEAN_FLUX_DIFFERENCE,
            MEAN_FLUX_FOR_TARGET_TABLE);
        assertEquals(differenceImagePixelData, dipd);

        dipd = createDifferenceImagePixelData(CCD_ROW + 1, CCD_COLUMN,
            MEAN_FLUX_IN_TRANSIT, MEAN_FLUX_OUT_OF_TRANSIT,
            MEAN_FLUX_DIFFERENCE, MEAN_FLUX_FOR_TARGET_TABLE);
        assertFalse("equals", differenceImagePixelData.equals(dipd));

        dipd = createDifferenceImagePixelData(CCD_ROW, CCD_COLUMN + 1,
            MEAN_FLUX_IN_TRANSIT, MEAN_FLUX_OUT_OF_TRANSIT,
            MEAN_FLUX_DIFFERENCE, MEAN_FLUX_FOR_TARGET_TABLE);
        assertFalse("equals", differenceImagePixelData.equals(dipd));

        dipd = createDifferenceImagePixelData(CCD_ROW, CCD_COLUMN,
            new DvQuantity(42.0F, 42.0F), MEAN_FLUX_OUT_OF_TRANSIT,
            MEAN_FLUX_DIFFERENCE, MEAN_FLUX_FOR_TARGET_TABLE);
        assertFalse("equals", differenceImagePixelData.equals(dipd));

        dipd = createDifferenceImagePixelData(CCD_ROW, CCD_COLUMN,
            MEAN_FLUX_IN_TRANSIT, new DvQuantity(42.0F, 42.0F),
            MEAN_FLUX_DIFFERENCE, MEAN_FLUX_FOR_TARGET_TABLE);
        assertFalse("equals", differenceImagePixelData.equals(dipd));

        dipd = createDifferenceImagePixelData(CCD_ROW, CCD_COLUMN,
            MEAN_FLUX_IN_TRANSIT, MEAN_FLUX_OUT_OF_TRANSIT, new DvQuantity(
                42.0F, 42.0F), MEAN_FLUX_FOR_TARGET_TABLE);
        assertFalse("equals", differenceImagePixelData.equals(dipd));

        dipd = createDifferenceImagePixelData(CCD_ROW, CCD_COLUMN,
            MEAN_FLUX_IN_TRANSIT, MEAN_FLUX_OUT_OF_TRANSIT,
            MEAN_FLUX_DIFFERENCE, new DvQuantity(42.0F, 42.0F));
        assertFalse("equals", differenceImagePixelData.equals(dipd));
    }

    @Test
    public void testHashCode() {
        // Include all don't-care fields here.
        DvDifferenceImagePixelData s = createDifferenceImagePixelData(CCD_ROW,
            CCD_COLUMN, MEAN_FLUX_IN_TRANSIT, MEAN_FLUX_OUT_OF_TRANSIT,
            MEAN_FLUX_DIFFERENCE, MEAN_FLUX_FOR_TARGET_TABLE);
        assertEquals(differenceImagePixelData.hashCode(), s.hashCode());

        s = createDifferenceImagePixelData(CCD_ROW + 1, CCD_COLUMN,
            MEAN_FLUX_IN_TRANSIT, MEAN_FLUX_OUT_OF_TRANSIT,
            MEAN_FLUX_DIFFERENCE, MEAN_FLUX_FOR_TARGET_TABLE);
        assertFalse("hashCode",
            differenceImagePixelData.hashCode() == s.hashCode());

        s = createDifferenceImagePixelData(CCD_ROW, CCD_COLUMN + 1,
            MEAN_FLUX_IN_TRANSIT, MEAN_FLUX_OUT_OF_TRANSIT,
            MEAN_FLUX_DIFFERENCE, MEAN_FLUX_FOR_TARGET_TABLE);
        assertFalse("hashCode",
            differenceImagePixelData.hashCode() == s.hashCode());

        s = createDifferenceImagePixelData(CCD_ROW, CCD_COLUMN, new DvQuantity(
            42.0F, 42.0F), MEAN_FLUX_OUT_OF_TRANSIT, MEAN_FLUX_DIFFERENCE,
            MEAN_FLUX_FOR_TARGET_TABLE);
        assertFalse("hashCode",
            differenceImagePixelData.hashCode() == s.hashCode());

        s = createDifferenceImagePixelData(CCD_ROW, CCD_COLUMN,
            MEAN_FLUX_IN_TRANSIT, new DvQuantity(42.0F, 42.0F),
            MEAN_FLUX_DIFFERENCE, MEAN_FLUX_FOR_TARGET_TABLE);
        assertFalse("hashCode",
            differenceImagePixelData.hashCode() == s.hashCode());

        s = createDifferenceImagePixelData(CCD_ROW, CCD_COLUMN,
            MEAN_FLUX_IN_TRANSIT, MEAN_FLUX_OUT_OF_TRANSIT, new DvQuantity(
                42.0F, 42.0F), MEAN_FLUX_FOR_TARGET_TABLE);
        assertFalse("hashCode",
            differenceImagePixelData.hashCode() == s.hashCode());

        s = createDifferenceImagePixelData(CCD_ROW, CCD_COLUMN,
            MEAN_FLUX_IN_TRANSIT, MEAN_FLUX_OUT_OF_TRANSIT,
            MEAN_FLUX_DIFFERENCE, new DvQuantity(42.0F, 42.0F));
        assertFalse("hashCode",
            differenceImagePixelData.hashCode() == s.hashCode());
    }

    @Test
    public void testToString() {
        // Check log and ensure that output isn't brutally long.
        log.info(differenceImagePixelData.toString());
    }
}
