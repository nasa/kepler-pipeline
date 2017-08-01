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

package gov.nasa.kepler.hibernate.mc;

import static org.junit.Assert.assertEquals;

import java.util.ArrayList;
import java.util.List;

import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;

public class TransitNameModelTest {

    private static final int REVISION = 1;
    private static final int KEPLER_ID = 2;
    private static final String KOI_ID = "K00001.01";
    private static final String NAME = "kepler_name";
    private static final String VALUE = "Kepler-1 b";

    List<TransitName> transitNames = new ArrayList<TransitName>();

    @Before
    public void setUp() {
        transitNames.add(new TransitName(KEPLER_ID, KOI_ID, NAME, VALUE));
    }

    @Test
    public void testValidate() {
        new TransitNameModel(REVISION, transitNames);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testValidateWithDifferentValues() {
        transitNames.add(new TransitName(KEPLER_ID, KOI_ID, NAME, VALUE + "c"));

        new TransitNameModel(REVISION, transitNames);
    }

    @Test
    public void testFormatParse() {
        TransitName transitName = new TransitName(KEPLER_ID, KOI_ID, NAME,
            VALUE);
        List<TransitName> transitNames = ImmutableList.of(transitName);
        TransitNameModel transitNameModel = new TransitNameModel(0,
            transitNames);

        String formattedTransitNameModel = transitNameModel.toString();
        TransitNameModel parsedTransitNameModel = TransitNameModel.valueOf(formattedTransitNameModel);

        assertEquals(transitNameModel, parsedTransitNameModel);
    }

    @Test
    public void testFormatParseWithBlankLine() {
        TransitName transitName = new TransitName(KEPLER_ID, KOI_ID, NAME,
            VALUE);
        List<TransitName> transitNames = ImmutableList.of(transitName);
        TransitNameModel transitNameModel = new TransitNameModel(0,
            transitNames);

        String formattedTransitNameModel = "\n" + transitNameModel.toString()
            + "\n";
        TransitNameModel parsedTransitNameModel = TransitNameModel.valueOf(formattedTransitNameModel);

        assertEquals(transitNameModel, parsedTransitNameModel);
    }

    @Test
    public void testFormatParseWithCommentLine() {
        TransitName transitName = new TransitName(KEPLER_ID, KOI_ID, NAME,
            VALUE);
        List<TransitName> transitNames = ImmutableList.of(transitName);
        TransitNameModel transitNameModel = new TransitNameModel(0,
            transitNames);

        String formattedTransitNameModel = TransitNameModel.COMMENT_START_CHARACTER
            + " This is a comment.\n" + transitNameModel.toString() + "\n";
        TransitNameModel parsedTransitNameModel = TransitNameModel.valueOf(formattedTransitNameModel);

        assertEquals(transitNameModel, parsedTransitNameModel);
    }

    @Test
    public void testFormatParseWithCommentOnTheSameLine() {
        TransitName transitName = new TransitName(KEPLER_ID, KOI_ID, NAME,
            VALUE);
        List<TransitName> transitNames = ImmutableList.of(transitName);
        TransitNameModel transitNameModel = new TransitNameModel(0,
            transitNames);

        String transitNameModelString = transitNameModel.toString();
        String trimmedTransitNameModelString = transitNameModelString.substring(
            0, transitNameModelString.length() - 1);
        String formattedTransitNameModel = trimmedTransitNameModelString
            + TransitNameModel.COMMENT_START_CHARACTER + "This is a comment.";
        TransitNameModel parsedTransitNameModel = TransitNameModel.valueOf(formattedTransitNameModel);

        assertEquals(transitNameModel, parsedTransitNameModel);
    }

    @Test
    public void testFormatParseWithJunkLine() {
        TransitName transitName = new TransitName(KEPLER_ID, KOI_ID, NAME,
            VALUE);
        List<TransitName> transitNames = ImmutableList.of(transitName);
        TransitNameModel transitNameModel = new TransitNameModel(0,
            transitNames);

        String formattedTransitNameModel = "GenerationDate:             2012-12-20 10:30:00.00\n"
            + transitNameModel.toString() + "\n";
        TransitNameModel parsedTransitNameModel = TransitNameModel.valueOf(formattedTransitNameModel);

        assertEquals(transitNameModel, parsedTransitNameModel);
    }
}
