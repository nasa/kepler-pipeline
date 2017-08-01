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

package gov.nasa.kepler.dr.kicextension;

import gov.nasa.kepler.dr.dispatch.Importer;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.dbservice.TransactionWrapper;
import gov.nasa.kepler.hibernate.pi.ModelMetadata;
import gov.nasa.kepler.hibernate.pi.ModelMetadataCrud;
import gov.nasa.kepler.pi.models.ModelOperations;

import java.io.File;
import java.io.FileInputStream;
import java.util.Date;

/**
 * Imports a kic extension.
 * 
 * @author Miles Cote
 * 
 */
public class KicExtensionImporter {

    static final String MODEL_TYPE = "KIC_EXTENSION";

    private final Importer<KicExtension> kicExtensionImporter;
    private final ModelMetadataCrud modelMetadataCrud;
    private final String description;

    public KicExtensionImporter(Importer<KicExtension> kicExtensionImporter,
        ModelMetadataCrud modelMetadataCrud, String description) {
        this.kicExtensionImporter = kicExtensionImporter;
        this.modelMetadataCrud = modelMetadataCrud;
        this.description = description;
    }

    public void importData() {
        kicExtensionImporter.importData();

        updateModelMetadata();
    }

    private void updateModelMetadata() {
        ModelMetadata latestModelMetadata = modelMetadataCrud.retrieveLatestModelRevision(MODEL_TYPE);

        int revision = ModelOperations.getRevision(latestModelMetadata);

        if (latestModelMetadata == null || latestModelMetadata.isLocked()) {
            revision++;

            modelMetadataCrud.updateModelMetaData(MODEL_TYPE, description,
                new Date(), String.valueOf(revision));
        }
    }

    public static void main(String[] args) {
        if (args.length != 2) {
            System.err.println("USAGE: import-kic-extension FILENAME DESCRIPTION");
            System.err.println("EXAMPLE: import-kic-extension ~/kic-extension.mrg \"Added initial version of the model.\"");
            System.exit(-1);
        }

        final File file = new File(args[0]);
        final String description = args[1];

        System.out.println("Importing " + file);

        TransactionWrapper.run(new Runnable() {
            @Override
            public void run() {
                try {
                    KicExtensionImporter kicExtensionImporter = new KicExtensionImporter(
                        new Importer<KicExtension>(new KicExtensionReader(
                            new FileInputStream(file)), new KicExtensionStorer(
                            new KicCrud())), new ModelMetadataCrud(),
                        description);
                    kicExtensionImporter.importData();
                } catch (Exception e) {
                    throw new IllegalArgumentException("Unable to import.", e);
                }
            }
        });
    }

}
