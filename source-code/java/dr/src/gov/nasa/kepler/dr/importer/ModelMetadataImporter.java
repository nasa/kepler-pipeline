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
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.dr.ReceiveLog;
import gov.nasa.kepler.hibernate.pi.ModelMetadataCrud;
import gov.nasa.kepler.pi.models.ModelMetadataOperations;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.Date;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class imports model metadata from incoming files into the database.
 * 
 * @author Miles Cote
 * 
 */
public class ModelMetadataImporter {

    private static final String ALLOW_NON_EXISTENT_MODEL_METADATA = "dr.importer.allowNonExistentModelMetadata";

    private static final Log log = LogFactory.getLog(ModelMetadataImporter.class);

    private final ModelMetadataCrud modelMetadataCrud;

    public ModelMetadataImporter(ModelMetadataCrud modelMetadataCrud) {
        this.modelMetadataCrud = modelMetadataCrud;
    }

    public static boolean isMocModel(String messageFileName) {
        return messageFileName != null
            && (messageFileName.endsWith(FileWatcher.SPACECRAFT_EPHEMERIS_NOTIFICATION_MSG_EXTENSION) || messageFileName.endsWith(FileWatcher.SCLK_NOTIFICATION_MSG_EXTENSION));
    }

    public void importModelMetadata(ReceiveLog receiveLog,
        DispatcherType dispatcherType) {

        if (receiveLog != null) {
            String messageFileName = receiveLog.getMessageFileName();
            if (isMocModel(messageFileName)) {
                Configuration configService = ConfigurationServiceFactory.getInstance();
                boolean allowNonExistentModelMetadata = configService.getBoolean(
                    ALLOW_NON_EXISTENT_MODEL_METADATA, false);

                try {
                    File nmMetadataDir = MocModelDrCopier.getNmMetadataDir(new File(
                        messageFileName));
                    if (!nmMetadataDir.exists() || !nmMetadataDir.isDirectory()) {
                        throw new IllegalArgumentException(
                            "nmMetadataDir does not exist or is not a directory.\n  nmMetadataDir: "
                                + nmMetadataDir);
                    }

                    File modelMetadataFile = new File(nmMetadataDir,
                        MocModelDrCopier.MODEL_METADATA_FILE_NAME);
                    BufferedReader reader = new BufferedReader(new FileReader(
                        modelMetadataFile));
                    StringBuilder builder = new StringBuilder();
                    for (String s = reader.readLine(); s != null; s = reader.readLine()) {
                        builder.append(s + "\n");
                    }
                    reader.close();

                    Pair<String, String> modelMetadata = MocModelDrCopier.parseModelMetadata(builder.toString());

                    Date ingestTime = new Date();
                    log.info("calling "
                        + ModelMetadataOperations.class.getSimpleName()
                        + ".updateModelMetaData(" + dispatcherType.toString()
                        + ", " + modelMetadata.right + ", " + ingestTime + ", "
                        + modelMetadata.left + ")");
                    modelMetadataCrud.updateModelMetaData(
                        dispatcherType.toString(), modelMetadata.right,
                        ingestTime, modelMetadata.left);
                } catch (Throwable e) {
                    if (allowNonExistentModelMetadata) {
                        // Just log the error and return.
                        log.error("Unable to set model metadata.", e);
                    } else {
                        // model metadata is required.
                        throw new IllegalStateException(
                            "Unable to store model metadata.\n  - Did you use drcopy-moc-model to copy files into "
                                + "the dr incoming dir?\n  - To disable storing model metadata, set "
                                + ALLOW_NON_EXISTENT_MODEL_METADATA + "=true",
                            e);
                    }
                }
            }
        }
    }

}
