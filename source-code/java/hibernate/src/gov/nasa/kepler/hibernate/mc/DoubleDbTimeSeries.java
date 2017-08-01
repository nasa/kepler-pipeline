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

package gov.nasa.kepler.hibernate.mc;


import java.util.Arrays;

import org.apache.commons.lang.ArrayUtils;


/**
 * @author Sean McCauliff
 *
 */
public class DoubleDbTimeSeries {
	private double[] values;
	private boolean[] gapIndicators;
	private long[] originators;
	private DoubleTimeSeriesType timeSeriesType;
	private int startCadence;
	private int endCadence;
	
	public DoubleDbTimeSeries(double[] values, int startCadence, int endCadence,
			boolean[] gapIndicators, long[] originators,
			DoubleTimeSeriesType timeSeriesType) {
		
		init(values, startCadence, endCadence, gapIndicators, originators,
            timeSeriesType);
	}

    /**
     * @param values
     * @param startCadence
     * @param endCadence
     * @param gapIndicators
     * @param originators
     * @param timeSeriesType
     */
    private void init(double[] values, int startCadence, int endCadence,
        boolean[] gapIndicators, long[] originators,
        DoubleTimeSeriesType timeSeriesType) {
        if (values.length != originators.length) {
			throw new IllegalArgumentException("Values are not the same" +
					" length as originators.");
		}
		if (originators.length != gapIndicators.length) {
			throw new IllegalArgumentException("Originators length not the same" +
					" as gapIndicators length.");
		}
		
		if (timeSeriesType == null) {
			throw new NullPointerException("timeSeriesType must not be null.");
		}
		
		if (endCadence < startCadence) {
			throw new IllegalArgumentException("startCadence comes after endCadence.");
		}
		
		this.values = values;
		this.gapIndicators = gapIndicators;
		this.timeSeriesType = timeSeriesType;
		this.startCadence = startCadence;
		this.endCadence = endCadence;
		this.originators = originators;
    }
    
    public DoubleDbTimeSeries(double[] values, int startCadence, int endCadence,
        boolean[] gapIndicators, long originator, DoubleTimeSeriesType timeSeriesType) {
       
        long[] o = new long[values.length];
        Arrays.fill(o, originator);
        
        init(values, startCadence, endCadence, gapIndicators, o, timeSeriesType);
    }
	
	public DoubleDbTimeSeries(double[] values, int startCadence, int endCadence,
	    int[] gapIndices, long originator, DoubleTimeSeriesType timeSeriesType) {
	   
	    long[] o = new long[values.length];
	    Arrays.fill(o, originator);
	    
	    boolean[] gapIndicators = new boolean[values.length];
	    for (int i=0; i < gapIndices.length; i++) {
	        gapIndicators[gapIndices[i]] = true;
	    }
	    
	    init(values, startCadence, endCadence, gapIndicators, o, timeSeriesType);
	    
	}

	public double[] getValues() {
		return values;
	}

	public boolean[] getGapIndicators() {
		return gapIndicators;
	}

	public DoubleTimeSeriesType getTimeSeriesType() {
		return timeSeriesType;
	}

	public int getStartCadence() {
		return startCadence;
	}

	public int getEndCadence() {
		return endCadence;
	}

	public long[] getOriginators() {
		return originators;
	}
	
	public int[] getGapIndices() {
		int nindices = 0;
		for (int i=0; i < this.gapIndicators.length; i++) {
			if (gapIndicators[i]) {
				nindices++;
			}
		}
		
		if (nindices == 0) {
			return ArrayUtils.EMPTY_INT_ARRAY;
		}
		
		int[] indices = new int[nindices];
		int index=0;
		for (int i=0; i < gapIndicators.length; i++) {
			if (gapIndicators[i]) {
				indices[index++] = i;
			}
		}
		return indices;
	}

	@Override
	public int hashCode() {
		int prime = 31;
		int result = 1;
		result = prime * result + endCadence;
		result = prime * result + Arrays.hashCode(gapIndicators);
		result = prime * result + Arrays.hashCode(originators);
		result = prime * result + startCadence;
		result = prime * result
				+ ((timeSeriesType == null) ? 0 : timeSeriesType.hashCode());
		result = prime * result + Arrays.hashCode(values);
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj) {
			return true;
		}
		if (obj == null) {
			return false;
		}
		if (getClass() != obj.getClass()) {
			return false;
		}
		DoubleDbTimeSeries other = (DoubleDbTimeSeries) obj;
		if (endCadence != other.endCadence) {
			return false;
		}
		if (!Arrays.equals(gapIndicators, other.gapIndicators)) {
			return false;
		}
		if (!Arrays.equals(originators, other.originators)) {
			return false;
		}
		if (startCadence != other.startCadence) {
			return false;
		}
		if (timeSeriesType == null) {
			if (other.timeSeriesType != null) {
				return false;
			}
		} else if (!timeSeriesType.equals(other.timeSeriesType)) {
			return false;
		}
		if (!Arrays.equals(values, other.values)) {
			return false;
		}
		return true;
	}
	
	@Override
	public String toString() {
	    StringBuilder bldr = new StringBuilder();
	    bldr.append("DoubleDbTimeSeries, start=").append(startCadence)
	        .append(", end=").append(endCadence);
	    return bldr.toString();
	}
	
}
