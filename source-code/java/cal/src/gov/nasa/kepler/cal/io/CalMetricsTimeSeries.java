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

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.CalFsIdFactory.MetricsTimeSeriesType;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnoreStatics;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.Arrays;
import java.util.List;

import org.apache.commons.lang.ArrayUtils;

/**
 * Metrics for a time series.
 * <p>
 * Objects of this class are immutable.
 * </p>
 * 
 * @author Sean McCauliff
 * @author Bill Wohler
 */
@ProxyIgnoreStatics
public class CalMetricsTimeSeries implements Persistable {
    /** This must be as long as the number of cadences in the unit of work. */
    protected float[] values = ArrayUtils.EMPTY_FLOAT_ARRAY;
    /** The uncertaintiy in the metric value.  This is the same length as
     * values. */
    protected float[] uncertainties = ArrayUtils.EMPTY_FLOAT_ARRAY;
    
    /** Then gapIndicators[i] is true then values[i] and uncertainties[i] is
     * undefined.  This has the same length as values.
     */
    protected boolean[] gapIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;

    /**
     * Do not use. For serialization use only.
     */
    public CalMetricsTimeSeries() {
    }

    /**
     * Creates a {@link CalMetricsTimeSeries} with the given values.
     */
    public CalMetricsTimeSeries(float[] values, float[] uncertainties,
        boolean[] gapIndicators) {
        
        this.values = values;
        this.uncertainties = uncertainties;
        this.gapIndicators = gapIndicators;
    }
    
    public boolean[] gapIndicators() {
        return gapIndicators;
    }

    public float[] uncertainties() {
        return uncertainties;
    }

    public float[] values() {
        return values;
    }
    
    protected FsId generateFsId(CadenceType cadenceType, MetricsTimeSeriesType metricsType, int ccdModule, int ccdOutput) {
        return CalFsIdFactory.getMetricsTimeSeriesFsId(cadenceType,
            metricsType, ccdModule, ccdOutput);
    }
    
    /**
     * Converts metric time series to filestore time series.
     * 
     * @param startCadence the starting cadence.
     * @param endCadence the ending cadence, inclusive
     * @param timeSeriesType the type of time series.
     * @param uncertainTimeSeriesType the type of the time series'
     * uncertainties.
     * @throws PipelineException if the data store could not be accessed.
     */
    public List<TimeSeries> toFileStoreTimeSeries(int startCadence,
        int endCadence, CadenceType cadenceType, 
        MetricsTimeSeriesType timeSeriesType,
        MetricsTimeSeriesType uncertainTimeSeriesType, 
        int ccdModule, int ccdOutput, long originator) {

        // Concatenate pixel values and uncertainties.
        TimeSeries[] timeSeries = new TimeSeries[2];

        // Wrap all of the time series in an array of FloatTimeSeries.
        FsId fsId = generateFsId(cadenceType, timeSeriesType, ccdModule, ccdOutput);
        
        timeSeries[0] = 
            new FloatTimeSeries(fsId, values, startCadence, endCadence, gapIndicators, originator);

        fsId = generateFsId(cadenceType, uncertainTimeSeriesType, ccdModule, ccdOutput);
        
        timeSeries[1] = new FloatTimeSeries(fsId,
            uncertainties, startCadence, endCadence,
            gapIndicators, originator);

        return Arrays.asList(timeSeries);
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
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
        CalMetricsTimeSeries other = (CalMetricsTimeSeries) obj;
        if (!Arrays.equals(gapIndicators, other.gapIndicators))
            return false;
        if (!Arrays.equals(uncertainties, other.uncertainties))
            return false;
        if (!Arrays.equals(values, other.values))
            return false;
        return true;
    }
    
    
}
