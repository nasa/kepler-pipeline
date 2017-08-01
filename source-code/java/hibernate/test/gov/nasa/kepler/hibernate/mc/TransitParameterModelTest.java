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

public class TransitParameterModelTest {

    private static final int REVISION = 1;
    private static final int KEPLER_ID = 2;
    private static final String KOI_ID = "K00001.01";
    private static final String NAME = "koi_period";
    private static final String VALUE = "2.470613170";

    List<TransitParameter> transitParameters = new ArrayList<TransitParameter>();

    @Before
    public void setUp() {
        transitParameters.add(new TransitParameter(KEPLER_ID, KOI_ID, NAME,
            VALUE));
    }

    @Test
    public void testValidate() {
        new TransitParameterModel(REVISION, transitParameters);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testValidateWithDifferentValues() {
        transitParameters.add(new TransitParameter(KEPLER_ID, KOI_ID, NAME,
            VALUE + "9"));

        new TransitParameterModel(REVISION, transitParameters);
    }

    @Test
    public void testFormatParse() {
        List<TransitParameter> transitParameters = new ArrayList<TransitParameter>();
        transitParameters.add(new TransitParameter(11446443, "K00001.01",
            "koi_period", "1"));
        transitParameters.add(new TransitParameter(11446443, "K00001.01",
            "koi_time0bk", "2"));
        transitParameters.add(new TransitParameter(11446443, "K00001.01",
            "koi_duration", "3"));
        TransitParameterModel transitParameterModel = new TransitParameterModel(
            0, transitParameters);
        String formattedTransitParameter = transitParameterModel.toString();
        TransitParameterModel parsedTransitParameterModel = TransitParameterModel.valueOf(formattedTransitParameter);

        assertEquals(transitParameterModel, parsedTransitParameterModel);
    }

    @Test
    public void testFormatParseWithBlankLine() {
        List<TransitParameter> transitParameters = new ArrayList<TransitParameter>();
        transitParameters.add(new TransitParameter(11446443, "K00001.01",
            "koi_period", "1"));
        transitParameters.add(new TransitParameter(11446443, "K00001.01",
            "koi_time0bk", "2"));
        transitParameters.add(new TransitParameter(11446443, "K00001.01",
            "koi_duration", "3"));
        TransitParameterModel transitParameterModel = new TransitParameterModel(
            0, transitParameters);
        String formattedTransitParameter = "\n"
            + transitParameterModel.toString() + "\n";
        TransitParameterModel parsedTransitParameterModel = TransitParameterModel.valueOf(formattedTransitParameter);

        assertEquals(transitParameterModel, parsedTransitParameterModel);
    }

    @Test
    public void testFormatParseWithCommentLine() {
        List<TransitParameter> transitParameters = new ArrayList<TransitParameter>();
        transitParameters.add(new TransitParameter(11446443, "K00001.01",
            "koi_period", "1"));
        transitParameters.add(new TransitParameter(11446443, "K00001.01",
            "koi_time0bk", "2"));
        transitParameters.add(new TransitParameter(11446443, "K00001.01",
            "koi_duration", "3"));
        TransitParameterModel transitParameterModel = new TransitParameterModel(
            0, transitParameters);

        String formattedTransitParameterModel = TransitParameterModel.COMMENT_START_CHARACTER
            + " This is a comment.\n" + transitParameterModel.toString() + "\n";
        TransitParameterModel parsedTransitParameterModel = TransitParameterModel.valueOf(formattedTransitParameterModel);

        assertEquals(transitParameterModel, parsedTransitParameterModel);
    }

    @Test
    public void testFormatParseWithCommentOnTheSameLine() {
        List<TransitParameter> transitParameters = new ArrayList<TransitParameter>();
        transitParameters.add(new TransitParameter(11446443, "K00001.01",
            "koi_period", "1"));
        transitParameters.add(new TransitParameter(11446443, "K00001.01",
            "koi_time0bk", "2"));
        transitParameters.add(new TransitParameter(11446443, "K00001.01",
            "koi_duration", "3"));
        TransitParameterModel transitParameterModel = new TransitParameterModel(
            0, transitParameters);

        String transitParameterModelString = transitParameterModel.toString();
        String trimmedTransitParameterModelString = transitParameterModelString.substring(
            0, transitParameterModelString.length() - 1);
        String formattedTransitParameterModel = trimmedTransitParameterModelString
            + TransitParameterModel.COMMENT_START_CHARACTER
            + "This is a comment.";
        TransitParameterModel parsedTransitParameterModel = TransitParameterModel.valueOf(formattedTransitParameterModel);

        assertEquals(transitParameterModel, parsedTransitParameterModel);
    }

    @Test
    public void testFormatParseWithJunkLine() {
        List<TransitParameter> transitParameters = new ArrayList<TransitParameter>();
        transitParameters.add(new TransitParameter(11446443, "K00001.01",
            "koi_period", "1"));
        transitParameters.add(new TransitParameter(11446443, "K00001.01",
            "koi_time0bk", "2"));
        transitParameters.add(new TransitParameter(11446443, "K00001.01",
            "koi_duration", "3"));
        TransitParameterModel transitParameterModel = new TransitParameterModel(
            0, transitParameters);

        String formattedTransitParameterModel = "GenerationDate:             2012-12-20 10:30:00.00\n"
            + transitParameterModel.toString() + "\n";
        TransitParameterModel parsedTransitParameterModel = TransitParameterModel.valueOf(formattedTransitParameterModel);

        assertEquals(transitParameterModel, parsedTransitParameterModel);
    }

}
