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

package gov.nasa.kepler.ui.proxy;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.DataAnomaly;
import gov.nasa.kepler.hibernate.dr.DataAnomaly.DataAnomalyType;
import gov.nasa.kepler.hibernate.dr.DataAnomalyModel;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.hibernate.services.Privilege;
import gov.nasa.kepler.mc.pi.ModelOperationsFactory;
import gov.nasa.kepler.pi.models.ModelOperations;
import gov.nasa.kepler.ui.PipelineConsole;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Callable;

/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class DataAnomalyModelCrudProxy extends CrudProxy {

    /**
     * @param databaseService
     */
    public DataAnomalyModelCrudProxy() {
    }

    public List<DataAnomaly> retrieveAllDataAnomalies() {
        verifyPrivileges(Privilege.PIPELINE_MONITOR);
        List<DataAnomaly> results = (List<DataAnomaly>) PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<List<DataAnomaly>>() {
            public List<DataAnomaly> call() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                ModelOperations<DataAnomalyModel> modelOperations = ModelOperationsFactory.getDataAnomalyInstance(new ModelMetadataRetrieverLatest());

                databaseService.beginTransaction();

                List<DataAnomaly> r = modelOperations.retrieveModel()
                    .getDataAnomalies();

                databaseService.flush();
                databaseService.commitTransaction();

                return r;
            }
        });
        return results;
    }

    public void addDataAnomaly(final DataAnomalyType dataAnomalyType,
        final CadenceType cadenceType, final int startCadence,
        final int endCadence) {
        verifyPrivileges(Privilege.PIPELINE_CONFIG);
        PipelineConsole.crudProxyExecutor.executeSynchronous(new Runnable() {
            public void run() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                ModelOperations<DataAnomalyModel> modelOperations = ModelOperationsFactory.getDataAnomalyInstance(new ModelMetadataRetrieverLatest());

                databaseService.beginTransaction();

                DataAnomalyModel model = modelOperations.retrieveModel();

                List<DataAnomaly> dataAnomalies = model.getDataAnomalies();
                dataAnomalies.add(new DataAnomaly(dataAnomalyType,
                    cadenceType.intValue(), startCadence, endCadence));

                modelOperations.replaceExistingModel(
                    new DataAnomalyModel(model.getRevision(), dataAnomalies),
                    DataAnomalyModel.DEFAULT_DESCRIPTION);

                databaseService.flush();
                databaseService.commitTransaction();
            }
        });
    }

    public void deleteDataAnomaly(final long id) {
        verifyPrivileges(Privilege.PIPELINE_CONFIG);
        PipelineConsole.crudProxyExecutor.executeSynchronous(new Runnable() {
            public void run() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                ModelOperations<DataAnomalyModel> modelOperations = ModelOperationsFactory.getDataAnomalyInstance(new ModelMetadataRetrieverLatest());

                databaseService.beginTransaction();

                DataAnomalyModel model = modelOperations.retrieveModel();

                List<DataAnomaly> dataAnomalies = new ArrayList<DataAnomaly>();
                for (DataAnomaly dataAnomaly : model.getDataAnomalies()) {
                    if (dataAnomaly.getId() != id) {
                        dataAnomalies.add(dataAnomaly);
                    }
                }

                modelOperations.replaceExistingModel(
                    new DataAnomalyModel(model.getRevision(), dataAnomalies),
                    DataAnomalyModel.DEFAULT_DESCRIPTION);

                databaseService.flush();
                databaseService.commitTransaction();
            }
        });
    }

    @Override
    public void saveChanges() {
        verifyPrivileges(Privilege.PIPELINE_CONFIG);
        super.saveChanges();
    }
}
