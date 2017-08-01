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

package gov.nasa.kepler.services.security;

import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.services.Privilege;
import gov.nasa.kepler.hibernate.services.Role;
import gov.nasa.kepler.hibernate.services.User;
import gov.nasa.kepler.hibernate.services.UserCrud;
import gov.nasa.spiffy.common.pi.PipelineException;

/**
 * This class populates seed data for {@link User}s and {@link Role}s.
 * 
 */
public class TestSecuritySeedData {

    private UserCrud userCrud;

    public TestSecuritySeedData() {
        this(DatabaseServiceFactory.getInstance());
    }

    public TestSecuritySeedData(DatabaseService databaseService) {
        userCrud = new UserCrud(databaseService);
    }

    /**
     * Loads initial security data into {@link User} and {@link Role} tables.
     * Use {@link #deleteAllUsersAndRoles()} to clear these tables before
     * running this method. The caller is responsible for calling
     * {@link DatabaseService#beginTransaction()} and
     * {@link DatabaseService#commitTransaction()}.
     * 
     * @throws PipelineException if there were problems inserting records into
     * the database.
     */
    public void loadSeedData() {
        insertAll();
    }

    private void insertAll() {
        Role superRole = new Role("Super User");
        for (Privilege privilege : Privilege.values()) {
            superRole.addPrivilege(privilege.toString());
        }
        userCrud.createRole(superRole);

        Role opsRole = new Role("Pipeline Operator");
        opsRole.addPrivilege(Privilege.USER_ADMIN.toString());
        opsRole.addPrivilege(Privilege.PIPELINE_CONFIG.toString());
        userCrud.createRole(opsRole);

        Role managerRole = new Role("Pipeline Manager");
        managerRole.addPrivilege(Privilege.PIPELINE_OPERATIONS.toString());
        managerRole.addPrivilege(Privilege.PIPELINE_MONITOR.toString());
        userCrud.createRole(managerRole);

        User admin = new User("admin", "Administrator", "admin",
            "admin@kepler.nasa.gov", "x111");
        admin.addRole(superRole);
        userCrud.createUser(admin);

        User joeOps = new User("joe", "Joe Operator", "joe",
            "joe@kepler.nasa.gov", "x222");
        joeOps.addRole(opsRole);
        userCrud.createUser(joeOps);

        User tonyOps = new User("tony", "Tony Trainee", "tony",
            "tony@kepler.nasa.gov", "x444");
        // Since Tony is only a trainee, we'll just give him monitor privs for
        // now...
        tonyOps.addPrivilege(Privilege.PIPELINE_CONFIG.toString());
        userCrud.createUser(tonyOps);

        User MaryMgr = new User("mary", "Mary Manager", "mary",
            "mary@kepler.nasa.gov", "x333");
        MaryMgr.addRole(managerRole);
        userCrud.createUser(MaryMgr);
    }

    public void deleteAllUsersAndRoles() {
        for (User user : userCrud.retrieveAllUsers()) {
            userCrud.deleteUser(user);
        }
        for (Role role : userCrud.retrieveAllRoles()) {
            userCrud.deleteRole(role);
        }
    }

    /**
     * This function runs the tests declared in this class.
     * 
     * @param args
     * @throws PipelineException
     */
    public static void main(String[] args) {
        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        TestSecuritySeedData testSecuritySeedData = new TestSecuritySeedData(
            databaseService);

        try {
            databaseService.beginTransaction();
            testSecuritySeedData.loadSeedData();
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }
}
