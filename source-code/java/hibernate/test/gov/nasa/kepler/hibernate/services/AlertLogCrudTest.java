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

package gov.nasa.kepler.hibernate.services;

import static org.apache.log4j.lf5.LogLevel.DEBUG;
import static org.apache.log4j.lf5.LogLevel.ERROR;
import static org.apache.log4j.lf5.LogLevel.FATAL;
import static org.apache.log4j.lf5.LogLevel.INFO;
import static org.apache.log4j.lf5.LogLevel.SEVERE;
import static org.apache.log4j.lf5.LogLevel.WARN;
import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class AlertLogCrudTest {

    private DatabaseService databaseService = null;
    private AlertLogCrud alertCrud;

    private SimpleDateFormat parser = new SimpleDateFormat("MMM-dd-yy HH:mm:ss");

    private Date date1;
    private Date date2;
    private Date date3;
    private Date date4;
    private Date date5;
    private Date date6;
    private Date date7;

    @Before
    public void setUp() throws Exception {
        databaseService = DatabaseServiceFactory.getInstance();
        alertCrud = new AlertLogCrud(databaseService);

        TestUtils.setUpDatabase(databaseService);

        date1 = parser.parse("Jun-1-12 12:00:00");
        date2 = parser.parse("Jun-2-12 12:00:00");
        date3 = parser.parse("Jul-10-12 15:00:00");
        date4 = parser.parse("Aug-12-12 02:00:00");
        date5 = parser.parse("Sep-20-12 05:00:00");
        date6 = parser.parse("Sep-21-12 05:00:00");
        date7 = parser.parse("Oct-31-12 19:00:00");
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(databaseService);
    }

    @Test
    public void testRetrieveComponents() {
        List<String> components = alertCrud.retrieveComponents();
        assertEquals(0, components.size());

        populateObjects();

        components = alertCrud.retrieveComponents();

        // Check number of components as well as sort.
        assertEquals(8, components.size());
        assertEquals("s1", components.get(0));
        assertEquals("s2", components.get(1));
        assertEquals("s3", components.get(2));
        assertEquals("s4", components.get(3));
    }

    @Test
    public void testRetrieveSeverities() {
        List<String> severities = alertCrud.retrieveSeverities();
        assertEquals(0, severities.size());

        populateObjects();

        severities = alertCrud.retrieveSeverities();

        // Check number of components as well as sort.
        assertEquals(6, severities.size());
        assertEquals(DEBUG.getLabel(), severities.get(0));
        assertEquals(ERROR.getLabel(), severities.get(1));
        assertEquals(FATAL.getLabel(), severities.get(2));
        assertEquals(INFO.getLabel(), severities.get(3));
        assertEquals(SEVERE.getLabel(), severities.get(4));
        assertEquals(WARN.getLabel(), severities.get(5));
    }

    @Test
    public void testCreateRetrieve() throws Exception {
        populateObjects();

        List<AlertLog> alerts = alertCrud.retrieve(date2, date6);
        assertEquals("alerts.size()", 6, alerts.size());
    }

    @Test(expected = NullPointerException.class)
    public void testRetrieveNullStart() {
        alertCrud.retrieve(null, null, null, null);
    }

    @Test(expected = NullPointerException.class)
    public void testRetrieveNullEnd() {
        alertCrud.retrieve(new Date(), null, null, null);
    }

    @Test(expected = NullPointerException.class)
    public void testRetrieveNullComponent() {
        alertCrud.retrieve(new Date(), new Date(), null, null);
    }

    @Test(expected = NullPointerException.class)
    public void testRetrieveNullSeverity() {
        alertCrud.retrieve(new Date(), new Date(), new String[0], null);
    }

    @Test
    public void testRetreiveAlertsByTaskId() {
        populateObjects();

        List<Long> taskIds = new ArrayList<Long>();
        taskIds.add(5L);
        taskIds.add(1L);

        List<AlertLog> alerts = alertCrud.retrieveByPipelineTaskIds(taskIds);
        assertEquals(4, alerts.size());
    }

    @Test
    public void testRetrieve() {
        populateObjects();

        // Test that empty components means that all components are considered.
        String[] components = new String[0];
        String[] severities = new String[0];
        List<AlertLog> alerts = alertCrud.retrieve(date2, date6, components,
            severities);
        assertEquals(6, alerts.size());

        // This component isn't in the date range.
        components = new String[] { "s4" };
        alerts = alertCrud.retrieve(date2, date6, components, severities);
        assertEquals(0, alerts.size());

        // This component has one entry in and one outside of the range.
        components[0] = "s1";
        alerts = alertCrud.retrieve(date2, date6, components, severities);
        assertEquals(1, alerts.size());
        assertEquals("D", alerts.get(0)
            .getAlertData()
            .getProcessName());

        // Specify all components; check sort.
        components = new String[] { "s1", "s2", "s3", "s4" };
        severities = new String[] { SEVERE.getLabel(), FATAL.getLabel(),
            DEBUG.getLabel(), INFO.getLabel(), WARN.getLabel(),
            ERROR.getLabel() };
        alerts = alertCrud.retrieve(date1, date7, components, severities);
        assertEquals(5, alerts.size());
        assertEquals("D", alerts.get(0)
            .getAlertData()
            .getProcessName());
        assertEquals("E", alerts.get(1)
            .getAlertData()
            .getProcessName());
        assertEquals("C", alerts.get(2)
            .getAlertData()
            .getProcessName());
        assertEquals("B", alerts.get(3)
            .getAlertData()
            .getProcessName());
        assertEquals("A", alerts.get(4)
            .getAlertData()
            .getProcessName());
        assertEquals(ERROR.getLabel(), alerts.get(0)
            .getAlertData()
            .getSeverity());

        components = new String[] { "s5", "s6", "s7", "s8" };
        alerts = alertCrud.retrieve(date1, date7, components, severities);
        assertEquals(5, alerts.size());
        assertEquals(FATAL.getLabel(), alerts.get(0)
            .getAlertData()
            .getSeverity());
        assertEquals(SEVERE.getLabel(), alerts.get(1)
            .getAlertData()
            .getSeverity());
        assertEquals(DEBUG.getLabel(), alerts.get(2)
            .getAlertData()
            .getSeverity());
        assertEquals(INFO.getLabel(), alerts.get(3)
            .getAlertData()
            .getSeverity());
        assertEquals(WARN.getLabel(), alerts.get(4)
            .getAlertData()
            .getSeverity());

        // Check just the SEVERE severity.
        severities = new String[] { SEVERE.getLabel() };
        alerts = alertCrud.retrieve(date1, date7, components, severities);
        assertEquals(1, alerts.size());
        assertEquals(SEVERE.getLabel(), alerts.get(0)
            .getAlertData()
            .getSeverity());
    }

    private void populateObjects() {
        databaseService.beginTransaction();

        alertCrud.create(new AlertLog(new Alert(date7, "s1", 5, "E", "e", 105,
            "message5")));
        alertCrud.create(new AlertLog(new Alert(date5, "s1", 4, "D", "d", 104,
            "message4")));
        alertCrud.create(new AlertLog(new Alert(date4, "s2", 3, "C", "c", 103,
            "message3")));
        alertCrud.create(new AlertLog(new Alert(date3, "s3", 2, "B", "b", 102,
            "message2")));
        alertCrud.create(new AlertLog(new Alert(date1, "s4", 1, "A", "a", 101,
            "message1")));

        alertCrud.create(new AlertLog(new Alert(date5, "s5", 4, "DS", "d", 104,
            SEVERE.getLabel(), "message4")));
        alertCrud.create(new AlertLog(new Alert(date7, "s5", 5, "EF", "e", 105,
            FATAL.getLabel(), "message5")));
        alertCrud.create(new AlertLog(new Alert(date4, "s6", 3, "CD", "c", 103,
            DEBUG.getLabel(), "message3")));
        alertCrud.create(new AlertLog(new Alert(date3, "s7", 2, "BI", "b", 102,
            INFO.getLabel(), "message2")));
        alertCrud.create(new AlertLog(new Alert(date1, "s8", 1, "AW", "a", 101,
            WARN.getLabel(), "message1")));

        databaseService.commitTransaction();
        databaseService.closeCurrentSession();
    }
}
