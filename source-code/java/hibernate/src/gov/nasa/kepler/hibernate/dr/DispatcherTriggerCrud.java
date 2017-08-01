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

package gov.nasa.kepler.hibernate.dr;

import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;

/**
 * Provides CRUD access to the {@link DispatcherTrigger}.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class DispatcherTriggerCrud extends AbstractCrud {

    public DispatcherTriggerCrud() {
    }

    public DispatcherTriggerCrud(DatabaseService dbs) {
        super(dbs);
    }

    /**
     * Persist a new {@link DispatcherTrigger} instance
     * 
     * @param dispatcherTrigger
     * @throws PipelineException
     */
    public void create(DispatcherTrigger dispatcherTrigger) {
        getSession().save(dispatcherTrigger);
    }

    /**
     * Retrieve the {@link DispatcherTrigger} for a given dispatcher class
     * 
     * @throws PipelineException
     */
    public DispatcherTrigger retrieve(String dispatcherClass) {

        Session session = getSession();
        Query q = session.createQuery("from DispatcherTrigger where dispatcherClass = :dispatcherClass and enabled = :enabled");
        q.setString("dispatcherClass", dispatcherClass);
        q.setBoolean("enabled", true);
        q.setMaxResults(1);

        return uniqueResult(q);
    }

    /**
     * Retrieve all {@link DispatcherTrigger}
     * 
     * @throws PipelineException
     */
    public List<DispatcherTrigger> retrieveAll() {

        Session session = getSession();
        Query q = session.createQuery("from DispatcherTrigger");

        List<DispatcherTrigger> result = list(q);

        return result;
    }

    /**
     * 
     * @param dispatcherTrigger
     */
    public void delete(DispatcherTrigger dispatcherTrigger) {
        getSession().delete(dispatcherTrigger);
    }
}
