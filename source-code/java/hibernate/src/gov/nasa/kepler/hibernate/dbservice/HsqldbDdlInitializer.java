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

package gov.nasa.kepler.hibernate.dbservice;

import gov.nasa.spiffy.common.pi.PipelineException;

import java.sql.SQLException;
import java.util.List;

/**
 * {@link DdlInitializer} implementation for HSQLDB
 * 
 * @author Sean McCauliff
 * @author tklaus
 * @author Forrest Girouard
 */
public class HsqldbDdlInitializer extends ScriptedDdlInitializer implements
    DdlInitializer {

    private static final String CREATE_INIT_TABLE_SQL = "create memory table PUBLIC.%s ( message varchar(256) )";
    private static final String TABLE_NAMES = "select table_name from INFORMATION_SCHEMA.tables where TABLE_SCHEMA = 'PUBLIC' and table_name != '%s'";
    private static final String TABLE_COUNT = "select count(*) from INFORMATION_SCHEMA.tables where TABLE_SCHEMA = 'PUBLIC' and table_name != '%s'";
    private static final String TABLE_EXISTS = "select count(*) from INFORMATION_SCHEMA.tables where TABLE_SCHEMA = 'PUBLIC' and table_name = '%s'";

    /**
     * @param url
     * @param driverName
     * @param username
     * @param password
     * @throws PipelineException
     */
    public HsqldbDdlInitializer(String url, String driverName, String username,
        String password) {

        super("hsqldb", url, driverName, username, password);
    }

    @Override
    public List<String> tableNames() throws PipelineException {

        try {

            return tableNames(true);
        } catch (SQLException sqle) {
            throw new PipelineException(sqle);
        }
    }

    @Override
    public List<String> tableNames(boolean logErrors) throws SQLException {

        return tableNames(String.format(TABLE_NAMES, INIT_TABLE_NAME),
            logErrors);
    }

    @Override
    public long tableCount() {

        return tableCount(String.format(TABLE_COUNT, INIT_TABLE_NAME));
    }

    @Override
    public long rowCount(String tableName) throws PipelineException {

        return rowCount(tableName, true);
    }

    @Override
    public long rowCount(String tableName, boolean logErrors)
        throws PipelineException {

        try {

            return super.rowCount(tableName.trim()
                .toUpperCase(), logErrors);
        } catch (SQLException sqle) {
            throw new PipelineException(sqle);
        }
    }

    @Override
    public boolean tableExists(String tableName) throws PipelineException {

        return tableExists(String.format(TABLE_EXISTS, tableName.trim()
            .toUpperCase()), tableName.trim()
            .toUpperCase());
    }

    public void createInitTable() throws PipelineException {

        try {

            createInitTable(String.format(CREATE_INIT_TABLE_SQL,
                INIT_TABLE_NAME));
        } catch (SQLException sqle) {
            throw new PipelineException(sqle);
        }
    }
}
