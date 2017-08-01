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

package gov.nasa.kepler.pi.common;

import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskMetrics;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Compute the time spent on the specified category for a list
 * of tasks and the percentage of the total time spent on that category
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class TaskMetrics {

    // Map<category,Pair<categoryTimeMillis,categoryPercent>>
    private Map<String,Pair<Long,Double>> categoryMetrics = new HashMap<String,Pair<Long,Double>>();
    private Pair<Long,Double> unallocatedTime = null;
    private long totalProcessingTimeMillis;
    
    public TaskMetrics(List<PipelineTask> tasks) {
        totalProcessingTimeMillis = 0;
        // Map<category,categoryTimeMillis>
        Map<String,Long> allocatedTimeByCategory = new HashMap<String,Long>();
        
        if(tasks != null){
            for (PipelineTask task : tasks) {
                totalProcessingTimeMillis += DisplayModel.getProcessingMillis(task.getStartProcessingTime(), task.getEndProcessingTime());
                
                List<PipelineTaskMetrics> summaryMetrics = task.getSummaryMetrics();
                for (PipelineTaskMetrics metrics : summaryMetrics) {
                    String category = metrics.getCategory();
                    Long categoryTimeMillis = allocatedTimeByCategory.get(category);
                    if(categoryTimeMillis == null){
                        allocatedTimeByCategory.put(category, metrics.getValue());
                    }else{
                        allocatedTimeByCategory.put(category, categoryTimeMillis + metrics.getValue());
                    }
                }
            }
        }
        
        long unallocatedTimeMillis = totalProcessingTimeMillis;
        
        for (String category : allocatedTimeByCategory.keySet()) {
            long categoryTimeMillis = allocatedTimeByCategory.get(category);
            double categoryPercent = ((double)categoryTimeMillis/(double)totalProcessingTimeMillis) * 100.0;
            
            categoryMetrics.put(category, Pair.of(categoryTimeMillis, categoryPercent));
            
            unallocatedTimeMillis -= categoryTimeMillis;
        }

        double unallocatedPercent = ((double)unallocatedTimeMillis/(double)totalProcessingTimeMillis) * 100.0;
        unallocatedTime = Pair.of(unallocatedTimeMillis, unallocatedPercent);
    }

    public Map<String, Pair<Long, Double>> getCategoryMetrics() {
        return categoryMetrics;
    }

    public Pair<Long, Double> getUnallocatedTime() {
        return unallocatedTime;
    }

    public long getTotalProcessingTimeMillis() {
        return totalProcessingTimeMillis;
    }
}
