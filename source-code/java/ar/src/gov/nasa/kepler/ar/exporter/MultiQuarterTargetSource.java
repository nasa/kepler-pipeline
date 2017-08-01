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

import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.hibernate.tps.TpsDbResult;
import gov.nasa.kepler.mc.SciencePixelOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.List;
import java.util.Map;

/**
 * Methods should always return the same value if called multiple times.
 * 
 * @author Sean McCauliff
 *
 */
public interface MultiQuarterTargetSource extends BaseExporterSource {

    /**
     * Target table ids in quarter ordering.
     * 
     * @return non-null, but entries may be null to indicate quarters
     * where targets could not be observed.
     */
    Integer[] targetTableExternalId();
    
    /**
     * A map from the external target table id to a pair (ccdModule, ccdOutput).
     */
    Map<Integer, Pair<Integer, Integer>> ccdChannels();
    
    /**
     * 
     * @return non-null map targetTableId -> rolling band pulse durations.
     * The value array should never be null, but might be zero length.
     */
    Map<Integer, RollingBandUtils> rollingBandPulseDurationsCadences();

    /**
     * 
     * @return non-null.
     */
    List<CelestialObject> celestialObjects();
    
    /**
     * 
     * @return the same length as celestialObjects().  keplerIds().get(i)
     * is the kepler id for celestialObjects()[i].  This is here for
     * for methods that only want ids.
     */
    List<Integer> keplerIds();

    /**
     * 
     * @return non-null.  All the observed targets for all the celestial
     * objects observed.
     */
    List<ObservedTarget> observedTargets();
    
    /**
     * 
     * @return non-null.  All the tps results for all the celestial
     * objects observed.  Each celestial object should have at least one
     * tps result associated with it.
     */
    List<TpsDbResult> tpsResults();

    /** @return the same length as targetTableExternalId.
    * If targetTableExternalId[i] is null then so is ith element
    * returned by this method.
    */
    List<SciencePixelOperations> sciOps();

    /**
     * 
     * @return the same length as targetTableExternalId.
    * If targetTableExternalId[i] is null then so is ith element
    * returned by this method.
     */
    List<TargetTableLog> targetTableLogs();

    /**
     * 
     * @return non-null
     */
    MjdToCadence mjdToCadence();

    /**
     * 
     * @return non-null, positive length, no NaN or Inf.
     */
    float[] tpsTrialTransitPulseDurationsHours();

}
