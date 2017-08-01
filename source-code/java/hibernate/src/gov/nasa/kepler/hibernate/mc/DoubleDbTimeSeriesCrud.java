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

import gov.nasa.kepler.hibernate.AbstractCrud;

import java.util.Arrays;
import java.util.List;

import org.hibernate.Query;

/**
 * Create, remove, update delete time series based on DoubleDbTimeSeriesEntry.
 * 
 * @author Sean McCauliff
 *
 */
public class DoubleDbTimeSeriesCrud extends AbstractCrud {
	
	/**
	 * This also removes the parts of the time series between 
	 * timeSeries.startCadence and timeSeries.endCadence inclusive.
	 * @param timeSeries
	 */
	public void create(DoubleDbTimeSeries timeSeries) {
		remove(timeSeries.getStartCadence(), timeSeries.getEndCadence(), timeSeries.getTimeSeriesType());
		
		for (int i=0; i < timeSeries.getGapIndicators().length; i++) {
			if (timeSeries.getGapIndicators()[i]) {
				continue;
			}
			
			DoubleDbTimeSeriesEntry entry = 
				new DoubleDbTimeSeriesEntry(timeSeries.getTimeSeriesType(),
						i + timeSeries.getStartCadence(), 
						timeSeries.getValues()[i],
						timeSeries.getOriginators()[i]);
			getSession().save(entry);
		}
	}
	
	public void remove(int startCadence, int endCadence, DoubleTimeSeriesType timeSeriesType) {
		String deleteQueryStr = "delete DoubleDbTimeSeriesEntry " +
			" where cadence >= :startCadenceParam and cadence <= :endCadenceParam " +
			" and timeSeriesType = :timeSeriesType";
		Query deleteQuery = getSession().createQuery(deleteQueryStr);
		deleteQuery.setParameter("startCadenceParam", startCadence);
		deleteQuery.setParameter("endCadenceParam", endCadence);
		deleteQuery.setParameter("timeSeriesType", timeSeriesType);
		
		deleteQuery.executeUpdate();
	}
	

	/**
	 * 
	 * @param timeSeriesType
	 * @param startCadence
	 * @param endCadence inclusive
	 * @return
	 */
	public DoubleDbTimeSeries retrieve(DoubleTimeSeriesType timeSeriesType,
			int startCadence, int endCadence) {
		
		long[] originators = new long[endCadence - startCadence + 1];
		double[] values = new double[originators.length];
		boolean[] gapIndicators = new boolean[originators.length];
		Arrays.fill(gapIndicators, true);
		
		//This query is not sorted, this is good.  The code below that
		//repacks the entries into the DoubleDbTimeSeries does an
		//implicit counting sort.  Which is O(n) rather than a generic sort
		//which would be O(n log n)
		String queryStr = "from DoubleDbTimeSeriesEntry where " +
			" timeSeriesType = :timeSeriesTypeParam and " +
			" cadence >= :startCadenceParam and " +
			" cadence <= :endCadenceParam";
		
		Query q = getSession().createQuery(queryStr);
		q.setParameter("timeSeriesTypeParam", timeSeriesType);
		q.setParameter("startCadenceParam", startCadence);
		q.setParameter("endCadenceParam", endCadence);
		
		List<DoubleDbTimeSeriesEntry> entries = list(q);
		for (DoubleDbTimeSeriesEntry entry : entries) {
			int i = entry.getCadence() - startCadence;
			originators[i] = entry.getOriginator();
			values[i] = entry.getValue();
			gapIndicators[i] = false;
		}
		
		return new DoubleDbTimeSeries(values, startCadence, endCadence, 
				gapIndicators, originators, timeSeriesType);
		
	}
}
