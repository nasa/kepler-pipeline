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

package gov.nasa.kepler.cal.io;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.CalFsIdFactory.PixelTimeSeriesType;
import gov.nasa.spiffy.common.persistable.Persistable;

/**
 * "Calibrated" black.
 * This is used when there will only be a single time series at the corners of
 * the CCD during short cadence.
 * 
 * @author Sean McCauliff
 *
 */
public class SingleResidualBlackTimeSeries implements Persistable {
    /** When false the following fields have undefined values and should not 
     * be stored in the file store.  This should only be true with short 
     * cadence inputs.
     */
    private boolean exists = false;
    /** The value of the residual.  The length of this array is the length of
     * cadenceTimes.startCadence. */
    private float[] values = org.apache.commons.lang.ArrayUtils.EMPTY_FLOAT_ARRAY;
    
    /** The uncertainty of the residual.  This has the same length as values.*/
    private float[] uncertainties =  org.apache.commons.lang.ArrayUtils.EMPTY_FLOAT_ARRAY;
    
    /** When gapIndicators[i] is true then  
     * values[i] and uncertainties[i] are undefined.  This has the same length
     * as values.
     */
    private boolean[] gapIndicators = org.apache.commons.lang.ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    
    public SingleResidualBlackTimeSeries() {
        
    }
    
    public SingleResidualBlackTimeSeries(float[] values, 
    		float[] uncertainties, boolean[] gapIndicators) {
        this.values = values;
        this.gapIndicators = gapIndicators;
        this.exists = true;
        this.uncertainties = uncertainties;
    }
    
    public int size() { if (exists()) { return 1; } else { return 0; } }
    public boolean exists() { return exists; }
    public float[] values() { return values; }
    public float[] uncertainties() { return uncertainties; }
    public boolean[] gapIndicators() { return gapIndicators; }
    
    
    public List<TimeSeries> toTimeSeries(CollateralType cType, int ccdModule, int ccdOutput, 
        int startCadence, int endCadence, CadenceType cadenceType, long taskId) {
        
        if (cType != CollateralType.BLACK_MASKED && cType != CollateralType.BLACK_VIRTUAL) {
            throw new IllegalArgumentException("Invalid single black collateral type \"" + cType + "\".");
        }
        
        List<TimeSeries> rv = new ArrayList<TimeSeries>(2);
        
        FsId id = CalFsIdFactory.getCalibratedCollateralFsId(cType, 
            PixelTimeSeriesType.SOC_CAL, cadenceType, ccdModule, ccdOutput, 0);
        FloatTimeSeries ts = 
            new FloatTimeSeries(id, values, startCadence, endCadence, gapIndicators, taskId);
        
        rv.add(ts);
        
        FsId uncertId = CalFsIdFactory.getCalibratedCollateralFsId(cType, 
                PixelTimeSeriesType.SOC_CAL_UNCERTAINTIES, 
                cadenceType, ccdModule, ccdOutput, 0);
        FloatTimeSeries uncertSeries =
        	new FloatTimeSeries(uncertId, uncertainties, startCadence, endCadence, gapIndicators, taskId);
        rv.add(uncertSeries);
        
        return rv;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + (exists ? 1231 : 1237);
        result = prime * result + Arrays.hashCode(gapIndicators);
        result = prime * result + Arrays.hashCode(uncertainties);
        result = prime * result + Arrays.hashCode(values);
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        SingleResidualBlackTimeSeries other = (SingleResidualBlackTimeSeries) obj;
        if (exists != other.exists)
            return false;
        if (!Arrays.equals(gapIndicators, other.gapIndicators))
            return false;
        if (!Arrays.equals(uncertainties, other.uncertainties))
            return false;
        if (!Arrays.equals(values, other.values))
            return false;
        return true;
    }
    
    
}