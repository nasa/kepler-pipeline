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
import gov.nasa.kepler.common.persistable.MatPersistableOutputStream;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.BlobSeriesType;
import gov.nasa.kepler.systest.sbt.data.SbtBlobSeries;
import gov.nasa.kepler.systest.sbt.data.SbtBlobSeriesOperations;

import java.io.File;

/**
 * Sandbox tool to retrieve all raw data and pipeline products associated with a
 * specified Kepler ID or list of Kepler IDs.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class SbtRetrieveBlobSeries {

    private static final String MAT_FILE_NAME = "sbt.mat";
    private static final boolean REQUIRES_DATABASE = true;
    private static final boolean REQUIRES_FILESTORE = true;

    public SbtRetrieveBlobSeries() {
    }

    public static String retrieveBlobSeries(int ccdModule, int ccdOutput,
        int startCadence, int endCadence, String blobType) throws Exception {

        if (! new AbstractSbt(REQUIRES_DATABASE, REQUIRES_FILESTORE).validateDatastores()) {
            return "";
        }
        
        SbtBlobSeriesOperations sbtOperations = new SbtBlobSeriesOperations();

        System.out.println("Retrieving blobs...");

        BlobSeriesType blobSeriesType = BlobSeriesType.valueOf(blobType);
        SbtBlobSeries blobs = sbtOperations.retrieveSbtBlobSeries(
            blobSeriesType, ccdModule, ccdOutput, CadenceType.LONG,
            startCadence, endCadence);

        System.out.println("Generating .mat file...");

        File matFile = new File("/tmp", MAT_FILE_NAME);
        MatPersistableOutputStream mpos = new MatPersistableOutputStream(
            matFile);
        System.out.println("Saving: " + matFile);
        mpos.save(blobs);

        System.out.println("DONE Generating .mat file");

        return matFile.getCanonicalPath();
    }

    public static void main(String[] args) throws Exception {
        String path = SbtRetrieveBlobSeries.retrieveBlobSeries(2, 1, 2965,
            7318, "BACKGROUND");
        System.out.println("path=" + path);
    }
}
