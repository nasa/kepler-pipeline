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

public class ExternalTceModelTest {

    private static final int REVISION = 1;
    private static final int KEPLER_ID = 2;
    private static final int PLANET_NUMBER = 1;
    private static final float TRANSIT_DURATION_HOURS = 2.0F;
    private static final double EPOCH_MJD = 3.0;
    private static final float ORBITAL_PERIOD_DAYS = 4.0F;
    private static final float MAX_SINGLE_EVENT_SIGMA = 5.0F;
    private static final float MAX_MULTIPLE_EVENT_SIGMA = 6.0F;

    List<ExternalTce> externalTces = new ArrayList<ExternalTce>();

    @Before
    public void setUp() {
        externalTces.add(new ExternalTce(KEPLER_ID, PLANET_NUMBER,
            TRANSIT_DURATION_HOURS, EPOCH_MJD, ORBITAL_PERIOD_DAYS,
            MAX_SINGLE_EVENT_SIGMA, MAX_MULTIPLE_EVENT_SIGMA));
    }

    @Test
    public void testValidate() {
        new ExternalTceModel(REVISION, externalTces);
    }

    @Test
    public void testValidateWithDuplicateTces() {
        externalTces.add(new ExternalTce(KEPLER_ID, PLANET_NUMBER,
            TRANSIT_DURATION_HOURS, EPOCH_MJD, ORBITAL_PERIOD_DAYS,
            MAX_SINGLE_EVENT_SIGMA, MAX_MULTIPLE_EVENT_SIGMA));

        new ExternalTceModel(REVISION, externalTces);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testValidateWithDifferentDurationValues() {
        externalTces.add(new ExternalTce(KEPLER_ID, PLANET_NUMBER,
            TRANSIT_DURATION_HOURS + 1.0F, EPOCH_MJD, ORBITAL_PERIOD_DAYS,
            MAX_SINGLE_EVENT_SIGMA, MAX_MULTIPLE_EVENT_SIGMA));

        new ExternalTceModel(REVISION, externalTces);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testValidateWithDifferentEpochValues() {
        externalTces.add(new ExternalTce(KEPLER_ID, PLANET_NUMBER,
            TRANSIT_DURATION_HOURS, EPOCH_MJD + 1.0, ORBITAL_PERIOD_DAYS,
            MAX_SINGLE_EVENT_SIGMA, MAX_MULTIPLE_EVENT_SIGMA));

        new ExternalTceModel(REVISION, externalTces);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testValidateWithDifferentPeriodValues() {
        externalTces.add(new ExternalTce(KEPLER_ID, PLANET_NUMBER,
            TRANSIT_DURATION_HOURS, EPOCH_MJD, ORBITAL_PERIOD_DAYS + 1.0F,
            MAX_SINGLE_EVENT_SIGMA, MAX_MULTIPLE_EVENT_SIGMA));

        new ExternalTceModel(REVISION, externalTces);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testValidateWithDifferentSingleValues() {
        externalTces.add(new ExternalTce(KEPLER_ID, PLANET_NUMBER,
            TRANSIT_DURATION_HOURS, EPOCH_MJD, ORBITAL_PERIOD_DAYS,
            MAX_SINGLE_EVENT_SIGMA + 1.0F, MAX_MULTIPLE_EVENT_SIGMA));

        new ExternalTceModel(REVISION, externalTces);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testValidateWithDifferentMultipleValues() {
        externalTces.add(new ExternalTce(KEPLER_ID, PLANET_NUMBER,
            TRANSIT_DURATION_HOURS, EPOCH_MJD, ORBITAL_PERIOD_DAYS,
            MAX_SINGLE_EVENT_SIGMA, MAX_MULTIPLE_EVENT_SIGMA + 1.0F));

        new ExternalTceModel(REVISION, externalTces);
    }

    @Test
    public void testFormatParse() {
        ExternalTce externalTce = new ExternalTce(KEPLER_ID, PLANET_NUMBER,
            TRANSIT_DURATION_HOURS, EPOCH_MJD, ORBITAL_PERIOD_DAYS,
            MAX_SINGLE_EVENT_SIGMA, MAX_MULTIPLE_EVENT_SIGMA);
        List<ExternalTce> externalTces = ImmutableList.of(externalTce);
        ExternalTceModel externalTceModel = new ExternalTceModel(0,
            externalTces);

        String formattedExternalTceModel = externalTceModel.toString();
        ExternalTceModel parsedExternalTceModel = ExternalTceModel.valueOf(formattedExternalTceModel);

        assertEquals(externalTceModel, parsedExternalTceModel);
    }

    @Test
    public void testFormatParseWithBlankLine() {
        ExternalTce externalTce = new ExternalTce(KEPLER_ID, PLANET_NUMBER,
            TRANSIT_DURATION_HOURS, EPOCH_MJD, ORBITAL_PERIOD_DAYS,
            MAX_SINGLE_EVENT_SIGMA, MAX_MULTIPLE_EVENT_SIGMA);
        List<ExternalTce> externalTces = ImmutableList.of(externalTce);
        ExternalTceModel externalTceModel = new ExternalTceModel(0,
            externalTces);

        String formattedExternalTceModel = "\n" + externalTceModel.toString()
            + "\n";
        ExternalTceModel parsedExternalTceModel = ExternalTceModel.valueOf(formattedExternalTceModel);

        assertEquals(externalTceModel, parsedExternalTceModel);
    }

    @Test
    public void testFormatParseWithCommentLine() {
        ExternalTce externalTce = new ExternalTce(KEPLER_ID, PLANET_NUMBER,
            TRANSIT_DURATION_HOURS, EPOCH_MJD, ORBITAL_PERIOD_DAYS,
            MAX_SINGLE_EVENT_SIGMA, MAX_MULTIPLE_EVENT_SIGMA);
        List<ExternalTce> externalTces = ImmutableList.of(externalTce);
        ExternalTceModel externalTceModel = new ExternalTceModel(0,
            externalTces);

        String formattedExternalTceModel = ExternalTceModel.COMMENT_START_CHARACTER
            + " This is a comment.\n" + externalTceModel.toString() + "\n";
        ExternalTceModel parsedExternalTceModel = ExternalTceModel.valueOf(formattedExternalTceModel);

        assertEquals(externalTceModel, parsedExternalTceModel);
    }

    @Test
    public void testFormatParseWithCommentOnTheSameLine() {
        ExternalTce externalTce = new ExternalTce(KEPLER_ID, PLANET_NUMBER,
            TRANSIT_DURATION_HOURS, EPOCH_MJD, ORBITAL_PERIOD_DAYS,
            MAX_SINGLE_EVENT_SIGMA, MAX_MULTIPLE_EVENT_SIGMA);
        List<ExternalTce> externalTces = ImmutableList.of(externalTce);
        ExternalTceModel externalTceModel = new ExternalTceModel(0,
            externalTces);

        String externalTceModelString = externalTceModel.toString();
        String trimmedExternalTceModelString = externalTceModelString.substring(
            0, externalTceModelString.length() - 1);
        String formattedExternalTceModel = trimmedExternalTceModelString
            + ExternalTceModel.COMMENT_START_CHARACTER + "This is a comment.";
        ExternalTceModel parsedExternalTceModel = ExternalTceModel.valueOf(formattedExternalTceModel);

        assertEquals(externalTceModel, parsedExternalTceModel);
    }

    @Test
    public void testFormatParseWithJunkLine() {
        ExternalTce externalTce = new ExternalTce(KEPLER_ID, PLANET_NUMBER,
            TRANSIT_DURATION_HOURS, EPOCH_MJD, ORBITAL_PERIOD_DAYS,
            MAX_SINGLE_EVENT_SIGMA, MAX_MULTIPLE_EVENT_SIGMA);
        List<ExternalTce> externalTces = ImmutableList.of(externalTce);
        ExternalTceModel externalTceModel = new ExternalTceModel(0,
            externalTces);

        String formattedExternalTceModel = "GenerationDate:             2012-12-20 10:30:00.00\n"
            + externalTceModel.toString() + "\n";
        ExternalTceModel parsedExternalTceModel = ExternalTceModel.valueOf(formattedExternalTceModel);

        assertEquals(externalTceModel, parsedExternalTceModel);
    }

}
