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

import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.common.FilenameConstants;
import gov.nasa.spiffy.common.os.ProcessUtils;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hsqldb.Server;

/**
 * Utility methods for test code to interact with the HSQLDB database server and
 * associated files.
 * 
 * @author Forrest Girouard (forrest.girouard@nasa.gov)
 * @author tklaus
 * 
 */
public class HsqldbUtils {
    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(HsqldbUtils.class);

    private static final String INSERT_SQL_STRING = "INSERT INTO";

    private HsqldbUtils() {
    }

    /**
     * Remove the default HSQLDB schema directory
     * {@link gov.nasa.kepler.common.DefaultProperties#getHsqldbSchemaDir()} and
     * then recreate it.
     * 
     * @throws IOException
     */
    public static void cleanSchemaDir() throws IOException {

        File schemaDir = new File(DefaultProperties.getHsqldbSchemaDir());
        FileUtils.deleteDirectory(schemaDir);
        FileUtils.forceMkdir(schemaDir);
    }

    /**
     * Start the database in networked mode The server can be shutdown using
     * JDBC and the SHUTDOWN command
     * 
     * @param cachedTableType if true, use disk-cached tables instead of memory
     * tables. Allows larger databases and uses less memory, but database
     * contents are not captured in the .script file in this mode so it is not
     * suitable for AFT use.
     */
    public static void startNetworkDatabase(boolean cachedTableType) {

        Server server = new org.hsqldb.Server();

        server.setDatabaseName(0, "kepler");
        server.setDatabasePath(0, "file:"
            + DefaultProperties.getHsqldbSchemaDir() + "/kepler");

        Configuration config = ConfigurationServiceFactory.getInstance();
        int port = config.getInt("hsqldb.server.port", -1);
        if (port != -1) {
            server.setPort(port);
        }

        server.setSilent(true);
        server.setNoSystemExit(true);

        server.start();
    }

    public static Process startNetworkDatabaseInNewVm(boolean cachedTableType)
        throws IOException {

        return ProcessUtils.runJava(org.hsqldb.Server.class,
            getDatabaseArgs(cachedTableType));
    }

    private static List<String> getDatabaseArgs(boolean defaultCachedTableType) {
        List<String> args = new ArrayList<String>();

        Configuration config = ConfigurationServiceFactory.getInstance();

        boolean cachedTableType = config.getBoolean("cacheAllTables",
            defaultCachedTableType);
        String tableType = cachedTableType ? ";hsqldb.default_table_type=cached"
            : "";
        args.add("-database.0");
        args.add("file:" + DefaultProperties.getHsqldbSchemaDir() + "/kepler"
            + tableType);
        args.add("-dbname.0");
        args.add("kepler");

        String port = config.getString("hsqldb.server.port");
        if (port != null) {
            args.add("-port");
            args.add(port);
        }

        return args;
    }

    /**
     * Clears the HSQLDB *.log file of any un-checkpointed operations and brings
     * the *.script file up to date.
     * 
     * This method should be called before exporting the database.
     * 
     * @throws PipelineException
     */
    public static void checkpoint(ConnectInfo connectInfo) {

        SqlRunner sqlRunner = new SqlRunner(connectInfo);
        try {
            sqlRunner.connect();
            sqlRunner.executeSql(new String[] { "CHECKPOINT" });
        } catch (SQLException e) {
            throw new PipelineException(
                "failed to execute SQL CHECKPOINT, caught", e);
        }
    }

    /**
     * Tell the HSQLDB server to shutdown
     * 
     * @throws PipelineException
     */
    public static void shutdown(ConnectInfo connectInfo) {

        SqlRunner sqlRunner = new SqlRunner(connectInfo);
        try {
            sqlRunner.connect();
            sqlRunner.executeSql(new String[] { "SHUTDOWN" });
        } catch (SQLException e) {
            throw new PipelineException(
                "failed to execute SQL SHUTDOWN, caught", e);
        }
    }

    /**
     * Set a database property using JDBC
     * 
     * @throws PipelineException
     */
    public static void setDbProperty(ConnectInfo connectInfo, String propName,
        String propValue) {

        SqlRunner sqlRunner = new SqlRunner(connectInfo);
        try {
            sqlRunner.connect();
            sqlRunner.executeSql(new String[] { "SET PROPERTY \"" + propName
                + "=" + propValue + "\"" });
        } catch (SQLException e) {
            throw new PipelineException(
                "failed to execute SQL SET PROPERTY, caught", e);
        }
    }

