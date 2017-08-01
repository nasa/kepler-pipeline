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

import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Simple class that loads SQL from a file and executes it using JDBC
 * 
 * @author tklaus
 * 
 */
public class SqlRunner {
    private static final Log log = LogFactory.getLog(SqlRunner.class);

    private ConnectInfo connectInfo;
    private Connection cachedConnection;

    public SqlRunner(ConnectInfo connectInfo) {
        this.connectInfo = connectInfo;
    }

    /**
     * (Re)connect to the database.
     * 
     * @throws PipelineException
     */
    public void connect() {
        try {
            Class.forName(connectInfo.getDriverName());
            cachedConnection = DriverManager.getConnection(
                connectInfo.getUrl(), connectInfo.getUsername(),
                connectInfo.getPassword());
        } catch (Exception e) {
            throw new PipelineException("failed to connect to: "
                + connectInfo.getUrl(), e);
        }
    }

    public void commit() throws SQLException {
        getCachedConnection().commit();
    }

    public Connection getCachedConnection() {
        return cachedConnection;
    }

    /**
     * Execute SQL commands. Each element in the array is executed separately
     * 
     * @param commands
     * @throws SQLException
     * @throws PipelineException
     */
    public void executeSql(String[] commands) throws SQLException {
        executeSqlStatements(commands, false);
    }

    /**
     * Load SQL commands from a file and execute.
     * 
     * @param path
     * @throws SQLException
     * @throws PipelineException
     */
    public void executeSql(File path) throws SQLException {
        executeSql(path, false);
    }

    public void executeSql(File path, boolean continueOnError)
        throws SQLException {
        String[] commands;
        try {
            commands = loadSql(path);
        } catch (IOException e1) {
            throw new PipelineException("failed to load: " + path, e1);
        }
        executeSqlStatements(commands, continueOnError);
    }

    private void executeSqlStatements(String[] commands, boolean continueOnError)
        throws SQLException {
        Statement stmt = cachedConnection.createStatement();

        try {
            for (int line = 0; line < commands.length; line++) {
                String command = commands[line];
                if (command.trim()
                    .length() == 0) {
                    continue;
                }
                try {
                    try {
                        stmt.execute(command);
                    } catch (SQLException e) {
                        if (!continueOnError) {
                            throw e;
                        }
                    }

                    ResultSet rs = stmt.getResultSet();

                    if (rs != null) {
                        ResultSetMetaData rsmd = rs.getMetaData();
                        int numberOfColumns = rsmd.getColumnCount();

                        while (rs.next()) {
                            for (int colIdx = 1; colIdx <= numberOfColumns; colIdx++) {
                                System.out.print(rs.getObject(colIdx));
                                if (colIdx < numberOfColumns) {
                                    System.out.print(",");
                                }
                            }
                            System.out.println();
                        }
                    }
                } catch (SQLException e) {
                    throw new SQLException(e.getMessage() + ": line " + line
                        + ": " + commands[line], e);
                }
            }
        } finally {
            stmt.close();
        }
    }

    private String[] loadSql(File path) throws FileNotFoundException,
        IOException {

        BufferedReader fileReader = new BufferedReader(new FileReader(path));
        StringBuilder bld = new StringBuilder((int) path.length());
        try {
            for (String line = fileReader.readLine(); line != null; line = fileReader.readLine()) {
                bld.append(line);
                bld.append(" ");
            }

            // Delete the last space so it won't be interpreted as a command.
            bld.deleteCharAt(bld.length() - 1);
        } finally {
            FileUtil.close(fileReader);
        }

        return bld.toString()
            .split(";");
    }

    private static String getPropertyChecked(Configuration config, String name)
        throws Exception {
        String value = config.getString(name);

        if (value == null) {
            throw new Exception("Required property " + name + " not set!");
        }
        return value;
    }

    private static void usage() {
        System.err.println("USAGE: execsql [-noCommit] [-continueOnError] FILENAME");
        System.exit(-1);
    }

    public static void main(String[] args) {
        boolean doCommit = true;
        boolean continueOnError = false;
        String filename = null;

        for (String arg : args) {
            if (filename != null) {
                System.err.println("Too many arguments");
                usage();
            }

            if (arg.equalsIgnoreCase("-noCommit")) {
                doCommit = false;
            } else if (arg.equalsIgnoreCase("-continueOnError")) {
                continueOnError = true;
            } else {
                filename = arg;
            }
        }

        if (filename == null) {
            usage();
        }

        File sqlFile = new File(filename);

        if (!sqlFile.isFile()) {
            System.err.println(filename
                + " does not exist or is not a regular file");
            System.exit(-1);
        }

        Configuration config = ConfigurationServiceFactory.getInstance();

        try {
            String url = getPropertyChecked(config,
                HibernateConstants.HIBERNATE_URL_PROP);
            String driver = getPropertyChecked(config,
                HibernateConstants.HIBERNATE_DRIVER_PROP);
            String username = getPropertyChecked(config,
                HibernateConstants.HIBERNATE_USERNAME_PROP);
            String password = getPropertyChecked(config,
                HibernateConstants.HIBERNATE_PASSWD_PROP);

            SqlRunner sqlRunner = new SqlRunner(new ConnectInfo(driver, url,
                username, password));

            log.info("Connecting to: " + url);

            sqlRunner.connect();

            log.info("Executing SQL in: " + sqlFile);

            sqlRunner.executeSql(sqlFile, continueOnError);

            if (doCommit) {
                log.info("Committing transaction");
                sqlRunner.commit();
            }

            log.info("SQL execution completed successfully");
        } catch (Exception e) {
            log.error("Failed to execute SQL script", e);
        }

    }
}
