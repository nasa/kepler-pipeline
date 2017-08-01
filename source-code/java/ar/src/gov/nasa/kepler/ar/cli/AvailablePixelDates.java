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

package gov.nasa.kepler.ar.cli;

import static gov.nasa.kepler.common.ModifiedJulianDate.mjdToDate;
import gov.nasa.kepler.ar.exporter.Iso8601Formatter;
import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * Displays the dates for which we have pixels available for export.
 * @author Sean McCauliff
 *
 */
public class AvailablePixelDates {

	/**
	 * @param argv
	 */
	public static void main(String[] argv) throws Exception {
		LogCrud logCrud = new LogCrud();
		TargetCrud targetCrud = new TargetCrud();
		
		System.out.println("Known long cadence target tables with received data.");
		System.out.println("        Id  Season Quarter Cadence MidMjd            UTC");
		
		Iso8601Formatter isoFmt = new Iso8601Formatter();
		RollTimeOperations rtOperations = new RollTimeOperations();
		List<TargetTable> targetTables =
			targetCrud.retrieveUplinkedTargetTables(TargetType.LONG_CADENCE);
		
		Collections.sort(targetTables, new Comparator<TargetTable>() {

			@Override
			public int compare(TargetTable o1, TargetTable o2) {
				return o1.getPlannedStartTime().compareTo(o2.getPlannedStartTime());
			}
			
		});
		
		for (TargetTable ttable : targetTables) {
			int externalId = ttable.getExternalId();
			//Pair<Double,Double> actualTimes = 
			//	logCrud.retrieveActualObservationTimeForTargetTable(externalId, TargetType.LONG_CADENCE);
			
			Pair<Integer, Integer> actualCadences =
			    logCrud.retrieveActualCadenceTimeForTargetTable(externalId, TargetType.LONG_CADENCE);
			MjdToCadence mjdToCadence = new MjdToCadence(Cadence.CadenceType.LONG, new ModelMetadataRetrieverLatest());

			double mjdMidStart = mjdToCadence.cadenceToMjd(actualCadences.left);
			double mjdMidEnd = mjdToCadence.cadenceToMjd(actualCadences.right);

			int startSeason = rtOperations.mjdToSeason(mjdMidStart);
			int endSeason = rtOperations.mjdToSeason(mjdMidEnd);
			
			int startQuarter = rtOperations.mjdToQuarter(new double[] {mjdMidStart})[0];
			int endQuarter = rtOperations.mjdToQuarter(new double[] {mjdMidEnd})[0];
			
			String startIso = isoFmt.format(mjdToDate(mjdMidStart));
			String endIso = isoFmt.format(mjdToDate(mjdMidEnd));
			
			System.out.format("  %3d Start %-6d %7d %7d %14.8f %s%n", 
					externalId, startSeason, startQuarter, actualCadences.left, 
					mjdMidStart, startIso);
			System.out.format("  %3d End   %-6d %7d %7d %14.8f %s%n",
					externalId, endSeason, endQuarter, actualCadences.right, 
					mjdMidEnd, endIso);
		}
		


		

	}

}
