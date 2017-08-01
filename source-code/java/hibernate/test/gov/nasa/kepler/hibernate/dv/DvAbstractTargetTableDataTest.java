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
 * Test the {@link DvAbstractTargetTableData} class
 * 
 * @author Forrest Girouard
 */
public class DvAbstractTargetTableDataTest {

    private static final Log log = LogFactory.getLog(DvAbstractTargetTableDataTest.class);

    static final int END_CADENCE = 52149;
    static final int START_CADENCE = 52000;
    static final int QUARTER = 2;
    static final int CCD_OUTPUT = 3;
    static final int CCD_MODULE = 7;
    static final int TARGET_TABLE_ID = 180;

    private DvAbstractTargetTableData targetTableData;

    @Before
    public void createExpectedTargetTableData() {
        targetTableData = createTargetTableData(TARGET_TABLE_ID, CCD_MODULE,
            CCD_OUTPUT, QUARTER, START_CADENCE, END_CADENCE);
    }

    static DvAbstractTargetTableData createTargetTableData(int targetTableId,
        int ccdModule, int ccdOutput, int quarter, int startCadence,
        int endCadence) {

        return new TargetTableData(targetTableId, ccdModule, ccdOutput,
            quarter, startCadence, endCadence);
    }

    @Test
    public void testConstructor() {
        testTargetTableData(targetTableData);
    }

    static void testTargetTableData(DvAbstractTargetTableData targetTableData) {

        assertEquals(TARGET_TABLE_ID, targetTableData.getTargetTableId());
        assertEquals(CCD_MODULE, targetTableData.getCcdModule());
        assertEquals(CCD_OUTPUT, targetTableData.getCcdOutput());
        assertEquals(QUARTER, targetTableData.getQuarter());
        assertEquals(START_CADENCE, targetTableData.getStartCadence());
        assertEquals(END_CADENCE, targetTableData.getEndCadence());
    }

    @Test
    public void testEquals() {
        // Include all don't-care fields here.
        DvAbstractTargetTableData ttd = createTargetTableData(TARGET_TABLE_ID,
            CCD_MODULE, CCD_OUTPUT, QUARTER, START_CADENCE, END_CADENCE);
        assertEquals(targetTableData, ttd);

        ttd = createTargetTableData(TARGET_TABLE_ID + 1, CCD_MODULE,
            CCD_OUTPUT, QUARTER, START_CADENCE, END_CADENCE);
        assertFalse("equals", targetTableData.equals(ttd));

        ttd = createTargetTableData(TARGET_TABLE_ID, CCD_MODULE + 1,
            CCD_OUTPUT, QUARTER, START_CADENCE, END_CADENCE);
        assertFalse("equals", targetTableData.equals(ttd));

        ttd = createTargetTableData(TARGET_TABLE_ID, CCD_MODULE,
            CCD_OUTPUT + 1, QUARTER, START_CADENCE, END_CADENCE);
        assertFalse("equals", targetTableData.equals(ttd));

        ttd = createTargetTableData(TARGET_TABLE_ID, CCD_MODULE, CCD_OUTPUT,
            QUARTER + 1, START_CADENCE, END_CADENCE);
        assertFalse("equals", targetTableData.equals(ttd));

        ttd = createTargetTableData(TARGET_TABLE_ID, CCD_MODULE, CCD_OUTPUT,
            QUARTER, START_CADENCE + 1, END_CADENCE);
        assertFalse("equals", targetTableData.equals(ttd));

        ttd = createTargetTableData(TARGET_TABLE_ID, CCD_MODULE, CCD_OUTPUT,
            QUARTER, START_CADENCE, END_CADENCE + 1);
        assertFalse("equals", targetTableData.equals(ttd));
    }

    @Test
    public void testHashCode() {
        // Include all don't-care fields here.
        DvAbstractTargetTableData ttd = createTargetTableData(TARGET_TABLE_ID,
            CCD_MODULE, CCD_OUTPUT, QUARTER, START_CADENCE, END_CADENCE);
        assertEquals(targetTableData.hashCode(), ttd.hashCode());

        ttd = createTargetTableData(TARGET_TABLE_ID + 1, CCD_MODULE,
            CCD_OUTPUT, QUARTER, START_CADENCE, END_CADENCE);
        assertFalse("hashCode", targetTableData.hashCode() == ttd.hashCode());

        ttd = createTargetTableData(TARGET_TABLE_ID, CCD_MODULE + 1,
            CCD_OUTPUT, QUARTER, START_CADENCE, END_CADENCE);
        assertFalse("hashCode", targetTableData.hashCode() == ttd.hashCode());

        ttd = createTargetTableData(TARGET_TABLE_ID, CCD_MODULE,
            CCD_OUTPUT + 1, QUARTER, START_CADENCE, END_CADENCE);
        assertFalse("hashCode", targetTableData.hashCode() == ttd.hashCode());

        ttd = createTargetTableData(TARGET_TABLE_ID, CCD_MODULE, CCD_OUTPUT,
            QUARTER + 1, START_CADENCE, END_CADENCE);
        assertFalse("hashCode", targetTableData.hashCode() == ttd.hashCode());

        ttd = createTargetTableData(TARGET_TABLE_ID, CCD_MODULE, CCD_OUTPUT,
            QUARTER, START_CADENCE + 1, END_CADENCE);
        assertFalse("hashCode", targetTableData.hashCode() == ttd.hashCode());

        ttd = createTargetTableData(TARGET_TABLE_ID, CCD_MODULE, CCD_OUTPUT,
            QUARTER, START_CADENCE, END_CADENCE + 1);
        assertFalse("hashCode", targetTableData.hashCode() == ttd.hashCode());
    }

    @Test
    public void testToString() {
        // Check log and ensure that output isn't brutally long.
        log.info(targetTableData.toString());
    }

    private static class TargetTableData extends DvAbstractTargetTableData {

        public TargetTableData(int targetTableId, int ccdModule, int ccdOutput,
            int quarter, int startCadence, int endCadence) {

            super(new Builder(targetTableId).ccdModule(ccdModule)
                .ccdOutput(ccdOutput)
                .quarter(quarter)
                .startCadence(startCadence)
                .endCadence(endCadence));
        }

        public static class Builder extends DvAbstractTargetTableData.Builder {

            public Builder(int targetTableId) {
                super(targetTableId);
            }

            @Override
            public Builder ccdModule(int ccdModule) {
                super.ccdModule(ccdModule);
                return this;
            }

            @Override
            public Builder ccdOutput(int ccdOutput) {
                super.ccdOutput(ccdOutput);
                return this;
            }

            @Override
            public Builder quarter(int quarter) {
                super.quarter(quarter);
                return this;
            }

            @Override
            public Builder startCadence(int startCadence) {
                super.startCadence(startCadence);
                return this;
            }

            @Override
            public Builder endCadence(int endCadence) {
                super.endCadence(endCadence);
                return this;
            }
        }
    }
}
