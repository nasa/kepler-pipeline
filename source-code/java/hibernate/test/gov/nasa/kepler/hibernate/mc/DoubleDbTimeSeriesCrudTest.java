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
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;

import java.util.Arrays;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Sean McCauliff
 * 
 */
public class DoubleDbTimeSeriesCrudTest {

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
        DoubleDbTimeSeriesCrud crud = new DoubleDbTimeSeriesCrud();
        int startCadence = 10;
        int endCadnece = 20;
        int cadenceLength = endCadnece - startCadence + 1;
        double[] values = new double[cadenceLength];
        boolean[] gapIndicators = new boolean[cadenceLength];
        long[] originators = new long[cadenceLength];

        try {
            DatabaseServiceFactory.getInstance()
                .beginTransaction();
            DoubleDbTimeSeries timeSeries = new DoubleDbTimeSeries(values,
                startCadence, endCadnece, gapIndicators, originators,
                DoubleTimeSeriesType.FPG_DEC);
            crud.create(timeSeries);
            DoubleDbTimeSeries readSeries = crud.retrieve(
                DoubleTimeSeriesType.FPG_DEC, 10, 20);
            assertEquals(timeSeries, readSeries);
            DatabaseServiceFactory.getInstance()
                .commitTransaction();
        } finally {
            DatabaseServiceFactory.getInstance()
                .rollbackTransactionIfActive();
        }
    }

    @Test
    public void overwriteDoubleSeries() throws Exception {
        DoubleDbTimeSeriesCrud crud = new DoubleDbTimeSeriesCrud();

        int startCadence = 10;
        int endCadnece = 20;
        int cadenceLength = endCadnece - startCadence + 1;
        double[] values = new double[cadenceLength];
        for (int i = 0; i < values.length; i++) {
            values[i] = Math.PI * (i + 1);
        }
        boolean[] gapIndicators = new boolean[cadenceLength];
        long[] originators = new long[cadenceLength];

        DoubleDbTimeSeries timeSeries = new DoubleDbTimeSeries(values,
            startCadence, endCadnece, gapIndicators, originators,
            DoubleTimeSeriesType.FPG_DEC);

        try {
            DatabaseServiceFactory.getInstance()
                .beginTransaction();
            crud.create(timeSeries);

            int startCadence2 = 15;
            int endCadence2 = 30;
            int cadenceLength2 = endCadence2 - startCadence2 + 1;
            double[] values2 = new double[cadenceLength2];
            for (int i = 0; i < values2.length; i++) {
                values2[i] = Math.E * (i + 1);
            }
            boolean[] gapIndicators2 = new boolean[cadenceLength2];
            long[] originators2 = new long[cadenceLength2];
            gapIndicators2[0] = true;
            gapIndicators2[gapIndicators2.length - 2] = true;

            DoubleDbTimeSeries timeSeries2 = new DoubleDbTimeSeries(values2,
                startCadence2, endCadence2, gapIndicators2, originators2,
                DoubleTimeSeriesType.FPG_DEC);
            crud.create(timeSeries2);

            DoubleDbTimeSeries combined = crud.retrieve(
                DoubleTimeSeriesType.FPG_DEC, startCadence, endCadence2);
            double[] expectedValues = new double[endCadence2 - startCadence + 1];
            for (int i = 0; i < 5; i++) {
                expectedValues[i] = Math.PI * (i + 1);
            }
            for (int i = 6; i < expectedValues.length; i++) {
                expectedValues[i] = Math.E * (i - 4);
            }
            expectedValues[expectedValues.length - 2] = 0.0;
            assertTrue(Arrays.equals(expectedValues, combined.getValues()));
            DatabaseServiceFactory.getInstance()
                .commitTransaction();
        } finally {
            DatabaseServiceFactory.getInstance()
                .rollbackTransactionIfActive();
        }

    }

}
