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
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.common.intervals.BlobFileSeriesFactory;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.BlobSeriesType;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.jmock.JMockTest;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.io.File;
import java.io.FileOutputStream;
import java.util.List;

import org.junit.Test;

public class SbtBlobSeriesOperationsTest extends JMockTest {

    @SuppressWarnings("unchecked")
    @Test
    public void testRetrieve() throws Exception {
        final BlobSeriesType blobSeriesType = BlobSeriesType.BACKGROUND;

        final int ccdModule = 2;
        final int ccdOutput = 3;

        final CadenceType cadenceType = CadenceType.LONG;
        final int startCadence = 5;
        final int endCadence = 6;

        final int[] blobIndices = new int[] { 0, 0 };
        final boolean[] gapIndicators = new boolean[] { false, false };

        final byte[] bytes = new byte[] { 2 };

        final File file = new File("tempfile.tmp");

        final String[] fileNames = new String[] { file.getName() };

        final BlobSeries<String> blobSeries = mock(BlobSeries.class);

        final BlobFileSeries blobFileSeries = new BlobFileSeries(blobIndices,
            gapIndicators, fileNames, startCadence, endCadence);

        final BlobOperations blobOperations = mock(BlobOperations.class);
        final BlobFileSeriesFactory blobFileSeriesFactory = mock(BlobFileSeriesFactory.class);
        final LogCrud logCrud = mock(LogCrud.class);

        allowing(blobOperations).retrieveBackgroundBlobFileSeries(ccdModule,
            ccdOutput, startCadence, endCadence);
        will(returnValue(blobSeries));

        allowing(blobFileSeriesFactory).create(blobSeries);
        will(returnValue(blobFileSeries));

        // Write bytes to file.
        FileOutputStream os = new FileOutputStream(file);
        os.write(bytes);
        os.close();

        SbtBlobSeriesOperations sbtBlobSeriesOperations = new SbtBlobSeriesOperations(
            blobOperations, blobFileSeriesFactory, logCrud);
        SbtBlobSeries actualSbtBlobSeries = sbtBlobSeriesOperations.retrieveSbtBlobSeries(
            blobSeriesType, ccdModule, ccdOutput, cadenceType, startCadence,
            endCadence);

        List<SbtBlob> expectedSbtBlobs = newArrayList();
        expectedSbtBlobs.add(new SbtBlob(startCadence, endCadence, bytes));

        SbtBlobSeries expectedSbtBlobSeries = new SbtBlobSeries(
            blobSeriesType.toString(), blobIndices, gapIndicators,
            cadenceType.toString(), startCadence, endCadence, expectedSbtBlobs);

        ReflectionEquals reflectionEquals = new ReflectionEquals();
        reflectionEquals.assertEquals(expectedSbtBlobSeries,
            actualSbtBlobSeries);

        assertTrue(!file.exists());
    }

    @SuppressWarnings("unchecked")
    @Test
    public void testRetrieveBackgroundForShortCadence() throws Exception {
        final BlobSeriesType blobSeriesType = BlobSeriesType.BACKGROUND;

        final int ccdModule = 2;
        final int ccdOutput = 3;

        final CadenceType cadenceType = CadenceType.SHORT;
        final int startCadence = 5;
        final int endCadence = 6;

        final CadenceType cadenceTypeLong = CadenceType.LONG;
        final int startCadenceLong = 7;
        final int endCadenceLong = 8;

        final int[] blobIndices = new int[] { 0, 0 };
        final boolean[] gapIndicators = new boolean[] { false, false };

        final byte[] bytes = new byte[] { 2 };

        final File file = new File("tempfile.tmp");

        final String[] fileNames = new String[] { file.getName() };

        final BlobSeries<String> blobSeries = mock(BlobSeries.class);

        final BlobFileSeries blobFileSeries = new BlobFileSeries(blobIndices,
            gapIndicators, fileNames, startCadenceLong, endCadenceLong);

        final BlobOperations blobOperations = mock(BlobOperations.class);
        final BlobFileSeriesFactory blobFileSeriesFactory = mock(BlobFileSeriesFactory.class);
        final LogCrud logCrud = mock(LogCrud.class);

        allowing(blobOperations).retrieveBackgroundBlobFileSeries(ccdModule,
            ccdOutput, startCadenceLong, endCadenceLong);
        will(returnValue(blobSeries));

        allowing(blobFileSeriesFactory).create(blobSeries);
        will(returnValue(blobFileSeries));

        allowing(logCrud).shortCadenceToLongCadence(startCadence, endCadence);
        will(returnValue(Pair.of(startCadenceLong, endCadenceLong)));

        // Write bytes to file.
        FileOutputStream os = new FileOutputStream(file);
        os.write(bytes);
        os.close();

        SbtBlobSeriesOperations sbtBlobSeriesOperations = new SbtBlobSeriesOperations(
            blobOperations, blobFileSeriesFactory, logCrud);
        SbtBlobSeries actualSbtBlobSeries = sbtBlobSeriesOperations.retrieveSbtBlobSeries(
            blobSeriesType, ccdModule, ccdOutput, cadenceType, startCadence,
            endCadence);

        List<SbtBlob> expectedSbtBlobs = newArrayList();
        expectedSbtBlobs.add(new SbtBlob(startCadenceLong, endCadenceLong,
            bytes));

        SbtBlobSeries expectedSbtBlobSeries = new SbtBlobSeries(
            blobSeriesType.toString(), blobIndices, gapIndicators,
            cadenceTypeLong.toString(), startCadenceLong, endCadenceLong,
            expectedSbtBlobs);

        ReflectionEquals reflectionEquals = new ReflectionEquals();
        reflectionEquals.assertEquals(expectedSbtBlobSeries,
            actualSbtBlobSeries);

        assertTrue(!file.exists());
    }

}
