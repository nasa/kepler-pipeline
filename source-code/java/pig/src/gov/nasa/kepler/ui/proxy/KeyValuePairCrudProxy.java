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

import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.services.KeyValuePair;
import gov.nasa.kepler.hibernate.services.KeyValuePairCrud;
import gov.nasa.kepler.hibernate.services.Privilege;
import gov.nasa.kepler.ui.PipelineConsole;

import java.util.List;
import java.util.concurrent.Callable;

/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class KeyValuePairCrudProxy extends CrudProxy {

    /**
     * @param databaseService
     */
    public KeyValuePairCrudProxy() {
    }

    /*
     * (non-Javadoc)
     * 
     * @see gov.nasa.kepler.hibernate.services.KeyValuePairCrud#createKeyValuePair(gov.nasa.kepler.hibernate.services.KeyValuePair)
     */
    public void save(final KeyValuePair keyValuePair) {
        verifyPrivileges(Privilege.PIPELINE_CONFIG);
        PipelineConsole.crudProxyExecutor.executeSynchronous(new Runnable() {
            public void run() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                KeyValuePairCrud crud = new KeyValuePairCrud(databaseService);

                databaseService.beginTransaction();

                crud.create(keyValuePair);

                databaseService.flush();
                databaseService.commitTransaction();
            }
        });
    }

    /*
     * (non-Javadoc)
     * 
     * @see gov.nasa.kepler.hibernate.services.KeyValuePairCrud#deleteKeyValuePair(gov.nasa.kepler.hibernate.services.KeyValuePair)
     */
    public void delete(final KeyValuePair keyValuePair) {
        verifyPrivileges(Privilege.PIPELINE_CONFIG);
        PipelineConsole.crudProxyExecutor.executeSynchronous(new Runnable() {
            public void run() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                KeyValuePairCrud crud = new KeyValuePairCrud(databaseService);

                databaseService.beginTransaction();

                crud.delete(keyValuePair);

                databaseService.flush();
                databaseService.commitTransaction();
            }
        });
    }

    /*
     * (non-Javadoc)
     * 
     * @see gov.nasa.kepler.hibernate.services.KeyValuePairCrud#retrieveKeyValuePair(java.lang.String)
     */
    public KeyValuePair retrieve(final String key) {
        verifyPrivileges(Privilege.PIPELINE_MONITOR);
        KeyValuePair result = (KeyValuePair) PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<KeyValuePair>() {
            public KeyValuePair call() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                KeyValuePairCrud crud = new KeyValuePairCrud(databaseService);

                databaseService.beginTransaction();

                KeyValuePair result = crud.retrieve(key);

                databaseService.flush();
                databaseService.commitTransaction();

                return result;
            }
        });
        return result;
    }

    public List<KeyValuePair> retrieveAll() {
        verifyPrivileges(Privilege.PIPELINE_MONITOR);
        List<KeyValuePair> results = (List<KeyValuePair>) PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<List<KeyValuePair>>() {
            public List<KeyValuePair> call() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                KeyValuePairCrud crud = new KeyValuePairCrud(databaseService);

                databaseService.beginTransaction();

                List<KeyValuePair> r = crud.retrieveAll();

                databaseService.flush();
                databaseService.commitTransaction();

                return r;
            }
        });
        return results;
    }
}
