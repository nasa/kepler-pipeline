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
import gov.nasa.kepler.hibernate.services.Privilege;
import gov.nasa.kepler.hibernate.services.Role;
import gov.nasa.kepler.hibernate.services.User;
import gov.nasa.kepler.hibernate.services.UserCrud;
import gov.nasa.kepler.ui.PipelineConsole;

import java.util.List;
import java.util.concurrent.Callable;

/**
 * This proxy class provides wrappers for the CRUD methods in {@link UserCrud}
 * to support 'off-line' conversations (modifications to persisted objects
 * without immediate db updates) The pattern is similar for all CRUD operations:
 * 
 * <pre>
 * 
 * 1- start a transaction
 * 2- invoke real CRUD method
 * 3- call Session.flush()
 * 4- commit the transaction
 * 
 * </pre>
 * 
 * This class assumes that auto-flushing has been turned off for the current
 * session by the application before calling this class.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class UserCrudProxy extends CrudProxy {

    public UserCrudProxy() {
    }

    public void saveRole(final Role role) {
        verifyPrivileges(Privilege.USER_ADMIN);
        PipelineConsole.crudProxyExecutor.executeSynchronous(new Runnable() {
            public void run() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                UserCrud crud = new UserCrud(databaseService);

                databaseService.beginTransaction();

                crud.createRole(role);

                databaseService.flush();
                databaseService.commitTransaction();
            }
        });
    }

    public Role retrieveRole(final String roleName) {
        verifyPrivileges(Privilege.USER_ADMIN);
        Role result = (Role) PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<Role>() {
            public Role call() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                UserCrud crud = new UserCrud(databaseService);

                databaseService.beginTransaction();

                Role r = crud.retrieveRole(roleName);

                databaseService.commitTransaction();

                return r;
            }
        });
        return result;
    }

    public List<Role> retrieveAllRoles() {
        verifyPrivileges(Privilege.USER_ADMIN);
        List<Role> result = (List<Role>) PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<List<Role>>() {
            public List<Role> call() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                UserCrud crud = new UserCrud(databaseService);

                databaseService.beginTransaction();

                List<Role> r = crud.retrieveAllRoles();

                databaseService.commitTransaction();

                return r;
            }
        });
        return result;
    }

    public void deleteRole(final Role role) {
        verifyPrivileges(Privilege.USER_ADMIN);
        PipelineConsole.crudProxyExecutor.executeSynchronous(new Runnable() {
            public void run() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                UserCrud crud = new UserCrud(databaseService);

                databaseService.beginTransaction();

                crud.deleteRole(role);

                databaseService.flush();
                databaseService.commitTransaction();
            }
        });
    }

    public void saveUser(final User user) {
        verifyPrivileges(Privilege.USER_ADMIN);
        PipelineConsole.crudProxyExecutor.executeSynchronous(new Runnable() {
            public void run() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                UserCrud crud = new UserCrud(databaseService);

                databaseService.beginTransaction();

                crud.createUser(user);

                databaseService.flush();
                databaseService.commitTransaction();
            }
        });
    }

    public User retrieveUser(final String loginName) {
        verifyPrivileges(Privilege.USER_ADMIN);
        User result = (User) PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<User>() {
            public User call() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                UserCrud crud = new UserCrud(databaseService);

                databaseService.beginTransaction();

                User r = crud.retrieveUser(loginName);

                databaseService.commitTransaction();

                return r;
            }
        });
        return result;
    }

    public List<User> retrieveAllUsers() {
        verifyPrivileges(Privilege.USER_ADMIN);
        List<User> result = (List<User>) PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<List<User>>() {
            public List<User> call() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                UserCrud crud = new UserCrud(databaseService);

                databaseService.beginTransaction();

                List<User> r = crud.retrieveAllUsers();

                databaseService.commitTransaction();

                return r;
            }
        });
        return result;
    }

    public void deleteUser(final User user) {
        verifyPrivileges(Privilege.USER_ADMIN);
        PipelineConsole.crudProxyExecutor.executeSynchronous(new Runnable() {
            public void run() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                UserCrud crud = new UserCrud(databaseService);

                databaseService.beginTransaction();

                crud.deleteUser(user);

                databaseService.flush();
                databaseService.commitTransaction();
            }
        });
    }
}
