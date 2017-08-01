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

import gov.nasa.kepler.ar.archive.BarycentricCorrection;
import gov.nasa.kepler.ar.archive.DvaTargetSource;
import gov.nasa.kepler.ar.archive.TargetDva;
import gov.nasa.kepler.ar.archive.TargetWcs;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.dr.DataAnomaly;
import gov.nasa.kepler.hibernate.pa.TargetAperture;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tps.AbstractTpsDbResult;
import gov.nasa.kepler.mc.SciencePixelOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;

import java.util.*;

/**
 * Information all single quarter target exporters need in order to export.
 * 
 * @author Sean McCauliff
 *
 */
public interface SingleQuarterExporterSource extends BaseExporterSource {

    /**
     * The timestamp to use when generating the file name.
     * 
     * @return
     */
    String fileTimestamp();

    /**
     * This should be generous and return any ids that might be exportable.
     * @return a non-null list the same length as observedTargets()
     */
    List<Integer> keplerIds();

    int ccdModule();

    int ccdOutput();

    /**
     * If a target with the specified kepler id was dropped by a supplemental tad
     * run then this will return true else false.
     * @return
     */
    boolean wasTargetDroppedBySupplementalTad(int keplerId);
    
    List<? extends AbstractTpsDbResult> tpsDbResults();

    int season();

    int quarter();
   
    /**
     * 
     * @return
     */
    SciencePixelOperations sciOps();

    double readNoiseE();

    /**
     * Gain in e-/DN
     * 
     * @return
     */
    double gainE();

    /**
     * The mean black level in DN.
     * 
     * @return
     */
    int meanBlackValue();

    /** The observed targets that match the kepler ids. */
    List<ObservedTarget> observedTargets();

    int targetTableExternalId();

    /**
     * @see gov.nasa.kepler.ar.archive.ArchiveMatlabProcess
     * @param customTargets Custom targets needing barycentric correction time
     * series.
     * @return allTimeSeries Might be used to calculate centroid if needed.
     */
    <T extends DvaTargetSource> Map<Integer, BarycentricCorrection> barycentricCorrection(
        Collection<T> customTargets, Map<FsId, TimeSeries> allTimeSeries);

    /**
     * @see gov.nasa.kepler.ar.archive.ArchiveMatlabProcess
     * @param targets targets needing velocity abberation correction information
     * series.
     * @return allTimeSeries Might be used to calculate centroid if needed.
     */
    <T extends DvaTargetSource> Map<Integer, TargetDva> dvaMotion(
        Collection<T> targets, Map<FsId, TimeSeries> allTimeSeries);

    /**
     * @see gov.nasa.kepler.ar.archive.ArchiveMatlabProcess
     * @param targets targets needing world coordinate system parameters
     * @return allTimeSeries Might be used to calculate centroid if needed.
     */
    <T extends DvaTargetSource> Map<Integer, TargetWcs> wcsCoordinates(
        Collection<T> targets, Map<FsId, TimeSeries> allTimeSeries);

    /**
     * Translates the current cadence time system to long cadence. In the case
     * where the current cadence type is LONG this will be the identity function
     * in the case where this the current cadence type is SHORT this will return
     * the corresponding long cadence.
     */
    int cadenceToLongCadence(int referenceCadence);
    
    /**
     * 
     * @param centroidTimeSeries a non-null collection of centroid time series
     * generated by PA used to determine which PA pipeline task was responsible
     * for generating TargetAperture.  We don't use the actual centroid information
     * for anything.
     * @return A mapping of kepler id to TargetAperture.  The map must be 
     * non-null map containing an entry for every kepler id.
     */
    Map<Integer, TargetAperture> targetApertures(Collection<TimeSeries> centroidTimeSeries);
    
    /**
     * @return non-null.  This should be equal to mjdToCadence().cadenceType()
     * @return
     */
    CadenceType cadenceType();
    
    /**
     * Set of target labels to exclude.
     * @return A non-null set of target label strings.
     */
    Set<String> excludeTargetsWithLabel();
    
    /**
     * The timestamp series for the covering long cadences.  If this is processing
     * long cadence then this should return the same instance as timestampSeries.
     * @return non-null
     */
    TimestampSeries longCadenceTimestampSeries();
    
    /**
     * If this is exporting long cadence targets then this should be the same
     * as the target table id.  Else this should be the target table for the
     * covering long cadences.
     * 
     * @return a valid target table id.
     */
    int longCadenceExternalTargetTableId();

    /**
     * MjdToCadence for the covering long cadences.  If this is processing
     * long cadence then this should return the same instance as mjdToCadence().
     * @return non-null
     */
    MjdToCadence longCadenceMjdToCadence();

    /**
     * The long cadence data anomalies.
     * @return a non-null list of data anomalies.
     */
    List<DataAnomaly> longCadenceAnomalies();
    
    /**
     * @return The K2 campaign number.  If this is not a K2 campaign then this returns an undefined
     * value.  
     */
    int k2Campaign();
    
    /**
     * 
     * @return true if this is a K2 campaign else false.
     */
    boolean isK2();

    RollingBandUtils rollingBandUtils();
    
    /**
     * Because we want to find others.
     * @return non-null
     */
    TargetTable userSelectedTargetTable();

    
}
