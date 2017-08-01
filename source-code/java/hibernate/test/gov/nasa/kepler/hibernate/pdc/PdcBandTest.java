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

package gov.nasa.kepler.hibernate.pdc;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Before;
import org.junit.Test;

public class PdcBandTest {

    private static final Log log = LogFactory.getLog(PdcBandTest.class);

    private static final String PRIOR_FIT_TYPE = "prior";
    private static final String ROBUST_FIT_TYPE = "robust";
    private static final float PRIOR_WEIGHT = 5.0F;
    private static final float PRIOR_GOODNESS = 6.0F;

    private PdcBand pdcBand;

    @Before
    public void createExpectedPdcBand() {
        pdcBand = new PdcBand(PRIOR_FIT_TYPE, PRIOR_WEIGHT, PRIOR_GOODNESS);
    }

    private static PdcBand createPdcBand(String fitType, float priorWeight,
        float priorGoodness) {

        return new PdcBand(fitType, priorWeight, priorGoodness);
    }

    @Test
    public void testConstructor() {
        // Create simply to get code coverage.
        new PdcBand();

        testPdcBand(pdcBand);
    }

    static void testPdcBand(PdcBand pdcBand) {
        assertEquals(PRIOR_FIT_TYPE, pdcBand.getFitType());
        assertEquals(PRIOR_WEIGHT, pdcBand.getPriorWeight(), 0.0000000001);
        assertEquals(PRIOR_GOODNESS, pdcBand.getPriorGoodness(), 0.0000000001);
    }

    @Test
    public void testEquals() {
        PdcBand pb = createPdcBand(PRIOR_FIT_TYPE, PRIOR_WEIGHT, PRIOR_GOODNESS);
        assertEquals(pdcBand, pb);

        pb = createPdcBand(ROBUST_FIT_TYPE, PRIOR_WEIGHT, PRIOR_GOODNESS);
        assertFalse("equals", pdcBand.equals(pb));

        pb = createPdcBand(PRIOR_FIT_TYPE, PRIOR_WEIGHT + 1.0F, PRIOR_GOODNESS);
        assertFalse("equals", pdcBand.equals(pb));

        pb = createPdcBand(PRIOR_FIT_TYPE, PRIOR_WEIGHT, PRIOR_GOODNESS + 1.0F);
        assertFalse("equals", pdcBand.equals(pb));
    }

    @Test
    public void testHashCode() {
        PdcBand pb = createPdcBand(PRIOR_FIT_TYPE, PRIOR_WEIGHT, PRIOR_GOODNESS);
        assertEquals(pdcBand.hashCode(), pb.hashCode());

        pb = createPdcBand(ROBUST_FIT_TYPE, PRIOR_WEIGHT, PRIOR_GOODNESS);
        assertFalse("hashCode", pdcBand.hashCode() == pb.hashCode());

        pb = createPdcBand(PRIOR_FIT_TYPE, PRIOR_WEIGHT + 1.0F, PRIOR_GOODNESS);
        assertFalse("hashCode", pdcBand.hashCode() == pb.hashCode());

        pb = createPdcBand(PRIOR_FIT_TYPE, PRIOR_WEIGHT, PRIOR_GOODNESS + 1.0F);
        assertFalse("hashCode", pdcBand.hashCode() == pb.hashCode());
    }

    @Test
    public void testToString() {
        // Check log and ensure that output isn't brutally long.
        log.info(pdcBand.toString());
    }
}
