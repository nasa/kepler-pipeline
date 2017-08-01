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

package gov.nasa.kepler.mc;

import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.spiffy.common.jmock.JMockTest;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.Date;
import java.util.List;

import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class TargetListSetValidatorTest extends JMockTest {

    private RollTimeOperations mockRollTimeOperations;

    @Before
    public void setUp() {
        mockRollTimeOperations = mock(RollTimeOperations.class);
    }

    @Test
    public void testValidTargetListSets() {
        Date startDate = new Date(1000);
        double startMjd = new ModifiedJulianDate(startDate.getTime()).getMjd();
        int startSeason = 1;

        Date endDate = new Date(2000);
        double endMjd = new ModifiedJulianDate(endDate.getTime()).getMjd();
        int endSeason = 1;

        TargetListSet tls = new TargetListSet("tls1");
        tls.setStart(startDate);
        tls.setEnd(endDate);
        tls.setState(State.LOCKED);

        List<TargetListSet> targetListSets = ImmutableList.of(tls);

        allowing(mockRollTimeOperations).mjdToSeason(startMjd);
        will(returnValue(startSeason));
        allowing(mockRollTimeOperations).mjdToSeason(endMjd);
        will(returnValue(endSeason));

        TargetListSetValidator validator = new TargetListSetValidator(
            mockRollTimeOperations);
        validator.validate(targetListSets);
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void testInvalidDatesMultipleSeasons() {
        Date startDate = new Date(1000);
        double startMjd = new ModifiedJulianDate(startDate.getTime()).getMjd();
        int startSeason = 1;

        Date endDate = new Date(2000);
        double endMjd = new ModifiedJulianDate(endDate.getTime()).getMjd();
        int endSeason = 2;

        TargetListSet tls = new TargetListSet("tls1");
        tls.setStart(startDate);
        tls.setEnd(endDate);
        tls.setState(State.LOCKED);

        List<TargetListSet> targetListSets = ImmutableList.of(tls);

        allowing(mockRollTimeOperations).mjdToSeason(startMjd);
        will(returnValue(startSeason));
        allowing(mockRollTimeOperations).mjdToSeason(endMjd);
        will(returnValue(endSeason));

        TargetListSetValidator validator = new TargetListSetValidator(
            mockRollTimeOperations);
        validator.validate(targetListSets);
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void testInvalidDatesEndBeforeStart() {
        Date startDate = new Date(3000);
        double startMjd = new ModifiedJulianDate(startDate.getTime()).getMjd();
        int startSeason = 1;

        Date endDate = new Date(2000);
        double endMjd = new ModifiedJulianDate(endDate.getTime()).getMjd();
        int endSeason = 1;

        TargetListSet tls = new TargetListSet("tls1");
        tls.setStart(startDate);
        tls.setEnd(endDate);
        tls.setState(State.LOCKED);

        List<TargetListSet> targetListSets = ImmutableList.of(tls);

        allowing(mockRollTimeOperations).mjdToSeason(startMjd);
        will(returnValue(startSeason));
        allowing(mockRollTimeOperations).mjdToSeason(endMjd);
        will(returnValue(endSeason));

        TargetListSetValidator validator = new TargetListSetValidator(
            mockRollTimeOperations);
        validator.validate(targetListSets);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testInvalidShortCadenceDates() {
        int season = 1;

        Date startDate1 = new Date(1000);
        double startMjd1 = new ModifiedJulianDate(startDate1.getTime()).getMjd();

        Date endDate1 = new Date(3000);
        double endMjd1 = new ModifiedJulianDate(endDate1.getTime()).getMjd();

        Date startDate2 = new Date(2000);
        double startMjd2 = new ModifiedJulianDate(startDate2.getTime()).getMjd();

        Date endDate2 = new Date(4000);
        double endMjd2 = new ModifiedJulianDate(endDate2.getTime()).getMjd();

        TargetListSet tls1 = new TargetListSet("tls1");
        tls1.setType(TargetType.SHORT_CADENCE);
        tls1.setStart(startDate1);
        tls1.setEnd(endDate1);
        tls1.setState(State.LOCKED);

        TargetListSet tls2 = new TargetListSet("tls2");
        tls2.setType(TargetType.SHORT_CADENCE);
        tls2.setStart(startDate2);
        tls2.setEnd(endDate2);
        tls2.setState(State.LOCKED);

        List<TargetListSet> targetListSets = ImmutableList.of(tls1, tls2);

        allowing(mockRollTimeOperations).mjdToSeason(startMjd1);
        will(returnValue(season));
        allowing(mockRollTimeOperations).mjdToSeason(endMjd1);
        will(returnValue(season));
        allowing(mockRollTimeOperations).mjdToSeason(startMjd2);
        will(returnValue(season));
        allowing(mockRollTimeOperations).mjdToSeason(endMjd2);
        will(returnValue(season));

        TargetListSetValidator validator = new TargetListSetValidator(
            mockRollTimeOperations);
        validator.validate(targetListSets);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testUnlockedTargetListSet() {
        Date startDate = new Date(1000);
        double startMjd = new ModifiedJulianDate(startDate.getTime()).getMjd();
        int startSeason = 1;

        Date endDate = new Date(2000);
        double endMjd = new ModifiedJulianDate(endDate.getTime()).getMjd();
        int endSeason = 1;

        TargetListSet tls = new TargetListSet("tls1");
        tls.setStart(startDate);
        tls.setEnd(endDate);
        tls.setState(State.UNLOCKED);

        List<TargetListSet> targetListSets = ImmutableList.of(tls);

        allowing(mockRollTimeOperations).mjdToSeason(startMjd);
        will(returnValue(startSeason));
        allowing(mockRollTimeOperations).mjdToSeason(endMjd);
        will(returnValue(endSeason));

        TargetListSetValidator validator = new TargetListSetValidator(
            mockRollTimeOperations);
        validator.validate(targetListSets);
    }

    @Test(expected = PipelineException.class)
    public void testThatNoPreviousTadProductsExist() {
        Date startDate = new Date(1000);
        double startMjd = new ModifiedJulianDate(startDate.getTime()).getMjd();
        int startSeason = 1;

        Date endDate = new Date(2000);
        double endMjd = new ModifiedJulianDate(endDate.getTime()).getMjd();
        int endSeason = 1;

        TargetListSet tls = new TargetListSet("tls1");
        tls.setStart(startDate);
        tls.setEnd(endDate);
        tls.setTargetTable(new TargetTable(TargetType.LONG_CADENCE));
        tls.setState(State.LOCKED);

        List<TargetListSet> targetListSets = ImmutableList.of(tls);

        allowing(mockRollTimeOperations).mjdToSeason(startMjd);
        will(returnValue(startSeason));
        allowing(mockRollTimeOperations).mjdToSeason(endMjd);
        will(returnValue(endSeason));

        TargetListSetValidator validator = new TargetListSetValidator(
            mockRollTimeOperations);
        validator.validate(targetListSets);
    }
}
