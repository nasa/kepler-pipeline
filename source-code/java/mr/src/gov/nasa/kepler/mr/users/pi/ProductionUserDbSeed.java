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

import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.services.Role;
import gov.nasa.kepler.hibernate.services.UserCrud;
import gov.nasa.spiffy.common.pi.PipelineException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class seeds the production database with the users, roles, and
 * privileges that are required by the Mission Reports web site. It assumes that
 * {@code ant seed-db} in services (or {@code runjava seed-security}) has been
 * run (in order to create the admin user) and that this class has not been run
 * before.
 * <p>
 * When making changes to this file, please update files in
 * webroot/WEB-INF/groups/ in a similar fashion. These files are used by
 * OpenEdit.
 * 
 * @author Bill Wohler
 * @author jbrittain
 */
public class ProductionUserDbSeed {

    private static final Log log = LogFactory.getLog(ProductionUserDbSeed.class);

    // Groups by software.
    public static final String GROUP_ADMIN = "administrators";
    public static final String GROUP_EDITOR = "editors";
    public static final String GROUP_INTRANET = "intranet";
    public static final String GROUP_REPORTS = "reports";

    // Groups by user.
    public static final String GROUP_SO = "so";
    public static final String GROUP_MMO = "mmo";
    public static final String GROUP_SOC = "soc";
    public static final String GROUP_SWG = "swg";
    public static final String GROUP_FOWG = "fowg";
    public static final String GROUP_MOC = "moc";
    public static final String GROUP_FPC = "fpc";
    public static final String GROUP_DMC = "dmc";

    /**
     * Loads seed data for MR.
     * 
     * @throws PipelineException if the data could not be stored in the database
     */
    public void loadSeedData() {
        createRoles();
    }

    /**
     * Creates the roles and users for MR.
     * 
     * @throws PipelineException if the admin user is not already present in the
     * database
     */
    private void createRoles() {
        UserCrud userCrud = new UserCrud();

        Role editors = userCrud.retrieveRole(GROUP_EDITOR);

        if (editors != null) {
            log.info("MR roles already exist");
            return;
        }

        editors = new Role(GROUP_EDITOR);
        editors.addPrivilege(Permissions.BLOG);
        editors.addPrivilege(Permissions.EDIT);
        editors.addPrivilege(Permissions.EDIT_FTPUPLOAD);
        editors.addPrivilege(Permissions.EDIT_UPLOAD);
        userCrud.createRole(editors);

        Role intranet = new Role(GROUP_INTRANET);
        intranet.addPrivilege(Permissions.FILEMANAGER);
        intranet.addPrivilege(Permissions.INTRANET);
        userCrud.createRole(intranet);

        Role reports = new Role(GROUP_REPORTS);
        reports.addPrivileges(editors);
        reports.addPrivileges(intranet);
        reports.addPrivilege(Permissions.PERM_REPORT_ALERTS);
        reports.addPrivilege(Permissions.PERM_REPORT_BAD_PIXELS);
        reports.addPrivilege(Permissions.PERM_REPORT_CONFIG_MAP);
        reports.addPrivilege(Permissions.PERM_REPORT_DATA_COMPRESSION);
        reports.addPrivilege(Permissions.PERM_REPORT_DATA_GAP);
        reports.addPrivilege(Permissions.PERM_REPORT_DR_SUMMARY);
        reports.addPrivilege(Permissions.PERM_REPORT_FC);
        reports.addPrivilege(Permissions.PERM_REPORT_GENERIC_REPORT);
        reports.addPrivilege(Permissions.PERM_REPORT_HUFFMAN_TABLES);
        reports.addPrivilege(Permissions.PERM_REPORT_PI_INSTANCE_DETAIL);
        reports.addPrivilege(Permissions.PERM_REPORT_PI_PROCESSING);
        reports.addPrivilege(Permissions.PERM_REPORT_REQUANT_TABLES);
        reports.addPrivilege(Permissions.PERM_REPORT_TAD_CCD_MODULE_OUTPUT);
        reports.addPrivilege(Permissions.PERM_REPORT_TAD_SUMMARY);
        userCrud.createRole(reports);

        Role administrators = new Role(GROUP_ADMIN);
        administrators.addPrivileges(reports);
        administrators.addPrivilege(Permissions.ADMINISTRATION);
        administrators.addPrivilege(Permissions.EDIT_APPROVES);
        administrators.addPrivilege(Permissions.EDIT_DRAFTMODE);
        // adminRole.addPrivilege(Permissions.EDIT_EDITSLANGUAGES);
        administrators.addPrivilege(Permissions.EDIT_LINKS);
        administrators.addPrivilege(Permissions.EDIT_MANAGENOTIFICATIONS);
        administrators.addPrivilege(Permissions.EDIT_NOTIFY);
        administrators.addPrivilege(Permissions.EDIT_RECENTEDITS);
        administrators.addPrivilege(Permissions.EDIT_UPDATE);
        administrators.addPrivilege(Permissions.ERROR_NOTIFY);
        // adminRole.addPrivilege(Permissions.USERMANAGER);
        userCrud.createRole(administrators);

        Role so = new Role(GROUP_SO);
        so.addPrivilege(Permissions.PERM_SO);
        so.addPrivileges(reports);
        userCrud.createRole(so);

        Role soc = new Role(GROUP_SOC);
        soc.addPrivilege(Permissions.PERM_SOC);
        userCrud.createRole(soc);

        Role mmo = new Role(GROUP_MMO);
        mmo.addPrivilege(Permissions.PERM_MMO);
        userCrud.createRole(mmo);

        Role dmc = new Role(GROUP_DMC);
        dmc.addPrivilege(Permissions.PERM_DMC);
        userCrud.createRole(dmc);

        Role moc = new Role(GROUP_MOC);
        moc.addPrivilege(Permissions.PERM_MOC);
        userCrud.createRole(moc);

        Role fpc = new Role(GROUP_FPC);
        fpc.addPrivilege(Permissions.PERM_FPC);
        userCrud.createRole(fpc);

        Role fowg = new Role(GROUP_FOWG);
        fowg.addPrivilege(Permissions.PERM_FOWG);
        userCrud.createRole(fowg);

        Role swg = new Role(GROUP_SWG);
        swg.addPrivilege(Permissions.PERM_SWG);
        userCrud.createRole(swg);
    }

    public static void main(String[] args) {
        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        try {
            databaseService.beginTransaction();
            new ProductionUserDbSeed().loadSeedData();
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }
}
