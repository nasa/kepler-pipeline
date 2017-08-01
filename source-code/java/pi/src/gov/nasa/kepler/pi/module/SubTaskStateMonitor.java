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

package gov.nasa.kepler.pi.module;

import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributeCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributes;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;

import java.util.List;
import java.util.Map;

/**
 * Command line utility to dump the sub-task states for all tasks
 * associated with the specified pipeline instance.
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class SubTaskStateMonitor {

    public static void main(String[] args) throws Exception {
        if(args.length != 1){
            System.err.println("USAGE subtaskmon PIPELINE_INSTANCE_ID");
            System.exit(-1);
        }
        
        long instanceId = Long.parseLong(args[0]);
        PipelineInstanceCrud instanceCrud = new PipelineInstanceCrud();
        PipelineTaskCrud taskCrud = new PipelineTaskCrud();
        
        PipelineInstance instance = instanceCrud.retrieve(instanceId);
        
        if(instance == null){
            System.err.println("No pipeline instance found for id=" + instanceId);
            System.exit(-1);
        }
        
        PipelineTaskAttributeCrud attrCrud = new PipelineTaskAttributeCrud();

        while(true){
            DatabaseServiceFactory.getInstance().getSession().clear();
            List<PipelineTask> tasks = taskCrud.retrieveAll(instance);
            Map<Long, PipelineTaskAttributes> taskAttrs = attrCrud.retrieveByInstanceId(instance.getId());
            
            for (PipelineTask task : tasks) {
                String label = taskAttrs.get(task.getId()).processingStateShortLabel();
                
                System.out.println(task.getId() + ": " + label);
            }
            
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
            }
        }
    }
}
