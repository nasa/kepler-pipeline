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

import javax.sql.DataSource;

import oracle.jdbc.pool.OracleDataSource;

import org.apache.commons.configuration.Configuration;
import org.hsqldb.jdbc.JDBCDataSource;

/**
 * {@link DataSource} factory that creates a non-XA DataSource based on the
 * hibernate properties (url, dirver, username, password)
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class DataSourceFactory {

    /**
     * private to prevent instantiation (static methods only)
     */
    private DataSourceFactory() {
    }

    public static DataSource createDataSource(Configuration config) {

        String dialect = getPropertyChecked(config, HibernateConstants.HIBERNATE_DIALECT_PROP);
        String url = getPropertyChecked(config, HibernateConstants.HIBERNATE_URL_PROP);
        String driver = getPropertyChecked(config, HibernateConstants.HIBERNATE_DRIVER_PROP);
        String username = getPropertyChecked(config, HibernateConstants.HIBERNATE_USERNAME_PROP);
        String password = config.getString(HibernateConstants.HIBERNATE_PASSWD_PROP);

        SqlDialect sqlDialect = SqlDialect.fromDialectString(dialect);

        DataSource dataSource = null;
        switch (sqlDialect) {
            case ORACLE:
                dataSource = createOracleDataSource(url, driver, username, password);
                break;
            case HSQLDB:
                dataSource = createHsqldbDataSource(url, driver, username, password);
                break;
            default:
                throw new IllegalArgumentException("SQL dialect " + sqlDialect + " not supported.");
        }

        return dataSource;
    }

    private static String getPropertyChecked(Configuration config, String name) {
        String value = config.getString(name);

        if (value == null) {
            throw new PipelineException("Required property " + name + " not set!");
        }
        return value;
    }

    private static DataSource createHsqldbDataSource(String url, String driver, String username, String password) {

        try {
            Class.forName(driver);
        } catch (ClassNotFoundException cnfe) {
            throw new PipelineException("Failed to load JDBC driver \"" + driver + "\".", cnfe);
        }

        JDBCDataSource dataSource = new JDBCDataSource();
        dataSource.setDatabase(url);
        dataSource.setUser(username);
        dataSource.setPassword(password);

        return dataSource;
    }

    private static DataSource createOracleDataSource(String url, String driver, String username, String password) {

        OracleDataSource oracleDataSource = null;
        try {
            oracleDataSource = new OracleDataSource();
        } catch (SQLException e) {
            throw new PipelineException("Failed to create Oracle data source.", e);
        }

        oracleDataSource.setURL(url);
        oracleDataSource.setUser(username);
        oracleDataSource.setPassword(password);

        return oracleDataSource;
    }
}
