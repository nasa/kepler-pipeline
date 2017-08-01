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

package gov.nasa.kepler.cal;

import java.io.File;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Set;

import com.jmatio.io.MatFileWriter;
import com.jmatio.types.MLArray;
import com.jmatio.types.MLDouble;

import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.SciencePixelOperations;

/**
 * Dumps the pixel coordinates for target and background pixels.
 * 
 * @author Sean McCauliff
 *
 */
public class PixelCoordinates {

    /**
     * @param args
     */
    public static void main(String[] argv) throws Exception {
        int ccdModule = Integer.parseInt(argv[0]);
        int ccdOutput = Integer.parseInt(argv[1]);
        int startCadence = Integer.parseInt(argv[2]);
        int endCadence = Integer.parseInt(argv[3]);
        
        TargetCrud targetCrud = new TargetCrud();
        
        List<TargetTableLog> targetTableLogs = 
            targetCrud.retrieveTargetTableLogs(TargetType.LONG_CADENCE,
            startCadence, endCadence);
        
        if (targetTableLogs.size() != 1) {
            throw new IllegalStateException("Should have only found 1 target" +
            		" table log but found " + targetTableLogs.size());
        }
        TargetTable lcTargetTable = targetTableLogs.get(0).getTargetTable();
        
        List<TargetTableLog> bkgLogList = targetCrud.retrieveTargetTableLogs(TargetType.BACKGROUND,
            startCadence, endCadence);
        
        if (bkgLogList.size() != 1) {
            throw new IllegalStateException("Should have found only one background" +
                " target table log, bug found " + bkgLogList.size());
        }
        
        TargetTable bgTargetTable =  bkgLogList.get(0).getTargetTable();
        SciencePixelOperations sciOps = 
            new SciencePixelOperations(lcTargetTable, bgTargetTable, ccdModule, ccdOutput);
        
        Set<Pixel> bgPixels = sciOps.getBackgroundPixels();
        
        double[][] pixelCoordinates = new double[bgPixels.size()][2];
        int i=0;
        for (Pixel pixel : bgPixels) {
            pixelCoordinates[i][0] = pixel.getRow();
            pixelCoordinates[i++][1] = pixel.getColumn();
        }
        MLDouble bgPixelCoordinates = new MLDouble("bgPixelCoord", pixelCoordinates);
        
        File outputFile = new File("bkg.pixel.coordinates." + ccdModule + "." + 
            ccdOutput + "." + startCadence + "." + endCadence+".mat");
        Collection<MLArray> outputArrays = new ArrayList<MLArray>();
        outputArrays.add(bgPixelCoordinates);
        new MatFileWriter(outputFile,outputArrays);

    }

}
