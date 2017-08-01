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

package gov.nasa.kepler.debug;

import gov.nasa.spiffy.common.pi.Parameters;

/**
 * Pipeline parameters used by the Debug Simple pipeline
 * The Debug Simple pipeline is intended to test the pipeline infrastructure
 * by exercising the various launch and transition use cases (dynamic UOW from
 * node to node, node synchronization (wait for all before advancing), data
 * accountability (locking/preserving module and pipeline params), error
 * handling, etc.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
public class DebugSimplePipelineParameters implements Parameters{

    /**
     * If true, always throw ModuleFatalProcessingException
     */
    private boolean fail;
    
    /** if non-zero, the pipeline task that corresponds to this channel number 
     * will throw an exception to test the error handling in the pipeline */
    private int failChannel;
    
    private double failureProbability;
    private long sleepTimeMillis;
    
    private boolean includeFilestore;
    private int numTimeseries;
    private int timeSeriesLength;
    private boolean launchAnotherInstance;
    
    public DebugSimplePipelineParameters() {
    }

    public int getFailChannel() {
        return failChannel;
    }

    public void setFailChannel(int failChannel) {
        this.failChannel = failChannel;
    }

    /**
     * @return the failureProbability
     */
    public double getFailureProbability() {
        return failureProbability;
    }

    /**
     * @param failureProbability the failureProbability to set
     */
    public void setFailureProbability(double failureProbability) {
        this.failureProbability = failureProbability;
    }

    public boolean isFail() {
        return fail;
    }

    public void setFail(boolean fail) {
        this.fail = fail;
    }

    public long getSleepTimeMillis() {
        return sleepTimeMillis;
    }

    public void setSleepTimeMillis(long sleepTimeMillis) {
        this.sleepTimeMillis = sleepTimeMillis;
    }

    public boolean isIncludeFilestore() {
        return includeFilestore;
    }

    public void setIncludeFilestore(boolean fetchTimeseries) {
        this.includeFilestore = fetchTimeseries;
    }

    public int getNumTimeseries() {
        return numTimeseries;
    }

    public void setNumTimeseries(int numTimeseries) {
        this.numTimeseries = numTimeseries;
    }

    /**
     * @return the timeseriesLength
     */
    public int getTimeSeriesLength() {
        return timeSeriesLength;
    }

    /**
     * @param timeseriesLength the timeseriesLength to set
     */
    public void setTimeSeriesLength(int timeseriesLength) {
        this.timeSeriesLength = timeseriesLength;
    }

    /**
     * @return the launchAnotherInstance
     */
    public boolean isLaunchAnotherInstance() {
        return launchAnotherInstance;
    }

    /**
     * @param launchAnotherInstance the launchAnotherInstance to set
     */
    public void setLaunchAnotherInstance(boolean launchAnotherInstance) {
        this.launchAnotherInstance = launchAnotherInstance;
    }
}
