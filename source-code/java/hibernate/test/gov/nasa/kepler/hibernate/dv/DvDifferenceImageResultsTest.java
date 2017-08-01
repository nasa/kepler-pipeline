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

import static gov.nasa.kepler.hibernate.dv.DvAbstractTargetTableDataTest.CCD_MODULE;
import static gov.nasa.kepler.hibernate.dv.DvAbstractTargetTableDataTest.CCD_OUTPUT;
import static gov.nasa.kepler.hibernate.dv.DvAbstractTargetTableDataTest.END_CADENCE;
import static gov.nasa.kepler.hibernate.dv.DvAbstractTargetTableDataTest.QUARTER;
import static gov.nasa.kepler.hibernate.dv.DvAbstractTargetTableDataTest.START_CADENCE;
import static gov.nasa.kepler.hibernate.dv.DvAbstractTargetTableDataTest.TARGET_TABLE_ID;
import static gov.nasa.kepler.hibernate.dv.DvDifferenceImagePixelDataTest.CCD_COLUMN;
import static gov.nasa.kepler.hibernate.dv.DvDifferenceImagePixelDataTest.CCD_ROW;
import static gov.nasa.kepler.hibernate.dv.DvTestUtils.createCentroidOffsets;
import static gov.nasa.kepler.hibernate.dv.DvTestUtils.createImageCentroid;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import gov.nasa.kepler.hibernate.dv.DvDifferenceImageResults.Builder;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Before;
import org.junit.Test;

/**
 * Test the {@link DvDifferenceImageResults} class.
 * 
 * @author Bill Wohler
 */
public class DvDifferenceImageResultsTest {

    private static final Log log = LogFactory.getLog(DvDifferenceImageResultsTest.class);

    private static final long ID = 42;
    private static final int COUNT = 1;
    private static final float VALUE = 1.0F;
    private static final float UNCERTAINTY = 0.0F;

    private static final int NUMBER_OF_TRANSITS = 42;
    private static final int NUMBER_OF_CADENCES_IN_TRANSIT = 43;
    private static final int NUMBER_OF_CADENCE_GAPS_IN_TRANSIT = 44;
    private static final int NUMBER_OF_CADENCES_OUT_OF_TRANSIT = 45;
    private static final int NUMBER_OF_CADENCE_GAPS_OUT_OF_TRANSIT = 46;

    private List<DvDifferenceImagePixelData> differenceImagePixelData;
    private DvDifferenceImageResults differenceImageResults;

    @Before
    public void createExpectedDifferenceImageResults() {
        differenceImagePixelData = createDifferenceImagePixelData(COUNT, VALUE);
        differenceImageResults = createDifferenceImageResults(ID,
            createDifferenceImagePixelData(COUNT, VALUE));
    }

    static List<DvDifferenceImagePixelData> createDifferenceImagePixelData(
        int count, float value) {

        List<DvDifferenceImagePixelData> differenceImagePixelDataList = new ArrayList<DvDifferenceImagePixelData>();
        for (int i = 0; i < count; i++) {
            differenceImagePixelDataList.add(createDifferenceImagePixelData(
                CCD_ROW + i, CCD_COLUMN - i, (i + 1) * value, UNCERTAINTY));
        }

        return differenceImagePixelDataList;
    }

    static DvDifferenceImagePixelData createDifferenceImagePixelData(
        int ccdRow, int ccdColumn, float value, float uncertainty) {

        return new DvDifferenceImagePixelData(ccdRow, ccdColumn,
            new DvQuantity(value + 1, uncertainty), new DvQuantity(value + 2,
                uncertainty), new DvQuantity(value + 3, uncertainty),
            new DvQuantity(value + 4, uncertainty));
    }

    private static DvDifferenceImageResults createDifferenceImageResults(
        long id, List<DvDifferenceImagePixelData> differenceImagePixelData) {

        Builder builder = new DvDifferenceImageResults.Builder(TARGET_TABLE_ID).ccdModule(
            CCD_MODULE)
            .ccdOutput(CCD_OUTPUT)
            .startCadence(START_CADENCE)
            .endCadence(END_CADENCE)
            .quarter(QUARTER)
            .controlCentroidOffsets(createCentroidOffsets(0))
            .controlImageCentroid(createImageCentroid(6))
            .differenceImageCentroid(createImageCentroid(10))
            .kicCentroidOffsets(createCentroidOffsets(14))
            .kicReferenceCentroid(createImageCentroid(20))
            .numberOfTransits(NUMBER_OF_TRANSITS)
            .numberOfCadencesInTransit(NUMBER_OF_CADENCES_IN_TRANSIT)
            .numberOfCadenceGapsInTransit(NUMBER_OF_CADENCE_GAPS_IN_TRANSIT)
            .numberOfCadencesOutOfTransit(NUMBER_OF_CADENCES_OUT_OF_TRANSIT)
            .numberOfCadenceGapsOutOfTransit(
                NUMBER_OF_CADENCE_GAPS_OUT_OF_TRANSIT)
            .differenceImagePixelData(differenceImagePixelData);
        if (id >= 0) {
            builder.id(id);
        }

        return builder.build();
    }

    static DvDifferenceImageResults createDifferenceImageResults(
        List<DvDifferenceImagePixelData> differenceImagePixelData) {

        return createDifferenceImageResults(-1, differenceImagePixelData);
    }

    @Test
    public void testConstructor() {
        // Create simply to get code coverage.
        new DvDifferenceImageResults();

        testDifferenceImageResults(differenceImageResults);
    }

    private void testDifferenceImageResults(
        DvDifferenceImageResults differenceImageResults) {

        DvAbstractTargetTableDataTest.testTargetTableData(differenceImageResults);

        assertEquals(ID, differenceImageResults.getId());
        assertEquals(differenceImagePixelData,
            differenceImageResults.getDifferenceImagePixelData());
    }

    @Test
    public void testEquals() {
        // Include all don't-care fields here.
        DvDifferenceImageResults pcr = createDifferenceImageResults(ID + 1,
            differenceImagePixelData);
        assertEquals("equals", differenceImageResults, pcr);

        pcr = createDifferenceImageResults(ID + 1,
            createDifferenceImagePixelData(COUNT, VALUE + 1.0F));
        assertFalse("equals", differenceImageResults.equals(pcr));

        pcr = createDifferenceImageResults(ID + 1,
            createDifferenceImagePixelData(COUNT + 1, VALUE));
        assertFalse("equals", differenceImageResults.equals(pcr));
    }

    @Test
    public void testHashCode() {
        // Include all don't-care fields here.
        DvDifferenceImageResults dir = createDifferenceImageResults(ID + 1,
            differenceImagePixelData);
        assertEquals("hashCode", differenceImageResults.hashCode(),
            dir.hashCode());

        dir = createDifferenceImageResults(ID + 1,
            createDifferenceImagePixelData(COUNT, VALUE + 1.0F));
        assertFalse("hashCode",
            differenceImageResults.hashCode() == dir.hashCode());

        dir = createDifferenceImageResults(ID + 1,
            createDifferenceImagePixelData(COUNT + 1, VALUE));
        assertFalse("hashCode",
            differenceImageResults.hashCode() == dir.hashCode());
    }

    @Test
    public void testToString() {
        // Check log and ensure that output isn't brutally long.
        log.info(differenceImageResults.toString());
    }
}
