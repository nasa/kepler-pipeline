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
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Sandbox tool to retrieve DR_PIXEL_LOG data for a specified cadence or MJD
 * range
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class SbtRetrieveCadenceLogs extends AbstractSbt {
    static final Log log = LogFactory.getLog(SbtRetrieveCadenceLogs.class);

    public static final String SDF_FILE_NAME = "/tmp/sbt-rcl.sdf";
    private static final boolean REQUIRES_DATABASE = true;
    private static final boolean REQUIRES_FILESTORE = false;

    private static class PixelLogResults {
        public List<PixelLog> pixelLogs;
    }

    public SbtRetrieveCadenceLogs() {
        super(REQUIRES_DATABASE, REQUIRES_FILESTORE);
    }

    public String retrieveCadenceLogsByCadence(int startCadence,
        int endCadence, String cadenceType) throws Exception {
        if (!validateDatastores()) {
            return "";
        }

        TicToc.tic("Retrieving cadence logs...");

        LogCrud logCrud = new LogCrud();
        PixelLogResults results = new PixelLogResults();

        results.pixelLogs = logCrud.retrievePixelLog(
            CadenceType.valueOf(cadenceType)
                .intValue(), DataSetType.Target, startCadence, endCadence);

        TicToc.toc();

        return makePixelLogSdf(results, SDF_FILE_NAME);
    }

    public String retrieveCadenceLogsByMjd(double startMjd, double endMjd,
        String cadenceType) throws Exception {
        if (!validateDatastores()) {
            return "";
        }

        log.info("Retrieving cadence logs...");

        LogCrud logCrud = new LogCrud();
        PixelLogResults results = new PixelLogResults();

        results.pixelLogs = logCrud.retrievePixelLog(
            CadenceType.valueOf(cadenceType)
                .intValue(), DataSetType.Target, startMjd, endMjd);

        return makePixelLogSdf(results, SDF_FILE_NAME);
    }

    private String makePixelLogSdf(PixelLogResults results, String sdfPath)
        throws FileNotFoundException, IOException, Exception {
        for (PixelLog pixelLog : results.pixelLogs) {
            if (pixelLog.getFitsFilename() == null) {
                pixelLog.setFitsFilename("");
            }
            if (pixelLog.getDatasetName() == null) {
                pixelLog.setDatasetName("");
            }
            if (pixelLog.getBaselineImageRootname() == null) {
                pixelLog.setBaselineImageRootname("");
            }
            if (pixelLog.getResidualBaselineImageRootname() == null) {
                pixelLog.setResidualBaselineImageRootname("");
            }
        }

        return makeSdf(results, sdfPath);
    }

    public static void main(String[] args) throws Exception {

        SbtRetrieveCadenceLogs sbt = new SbtRetrieveCadenceLogs();
        String path = sbt.retrieveCadenceLogsByCadence(2965, 7318, "LONG");
        System.out.println("path=" + path);
    }
}
