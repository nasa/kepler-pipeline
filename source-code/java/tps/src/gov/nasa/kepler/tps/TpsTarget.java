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

package gov.nasa.kepler.tps;

import java.util.List;

import gov.nasa.kepler.mc.Transit;
import gov.nasa.spiffy.common.persistable.Persistable;
import static com.google.common.base.Preconditions.checkNotNull;

/**
 *  The flux for a single target.
 *  
 * @author Sean McCauliff
 *
 */
@SuppressWarnings("unused")
public class TpsTarget implements Persistable{

    /** The Kepler ID of this target. 
     */
    private int keplerId;
    
    /** Diagnoistic information about the target useful for debugging. */
    private TargetDiagnostics diagnostics;
    
    /** 
     *  The filled corrrected flux of the target as calculated by PDC.
     */
    private float[] fluxValue;
    
    /** The uncertaintiy of the fluxValues.  This has the same length as
     * fluxValue.
     */
    private float[] uncertainty;
    
    /** The gap indices for the flux values.  For all valid values of i
     * fluxValue[gapIndices[i]] and uncertaintiy[gapIndices[i]] are undefined.
     * There may be zero or more gapIndices.
     */
    private int[] gapIndices;
    
    /**
     * Indicates that a flux value has been filled by PDC.  For all valid values
     * of i fluxValue[fillIndices[i]] has been filled.  There may be zero or
     * more fillIndices.
     */
    private int[] fillIndices;
    
    /** Indicates that PDC identified an outlier at this index in the flux.  For
     * all valid values of i fluxValue[outlierIndices[i]] is an outlier.
     */
    private int[] outlierIndices;
    
    /**
     * Indicates indices in the flux values where PDC found a discontinuity that
     * it fixed.  For all valid values of i fluxValue[discontinuityIndices[i]]
     * is a discontinuity fixed by PDC.
     */
    private int[] discontinuityIndices;
    
    /**
     *  The length of this array is the number of quarters in the unit of work.
     *  When an indicator is true it indicates a gap in the data for the
     *  specified quarter index.
     */
    private boolean[] quarterGapIndicators;
    
    private List<Transit> transitEphemeris;
    
    /** Don't use this. */
    private TpsTarget() {
        
    }

    public TpsTarget(int keplerId, TargetDiagnostics targetDiagnostics,
        float[] fluxValue,
        float[] uncertainty, int[] gapIndices, int[] fillIndices, 
        int[] outlierIndices, int[] discontinuityIndices,
        boolean[] quarterGapIndicators,
        List<Transit> transitEphemeris) {

        checkNotNull(transitEphemeris, "transitEphemeris");
        checkNotNull(quarterGapIndicators, "quarterGapIndicators");
        checkNotNull(discontinuityIndices, "discontinuityIndices");
        checkNotNull(targetDiagnostics, "targetDiagnostics");
        checkNotNull(outlierIndices, "outlierIndices");
        checkNotNull(gapIndices, "gapIndices");
        checkNotNull(fillIndices, "fillIndices");
        checkNotNull(uncertainty, "uncertainty");
        checkNotNull(fluxValue, "valueValue");
        
        this.diagnostics = targetDiagnostics;
        this.keplerId = keplerId;
        this.fluxValue = fluxValue;
        this.uncertainty = uncertainty;
        this.gapIndices = gapIndices;
        this.fillIndices = fillIndices;
        this.outlierIndices = outlierIndices;
        this.discontinuityIndices = discontinuityIndices;
        this.quarterGapIndicators = quarterGapIndicators;
        this.transitEphemeris = transitEphemeris;
    }

}
