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

package gov.nasa.kepler.systest.sbt;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.TicToc;
import gov.nasa.kepler.common.persistable.SdfPersistableOutputStream;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.systest.sbt.data.PipelineProductLists;
import gov.nasa.kepler.systest.sbt.data.PixelCoordinateSystemConverter;
import gov.nasa.kepler.systest.sbt.data.PixelCoordinateSystemConverterToOneBased;
import gov.nasa.kepler.systest.sbt.data.PixelCoordinateSystemConverterToZeroBased;
import gov.nasa.kepler.systest.sbt.data.SbtData;
import gov.nasa.kepler.systest.sbt.data.SbtDataOperations;
import gov.nasa.spiffy.common.io.FileUtil;

import java.io.BufferedOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Sandbox tool to retrieve all raw data and pipeline products associated with a
 * specified Kepler ID or list of Kepler IDs.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class SbtRetrieveTargetData {
    static final Log log = LogFactory.getLog(SbtRetrieveTargetData.class);

    public static final String SDF_FILE_NAME = "/tmp/sbt-rtd.sdf";
    private static final boolean REQUIRES_DATABASE = true;
    private static final boolean REQUIRES_FILESTORE = true;

    public SbtRetrieveTargetData() {
    }

    public static String retrieveTargetData(int[] keplerIds, int startCadence,
        int endCadence, String cadenceType,
        String pixelCoordinateBaseDescription, String[] includeList,
        String[] excludeList, int debugLevel) throws Exception {

        if (keplerIds == null || keplerIds.length == 0) {
            throw new IllegalArgumentException("keplerIds cannot be empty.");
        }

        if (!new AbstractSbt(REQUIRES_DATABASE, REQUIRES_FILESTORE).validateDatastores()) {
            return "";
        }

        try {
            closeFilestoreConnection();

            PixelCoordinateSystemConverter pixelCoordinateSystemConverter = null;
            if (pixelCoordinateBaseDescription.toLowerCase()
                .equals("zero-based")) {
                pixelCoordinateSystemConverter = new PixelCoordinateSystemConverterToZeroBased();
            } else if (pixelCoordinateBaseDescription.toLowerCase()
                .equals("one-based")) {
                pixelCoordinateSystemConverter = new PixelCoordinateSystemConverterToOneBased();
            } else {
                throw new IllegalArgumentException(
                    "The pixelCoordinateBaseDescription must be either 'zero-based' or 'one-based'.\n  pixelCoordinateBaseDescription: "
                        + pixelCoordinateBaseDescription);
            }

            SbtDataOperations sbtOperations = new SbtDataOperations();

            List<Integer> keplerIdList = new ArrayList<Integer>(
                keplerIds.length);
            for (int keplerId : keplerIds) {
                keplerIdList.add(keplerId);
            }

            TicToc.setLevel(debugLevel);
            TicToc.tic("Retrieving target data");

            SbtData targetData = sbtOperations.retrieveSbtData(keplerIdList,
                CadenceType.valueOf(cadenceType.toUpperCase()), startCadence,
                endCadence, pixelCoordinateSystemConverter,
                new PipelineProductLists(includeList, excludeList));

            TicToc.toc();

            TicToc.tic("Generating .sdf file...");

            File sdfFile = new File(SDF_FILE_NAME);
            FileOutputStream fos = new FileOutputStream(sdfFile);
            BufferedOutputStream bos = new BufferedOutputStream(fos);
            DataOutputStream dos = new DataOutputStream(bos);

            SdfPersistableOutputStream spos = new SdfPersistableOutputStream(
                dos);

            spos.save(targetData);
            dos.close();

            TicToc.toc();

            return sdfFile.getCanonicalPath();
        } finally {
            closeFilestoreConnection();
        }
    }

    private static void closeFilestoreConnection() {
        FileStoreClient instance = FileStoreClientFactory.getInstance();
        FileUtil.close(instance);
    }

    public static void main(String[] args) throws Exception {

        // hatp7 = retrieve_target_data(10666592, 2965,7318,'LONG','one-based')
        String path = SbtRetrieveTargetData.retrieveTargetData(
            new int[] { 5094751 }, 20579, 20728, "LONG", "one-based",
            new String[] {}, new String[] { "TPS" }, 0);
        System.out.println("path=" + path);
    }
}
