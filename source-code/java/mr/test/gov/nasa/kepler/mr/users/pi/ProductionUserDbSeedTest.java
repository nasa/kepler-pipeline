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

package gov.nasa.kepler.mr.users.pi;

import static gov.nasa.kepler.mr.users.pi.Permissions.ADMINISTRATION;
import static gov.nasa.kepler.mr.users.pi.Permissions.BLOG;
import static gov.nasa.kepler.mr.users.pi.Permissions.EDIT;
import static gov.nasa.kepler.mr.users.pi.Permissions.EDIT_APPROVES;
import static gov.nasa.kepler.mr.users.pi.Permissions.EDIT_DRAFTMODE;
import static gov.nasa.kepler.mr.users.pi.Permissions.EDIT_FTPUPLOAD;
import static gov.nasa.kepler.mr.users.pi.Permissions.EDIT_LINKS;
import static gov.nasa.kepler.mr.users.pi.Permissions.EDIT_MANAGENOTIFICATIONS;
import static gov.nasa.kepler.mr.users.pi.Permissions.EDIT_NOTIFY;
import static gov.nasa.kepler.mr.users.pi.Permissions.EDIT_RECENTEDITS;
import static gov.nasa.kepler.mr.users.pi.Permissions.EDIT_UPDATE;
import static gov.nasa.kepler.mr.users.pi.Permissions.EDIT_UPLOAD;
import static gov.nasa.kepler.mr.users.pi.Permissions.ERROR_NOTIFY;
import static gov.nasa.kepler.mr.users.pi.Permissions.FILEMANAGER;
import static gov.nasa.kepler.mr.users.pi.Permissions.INTRANET;
import static gov.nasa.kepler.mr.users.pi.Permissions.PERM_DMC;
import static gov.nasa.kepler.mr.users.pi.Permissions.PERM_FOWG;
import static gov.nasa.kepler.mr.users.pi.Permissions.PERM_FPC;
import static gov.nasa.kepler.mr.users.pi.Permissions.PERM_MMO;
import static gov.nasa.kepler.mr.users.pi.Permissions.PERM_MOC;
import static gov.nasa.kepler.mr.users.pi.Permissions.PERM_REPORT_DATA_GAP;
import static gov.nasa.kepler.mr.users.pi.Permissions.PERM_REPORT_GENERIC_REPORT;
import static gov.nasa.kepler.mr.users.pi.Permissions.PERM_REPORT_HUFFMAN_TABLES;
import static gov.nasa.kepler.mr.users.pi.Permissions.PERM_REPORT_PI_PROCESSING;
import static gov.nasa.kepler.mr.users.pi.Permissions.PERM_REPORT_REQUANT_TABLES;
import static gov.nasa.kepler.mr.users.pi.Permissions.PERM_REPORT_TAD_CCD_MODULE_OUTPUT;
import static gov.nasa.kepler.mr.users.pi.Permissions.PERM_REPORT_TAD_SUMMARY;
import static gov.nasa.kepler.mr.users.pi.Permissions.PERM_SO;
import static gov.nasa.kepler.mr.users.pi.Permissions.PERM_SOC;
import static gov.nasa.kepler.mr.users.pi.Permissions.PERM_SWG;
import static gov.nasa.kepler.mr.users.pi.ProductionUserDbSeed.GROUP_ADMIN;
import static gov.nasa.kepler.mr.users.pi.ProductionUserDbSeed.GROUP_DMC;
import static gov.nasa.kepler.mr.users.pi.ProductionUserDbSeed.GROUP_EDITOR;
import static gov.nasa.kepler.mr.users.pi.ProductionUserDbSeed.GROUP_FOWG;
import static gov.nasa.kepler.mr.users.pi.ProductionUserDbSeed.GROUP_FPC;
import static gov.nasa.kepler.mr.users.pi.ProductionUserDbSeed.GROUP_INTRANET;
import static gov.nasa.kepler.mr.users.pi.ProductionUserDbSeed.GROUP_MMO;
import static gov.nasa.kepler.mr.users.pi.ProductionUserDbSeed.GROUP_MOC;
import static gov.nasa.kepler.mr.users.pi.ProductionUserDbSeed.GROUP_SO;
import static gov.nasa.kepler.mr.users.pi.ProductionUserDbSeed.GROUP_SOC;
import static gov.nasa.kepler.mr.users.pi.ProductionUserDbSeed.GROUP_SWG;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DdlInitializer;
import gov.nasa.kepler.hibernate.services.UserCrud;

import org.junit.After;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

import com.openedit.users.Group;

/**
 * Tests the {@link ProductionUserDbSeed} class.
 * 
 * @author Bill Wohler
 * @author jbrittain
 */
public class ProductionUserDbSeedTest {

    private static DatabaseService dbService;
    private PipelineUserManager userManager;
    private DdlInitializer ddlInitializer;

    @BeforeClass
    public static void setUp() throws Exception {
        dbService = DatabaseServiceFactory.getInstance();
    }

