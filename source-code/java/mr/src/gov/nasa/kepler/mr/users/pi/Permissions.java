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

public interface Permissions {

    // MR permissions prefix.
    public static final String PERM_MR_PREFIX = "mr.";

    public static final String PERM_SO = PERM_MR_PREFIX + "so";
    public static final String PERM_SOC = PERM_MR_PREFIX + "soc";
    public static final String PERM_MMO = PERM_MR_PREFIX + "mmo";
    public static final String PERM_DMC = PERM_MR_PREFIX + "dmc";
    public static final String PERM_MOC = PERM_MR_PREFIX + "moc";
    public static final String PERM_FPC = PERM_MR_PREFIX + "fpc";
    public static final String PERM_SWG = PERM_MR_PREFIX + "swg";
    public static final String PERM_FOWG = PERM_MR_PREFIX + "fowg";

    // Role: reports
    public static final String PERM_REPORT_ALERTS = PERM_MR_PREFIX + "alerts";
    public static final String PERM_REPORT_BAD_PIXELS = PERM_MR_PREFIX
        + "bad-pixels";
    public static final String PERM_REPORT_CONFIG_MAP = PERM_MR_PREFIX
        + "config-map";
    public static final String PERM_REPORT_DATA_COMPRESSION = PERM_MR_PREFIX
        + "data-compression";
    public static final String PERM_REPORT_DATA_GAP = PERM_MR_PREFIX
        + "data-gap";
    public static final String PERM_REPORT_DR_SUMMARY = PERM_MR_PREFIX
        + "dr-summary";
    public static final String PERM_REPORT_FC = PERM_MR_PREFIX + "fc";
    public static final String PERM_REPORT_GENERIC_REPORT = PERM_MR_PREFIX
        + "generic-report";
    public static final String PERM_REPORT_HUFFMAN_TABLES = PERM_MR_PREFIX
        + "huffman-tables";
    public static final String PERM_REPORT_PI_PROCESSING = PERM_MR_PREFIX
        + "pipeline-processing";
    public static final String PERM_REPORT_PI_INSTANCE_DETAIL = PERM_MR_PREFIX
        + "pipeline-instance-detail";
    public static final String PERM_REPORT_REQUANT_TABLES = PERM_MR_PREFIX
        + "requantization-tables";
    public static final String PERM_REPORT_TAD_CCD_MODULE_OUTPUT = PERM_MR_PREFIX
        + "tad-ccd-module-output";
    public static final String PERM_REPORT_TAD_SUMMARY = PERM_MR_PREFIX
        + "tad-summary";

    /* OpenEdit standard permissions. */

    // Role: editors
    public static final String BLOG = "oe.blog";
    public static final String EDIT = "oe.edit";
    public static final String EDIT_FTPUPLOAD = "oe.edit.ftpUpload";
    public static final String EDIT_UPLOAD = "oe.edit.upload";

    // Role: intranet
    public static final String FILEMANAGER = "oe.filemanager";
    public static final String INTRANET = "oe.intranet";

    // Role: administrators
    public static final String ADMINISTRATION = "oe.administration";
    public static final String EDIT_APPROVES = "oe.edit.approves";
    public static final String EDIT_APPROVE_LEVEL1 = "oe.edit.approve.level1";
    public static final String EDIT_APPROVE_LEVEL2 = "oe.edit.approve.level2";
    public static final String EDIT_APPROVE_LEVEL3 = "oe.edit.approve.level3";
    public static final String EDIT_DIRECTEDIT = "oe.edit.directedit";
    public static final String EDIT_DRAFTMODE = "oe.edit.draftmode";
    public static final String EDIT_EDITOR_ADVANCED = "oe.edit.editor.advanced";
    public static final String EDIT_EDITSLANGUAGES = "oe.edit.editslanguages";
    public static final String EDIT_LINKS = "oe.edit.links";
    public static final String EDIT_MANAGENOTIFICATIONS = "oe.edit.managenotifications";
    public static final String EDIT_NOTIFY = "oe.edit.notify";
    public static final String EDIT_RECENTEDITS = "oe.edit.recentedits";
    public static final String EDIT_SETTINGS_ADVANCED = "oe.edit.settings.advanced";
    public static final String EDIT_UPDATE = "oe.edit.update";
    public static final String ERROR_NOTIFY = "oe.error.notify";
    public static final String USERMANAGER = "oe.usermanager";
}
