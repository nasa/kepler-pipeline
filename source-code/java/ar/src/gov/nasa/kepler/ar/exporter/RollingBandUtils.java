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

package gov.nasa.kepler.ar.exporter;

import gov.nasa.kepler.dynablack.DynablackModuleParameters;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.mc.RollingBandArtifactParameters;
import gov.nasa.kepler.mc.blob.BlobOperations;

import java.util.Arrays;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Used to get rolling band flag information and such.
 * 
 * @author Sean McCauliff
 *
 */
public class RollingBandUtils {
    private static final Log log = LogFactory.getLog(RollingBandUtils.class);

    /**
     * This is here because the RollingBandArtifactParameters changed quite a
     * bit between 9.2 and 9.3.  In order to export rolling band I'm doing this
     * instead of trying to dig through all String to String maps that are in
     * PipelineTask.
     */
    private static final int[] DEFAULT_ROLLING_BAND_PULSE_DURATIONS = new int[] { 21 };
    
    private final int[] rollingBandPulseDurations;
    private final Integer scDPixThreshold;
    private final Integer nearTbMinpix;
    
    public static RollingBandUtils emptyInstance() {
        return new RollingBandUtils();
    }
    
    /**
     * Construct an empty rolling band utils.
     */
    private RollingBandUtils() {
        rollingBandPulseDurations = ArrayUtils.EMPTY_INT_ARRAY;
        nearTbMinpix = null;
        scDPixThreshold = null;
    }
    
    public RollingBandUtils(int ccdModule, int ccdOutput, int startCadence, int endCadence) {

        long[] dynablackTaskIds = getBlobOps()
                .retrieveDynamicTwoDBlackOriginators(ccdModule, ccdOutput, startCadence, endCadence);
        //"gov.nasa.kepler.dynablack.RollingBandArtifactParameters"
        int[] rbDurations = null;
        int scDPixThreshold = -1;
        int nearTbMinpix = -1;
        for (long taskId : dynablackTaskIds) {
            PipelineTask dynablackTask = getPipelineTaskCrud().retrieve(taskId);
            
            int[] foundTestPulseDurations = null;
            
            //log.info("Dynablack task " + dynablackTask.prettyPrint());
            //This variable can be null
            RollingBandArtifactParameters rbParameters =
                    dynablackTask.getParameters(RollingBandArtifactParameters.class, false);
            if (rbParameters == null) {
                foundTestPulseDurations = Arrays.copyOf(DEFAULT_ROLLING_BAND_PULSE_DURATIONS,
                    DEFAULT_ROLLING_BAND_PULSE_DURATIONS.length);
            } else {
                foundTestPulseDurations = rbParameters.getTestPulseDurations();
            }
            
            DynablackModuleParameters dynablackModuleParameters = 
                dynablackTask.getParameters(DynablackModuleParameters.class);
            if (scDPixThreshold == -1) {
                scDPixThreshold = dynablackModuleParameters.getScDPixThreshold();
            } else if (scDPixThreshold != dynablackModuleParameters.getScDPixThreshold()) {
                throw new IllegalStateException("Found different values of scDPixThreshold().");
            }
            
            if (nearTbMinpix == -1) {
                nearTbMinpix = dynablackModuleParameters.getNearTbMinpix();
            } else if (nearTbMinpix != dynablackModuleParameters.getNearTbMinpix()) {
                throw new IllegalStateException("Found different values of nearTbMinpix.");
            }
            
            rbDurations = resolveTestPulseDurationConflict(foundTestPulseDurations, rbDurations);
        }

        if (rbDurations == null) {
            log.warn("Empty rolling band pulse durations.");
            rollingBandPulseDurations = ArrayUtils.EMPTY_INT_ARRAY;
        } else {
            rollingBandPulseDurations = rbDurations;
            log.info("Rolling band pulse durations " + 
                Arrays.toString(rollingBandPulseDurations) + ".");
        }
        
        this.nearTbMinpix = nearTbMinpix;
        this.scDPixThreshold = scDPixThreshold;
    }
    
    /**
     * When this find multiple sets of testPulseDurations lets check that they are
     * all the same or one is a subset of the other.
     * @param found null ok
     * @param current null ok
     * @return either found or current or throws an exception if the conditions
     * for merging are not met.
     */
    private static final int[] resolveTestPulseDurationConflict(int[] found, int[] current) {
        if (current == null) {
            return found;
        }
        if (found == null) {
            return current;
        }
        
        if (Arrays.equals(found, current)) {
            return current;
        }
        
        if (found.length == current.length) {
            throw new IllegalStateException(
                "Found multiple different rolling band pulse durations " + 
                Arrays.toString(found) + " and " + Arrays.toString(current) + 
                ".");
        }
        
        int[] smaller = null;
        int[] larger = null;
        //Check proper subset.
        if (found.length < current.length) {
            smaller = found;
            larger = current;
        } else {
            smaller = current;
            larger = found;
        }
        
        for (int transitPulseDuration : smaller) {
            if (Arrays.binarySearch(larger, transitPulseDuration) < 0) {
                throw new IllegalStateException(
                    "Found multiple different rolling band pulse durations " + 
                    Arrays.toString(found) + " and " + Arrays.toString(current) + 
                    ".");
            }
        }
        return larger;
    }
    
    /**
     * The durations used to compute the rolling band in units of long cadence.
     * 
     * @return non-null
     */
    public int[] rollingBandPulseDurations() {
        return rollingBandPulseDurations;
    }
    
    /**
     * 
     * @param lcExposureTimeDays the duration of a long cadence in days.
     * @return column cutoff in electrons per second.  Returns null if 
     * dynablack was not run for the specified cadence interval.
     */
    public Double fluxThreshold(double lcExposureTimeDays) {
        if (scDPixThreshold == null) {
            return null;
        }
        double exposureS =  lcExposureTimeDays * 24.0 * 60.0 * 60.0;
        
        return scDPixThreshold / exposureS;
    }
    
    /**
     * 
     * @return This returns null if dynablack was not run for the
     * specified cadence interval.
     */
    public Integer columnCutoff() {
        return nearTbMinpix;
    }

    protected PipelineTaskCrud getPipelineTaskCrud() {
        return new PipelineTaskCrud();
    }
    
    protected BlobOperations getBlobOps() {
        return new BlobOperations();
    }
}
