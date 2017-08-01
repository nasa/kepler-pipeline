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

import static com.google.common.collect.Maps.newHashMap;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.Map;
import java.util.Set;

/**
 * Writes and reads {@link FsId}s.
 * 
 * @author Miles Cote
 * 
 */
public class FsIdsStream {

    private static final String FILE_EXTENSION = ".ser";

    private Map<DataSetType, Integer> dataSetTypeToWriteCount = newHashMap();
    private Map<DataSetType, Integer> dataSetTypeToReadCount = newHashMap();

    public void write(DataSetType dataSetType, File workingDir, Set<FsId> fsIds) {
        try {
            Integer writeCount = getWriteCount(dataSetType);

            String fileName = getFileName(dataSetType, writeCount);
            FileOutputStream fos = new FileOutputStream(new File(workingDir,
                fileName));
            ObjectOutputStream oos = new ObjectOutputStream(fos);
            oos.writeObject(fsIds);
            oos.flush();
            oos.close();
        } catch (Exception e) {
            throw new IllegalArgumentException("Unable to write.", e);
        }
    }

    private Integer getWriteCount(DataSetType dataSetType) {
        Integer writeCount = dataSetTypeToWriteCount.get(dataSetType);
        if (writeCount == null) {
            writeCount = 0;
        } else {
            writeCount++;
        }

        dataSetTypeToWriteCount.put(dataSetType, writeCount);

        return writeCount;
    }

    private String getFileName(DataSetType dataSetType, Integer count) {
        return dataSetType + "-" + count + FILE_EXTENSION;
    }

    public Set<FsId> read(DataSetType dataSetType, File workingDir) {
        try {
            Integer readCount = getReadCount(dataSetType);

            String fileName = getFileName(dataSetType, readCount);
            FileInputStream fis = new FileInputStream(new File(workingDir,
                fileName));
            ObjectInputStream ois = new ObjectInputStream(fis);
            @SuppressWarnings("unchecked")
            Set<FsId> fsIds = (Set<FsId>) ois.readObject();
            ois.close();

            return fsIds;
        } catch (Exception e) {
            throw new IllegalArgumentException("Unable to read.", e);
        }
    }

    private Integer getReadCount(DataSetType dataSetType) {
        Integer readCount = dataSetTypeToReadCount.get(dataSetType);
        if (readCount == null) {
            readCount = 0;
        } else {
            readCount++;
        }

        dataSetTypeToReadCount.put(dataSetType, readCount);

        return readCount;
    }

}
