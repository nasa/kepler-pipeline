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

package gov.nasa.kepler.dr.importer;

import gov.nasa.kepler.dr.dispatch.FileWatcher;
import gov.nasa.kepler.dr.dispatch.NmFileOps;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.io.FileUtil;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.io.FileUtils;

/**
 * This class drcopies moc models along with metadata about the models.
 * 
 * @author Miles Cote
 * 
 */
public class MocModelDrCopier {

    private static final String METADATA_DELIMITER = "\n";

    public static final String MODEL_METADATA_FILE_NAME = "model-metadata.txt";

    private final NmFileOps nmFileOps;
    private final PegUrlFactory pegUrlFactory;

    public MocModelDrCopier(NmFileOps nmFileOps, PegUrlFactory pegUrlFactory) {
        this.nmFileOps = nmFileOps;
        this.pegUrlFactory = pegUrlFactory;
    }

    public void drCopyMocModel(File localSvnNmFile, String description)
        throws Exception {
        File localSvnDir = localSvnNmFile.getParentFile();
        if (!localSvnDir.exists() || !localSvnDir.isDirectory()) {
            throw new IllegalArgumentException(
                "localSvnDir does not exist or is not a directory.\n  localSvnDir: "
                    + localSvnDir);
        }

        String pegUrl = pegUrlFactory.create(localSvnDir.getAbsolutePath());

        drCopyMocModel(localSvnNmFile, pegUrl, description);
    }

    public void drCopyMocModel(File localNmFile, String pegUrl,
        String description) throws Exception {
        File localDir = localNmFile.getParentFile();
        if (!localDir.exists() || !localDir.isDirectory()) {
            throw new IllegalArgumentException(
                "localDir does not exist or is not a directory.\n  localDir: "
                    + localDir);
        }

        File nmMetadataDir = getNmMetadataDir(localNmFile);
        FileUtil.cleanDir(nmMetadataDir);

        FileUtils.copyDirectory(localDir, nmMetadataDir);

        File modelMetadataFile = new File(nmMetadataDir,
            MODEL_METADATA_FILE_NAME);
        BufferedWriter writer = new BufferedWriter(new FileWriter(
            modelMetadataFile));
        writer.write(formatModelMetadata(pegUrl, description));
        writer.close();

        nmFileOps.drCopy(localNmFile.getAbsolutePath());
    }

    public static String formatModelMetadata(String pegUrl, String description) {
        return pegUrl + METADATA_DELIMITER + description + METADATA_DELIMITER;
    }

    public static Pair<String, String> parseModelMetadata(String string) {
        String[] strings = string.split(METADATA_DELIMITER);
        if (strings.length != 2) {
            throw new IllegalArgumentException(
                "Illegal model metadata format:\n" + string);
        }

        return Pair.of(strings[0], strings[1]);
    }

    public static File getNmMetadataDir(File nmFile) {
        Configuration configService = ConfigurationServiceFactory.getInstance();
        String incomingDirectoryString = configService.getString(FileWatcher.INCOMING_DIR_PROP);
        File incomingDirectory = new File(incomingDirectoryString);
        File drWorkingDir = incomingDirectory.getParentFile();

        File drModelMetadataDir = new File(drWorkingDir, "model-metadata");

        File nmMetadataDir = new File(drModelMetadataDir, nmFile.getName());

        return nmMetadataDir;
    }

    public static void main(String[] args) throws Exception {
        MocModelDrCopier mocModelDrCopier = new MocModelDrCopier(
            new NmFileOps(), new PegUrlFactory());

        if (args.length == 4) {
            mocModelDrCopier.drCopyMocModel(new File(args[0]), args[1] + "@"
                + args[2], args[3]);
        } else if (args.length == 2) {
            mocModelDrCopier.drCopyMocModel(new File(args[0]), args[1]);
        } else {
            System.err.println("Here are the valid modes of operation:\n");
            System.err.println("USAGE: drcopy-moc-model LOCAL_SVN_NM_PATH DESCRIPTION");
            System.err.println("EXAMPLE: drcopy-moc-model /path/to/models/file_senm.xml "
                + "\"Comment\"\n");
            System.err.println("USAGE: drcopy-moc-model LOCAL_NM_PATH NM_SVN_URL NM_SVN_REVISION DESCRIPTION");
            System.err.println("EXAMPLE: drcopy-moc-model /path/to/model/file_senm.xml "
                + "svn+ssh://host/path/to/data/file_senm.xml 1234 "
                + "\"Comment\"\n");
            System.exit(-1);
        }

        System.exit(0);
    }

}
