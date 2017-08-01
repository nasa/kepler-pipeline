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

package gov.nasa.kepler.mc.hsqldb;

import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.common.FilenameConstants;
import gov.nasa.kepler.hibernate.dbservice.ConnectInfo;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DdlInitializer;
import gov.nasa.kepler.hibernate.dbservice.HsqldbUtils;

import java.io.File;
import java.util.Properties;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Base class for database seed data types.
 * 
 * Sub-classes are responsible for generating the seed data and writing it to
 * the db so it could be exported, and for seeding that exported data into a new
 * database
 * 
 * @author tklaus
 * 
 */
public abstract class SeedData {

    private static final Log log = LogFactory.getLog(SeedData.class);

    private File seedFile = null;
    private ConnectInfo connectInfo = null;
    Properties destDbProperties = null;

    /**
     * Sub-classes should pass in the base name of the file that contains the
     * seed data in the export format (sql insert)
     * 
     * @param outputFilename
     */
    public SeedData(String outputFilename) {
        destDbProperties = new Properties();
        DefaultProperties.setPropsHsqldbFile(destDbProperties);
        this.seedFile = new File(FilenameConstants.DIST_SEED_DATA,
            outputFilename);
        this.connectInfo = new ConnectInfo(destDbProperties);
    }

    /**
     * Sub-classes should write their seed data to the db here. Sub-classes are
     * responsible for transaction management (notably, commit).
     * 
     * @throws Exception
     */
    protected abstract void writeSeedData(DatabaseService dbService)
        throws Exception;

    public void generate() throws Exception {

        HsqldbUtils.cleanSchemaDir();

        DatabaseService destDbService = DatabaseServiceFactory.getInstance(destDbProperties);

        DdlInitializer ddlInitializer = destDbService.getDdlInitializer();
        ddlInitializer.initDB();

        writeSeedData(destDbService);

        // flush the hsqldb log
        HsqldbUtils.checkpoint(connectInfo);
        HsqldbUtils.exportDatabaseContents(seedFile);
    }
}
