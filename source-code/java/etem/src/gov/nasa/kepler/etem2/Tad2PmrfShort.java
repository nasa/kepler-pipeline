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

package gov.nasa.kepler.etem2;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.primitives.Bytes.toArray;
import static com.google.common.primitives.Ints.toArray;
import static com.google.common.primitives.Shorts.toArray;
import gov.nasa.kepler.dr.NmGenerator;
import gov.nasa.kepler.etem.CollateralPmrfFits;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;

import java.io.IOException;
import java.util.List;

import nom.tam.fits.FitsException;

public class Tad2PmrfShort extends Tad2Pmrf {

    public Tad2PmrfShort(String targetListSetName, String fitsDir,
        double startMjd, int scConfigId, String masterFitsPath,
        double secondsPerShortCadence, int shortCadencesPerLong,
        int compressionId, int badId, int bgpId, int tadId, int lctId,
        int sctId, int rptId) {

        super(targetListSetName, fitsDir, startMjd, scConfigId, masterFitsPath,
            secondsPerShortCadence, shortCadencesPerLong, compressionId, badId,
            bgpId, tadId, lctId, sctId, rptId);
    }

    @Override
    protected void exportCollateral(CollateralPmrfFits collateralDataSet,
        List<TargetDefinition> targetDefs) throws FitsException, IOException {

        ProjectionTracker projectionTracker = new ProjectionTracker();
        List<SccPmrfFitsRow> sccPmrfFitsRows = projectionTracker.getSccPmrfFitsRows(targetDefs);

        // Convert rows to columns.
        List<Byte> pixelTypeColumn = newArrayList();
        List<Short> rowOrColOffsetColumn = newArrayList();
        List<Integer> targetIdColumn = newArrayList();

        for (SccPmrfFitsRow row : sccPmrfFitsRows) {
            pixelTypeColumn.add(row.getPixelType());
            rowOrColOffsetColumn.add(row.getRowOrColOffset());
            targetIdColumn.add(row.getTargetId());
        }

        collateralDataSet.addColumns(toArray(pixelTypeColumn),
            toArray(rowOrColOffsetColumn), toArray(targetIdColumn));
    }

    @Override
    protected void exportBackground() {
        // Do nothing for short cadence. There is no background for short
        // cadence.
        return;
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 14) {
            throw new IllegalArgumentException(
                "There must be 14 args.\n  args.length: " + args.length);
        }

        String targetListSetName = args[0];
        String fitsDir = args[1];
        String startMjd = args[2];
        String scConfigId = args[3];
        String masterFitsPath = args[4];
        String secondsPerShortCadence = args[5];
        String shortCadencesPerLong = args[6];
        String compressionId = args[7];
        String badId = args[8];
        String bgpId = args[9];
        String tadId = args[10];
        String lctId = args[11];
        String sctId = args[12];
        String rptId = args[13];

        Tad2PmrfShort tad2PmrfShort = new Tad2PmrfShort(targetListSetName,
            fitsDir, Double.valueOf(startMjd), Integer.valueOf(scConfigId),
            masterFitsPath, Double.valueOf(secondsPerShortCadence),
            Integer.valueOf(shortCadencesPerLong),
            Integer.valueOf(compressionId), Integer.valueOf(badId),
            Integer.valueOf(bgpId), Integer.valueOf(tadId),
            Integer.valueOf(lctId), Integer.valueOf(sctId),
            Integer.valueOf(rptId));

        tad2PmrfShort.export();

        // Generate nm.
        NmGenerator.generateNotificationMessage(fitsDir, "tara");
    }

}
