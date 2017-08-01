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

package gov.nasa.kepler.etem;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.DateUtils;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.Date;
import java.util.List;

import nom.tam.fits.AsciiTable;
import nom.tam.fits.Header;

import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class CadenceFitsTest {

    private static final double FGS_FRAMES_PER_INTEGRATION = 58.0;
    private static final double MILLISECONDS_PER_FGS_FRAME = 103.7897052288;
    private static final double MILLISECONDS_PER_READOUT = 518.948526144;
    private static final double MILLISECONDS_PER_SECOND = 1000.0;
    private static final double INTEGRATIONS_PER_SHORT_CADENCE = 9.0;

    private static final double EXPECTED_SECONDS_PER_SHORT_CADENCE = ((FGS_FRAMES_PER_INTEGRATION
        * MILLISECONDS_PER_FGS_FRAME + MILLISECONDS_PER_READOUT) * INTEGRATIONS_PER_SHORT_CADENCE)
        / MILLISECONDS_PER_SECOND;

    private int shortCadencesPerLongCadence = 30;

    @Test
    public void testGetTimestamp() throws Exception {
        String expectedDmcTimestamp = "2009151112045";
        double expectedEndMjd = 5.498247274870E+04;
        int expectedCadenceNumber = 2008;

        double expectedCadenceZeroMjd = 54941.42164988;

        List<Header> headers = ImmutableList.of(new Header(new AsciiTable()));

        CadenceFits cadenceFits = new CadenceFits(Filenames.BUILD_TMP,
            TargetType.LONG_CADENCE, expectedCadenceNumber,
            expectedCadenceZeroMjd, headers, 0,
            EXPECTED_SECONDS_PER_SHORT_CADENCE, shortCadencesPerLongCadence, 0,
            0, 0, 0, 0, 0, 0, false) {
            @Override
            protected String getSuffix(TargetType targetType)
                throws PipelineException {
                return null;
            }
        };

        Date actualTimestamp = cadenceFits.getTimestamp();
        assertEquals(new ModifiedJulianDate(expectedEndMjd).getTime()
            .getTime(), actualTimestamp.getTime());

        String actualDmcTimestamp = DateUtils.formatLikeDmc(actualTimestamp);
        assertEquals(expectedDmcTimestamp, actualDmcTimestamp);
    }

}
