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

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics;

/**
 * Computes the following statistics based on the processing times
 * for the specified list of pipeline tasks:
 * <pre>
 * max
 * min
 * mean
 * stddev
 * 
 * @author tklaus
 *
 */
public class TaskProcessingTimeStats {

    private int count;
    private double sum;
    private double min;
    private double max;
    private double mean;
    private double stddev;
    private Date minStart = new Date();
    private Date maxEnd = new Date(0);
    private double totalElapsed;
    
    /** Private to prevent instantiation.  Use static 'of' method
     * to create instances.
     * @param tasks
     */
    private TaskProcessingTimeStats() {
    }

    public static TaskProcessingTimeStats of(List<PipelineTask> tasks) {
        TaskProcessingTimeStats s = new TaskProcessingTimeStats();
        
        List<Double> processingTimesHrs = new ArrayList<Double>(tasks.size());
        
        for (PipelineTask task : tasks) {
            Date startProcessingTime = task.getStartProcessingTime();
            Date endProcessingTime = task.getEndProcessingTime();
            
            if(startProcessingTime.getTime() > 0 && startProcessingTime.getTime() < s.minStart.getTime()){
                s.minStart = startProcessingTime;
            }
            
            if(endProcessingTime.getTime() > 0 && endProcessingTime.getTime() > s.maxEnd.getTime()){
                s.maxEnd = endProcessingTime;
            }
            
            processingTimesHrs.add(DisplayModel.getProcessingHours(startProcessingTime, endProcessingTime));
        }
        
        s.totalElapsed = DisplayModel.getProcessingHours(s.minStart, s.maxEnd);
        
        DescriptiveStatistics stats = new DescriptiveStatistics();

        for (Double d : processingTimesHrs) {
            stats.addValue(d);
        }
        
        s.count = tasks.size();
        s.sum = stats.getSum();
        s.min = stats.getMin();
        s.max = stats.getMax();
        s.mean = stats.getMean();
        s.stddev = stats.getStandardDeviation();
        
        return s;
    }

    public double getMin() {
        return min;
    }

    public double getMax() {
        return max;
    }

    public double getMean() {
        return mean;
    }

    public double getStddev() {
        return stddev;
    }
    public int getCount() {
        return count;
    }

    /**
     * @return the minStart
     */
    public Date getMinStart() {
        return minStart;
    }

    /**
     * @return the maxEnd
     */
    public Date getMaxEnd() {
        return maxEnd;
    }

    /**
     * @return the totalElapsed
     */
    public double getTotalElapsed() {
        return totalElapsed;
    }

    /**
     * @return the sum
     */
    public double getSum() {
        return sum;
    }

    /**
     * @param sum the sum to set
     */
    public void setSum(double sum) {
        this.sum = sum;
    }

}
