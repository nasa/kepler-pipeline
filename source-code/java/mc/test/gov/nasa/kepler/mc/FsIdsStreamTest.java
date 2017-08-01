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

package gov.nasa.kepler.mc;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.util.Set;

import org.junit.Test;

import com.google.common.collect.ImmutableSet;

/**
 * @author Miles Cote
 * 
 */
public class FsIdsStreamTest {

    private File workingDir = new File(Filenames.BUILD_TMP);

    private DataSetType dataSetType1 = DataSetType.Background;
    private DataSetType dataSetType2 = DataSetType.Target;

    private FsId fsId1 = DrFsIdFactory.getPixelFitsHeaderFile("fsId1");
    private Set<FsId> fsIds1 = ImmutableSet.of(fsId1);

    private FsId fsId2 = DrFsIdFactory.getPixelFitsHeaderFile("fsId2");
    private Set<FsId> fsIds2 = ImmutableSet.of(fsId2);

    private FsIdsStream outputStream = new FsIdsStream();
    private FsIdsStream inputStream = new FsIdsStream();

    @Test
    public void testSameTypeWriteReadWriteRead() {
        outputStream.write(dataSetType1, workingDir, fsIds1);
        Set<FsId> actualFsIds1 = inputStream.read(dataSetType1, workingDir);
        
        outputStream.write(dataSetType1, workingDir, fsIds2);
        Set<FsId> actualFsIds2 = inputStream.read(dataSetType1, workingDir);

        assertEquals(fsIds1, actualFsIds1);
        assertEquals(fsIds2, actualFsIds2);
    }

    @Test
    public void testSameTypeWriteWriteReadRead() {
        outputStream.write(dataSetType1, workingDir, fsIds1);
        outputStream.write(dataSetType1, workingDir, fsIds2);

        Set<FsId> actualFsIds1 = inputStream.read(dataSetType1, workingDir);
        Set<FsId> actualFsIds2 = inputStream.read(dataSetType1, workingDir);

        assertEquals(fsIds1, actualFsIds1);
        assertEquals(fsIds2, actualFsIds2);
    }

    @Test
    public void testDifferentTypesWriteReadWriteRead() {
        outputStream.write(dataSetType1, workingDir, fsIds1);
        Set<FsId> actualFsIds1 = inputStream.read(dataSetType1, workingDir);
        
        outputStream.write(dataSetType2, workingDir, fsIds2);
        Set<FsId> actualFsIds2 = inputStream.read(dataSetType2, workingDir);

        assertEquals(fsIds1, actualFsIds1);
        assertEquals(fsIds2, actualFsIds2);
    }

    @Test
    public void testDifferentTypesWriteWriteReadRead() {
        outputStream.write(dataSetType1, workingDir, fsIds1);
        outputStream.write(dataSetType2, workingDir, fsIds2);

        Set<FsId> actualFsIds1 = inputStream.read(dataSetType1, workingDir);
        Set<FsId> actualFsIds2 = inputStream.read(dataSetType2, workingDir);

        assertEquals(fsIds1, actualFsIds1);
        assertEquals(fsIds2, actualFsIds2);
    }

}
