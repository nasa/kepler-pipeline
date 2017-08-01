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

package gov.nasa.kepler.hibernate.pi;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.pi.PipelineInstance.State;

import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;
import org.junit.Test;

public class PipelineInstanceFilterTest {

    @Test
    public void testNoFilters() {
        PipelineInstanceFilter filter = new PipelineInstanceFilter();

        Session session = DatabaseServiceFactory.getInstance()
            .getSession();
        Query q = filter.query(session);

        assertEquals("query", "from PipelineInstance order by id asc",
            q.getQueryString());
    }

    @Test
    public void testNameFilters() {
        PipelineInstanceFilter filter = new PipelineInstanceFilter();
        filter.setNameContains("foo");

        Session session = DatabaseServiceFactory.getInstance()
            .getSession();
        Query q = filter.query(session);

        assertEquals("query",
            "from PipelineInstance where name like '%foo%' order by id asc",
            q.getQueryString());
    }

    @Test
    public void testStateFilters() {
        PipelineInstanceFilter filter = new PipelineInstanceFilter();
        List<State> states = filter.getStates();
        states.add(PipelineInstance.State.ERRORS_RUNNING);
        states.add(PipelineInstance.State.ERRORS_STALLED);

        Session session = DatabaseServiceFactory.getInstance()
            .getSession();
        Query q = filter.query(session);

        assertEquals("query",
            "from PipelineInstance where state in (2,3) order by id asc",
            q.getQueryString());
    }

    @Test
    public void testAgeFilters() {
        PipelineInstanceFilter filter = new PipelineInstanceFilter();
        filter.setAgeDays(10);

        Session session = DatabaseServiceFactory.getInstance()
            .getSession();
        Query q = filter.query(session);

        assertEquals(
            "query",
            "from PipelineInstance where startProcessingTime >= :startProcessingTime order by id asc",
            q.getQueryString());
    }

    @Test
    public void testNameStateFilters() {
        PipelineInstanceFilter filter = new PipelineInstanceFilter();
        filter.setNameContains("foo");
        List<State> states = filter.getStates();
        states.add(PipelineInstance.State.ERRORS_RUNNING);
        states.add(PipelineInstance.State.ERRORS_STALLED);

        Session session = DatabaseServiceFactory.getInstance()
            .getSession();
        Query q = filter.query(session);

        assertEquals(
            "query",
            "from PipelineInstance where name like '%foo%' and state in (2,3) order by id asc",
            q.getQueryString());
    }

    @Test
    public void testNameAgeFilters() {
        PipelineInstanceFilter filter = new PipelineInstanceFilter();
        filter.setNameContains("foo");
        filter.setAgeDays(10);

        Session session = DatabaseServiceFactory.getInstance()
            .getSession();
        Query q = filter.query(session);

        assertEquals(
            "query",
            "from PipelineInstance where name like '%foo%' and startProcessingTime >= :startProcessingTime order by id asc",
            q.getQueryString());
    }

    @Test
    public void testStateAgeFilters() {
        PipelineInstanceFilter filter = new PipelineInstanceFilter();
        List<State> states = filter.getStates();
        states.add(PipelineInstance.State.ERRORS_RUNNING);
        states.add(PipelineInstance.State.ERRORS_STALLED);
        filter.setAgeDays(10);

        Session session = DatabaseServiceFactory.getInstance()
            .getSession();
        Query q = filter.query(session);

        assertEquals(
            "query",
            "from PipelineInstance where state in (2,3) and startProcessingTime >= :startProcessingTime order by id asc",
            q.getQueryString());
    }

    @Test
    public void testAllFilters() {
        PipelineInstanceFilter filter = new PipelineInstanceFilter();
        filter.setNameContains("foo");
        List<State> states = filter.getStates();
        states.add(PipelineInstance.State.ERRORS_RUNNING);
        states.add(PipelineInstance.State.ERRORS_STALLED);
        filter.setAgeDays(10);

        Session session = DatabaseServiceFactory.getInstance()
            .getSession();
        Query q = filter.query(session);

        assertEquals(
            "query",
            "from PipelineInstance where name like '%foo%' and state in (2,3) and startProcessingTime >= :startProcessingTime order by id asc",
            q.getQueryString());
    }
}
