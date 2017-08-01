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

package gov.nasa.kepler.hibernate.cm;

import static com.google.common.collect.Lists.newArrayList;
import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.hibernate.cm.Kic.Field;

import java.util.List;

import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class KicOverrideModelTest {

    private static final int REVISION = 1;
    private static final int KEPLER_ID = 2;
    private static final Field FIELD = Field.BLEND;
    private static final String PROVENANCE = "Test";
    private static final double VALUE = 4.4;
    private static final Double UNCERTAINTY = 5.5;

    private List<KicOverride> kicOverrides = newArrayList();

    @Before
    public void setUp() {
        kicOverrides.add(new KicOverride(KEPLER_ID, FIELD, PROVENANCE, VALUE,
            UNCERTAINTY));
    }

    @Test
    public void testValidate() {
        new KicOverrideModel(REVISION, kicOverrides);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testValidateWithDifferentValues() {
        kicOverrides.add(new KicOverride(KEPLER_ID, FIELD, PROVENANCE,
            VALUE + 1, UNCERTAINTY));

        new KicOverrideModel(REVISION, kicOverrides);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testValidateWithDifferentUncertainties() {
        kicOverrides.add(new KicOverride(KEPLER_ID, FIELD, PROVENANCE, VALUE,
            UNCERTAINTY + 1));

        new KicOverrideModel(REVISION, kicOverrides);
    }

    @Test
    public void testFormatParse() {
        KicOverride kicOverride = new KicOverride(1, Field.RA, PROVENANCE, 2.2,
            3.3);
        List<KicOverride> kicOverrides = ImmutableList.of(kicOverride);
        KicOverrideModel kicOverrideModel = new KicOverrideModel(0,
            kicOverrides);

        String formattedKicOverrideModel = kicOverrideModel.toString();
        KicOverrideModel parsedKicOverrideModel = KicOverrideModel.valueOf(formattedKicOverrideModel);

        assertEquals(kicOverrideModel, parsedKicOverrideModel);
    }

    @Test
    public void testFormatParseWithBlankLine() {
        KicOverride kicOverride = new KicOverride(1, Field.RA, PROVENANCE, 2.2,
            3.3);
        List<KicOverride> kicOverrides = ImmutableList.of(kicOverride);
        KicOverrideModel kicOverrideModel = new KicOverrideModel(0,
            kicOverrides);

        String formattedKicOverrideModel = "\n" + kicOverrideModel.toString()
            + "\n";
        KicOverrideModel parsedKicOverrideModel = KicOverrideModel.valueOf(formattedKicOverrideModel);

        assertEquals(kicOverrideModel, parsedKicOverrideModel);
    }

    @Test
    public void testFormatParseWithCommentOnItsOwnLine() {
        KicOverride kicOverride = new KicOverride(1, Field.RA, PROVENANCE, 2.2,
            3.3);
        List<KicOverride> kicOverrides = ImmutableList.of(kicOverride);
        KicOverrideModel kicOverrideModel = new KicOverrideModel(0,
            kicOverrides);

        String formattedKicOverrideModel = KicOverrideModel.COMMENT_START_CHARACTER
            + "This is a comment.\n" + kicOverrideModel.toString();
        KicOverrideModel parsedKicOverrideModel = KicOverrideModel.valueOf(formattedKicOverrideModel);

        assertEquals(kicOverrideModel, parsedKicOverrideModel);
    }

    @Test
    public void testFormatParseWithCommentOnTheSameLine() {
        KicOverride kicOverride = new KicOverride(1, Field.RA, PROVENANCE, 2.2,
            3.3);
        List<KicOverride> kicOverrides = ImmutableList.of(kicOverride);
        KicOverrideModel kicOverrideModel = new KicOverrideModel(0,
            kicOverrides);

        String kicOverrideModelString = kicOverrideModel.toString();
        String trimmedKicOverrideModelString = kicOverrideModelString.substring(
            0, kicOverrideModelString.length() - 1);
        String formattedKicOverrideModel = trimmedKicOverrideModelString
            + KicOverrideModel.COMMENT_START_CHARACTER + "This is a comment.";
        KicOverrideModel parsedKicOverrideModel = KicOverrideModel.valueOf(formattedKicOverrideModel);

        assertEquals(kicOverrideModel, parsedKicOverrideModel);
    }

    @Test
    public void testFormatParseWithBlankCommentOnItsOwnLine() {
        KicOverride kicOverride = new KicOverride(1, Field.RA, PROVENANCE, 2.2,
            3.3);
        List<KicOverride> kicOverrides = ImmutableList.of(kicOverride);
        KicOverrideModel kicOverrideModel = new KicOverrideModel(0,
            kicOverrides);

        String formattedKicOverrideModel = KicOverrideModel.COMMENT_START_CHARACTER
            + "\n" + kicOverrideModel.toString();
        KicOverrideModel parsedKicOverrideModel = KicOverrideModel.valueOf(formattedKicOverrideModel);

        assertEquals(kicOverrideModel, parsedKicOverrideModel);
    }

}
