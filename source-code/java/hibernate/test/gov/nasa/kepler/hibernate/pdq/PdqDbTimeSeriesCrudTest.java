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

package gov.nasa.kepler.hibernate.pdq;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;

import java.util.Arrays;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class PdqDbTimeSeriesCrudTest {

    private DatabaseService databaseService;

    @Before
    public void setUp() throws Exception {
        databaseService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(databaseService);
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(databaseService);
    }

    @Test
    public void simpleDoubleSeries() throws Exception {
        PdqDbTimeSeriesCrud crud = new PdqDbTimeSeriesCrud();
        PdqDoubleTimeSeriesType timeSeriesType = PdqDoubleTimeSeriesType.DESIRED_RA;
        int targetTableId = 1;
        int startCadence = 10;
        int endCadence = 20;

        PdqDbTimeSeries timeSeries = createDbTimeSeries(timeSeriesType,
            targetTableId, startCadence, endCadence, 1.0, 0.001, 1L, false);
        crud.create(timeSeries);
        PdqDbTimeSeries readSeries = crud.retrieve(targetTableId, startCadence,
            endCadence, timeSeriesType);
        assertEquals(timeSeries, readSeries);
    }

    @Test
    public void simpleDoubleSeriesGaps() throws Exception {
        PdqDbTimeSeriesCrud crud = new PdqDbTimeSeriesCrud();
        PdqDoubleTimeSeriesType timeSeriesType = PdqDoubleTimeSeriesType.DESIRED_RA;
        int targetTableId = 1;
        int startCadence = 10;
        int endCadence = 20;

        PdqDbTimeSeries timeSeries = createDbTimeSeries(timeSeriesType,
            targetTableId, startCadence, endCadence, 1.0, 0.001, 1L, true);
        crud.create(timeSeries);
        PdqDbTimeSeries readSeries = crud.retrieve(targetTableId, startCadence,
            endCadence, timeSeriesType);
        assertEquals(timeSeries, readSeries);
    }

    @Test
    public void simpleDoubleSeriesOverwrite() throws Exception {
        PdqDbTimeSeriesCrud crud = new PdqDbTimeSeriesCrud();
        PdqDoubleTimeSeriesType timeSeriesType = PdqDoubleTimeSeriesType.DELTA_ROLL;
        int targetTableId = 1;
        int startCadence = 10;
        int endCadence = 20;

        PdqDbTimeSeries timeSeries = createDbTimeSeries(timeSeriesType,
            targetTableId, startCadence, endCadence, 1.0, 0.001, 1L, false);
        crud.create(timeSeries);
        PdqDbTimeSeries extendedTimeSeries = createDbTimeSeries(timeSeriesType,
            targetTableId, startCadence, endCadence + 10, 2.0, 0.002, 2L, true);
        crud.create(extendedTimeSeries);

        PdqDbTimeSeries readSeries = crud.retrieve(targetTableId, startCadence,
            endCadence, timeSeriesType);
        assertTrue(!readSeries.equals(timeSeries));
        assertTrue(readSeries.getValues()[0] == extendedTimeSeries.getValues()[0]);
        assertTrue(readSeries.getGapIndicators()[1]);

        PdqDbTimeSeries extendedReadSeries = crud.retrieve(targetTableId,
            startCadence, endCadence + 10, timeSeriesType);
        assertEquals(extendedTimeSeries, extendedReadSeries);
    }

    private PdqDbTimeSeries createDbTimeSeries(
        PdqDoubleTimeSeriesType timeSeriesType, int targetTableId,
        int startCadence, int endCadence, double value, double uncertainty,
        long originator, boolean gaps) {

        int cadenceLength = endCadence - startCadence + 1;
        double[] values = new double[cadenceLength];
        double[] uncertainties = new double[cadenceLength];
        boolean[] gapIndicators = new boolean[cadenceLength];
        long[] originators = new long[cadenceLength];

        Arrays.fill(values, value);
        Arrays.fill(uncertainties, uncertainty);
        Arrays.fill(originators, originator);
        if (gaps) {
            setGap(1, gapIndicators, values, uncertainties, originators);
            setGap(cadenceLength - 2, gapIndicators, values, uncertainties,
                originators);
        }
        return new PdqDbTimeSeries(timeSeriesType, targetTableId, startCadence,
            endCadence, values, uncertainties, gapIndicators, originators);
    }

    private void setGap(int offset, boolean[] gapIndicators, double[] values,
        double[] uncertainties, long[] originators) {

        gapIndicators[offset] = true;
        values[offset] = 0;
        uncertainties[offset] = 0;
        originators[offset] = 0L;
    }

}
