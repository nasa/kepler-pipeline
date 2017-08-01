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

package gov.nasa.kepler.fs.api;

import gov.nasa.spiffy.common.intervals.Interval;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.Interval.MergeResult;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;

/**
 * Filters the time series metadata according to the a boolean filter
 * array.
 * 
 * @author Sean McCauliff
 *
 */
class IntervalFilter {

	/** The current count of filtered cadences. */
	private int filteredCount = 0;
	private long newIntervalStart = -1;
	private int cadenceDiff = 0;
	private boolean[] filter;
	
	IntervalFilter() {
		
	}
	
	private void init(int cadenceDiff, boolean[] filter) {
		filteredCount = 0;
		newIntervalStart = -1;
		this.cadenceDiff = cadenceDiff;
		this.filter = filter;
	}
	
	/**
	 * 
	 * @param orig the original intervals
	 * @param oldStartCadence The cadence for filter[0]
	 * @param newCadenceBasis everything from 0 to this cadence (exclusive) is
	 * trimmed.
	 * @param filter When filter[i] is true them remove cadence oldStart + i.
	 * @return the compressed list of intervals.
	 */
	List<? extends Interval> filter(List<? extends Interval> orig,
								int oldStartCadence,
								int newCadenceBasis, boolean[] filter) {
		
		if (newCadenceBasis < 0) {
			throw new IllegalArgumentException("The parameter newCadenceBasis was " 
					+ newCadenceBasis + " but must be non-negative.");
		}
		if (oldStartCadence < 0) {
			throw new IllegalArgumentException("The parameter oldStartCadence "+
					"must be non-negative but was " + oldStartCadence + " .");
		}
		if (newCadenceBasis > oldStartCadence) {
			throw new IllegalArgumentException("The parameter newCadenceBasis("+ 
					newCadenceBasis +") must be less than or equal to " +
					" oldStartCadence(" + oldStartCadence + ").");
		}
		
		if (orig.size() == 0) {
			return orig;
		}
		
		if (orig.get(0).start() < oldStartCadence) {
			throw new IllegalArgumentException("The set of original intervals is" +
					" not within the range of the filter.");
		}
		if ( (orig.get(orig.size() - 1).end() - orig.get(0).start()) + 1 >
			 filter.length) {
			throw new IllegalArgumentException("The specified filter array does" +
					" not not cover the entire interval.");
		}
		
		init( newCadenceBasis, filter);

		
		countFiltered(0, (int) orig.get(0).start() - oldStartCadence);
		List<Interval> rv = new ArrayList<Interval>();
		
		for (int interval_i = 0; interval_i < orig.size(); interval_i++) {
			Interval interval = orig.get(interval_i);
			long intervalLength = -1;
			newIntervalStart = -1;
			for (long oldCadence = interval.start(); 
				  oldCadence <= interval.end(); 
				  oldCadence++) {
				
				int oldIndex = (int) (oldCadence - oldStartCadence);		

				if (!filter[oldIndex] && oldCadence >= newCadenceBasis) {
					if (newIntervalStart == -1) {
						//found start
						newIntervalStart = oldCadenceToNewCadence(oldCadence);
						intervalLength = 1;
					} else {
						intervalLength++;
					}
				} else if (filter[oldIndex]) {
					filteredCount++;
				}
			}
			
			if (newIntervalStart != -1) {
				long newIntervalEnd = newIntervalStart + intervalLength - 1;
				//merge new with previous
				if (rv.size() > 0) {
					Interval prevInterval = rv.get(rv.size() - 1);
					if (prevInterval.end() == newIntervalStart ||
						prevInterval.end() == newIntervalStart - 1) {				
						MergeResult mergeResult = 
							prevInterval.merge(createNewInterval(interval, newIntervalStart, newIntervalEnd));
						rv.remove(rv.size() - 1);
						rv.addAll((Collection<? extends Interval>) mergeResult.mergedIntervals());
					} else {
						rv.add(createNewInterval(interval, newIntervalStart, newIntervalEnd));
					}
				} else {
					rv.add(createNewInterval(interval, newIntervalStart, newIntervalEnd));
				}
			}
			
			if ( (interval_i + 1) < orig.size()) {
				Interval nextInterval = orig.get(interval_i + 1);
				int startCheckIndex = (int) interval.end() + 1 - oldStartCadence;
				int endCheckIndex = (int) nextInterval.start() - oldStartCadence;
				countFiltered(startCheckIndex, endCheckIndex);
			}
			
			
		}
		
		if (rv.size() == 0) {
			@SuppressWarnings("unchecked")
			List<Interval> rv2 = Collections.EMPTY_LIST;
			return rv2;
		}
		 
		return rv;
	}
	
	/**
	 * 
	 * @param start index into filtered array
	 * @param stop index into filtered array, exclusive
	 */
	private void countFiltered(int start, int stop) {
		for (int i=start; i < filter.length && i < stop; i++) {
			if (filter[i]) {
				filteredCount++;
			}
		}
	}
	
	
	protected Interval createNewInterval(Interval old, long newStart, long newEnd) {
		return new SimpleInterval(newStart, newEnd);
	}
	
	private long oldCadenceToNewCadence(long oldCadence) {
		return oldCadence - cadenceDiff - this.filteredCount;
	}
}
