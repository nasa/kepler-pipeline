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
 * Smear data for a single column over time.
 * <p>
 * In the case of long cadence, we'll have one of these objects for all columns,
 * but for short cadence, we'll only have columns on which targets are found.
 * </p>
 * <p>
 * Objects of this class are immutable.
 * </p>
 * 
 * @author Sean McCauliff
 */
public class CalibratedSmearTimeSeries implements Persistable {
    /** The CCD column representing the coadded rows in that column for the
     * smear.
     */
    private int column;
    /** The value of the calibrated smear.  This array is the same length as
     * cadenceTimes.startTimestamps.
     */
    private float[] values;
    /** The uncertaintiy in the calibrated smear.  This array is the same length
     * as values.
     */
    private float[] uncertainties;
    /** When gapIndicators[i] is true then  values[i] and 
     * uncertainties[i] are undefined.  This array has the same length as values.
     */
    private boolean[] gapIndicators;

    /**
     * Do not use. For serialization use only.
     */
    public CalibratedSmearTimeSeries() {
    }

    /**
     * Creates a {@link SmearTimeSeries} with the given values.
     */
    public CalibratedSmearTimeSeries(int column, float[] values, 
    		float[] uncertainties, boolean[] gapIndicators) {
        this.column = column;
        this.values = values;
        this.gapIndicators = gapIndicators;
        this.uncertainties = uncertainties;
    }

    // Accessors listed alphabetically.

    public int getColumn() {
        return column;
    }

    public boolean[] getGapIndicators() {
        return gapIndicators;
    }

    public float[] getValues() {
        return values;
    }
    
    
    public float[] getUncertainties() {
		return uncertainties;
	}

	public List<TimeSeries> toTimeSeries(CollateralType collateralType, 
                                                        int ccdModule, int ccdOutput,
                                                        CadenceType cadenceType,
                                                        int startCadence, int endCadence,
                                                        long taskId) {
		List<TimeSeries> rv = new ArrayList<TimeSeries>(2);
        FsId id = CalFsIdFactory.getCalibratedCollateralFsId(collateralType, 
            PixelTimeSeriesType.SOC_CAL, cadenceType, ccdModule, ccdOutput, column);
        
        FloatTimeSeries ts = 
            new FloatTimeSeries(id, values, startCadence, endCadence, gapIndicators, taskId);
        rv.add(ts);
        
        FsId uncertId = CalFsIdFactory.getCalibratedCollateralFsId(collateralType, 
                PixelTimeSeriesType.SOC_CAL_UNCERTAINTIES, 
                cadenceType, ccdModule, ccdOutput, column);
        
        FloatTimeSeries uncertSeries =
            new FloatTimeSeries(uncertId, uncertainties, startCadence, 
            		endCadence, gapIndicators, taskId);
        rv.add(uncertSeries);
        return rv;
    }
}