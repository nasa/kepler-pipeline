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

package gov.nasa.kepler.tip;

import gov.nasa.kepler.common.SvnUtils;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.TransactionService;
import gov.nasa.kepler.hibernate.dbservice.TransactionServiceFactory;
import gov.nasa.kepler.hibernate.pi.ModelMetadataCrud;
import gov.nasa.kepler.hibernate.tip.TipBlobMetadata;
import gov.nasa.kepler.hibernate.tip.TipCrud;
import gov.nasa.kepler.mc.blob.BlobOperations;

import java.io.File;
import java.io.FileFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.io.FilenameUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.tmatesoft.svn.core.SVNException;

public class TipImporter {

    private static final Log log = LogFactory.getLog(TipImporter.class);

    public static final String MODEL_TYPE = "TRANSIT_INJECTION";
    public static final String DATAFILE_REGEX = "kplr\\d+-(\\d\\d)_tip.txt";

    private File dataDirectory;
    private String description;
    private ModelMetadataCrud modelMetadataCrud = new ModelMetadataCrud();
    private TipCrud tipCrud = new TipCrud();

    public TipImporter(File dataDirectory, String description) {

        this.dataDirectory = dataDirectory;
        this.description = description;
    }

    /**
     * @param args
     */
    public static void main(String[] args) {

        if (args.length != 2) {
            log.error("missing required args.");
            usage();
        }

        File dataDirectory = new File(args[0]);
        if (!dataDirectory.isDirectory()) {
            log.error(args[0] + ": not a directory");
            usage();
        }

        TransactionService transactionService = TransactionServiceFactory.getInstance();

        try {
            transactionService.beginTransaction(true, false, true);

            new TipImporter(dataDirectory, args[1]).importData();

            transactionService.commitTransaction();
        } catch (Exception e) {
            log.error("import failed: " + e.getMessage(), e);
        } finally {
            transactionService.rollbackTransactionIfActive();
        }
    }

    private void importData() throws IOException {
        log.info("importData ...");

        long nowSeconds = (long) Math.floor((double) (new Date()).getTime() / 1000);
        Date now = new Date(nowSeconds * 1000);

        String revision = null;
        try {
            revision = SvnUtils.getSvnInfoForDirectory(dataDirectory.getPath());
        } catch (SVNException e) {
            throw new IllegalArgumentException(e.getMessage(), e);
        }

        List<TipBlobMetadata> tipBlobMetadataList = new ArrayList<TipBlobMetadata>();
        for (File tipFile : dataDirectory.listFiles(new FileFilter() {
            @Override
            public boolean accept(File file) {
                return !file.isDirectory()
                    && Pattern.matches(DATAFILE_REGEX, file.getName());
            }
        })) {
            log.info("importing file " + tipFile.getPath());

            Matcher matcher = getMatcher(tipFile.getName());

            TipBlobMetadata tipBlobMetadata = new TipBlobMetadata(
                now.getTime(), Integer.valueOf(matcher.group(1)),
                FilenameUtils.getExtension(tipFile.getName()));
            tipBlobMetadataList.add(tipBlobMetadata);

            FileStoreClientFactory.getInstance()
                .writeBlob(BlobOperations.getFsId(tipBlobMetadata), 0, tipFile);
        }
        tipCrud.createTipBlobMetadata(tipBlobMetadataList);

        modelMetadataCrud.updateModelMetaData(MODEL_TYPE, description, now,
            revision);
        log.info("importData ... done");
    }

    private static void usage() {
        System.err.println("USAGE: import-tip DIRECTORY DESCRIPTION");
        System.err.println("EXAMPLE: import-tip /path/to/rec/soc/transit-injection/v1 \"Added initial version of the transit injection parameters.\"");
        System.exit(1);
    }

    private Matcher getMatcher(String filename) throws IOException {
        Matcher matcher = Pattern.compile(DATAFILE_REGEX)
            .matcher(filename);
        matcher.find();
        if (1 != matcher.groupCount()) {
            throw new IOException("bad filename, expected 1 match: " + filename
                + ", there are " + matcher.groupCount());
        }
        return matcher;
    }
}
