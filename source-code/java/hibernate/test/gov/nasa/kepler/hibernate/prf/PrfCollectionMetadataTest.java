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

package gov.nasa.kepler.hibernate.prf;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.Cadence.CadenceType;

import org.junit.Before;
import org.junit.Test;

/**
 * Unit tests for PrfBlobMetadata.
 * 
 * @author Forrest Girouard (fgirouard)
 * 
 */
public class PrfCollectionMetadataTest {

    private static final long PIPELINE_TASK_ID = 356;
    private static final int CCD_MODULE = 13;
    private static final int CCD_OUTPUT = 3;
    private static final int START_CADENCE = 2390;
    private static final int END_CADENCE = 2413;
    private static final String FILE_EXT = ".mat";
    private static final String PC_STRING_VALUE = "[pipelineTaskId="
        + PIPELINE_TASK_ID + "," + "startCadence=" + START_CADENCE + ","
        + "endCadence=" + END_CADENCE + "," + "cadenceType=" + CadenceType.LONG
        + "," + "fileExtension=" + FILE_EXT + "," + "ccdModule=" + CCD_MODULE
        + "," + "ccdOutput=" + CCD_OUTPUT + "]";

    private PrfBlobMetadata cm;

    @Before
    public void createCollectionMetadata() {
        cm = new PrfBlobMetadata(PIPELINE_TASK_ID, CCD_MODULE, CCD_OUTPUT,
            START_CADENCE, END_CADENCE, FILE_EXT);
    }

    @Test
    public void testConstructor() {
        assertEquals(cm.getPipelineTaskId(), PIPELINE_TASK_ID);
        assertEquals(cm.getCcdModule(), CCD_MODULE);
        assertEquals(cm.getCcdOutput(), CCD_OUTPUT);
        assertEquals(cm.getStartCadence(), START_CADENCE);
        assertEquals(cm.getEndCadence(), END_CADENCE);
    }

    @Test
    public void testEqualsObject() {
        PrfBlobMetadata cm1 = new PrfBlobMetadata(PIPELINE_TASK_ID, CCD_MODULE,
            CCD_OUTPUT, START_CADENCE, END_CADENCE, FILE_EXT);
        PrfBlobMetadata cm2 = new PrfBlobMetadata(PIPELINE_TASK_ID + 1,
            CCD_MODULE, CCD_OUTPUT, START_CADENCE + 100, END_CADENCE + 100,
            FILE_EXT);

        assertEquals(cm, cm1);
        assertFalse(cm1.equals(cm2));
    }

    @Test
    public void testHashCode() {
        PrfBlobMetadata cm1 = new PrfBlobMetadata(PIPELINE_TASK_ID, CCD_MODULE,
            CCD_OUTPUT, START_CADENCE, END_CADENCE, FILE_EXT);
        PrfBlobMetadata cm2 = new PrfBlobMetadata(PIPELINE_TASK_ID + 1,
            CCD_MODULE, CCD_OUTPUT, START_CADENCE + 100, END_CADENCE + 100,
            FILE_EXT);

        assertEquals(cm.hashCode(), cm1.hashCode());
        assertTrue(cm1.hashCode() != cm2.hashCode());
    }

    @Test
    public void testToString() {
        assertTrue(cm.toString()
            .indexOf(PC_STRING_VALUE) != -1);
    }

}
