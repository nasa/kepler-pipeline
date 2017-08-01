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

package gov.nasa.kepler.debug.uow;

import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTaskGenerator;
import gov.nasa.kepler.mc.uow.CadenceBinner;
import gov.nasa.kepler.mc.uow.ModOutBinner;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * {@link UnitOfWorkTask} generator for the {@link DebugUowDefinition} Uses the
 * {@link CadenceBinner} and {@link ModOutBinner} to bin the specified cadence
 * range into bins and then further subdivide those bins by module/output.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class DebugUowTaskGenerator implements UnitOfWorkTaskGenerator {
    static final Log log = LogFactory.getLog(DebugUowTaskGenerator.class);

    public DebugUowTaskGenerator() {
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * gov.nasa.kepler.hibernate.pi.UnitOfWorkTaskGenerator#unitOfWorkTaskType()
     */
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return DebugUowTask.class;
    }

    public List<Class<? extends Parameters>> requiredParameterClasses() {
        List<Class<? extends Parameters>> list = new LinkedList<Class<? extends Parameters>>();
        list.add(DebugUowParameters.class);
        return list;
    }

    public List<? extends UnitOfWorkTask> generateTasks(
        Map<Class<? extends Parameters>, Parameters> parameters) {
        DebugUowParameters debugUowParameters = (DebugUowParameters) parameters.get(DebugUowParameters.class);

        if (debugUowParameters.isFailInTaskGenerator()) {
            throw new PipelineException(
                "DebugUowParameters.failInTaskGenerator == true");
        }

        List<DebugUowTask> tasks = new ArrayList<DebugUowTask>();

        int numTasks = debugUowParameters.getNumTasks();
        for (int i = 0; i < numTasks; i++) {
            tasks.add(new DebugUowTask(i));

            if (i % 100 == 0) {
                log.info("taskNum=" + i);
            }
        }

        return tasks;
    }

    /**
     * used by the PIG to display the name of the task generator
     */
    public String toString() {
        return "Debug UOW";
    }
}
