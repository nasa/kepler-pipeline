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

package gov.nasa.kepler.ar.exporter;

import static org.junit.Assert.*;

import gov.nasa.kepler.ar.archive.TargetDva;

import java.util.Arrays;

import org.junit.Test;

public class PositionCorrectionFilterTest {

    @Test
    public void positionCorrectionFitlerTest() throws Exception {
        
        int[] dataQualityFlags = new int[128];
        int goodFlags = ~(QualityFieldCalculator.DESAT |
            QualityFieldCalculator.COARSE_POINT |
            QualityFieldCalculator.DETECTOR_ELECTRONICS_ANOMALY |
            QualityFieldCalculator.EARTH_POINT | 
            QualityFieldCalculator.ARGABRIGHTENING | 
            QualityFieldCalculator.SAFE_MODE);
        Arrays.fill(dataQualityFlags, goodFlags);
        dataQualityFlags[1] = QualityFieldCalculator.DESAT;
        
        float[] originalRow = new float[dataQualityFlags.length];
        float[] originalColumn = new float[dataQualityFlags.length];
        float[] expectedRow = new float[originalRow.length];
        float[] expectedColumn = new float[originalColumn.length];
        
        for (int i=0; i < originalRow.length; i++)  {
            originalRow[i] = (i+1);
            expectedRow[i] = (i+1);
            originalColumn[i] = (i+2);
            expectedColumn[i] = (i+2);
        }
        
        expectedColumn[1] = Float.NaN;
        expectedRow[1] = Float.NaN;
        
        TargetDva originalPositions = 
            new TargetDva(2, originalColumn, new boolean[originalColumn.length],
                          originalRow, new boolean[originalRow.length]);
        PositionCorrectionFilter positionCorrectionFilter = new PositionCorrectionFilter();
        
        TargetDva filtered = positionCorrectionFilter.positionCorrectionFilter(originalPositions, dataQualityFlags);
        
        filtered.fillGaps(Float.NaN);
        assertTrue(Arrays.equals(expectedRow, filtered.getRowDva()));
        assertTrue(Arrays.equals(expectedColumn, filtered.getColumnDva()));
    }
}
