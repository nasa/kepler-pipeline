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

import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.Set;

import org.hibernate.Query;

/**
 * CRUD APIs for DataAccountabilityTrail
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * @see gov.nasa.kepler.hibernate.pi.DataAccountabilityTrail
 */
public class DataAccountabilityTrailCrud extends AbstractCrud {

    public DataAccountabilityTrailCrud() {
    }

    public DataAccountabilityTrailCrud(DatabaseService databaseService) {
        super(databaseService);
    }

    /**
     * Store a DataAccountabilityTrail instance Only one instance is allowed for
     * each owning pipeline task id For that reason, pipeline modules should
     * first attempt to retrieve any existing instance and use that instance if
     * it exists rather than creating a new one (to support the case of
     * re-running a pipeline task)
     * 
     * @param trail
     * @throws PipelineException
     */
    public void create(DataAccountabilityTrail trail) {
        getSession().save(trail);
    }

    /**
     * Stores a {@link DataAccountabilityTrail} object that contains the given
     * {@code pipelineTask} and {@code producerTaskIds}.
     * 
     * @param pipelineTask the pipeline task.
     * @param producerTaskIds the producer task IDs.
     */
    public void create(PipelineTask pipelineTask, Set<Long> producerTaskIds) {
        DataAccountabilityTrail daTrail = new DataAccountabilityTrail(
            pipelineTask.getId());
        daTrail.setProducerTaskIds(producerTaskIds);
        create(daTrail);
    }

    /**
     * Retrieve a DataAccountabilityTrail instance for the specified task id
     * 
     * @param pipelineTaskId
     * @return If the trail does not exist then this returns null, else this
     * returns the accountability trail.
     * @throws PipelineException
     */
    public DataAccountabilityTrail retrieve(long pipelineTaskId) {

        Query query = getSession().createQuery(
            "from DataAccountabilityTrail where consumerTaskId = :pipelineTaskId");
        query.setLong("pipelineTaskId", pipelineTaskId);
        DataAccountabilityTrail daTrail = uniqueResult(query);
        return daTrail;
    }
}
