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

package gov.nasa.kepler.systest.sbt.data;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Maps.newLinkedHashMap;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.common.intervals.BlobFileSeriesFactory;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.BlobSeriesType;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Map;

/**
 * This class retrieves {@link SbtBlobSeries}.
 * 
 * @author Miles Cote
 * 
 */
public class SbtBlobSeriesOperations {

    private final BlobOperations blobOperations;
    private final BlobFileSeriesFactory blobFileSeriesFactory;
    private final LogCrud logCrud;

    public SbtBlobSeriesOperations() {
        this(new BlobOperations(), new BlobFileSeriesFactory(), new LogCrud());
    }

    public SbtBlobSeriesOperations(BlobOperations blobOperations,
        BlobFileSeriesFactory blobFileSeriesFactory, LogCrud logCrud) {
        this.blobOperations = blobOperations;
        this.blobFileSeriesFactory = blobFileSeriesFactory;
        this.logCrud = logCrud;
    }

    public SbtBlobSeries retrieveSbtBlobSeries(BlobSeriesType blobSeriesType,
        int ccdModule, int ccdOutput, CadenceType cadenceType,
        int startCadence, int endCadence) {
        if (cadenceType.equals(CadenceType.SHORT)) {
            if (blobSeriesType.equals(BlobSeriesType.BACKGROUND)
                || blobSeriesType.equals(BlobSeriesType.MOTION)) {
                cadenceType = CadenceType.LONG;

                Pair<Integer, Integer> longCadenceInterval = logCrud.shortCadenceToLongCadence(
                    startCadence, endCadence);
                startCadence = longCadenceInterval.left;
                endCadence = longCadenceInterval.right;
            }
        }

        BlobSeries<String> blobSeries = null;
        switch (blobSeriesType) {
            case BACKGROUND:
                blobSeries = blobOperations.retrieveBackgroundBlobFileSeries(
                    ccdModule, ccdOutput, startCadence, endCadence);
                break;
            case MOTION:
                blobSeries = blobOperations.retrieveMotionBlobFileSeries(
                    ccdModule, ccdOutput, startCadence, endCadence);
                break;
            case UNCERTAINTIES:
                blobSeries = blobOperations.retrievePaUncertaintiesBlobFileSeries(
                    ccdModule, ccdOutput, cadenceType, startCadence, endCadence);
                break;
            default:
                throw new IllegalArgumentException("Unexpected type: "
                    + blobSeriesType);
        }

        BlobFileSeries blobFileSeries = blobFileSeriesFactory.create(blobSeries);
        int startCadenceBlobFileSeries = blobFileSeries.getStartCadence();
        int endCadenceBlobFileSeries = blobFileSeries.getEndCadence();
        int[] blobIndices = blobFileSeries.getBlobIndices();
        boolean[] gapIndicators = blobFileSeries.getGapIndicators();

        Map<Integer, List<Integer>> blobIndexToCadenceNumbers = newLinkedHashMap();
        for (int i = 0; i < blobIndices.length; i++) {
            int blobIndex = blobIndices[i];
            List<Integer> cadenceNumbers = blobIndexToCadenceNumbers.get(blobIndex);
            if (cadenceNumbers == null) {
                cadenceNumbers = newArrayList();
                blobIndexToCadenceNumbers.put(blobIndex, cadenceNumbers);
            }

            if (gapIndicators[i] != true) {
                cadenceNumbers.add(startCadenceBlobFileSeries + i);
            }
        }

        List<SbtBlob> sbtBlobs = newArrayList();
        for (int i = 0; i < blobFileSeries.getBlobFilenames().length; i++) {
            String fileName = blobFileSeries.getBlobFilenames()[i];
            File file = new File(fileName);

            byte[] bytes;
            try {
                bytes = getBytes(file);
            } catch (IOException e) {
                throw new IllegalStateException(
                    "Unable to get bytes for file: " + file.getName(), e);
            }

            List<Integer> cadenceNumbers = blobIndexToCadenceNumbers.get(i);
            if (!cadenceNumbers.isEmpty()) {
                sbtBlobs.add(new SbtBlob(cadenceNumbers.get(0),
                    cadenceNumbers.get(cadenceNumbers.size() - 1), bytes));
            }

            file.delete();
        }

        SbtBlobSeries sbtBlobSeries = new SbtBlobSeries(
            blobSeriesType.toString(), blobIndices, gapIndicators,
            cadenceType.toString(), startCadenceBlobFileSeries,
            endCadenceBlobFileSeries, sbtBlobs);

        return sbtBlobSeries;
    }

    private byte[] getBytes(File file) throws IOException {
        byte[] bytes = new byte[(int) file.length()];
        InputStream is = new FileInputStream(file);
        try {
            int bytesReadCount = is.read(bytes);

            if (bytesReadCount != bytes.length) {
                throw new IOException("Unable to completely read file: "
                    + file.getName());
            }
        } finally {
            is.close();
        }

        return bytes;
    }

}
