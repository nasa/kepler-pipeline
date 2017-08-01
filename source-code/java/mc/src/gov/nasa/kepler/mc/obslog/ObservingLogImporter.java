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

package gov.nasa.kepler.mc.obslog;

import gov.nasa.kepler.hibernate.dbservice.TransactionWrapper;
import gov.nasa.kepler.hibernate.mc.ObservingLog;
import gov.nasa.kepler.hibernate.mc.ObservingLogModel;
import gov.nasa.kepler.hibernate.pi.Model;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.mc.pi.ModelOperationsFactory;
import gov.nasa.kepler.pi.models.ModelOperations;

import java.io.File;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Import an Observing Log XML file into the database and register
 * it with the data model registry.
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class ObservingLogImporter {
    private static final Log log = LogFactory.getLog(ObservingLogImporter.class);

    public void importFile(final File file, final String description) throws Exception {

        ObservingLogXml xml = new ObservingLogXml();

        try {
            log.info("reading from file: " + file);
            
            List<ObservingLog> logs = xml.readFromFile(file.getAbsolutePath());
            ObservingLogModel model = new ObservingLogModel(Model.NULL_REVISION, logs);

            ModelOperations<ObservingLogModel> modelOperations = 
                ModelOperationsFactory.getObservingLogInstance(new ModelMetadataRetrieverLatest());
            modelOperations.replaceExistingModel(model, description);
        } catch (Exception e) {
            throw new IllegalArgumentException("Unable to import.", e);
        }
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 2) {
            System.err.println("USAGE: import-obslog FILENAME DESCRIPTION");
            System.err.println("EXAMPLE: import-obslog ~/obslog.xml \"Added initial version of the model.\"");
            System.exit(-1);
        }

        final String fileName = args[0];
        final String description = args[1];

        final File file = new File(fileName);
        
        TransactionWrapper.run(new Runnable() {
            @Override
            public void run(){
                ObservingLogImporter importer = new ObservingLogImporter();
                try {
                    importer.importFile(file, description);
                } catch (Exception e) {
                    System.err.println("Unable to import, caught e = " + e);
                }
            }
        });
    }
}
