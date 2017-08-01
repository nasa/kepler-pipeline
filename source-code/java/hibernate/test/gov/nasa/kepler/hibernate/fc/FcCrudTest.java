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

package gov.nasa.kepler.hibernate.fc;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.Date;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class FcCrudTest {

    private DatabaseService databaseService;

    private FcCrud fcCrud;
    private SmallFlatFieldImage sfi;
    private History sfiHistory;
    private double time1 = 50000.0;
    private double time2 = 50000.1;
    private double time3 = 50000.2;

    @Before
    public void setUp() {

        System.setProperty("hibernate.show_sql", "true");
        databaseService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(databaseService);

        fcCrud = new FcCrud(databaseService);
    }

    @After
    public void destroyDatabase() {
        databaseService.closeCurrentSession();
        TestUtils.tearDownDatabase(databaseService);
    }

    private void populateObjects() {
        databaseService.beginTransaction();

        sfiHistory = new History(time1, HistoryModelName.SMALLFLATFIELD, 1);
        fcCrud.create(sfiHistory);
        fcCrud.create(new History(time2, HistoryModelName.GAIN, 1));
        fcCrud.create(new History(time3, HistoryModelName.GEOMETRY, 1));

        float[][] flats = new float[][] { { 2, 2 }, { 2, 2 } };
        float[][] uncert = new float[][] { { 20, 20 }, { 20, 20 } };
        sfi = new SmallFlatFieldImage(flats, uncert);
        // sfi.setHistory(sfiHistory);
        fcCrud.create(sfi);

        fcCrud.create(new Pixel(2, 3, 4, 5, PixelType.BLOOMING, time1, time2));
        fcCrud.create(new Pixel(6, 3, 7, 8, PixelType.CROSSTALK, time2, time3));
        fcCrud.create(new Pixel(9, 3, 10, 11, PixelType.DEAD, time3, time3));

        databaseService.commitTransaction();
        databaseService.closeCurrentSession();
    }

    @Test
    public void testSmallFlat() throws PipelineException {
        populateObjects();

        History history = fcCrud.retrieveHistory(HistoryModelName.SMALLFLATFIELD);

        SmallFlatFieldImage actualSfi = fcCrud.retrieveSmallFlatFieldImage(
            time1, 7, 1, history);

        assertTrue(actualSfi != null);
    }

    @Test
    public void testRetrieveActiveHistory() {
        Date startDate = ModifiedJulianDate.mjdToDate(time2 + 0.00001);
        Date endDate = ModifiedJulianDate.mjdToDate(time3);

        List<History> history = fcCrud.retrieveActiveHistory(startDate, endDate);
        assertEquals(0, history.size());

        populateObjects();
        databaseService.beginTransaction();
        fcCrud.create(new History(time2 - 0.00001, HistoryModelName.GAIN, 0));
        databaseService.commitTransaction();

        history = fcCrud.retrieveActiveHistory(startDate, endDate);

        assertEquals(3, history.size());
        assertEquals(HistoryModelName.SMALLFLATFIELD, history.get(0)
            .getModelType());
        assertEquals(HistoryModelName.GAIN, history.get(1)
            .getModelType());
        assertEquals(HistoryModelName.GEOMETRY, history.get(2)
            .getModelType());
    }

    @Test
    public void testRetrieveHistoryByDate() {
        List<History> history = fcCrud.retrieveHistoryByIngestDate(
            ModifiedJulianDate.mjdToDate(time2),
            ModifiedJulianDate.mjdToDate(time3));
        assertEquals(0, history.size());

        populateObjects();
        history = fcCrud.retrieveHistoryByIngestDate(
            ModifiedJulianDate.mjdToDate(time2),
            ModifiedJulianDate.mjdToDate(time3));
        assertEquals(2, history.size());
        assertEquals(HistoryModelName.GEOMETRY, history.get(0)
            .getModelType());
        assertEquals(HistoryModelName.GAIN, history.get(1)
            .getModelType());
    }

    @Test
    public void testRetrievePixelsByDate() {
        Date date = ModifiedJulianDate.mjdToDate(time2);
        List<Pixel> pixels = fcCrud.retrievePixels(date);
        assertEquals(0, pixels.size());

        populateObjects();
        pixels = fcCrud.retrievePixels(date);
        assertEquals(2, pixels.size());
        assertEquals(PixelType.BLOOMING, pixels.get(0)
            .getType());
        assertEquals(PixelType.CROSSTALK, pixels.get(1)
            .getType());
    }
}
