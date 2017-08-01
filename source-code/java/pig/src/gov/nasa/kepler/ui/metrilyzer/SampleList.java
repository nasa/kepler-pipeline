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

package gov.nasa.kepler.ui.metrilyzer;

import gov.nasa.kepler.hibernate.metrics.MetricValue;

import java.util.Collection;
import java.util.Date;
import java.util.Iterator;
import java.util.TreeSet;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.jfree.data.time.Millisecond;
import org.jfree.data.time.TimeSeries;

/**
 * Holds a list of {@link MetricValue}s and provides binning
 * functionality
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 */
public class SampleList {
	private static final Log log = LogFactory.getLog(SampleList.class);

	private class Sample implements Comparable<Sample>{
		public long time = 0;
		public double value = 0.0;
		
		public Sample(long time, double value) {
			this.time = time;
			this.value = value;
		}
		
		public int compareTo(Sample o) {
			return(int) ( this.time - o.time );
		}

		/* (non-Javadoc)
		 * @see java.lang.Object#equals(java.lang.Object)
		 */
		@Override
		public boolean equals(Object obj) {
			return this.time == ((Sample)obj).time;
		}
	}

	private TreeSet< Sample > samples = new TreeSet< Sample >();
	
	/**
	 * 
	 *
	 */
	public SampleList() {
	}
	
	/**
	 * Add the given metrics to the existing Sample list.
	 * Assumes all metrics in the given list are from the same
	 * JVM.
	 * 
	 * @param metrics
	 */
	public void ingest(Collection<MetricValue> metrics ){

		for (MetricValue metricValue : metrics) {
            addSample(metricValue.getTimestamp().getTime(), metricValue.getValue());
		}
	}

	/**
	 * Add a sample to the list.
	 * If a sample already exists with the same timestamp, it
	 * is replaced.  This results in some loss of data, but it should
	 * be rare to have two samples with the exact same timestamp.
	 * 
	 * @param timestamp
	 * @param value
	 */
	public void addSample( long timestamp, double value ){
		Sample newSample = new Sample( timestamp, value );
		samples.add( newSample );
	}
	
	/**
	 * 
	 * @param binSizeMillis
	 */
	public void bin( long binSizeMillis ){
		if( samples.size() == 0 ){
			log.warn("sample list empty!  No bin for you!");
			return;
		}
		
		Iterator< Sample > sampleIterator = samples.iterator();
		Sample currentSample = sampleIterator.next();
		TreeSet< Sample > newList = new TreeSet< Sample >();
		long thisBinStart = samples.first().time;
		long lastSampleTime = samples.last().time;
		long nextBinStart = thisBinStart + binSizeMillis;
		long currentBinMid = (thisBinStart + nextBinStart) / 2;
		double sum = 0.0;
		double count = 0.0;

		log.info("START binning, input set size=" + samples.size());

		while( thisBinStart < lastSampleTime ){
			if( currentSample.time >= nextBinStart ){
				// end of bin
				log.debug("end of bin, count=" + count);
				if( count > 0.0 ){
					// at least one sample in this bin, store the average
					log.debug("adding sample @" + new Date(currentBinMid) + " = " + sum/count );
					newList.add( new Sample(currentBinMid, sum/count ));
				}
				thisBinStart = nextBinStart;
				nextBinStart = thisBinStart + binSizeMillis;
				currentBinMid = (thisBinStart + nextBinStart) / 2;
				log.debug("new bin start = " + new Date( thisBinStart ));
				sum = 0.0;
				count = 0.0;
			}else{
				sum += currentSample.value;
				count += 1.0;
				if( sampleIterator.hasNext() ){
					currentSample = sampleIterator.next();
				}else{
					break; // no more samples
				}
			}
		}
		
		
		
//		for (Sample sample : samples) {
//			log.debug("sample.time = " + new Date( sample.time ));
//			if( sample.time >= nextBinStart ){
//				// end of bin
//				log.debug("end of bin, count=" + count);
//				if( count > 0.0 ){
//					// at least one sample in this bin, store the average
//					log.debug("adding sample @" + new Date(currentBinMid) + " = " + sum/count );
//					newList.add( new Sample(currentBinMid, sum/count ));
//				}
//				thisBinStart = nextBinStart;
//				nextBinStart = thisBinStart + binSizeMillis;
//				currentBinMid = (thisBinStart + nextBinStart) / 2;
//				log.debug("new bin start = " + new Date( thisBinStart ));
//				sum = 0.0;
//				count = 0.0;
//			}
//			
//			sum += sample.value;
//			count += 1.0;
//		}
		
		log.info("END binning, output set size=" + newList.size());

		samples = newList;
	}
	
	/**
	 * 
	 * @param name
	 * @return
	 */
	public TimeSeries asTimeSeries( String name ){
		@SuppressWarnings("deprecation")
        TimeSeries series = new TimeSeries( name, Millisecond.class );
		
		for (Sample sample : samples) {
			series.addOrUpdate( new Millisecond(new Date( sample.time )), new Double(sample.value));
		}
		
		return series;
	}

	public int size() {
		return samples.size();
	}
}