    /**
     * Writes all INSERT SQL statements for the specified prefixes from the
     * HSQLDB kepler.script file to the output file so they can be used to
     * verify test outputs or seed a different database.
     * 
     * Make sure you call checkpoint() before calling this method to ensure that
     * all changes have been flushed from the transaction log to the script
     * file.
     * 
     * @param outputFile
     * @param tablePrefixes
     * @throws IOException
     */
    public static void exportDatabaseContents(File outputFile,
        String[] tablePrefixes) throws IOException {

        OutputStream output = new PrintStream(new BufferedOutputStream(
            new FileOutputStream(outputFile)));
        exportDatabaseContents(output, tablePrefixes);
    }

    /**
     * Writes all INSERT SQL statements for the specified prefixes from the
     * HSQLDB kepler.script file to the output stream so they can be used to
     * verify test outputs or seed a different database.
     * 
     * Make sure you call checkpoint() before calling this method to ensure that
     * all changes have been flushed from the transaction log to the script
     * file.
     * 
     * @param output
     * @param tablePrefixes
     * @throws IOException
     */
    public static void exportDatabaseContents(OutputStream output,
        String[] tablePrefixes) throws IOException {

        File scriptFile = new File(DefaultProperties.getHsqldbSchemaDir(),
            FilenameConstants.KEPLER_SCRIPT);
        BufferedReader input = new BufferedReader(new FileReader(scriptFile));
        String previousTable = "";
        boolean previousTableIncluded = false;
        boolean includeThisLine = false;

        String oneLine = input.readLine();
        while (oneLine != null) {
            includeThisLine = false; // reset
            if (oneLine.startsWith(INSERT_SQL_STRING)) {
                if (tablePrefixes == null || tablePrefixes.length == 0) {
                    // include everything
                    includeThisLine = true;
                } else {
                    int tableEnd = oneLine.indexOf(" ",
                        INSERT_SQL_STRING.length() + 1);
                    String table = oneLine.substring(
                        INSERT_SQL_STRING.length() + 1, tableEnd);

                    if (table.equals(previousTable)) {
                        /*
                         * we have already checked this prefix against the
                         * tablePrefixes List, so no need to iterate over the
                         * List again. Since the .script file is in alphabetical
                         * order, this means that we only iterate over the List
                         * once for each prefix we see in the .script file
                         */
                        includeThisLine = previousTableIncluded;
                    } else {
                        for (String prefix : tablePrefixes) {
                            if (table.startsWith(prefix)) {
                                includeThisLine = true;
                                break;
                            }
                        }
                    }

                    previousTable = table;
                    previousTableIncluded = includeThisLine;
                }

                if (includeThisLine) {
                    output.write(oneLine.getBytes());
                    output.write((byte) '\n');
                }
            }
            oneLine = input.readLine();
        }

        output.close();
        input.close();
    }

    /**
     * Captures any INSERT SQL statements from the HSQLDB kepler.script file to
     * a separate file so they can be used to verify test outputs or seed a
     * different database.
     * 
     * Make sure you call checkpoint() before calling this method to ensure that
     * all changes have been flushed from the transaction log to the script
     * file.
     * 
     * @param destFile
     * @throws IOException
     */
    public static void exportDatabaseContents(File destFile) throws IOException {

        exportDatabaseContents(destFile, null);
    }

    /**
     * Exports the HSQL from the HSQLDB kepler.script file to the specified file
     * so that it can be used to verify test outputs or seed a different
     * database.
     * 
     * Make sure you call checkpoint() before calling this method to ensure that
     * all changes have been flushed from the transaction log to the script
     * file.
     * 
     * @param outputFile
     * @throws IOException
     */
    public static void exportDatabaseSchema(File outputFile) throws IOException {

        PrintStream output = new PrintStream(new BufferedOutputStream(
            new FileOutputStream(outputFile)));
        exportDatabaseSchema(output);
    }

    /**
     * Exports the HSQL from the HSQLDB kepler.script file to the stream so that
     * it can be used to verify test outputs or seed a different database.
     * 
     * Make sure you call checkpoint() before calling this method to ensure that
     * all changes have been flushed from the transaction log to the script
     * file.
     * 
     * @param output
     * @throws IOException
     */
    public static void exportDatabaseSchema(OutputStream output)
        throws IOException {

        File scriptFile = new File(DefaultProperties.getHsqldbSchemaDir(),
            FilenameConstants.KEPLER_SCRIPT);
        BufferedReader input = new BufferedReader(new FileReader(scriptFile));

        String oneLine = input.readLine();
        while (oneLine != null) {
            if (!oneLine.startsWith(INSERT_SQL_STRING)) {
                output.write(oneLine.getBytes());
                output.write((byte) '\n');
            }
            oneLine = input.readLine();
        }

        output.close();
        input.close();
    }
}
