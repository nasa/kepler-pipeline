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

import gov.nasa.kepler.hibernate.dbservice.TransactionWrapper;
import gov.nasa.kepler.hibernate.mc.EbTransitParameterModel;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.mc.pi.ModelOperationsFactory;
import gov.nasa.kepler.pi.models.ModelOperations;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Imports a txt file as a {@link EbTransitParameterModel}.
 * 
 * @author Forrest Girouard
 * 
 */
public class EbTransitParameterModelImporter {

    private static final Log log = LogFactory.getLog(EbTransitParameterModelImporter.class);

    public EbTransitParameterModel importFile(File file) throws IOException {
        log.debug("Reading file " + file.getPath());
        BufferedReader reader = new BufferedReader(new FileReader(file));
        StringBuilder builder = new StringBuilder();
        try {
            for (String s = reader.readLine(); s != null; s = reader.readLine()) {
                builder.append(s);
                builder.append("\n");
            }
        } finally {
            reader.close();
        }

        EbTransitParameterModel ebTransitParameterModel = EbTransitParameterModel.valueOf(builder.toString());
        log.debug("Done reading file " + file.getPath());

        return ebTransitParameterModel;
    }

    public static void main(String[] args) {
        if (args.length != 2) {
            System.err.println("USAGE: import-eb-transit-parameters-model FILENAME DESCRIPTION");
            System.err.println("EXAMPLE: import-eb-transit-parameters-model ~/eb-transit-parameters-model.txt \"Added initial version of the model.\"");
            System.exit(-1);
        }

        final String fileName = args[0];
        final String description = args[1];

        final File file = new File(fileName);

        System.out.println("Importing " + file);

        TransactionWrapper.run(new Runnable() {
            @Override
            public void run() {
                EbTransitParameterModelImporter importer = new EbTransitParameterModelImporter();
                EbTransitParameterModel ebTransitParametersModel = null;
                try {
                    ebTransitParametersModel = importer.importFile(file);
                } catch (IOException e) {
                    throw new IllegalArgumentException("Unable to import.", e);
                }

                ModelOperations<EbTransitParameterModel> modelOperations = ModelOperationsFactory.getEbTransitParameterInstance(new ModelMetadataRetrieverLatest());
                modelOperations.replaceExistingModel(ebTransitParametersModel,
                    String.format("%s: %s", file.getName(), description));
            }
        });
    }

}
