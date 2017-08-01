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

package gov.nasa.kepler.fs.server.xfiles;

import java.io.File;

import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;

/**
 * @author Sean McCauliff
 *
 */
public class MjdTimeSeriesTestData {
	public final double[] mjd = new double[1024*8];
	public final float[] values = new float[mjd.length];
	public final long[] originators =new long[mjd.length];
	public final FloatMjdTimeSeries series;
	
	//Write values that are interleaved between the values written.
	public final double[] mjd2 = new double[mjd.length];
	public final float[] values2 = new float[mjd2.length];
	public final long[] originators2 = new long[mjd2.length];
	public final double sqrt2 = Math.sqrt(2.0);
	
	
	public final FloatMjdTimeSeries middle;
	
	
	public final double[] combinedMjd = new double[mjd.length * 2];
	public final float[] combinedValues = new float[combinedMjd.length];
	public final long[] combinedOriginators = new long[combinedMjd.length];
	
	
	public final FloatMjdTimeSeries combinedSeries; 
	
	public MjdTimeSeriesTestData(FsId id) {
		for (int i=0; i < mjd.length; i++) {
			mjd[i] = Math.PI * (i+1);
			values[i] =(float) Math.E * (i + 1);
			originators[i] = Long.MAX_VALUE - i;
		}
		series = 
			new FloatMjdTimeSeries(id, -Double.MIN_VALUE, Double.MAX_VALUE,
					mjd, values, originators, true);
		
		for (int i=0; i < mjd2.length; i++) {
			mjd2[i] = Math.PI * (i + 1 + 0.5);
			values2[i] = (float) sqrt2 * (i + 1);
			originators2[i] = 2L;
		}
		
		 middle = new FloatMjdTimeSeries(id, -Double.MIN_VALUE, Double.MAX_VALUE, mjd2, values2, originators2, true);

		 for (int i=0; i < combinedMjd.length; i++) {
				boolean first = (i & 0x01) == 0;
				int srcIndex = i / 2;
				combinedMjd[i]= first ? mjd[srcIndex] : mjd2[srcIndex];
				combinedValues[i] = first ? values[srcIndex] : values2[srcIndex];
				combinedOriginators[i] = first ? originators[srcIndex] : originators2[srcIndex];
			}
			
		 combinedSeries = new FloatMjdTimeSeries(id, -Double.MIN_VALUE, Double.MAX_VALUE, combinedMjd, combinedValues, combinedOriginators, true);
			
	}
}