    @Before
    public void createDatabase() {
        ddlInitializer = dbService.getDdlInitializer();
        ddlInitializer.initDB();
        userManager = new PipelineUserManager();
    }

    @After
    public void destroyDatabase() {
        dbService.closeCurrentSession();
        dbService.getDdlInitializer()
            .cleanDB();
    }

    private void populateObjects() {
        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        try {
            databaseService.beginTransaction();
            // loadSeedData expects that the admin user has already been
            // created.
            new UserCrud(dbService).createUser(new gov.nasa.kepler.hibernate.services.User(
                "admin", "admin", "admin", "admin@nasa.gov", "515-1212"));
            new ProductionUserDbSeed().loadSeedData();
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();
    }

    @Test
    public void testSeed() throws Exception {
        populateObjects();

        // Verify groups.
        Group adminGroup = userManager.getGroup(GROUP_ADMIN);
        assertNotNull(GROUP_ADMIN + " group not found", adminGroup);
        assertAdminPermission(adminGroup);

        Group editorGroup = userManager.getGroup(GROUP_EDITOR);
        assertNotNull(GROUP_EDITOR + " group not found", editorGroup);
        assertEditorPermission(editorGroup);

        Group intranetGroup = userManager.getGroup(GROUP_INTRANET);
        assertNotNull(GROUP_INTRANET + " group not found", intranetGroup);
        assertIntranetPermission(intranetGroup);

        Group soGroup = userManager.getGroup(GROUP_SO);
        assertNotNull(GROUP_SO + " group not found", soGroup);
        assertPermission(soGroup, PERM_SO);
        assertReportPermission(soGroup);

        Group socGroup = userManager.getGroup(GROUP_SOC);
        assertNotNull(GROUP_SOC + " group not found", socGroup);
        assertPermission(socGroup, PERM_SOC);

        Group mmoGroup = userManager.getGroup(GROUP_MMO);
        assertNotNull(GROUP_MMO + " group not found", mmoGroup);
        assertPermission(mmoGroup, PERM_MMO);

        Group dmcGroup = userManager.getGroup(GROUP_DMC);
        assertNotNull(GROUP_DMC + " group not found", dmcGroup);
        assertPermission(dmcGroup, PERM_DMC);

        Group mocGroup = userManager.getGroup(GROUP_MOC);
        assertNotNull(GROUP_MOC + " group not found", mocGroup);
        assertPermission(mocGroup, PERM_MOC);

        Group fpcGroup = userManager.getGroup(GROUP_FPC);
        assertNotNull(GROUP_FPC + " group not found", fpcGroup);
        assertPermission(fpcGroup, PERM_FPC);

        Group fowgGroup = userManager.getGroup(GROUP_FOWG);
        assertNotNull(GROUP_FOWG + " group not found", fowgGroup);
        assertPermission(fowgGroup, PERM_FOWG);

        Group swgGroup = userManager.getGroup(GROUP_SWG);
        assertNotNull(GROUP_SWG + " group not found", swgGroup);
        assertPermission(swgGroup, PERM_SWG);
    }

    private void assertAdminPermission(Group group) {
        assertIntranetPermission(group);
        assertEditorPermission(group);

        assertPermission(group, ADMINISTRATION);
        assertPermission(group, EDIT_APPROVES);
        assertPermission(group, EDIT_DRAFTMODE);
        // assertPermission(group, EDIT_EDITSLANGUAGES);
        assertPermission(group, EDIT_LINKS);
        assertPermission(group, EDIT_MANAGENOTIFICATIONS);
        assertPermission(group, EDIT_NOTIFY);
        assertPermission(group, EDIT_RECENTEDITS);
        assertPermission(group, EDIT_UPDATE);
        assertPermission(group, ERROR_NOTIFY);
        // assertPermission(group, USERMANAGER);
    }

    private void assertReportPermission(Group group) {
        assertEditorPermission(group);
        assertIntranetPermission(group);

        assertPermission(group, PERM_REPORT_DATA_GAP);
        assertPermission(group, PERM_REPORT_GENERIC_REPORT);
        assertPermission(group, PERM_REPORT_HUFFMAN_TABLES);
        assertPermission(group, PERM_REPORT_PI_PROCESSING);
        assertPermission(group, PERM_REPORT_REQUANT_TABLES);
        assertPermission(group, PERM_REPORT_TAD_CCD_MODULE_OUTPUT);
        assertPermission(group, PERM_REPORT_TAD_SUMMARY);
    }

    private void assertEditorPermission(Group group) {
        assertPermission(group, BLOG);
        assertPermission(group, EDIT);
        assertPermission(group, EDIT_FTPUPLOAD);
        assertPermission(group, EDIT_UPLOAD);
    }

    private void assertIntranetPermission(Group group) {
        assertPermission(group, FILEMANAGER);
        assertPermission(group, INTRANET);
    }

    private void assertPermission(Group group, String permission) {
        assertTrue("Group " + group.getName() + " lacks permission "
            + permission, group.hasPermission(permission));
    }
}
