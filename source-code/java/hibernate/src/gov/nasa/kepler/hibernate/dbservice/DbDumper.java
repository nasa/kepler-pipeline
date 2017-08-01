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

import gov.nasa.kepler.common.RegexEditor;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;
import java.util.regex.Pattern;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;

/**
 * DbDumper - writes the contents of selected tables to a file
 * 
 * @author jgunter
 * 
 */
public class DbDumper {

    private static final Log log = LogFactory.getLog(DbDumper.class);

    private static final String FIELD_SEPARATOR = ",";
    private static final String COLUMN_EXPRESSION_SEPARATOR = "?";
    private static final String[] ALL_TABLES = new String[] { "%" };
    private static final String[] NO_COLUMNS = new String[] {};

    private ConnectInfo connectInfo;
    private Connection connection;
    private DatabaseMetaData dmd;
    private String[] tablePrefixes = ALL_TABLES;
    private String[] undesiredColumns = NO_COLUMNS;

    private final Map<String, Pattern[]> patternsByColumn = new HashMap<String, Pattern[]>();

    private static String exFilename;

    private static String acFilename;

    public static void main(String[] args) throws Exception {
        Logger logger = Logger.getLogger(DbDumper.class);
        logger.setLevel(Level.DEBUG);
        org.apache.log4j.BasicConfigurator.configure();

        File expectedFile = null;
        File actualFile = null;

        int i;
        for (i = 0; i < args.length; i++) {
            if (args[i].equals("x")) {
                args[i] = "";
            }
            log.info(String.format("args[%s]= " + args[i]));
        }
        i = 0;

        ConnectInfo connectInfo = new ConnectInfo("org.hsqldb.jdbcDriver",
            args[i++], "sa", "");

        if (args[i].equals("v")) {
            expectedFile = new File(args[++i]);
            actualFile = new File(args[++i]);
            DbDumper dbDumper = new DbDumper();
            dbDumper.validateDatabase(expectedFile, actualFile);
        } else {
            DbDumper dbDumper = new DbDumper(connectInfo);
            dbDumper.setTablePrefixes(nullIfNull(args[i++]));
            dbDumper.setUndesiredColumnNames(nullIfNull(args[i++]));
            dbDumper.writeDesiredTableData(new File(args[i++]));
        }
    }

    /**
     * If passed "null" returns null, otherwise returns String passed. This
     * allows null to be expressed when running DbDumper from command line.
     * 
     * @param s
     * @return
     */
    private static String nullIfNull(String s) {
        return s.equals("null") ? null : s;
    }

    /**
     * Constructor used when dumping all tables and columns, or when separate
     * calls to setTablePrefixes and setExcludeColumns makes sense.
     * 
     * @param connectInfo
     * @throws Exception
     */
    public DbDumper(ConnectInfo connectInfo) throws Exception {
        this.connectInfo = connectInfo;
        init();
    }

    /**
     * Constructor used when table prefixes and excluded columns are known up
     * front.
     * 
     * @param connectInfo
     * @param prefixes
     * @param excludeColumns
     * @throws Exception
     */
    public DbDumper(ConnectInfo connectInfo, String[] prefixes,
        String[] excludeColumns) throws Exception {
        this.connectInfo = connectInfo;
        setTablePrefixes(prefixes);
        setUndesiredColumnNames(excludeColumns);
        init();
    }

    public DbDumper() throws Exception {
        this(new ConnectInfo());
    }

    /**
     * Get database connection and get database metadata.
     * 
     * @throws Exception
     */
    private void init() throws Exception {
        connect();
        dmd = connection.getMetaData();
    }

    public void setTablePrefixes(String csv) {
        setTablePrefixes(csv.split(","));
    }

    public void setTablePrefixes(String[] prefixes) {
        tablePrefixes = prefixes;
    }

    public void setUndesiredColumnNames(String csv) {
        setUndesiredColumnNames(csv.split(","));
    }

    public void setUndesiredColumnNames(String[] names) {
        undesiredColumns = names;
    }

    /**
     * Reads database metadata to find tables whose names match table prefixes,
     * then determines which columns should be selected from the database, and
     * performs those queries to generate the output file.
     * 
     * @param outFile
     * @throws Exception
     */
    public void writeDesiredTableData(File outFile) throws Exception {
        log.info("Writing " + outFile.getAbsolutePath());
        if (tablePrefixes.equals(ALL_TABLES)) {
            log.info("all tables will be written");
        }
        if (undesiredColumns.equals(NO_COLUMNS)) {
            log.info("all columns will be written");
        }

        BufferedWriter output = new BufferedWriter(new FileWriter(outFile));

        updatePatternsByTable();

        // use database metadata to find tables with names matching prefixes
        List<String> tableNames = new ArrayList<String>();
        Map<String, ArrayList<String>> selects = new HashMap<String, ArrayList<String>>();
        for (String element : tablePrefixes) {
            log.debug("table prefix #1 = " + element);
            ResultSet tablesRS = dmd.getTables(null, null,
                element.toUpperCase() + "%", new String[] { "TABLE" });
            log.debug("tablesRS.getRow()=" + tablesRS.getRow());
            while (tablesRS.next()) {
                String tableName = tablesRS.getString("TABLE_NAME");
                log.info("table name: " + tableName);
                tableNames.add(tableName);

                // build list of desired (non-excluded) column names
                ResultSet columnsRS = dmd.getColumns(null, null,
                    tableName.toUpperCase(), null);
                log.debug("columnsRS.getRow()=" + columnsRS.getRow());
                String tableColumns = "";
                String comma = "";
                ArrayList<String> columnNames = new ArrayList<String>();
                while (columnsRS.next()) {
                    String colName = columnsRS.getString("COLUMN_NAME");
                    log.debug("colName = " + colName);
                    String colSize = columnsRS.getString("COLUMN_SIZE");
                    log.debug("colSize = " + colSize);

                    String fullColName = tableName + "." + colName;
                    int j = 0;
                    log.debug("undesiredColumns.length="
                        + undesiredColumns.length);
                    for (; j < undesiredColumns.length; j++) {
                        String column = undesiredColumns[j];
                        log.debug(String.format("undesiredColumns[%s]=", column));
                        if (column.indexOf(COLUMN_EXPRESSION_SEPARATOR) == -1
                            && fullColName.equalsIgnoreCase(column)) {
                            break;
                        }
                    }
                    if (j == undesiredColumns.length) {
                        tableColumns += comma + colName;
                        comma = ", ";
                        columnNames.add(colName);
                    }
                }
                columnsRS.close();
                if (0 == tableColumns.length()) {
                    tableColumns = "*";
                }
                if (0 == columnNames.size()) {
                    log.error("all columns filtered away for table "
                        + tableName);
                } else {
                    // sort the column names to ensure output comparability
                    Collections.sort(columnNames);
                    selects.put(tableName, columnNames);
                }
            }
            tablesRS.close();
        }

        // sort table names to ensure output comparability
        Collections.sort(tableNames);

        // build and run a SELECT statement for each table
        for (String tableName : tableNames) {
            log.debug("table name: " + tableName);
            ArrayList<String> columnNames = selects.get(tableName);
            if (null == columnNames || 0 == columnNames.size()) {
                log.warn("no columns selected from table " + tableName);
                continue;
            }
            String comma = "";
            String select = "SELECT ";
            for (String columnName : columnNames) {
                select += comma + columnName;
                comma = FIELD_SEPARATOR;
            }
            select += " FROM " + tableName;
            Statement stmt = connection.createStatement();
            log.info("select statement: " + select);
            output.write(select + "\n");
            ResultSet rs = stmt.executeQuery(select);
            log.debug("rs.getRow() = " + rs.getRow());
            List<String> tableLines = new ArrayList<String>(rs.getFetchSize());
            while (rs.next()) {
                String outLine = "";
                comma = "";
                ResultSetMetaData rsmd = rs.getMetaData();
                int ncols = rsmd.getColumnCount();
                for (int c = 1; c <= ncols; c++) {
                    outLine += comma + rs.getString(c);
                    comma = FIELD_SEPARATOR;
                }
                log.debug("row data = " + outLine);
                tableLines.add(outLine);
            }
            Collections.sort(tableLines);
            for (String line : tableLines) {
                output.write(line + "\n");
            }
            rs.close();
            stmt.close();
        }
        output.close();
    } // writeDesiredTableData

    /**
     * Compares two files written by writeDesiredTableData.
     */
    public void validateDatabase(File expectedData, File actualData)
        throws Exception {

        exFilename = expectedData.getAbsolutePath();
        acFilename = actualData.getAbsolutePath();
        log.info("actual=" + acFilename + ", expected=" + exFilename);

        DumpFile ac;
        try {
            ac = new DumpFile("actual", actualData);
        } catch (Exception e) {
            throw exception("Actual data file missing.");
        }
        DumpFile ex;
        try {
            ex = new DumpFile("expected", expectedData);
        } catch (Exception e) {
            throw exception("Expected data file was missing; "
                + "consider copying "
                + actualData.getAbsolutePath()
                + " to "
                + expectedData.getAbsolutePath()
                + " and rerunning this test to validate against the new expected data file.");
        }

        updatePatternsByTable();

        String[] exColumnValues = null;
        String[] acColumnValues = null;
        List<String> diffSelects = new ArrayList<String>();
        Set<String> tableNames = new TreeSet<String>();
        Set<String> diffColumns = new HashSet<String>();
        Map<String, Integer> diffCount = new HashMap<String, Integer>();
        int diffRows = 0;
        int totalDiffRows = 0;
        int totalDiffValues = 0;
        String allDiffs = "";
        boolean skipToNextSelect = false;

        while (true) {
            ex.read();
            ac.read();
            if (ex.eof && ac.eof) {
                break;
            }

            tableNames.add(ex.tableName);
            tableNames.add(ac.tableName);
            if (ex.select && ac.select) {
                diffRows = 0;
                int tableNameComparison = ex.tableName.compareTo(ac.tableName);
                skipToNextSelect = ex.waiting = ac.waiting = false;
                if (tableNameComparison == 0) {
                    // compare columns in SELECT statements
                    if (!ex.line.equals(ac.line)) {
                        diffSelects.add("Columns differ for table "
                            + ex.tableName + ":\nexpected columns:\n"
                            + ex.line + " (line #)" + ex.lines
                            + ":\nactual columns:\n" + ac.line
                            + " (line #)" + ac.lines);
                        skipToNextSelect = true;
                    }
                } else if (tableNameComparison < 0) {
                    // ex.tableName is alphabetically before current
                    // ac.tableName,
                    // so ex has a table that ac does not.
                    // Loop through the data rows of the current ex table
                    // and wait to see if ac has the next ex table.
                    ac.waiting = true;
                } else { // tableNameComparison > 0
                    ex.waiting = true;
                }
                continue;
            }

            if (ex.select && !ac.select) {
                // ac has more rows in current table than ex.
                // Just wait for next table (select statement).
                // Differing row counts appears in the report summation.
                if (!ac.eof) {
                    ex.waiting = true;
                }
                continue;
            }
            if (!ex.select && ac.select) {
                if (!ex.eof) {
                    ac.waiting = true;
                }
                continue;
            }

            if (!ex.waiting && !ex.eof && !ac.waiting && !ac.eof
                && !skipToNextSelect) {
                // compare data rows
                exColumnValues = ex.line.split(FIELD_SEPARATOR);
                acColumnValues = ac.line.split(FIELD_SEPARATOR);
                // need columns
                if (exColumnValues.length != acColumnValues.length) {
                    // If the expected vs actual selects matched
                    // but we get a different # of columns in the data
                    // we bail out. This should never happen.
                    throw exception("INTERNAL ERROR IN DBDUMPER, UNEQUAL NUMBER OF COLUMN VALUES:\n"
                        + "expected: table="
                        + ex.tableName
                        + ", #rows="
                        + ex.rowsInTable
                        + " line="
                        + ex.line
                        + "\nactual: table="
                        + ac.tableName
                        + ", #rows="
                        + ac.rowsInTable + " line=" + ac.line);
                }
                String diffs = ""; // diffs for this row
                boolean diffsInRow = false;
                for (int i = 0; i < ex.columnNames.length; i++) {
                    String tabCol = ex.tableName + "." + ex.columnNames[i];
                    Pattern[] patterns = patternsByColumn.get(tabCol);
                    if (((patterns == null || patterns.length == 0) && !exColumnValues[i].equals(acColumnValues[i]))
                        || ((patterns != null && patterns.length > 0) && !RegexEditor.stringEquals(
                            exColumnValues[i], acColumnValues[i], patterns))) {
                        diffsInRow = true;
                        totalDiffValues++;
                        // To make error reporting concise,
                        // we only report the first difference for a particular
                        // column.
                        if (!diffColumns.contains(tabCol)) {
                            diffColumns.add(tabCol);
                            diffs += "\n   column #" + i + " (column name="
                                + ex.columnNames[i]
                                + "): \n      expected value = '"
                                + exColumnValues[i] + "'"
                                + "\n      actual   value = '"
                                + acColumnValues[i] + "'";
                        }
                    }
                }
                if (diffsInRow) {
                    diffRows++;
                    totalDiffRows++;
                }
                diffCount.put(ex.tableName, diffRows);
                if (0 != diffs.length()) {
                    allDiffs += "\nTable " + ex.tableName
                        + ", first conflicting row: expected row #"
                        + ex.rowsInTable + " (line #" + ex.lines + ") "
                        + ", actual row #" + ac.rowsInTable + " (line #"
                        + ac.lines + ") " + ": differences:" + diffs;
                }
            }
        }

        // gather differences into a single message to throw in an exception
        String msg = "";
        for (String s : diffSelects) {
            msg += "\n" + s;
        }
        for (String table : tableNames) {
            String s = "";
            int exRows = -1;
            int acRows = -1;
            s += "\nTable " + table;
            if (ex.tableNames.contains(table)) {
                exRows = ex.rowCount.get(table);
                s += ": expected has " + exRows + " rows";
            } else {
                s += " (table missing in expected)";
            }
            if (ac.tableNames.contains(table)) {
                acRows = ac.rowCount.get(table);
                s += ": actual has " + acRows + " rows";
            } else {
                s += " (table missing in actual)";
            }
            Integer n = diffCount.get(table);
            int diffs = 0;
            if (null != n) {
                diffs = diffCount.get(table);
            }
            if (diffs > 0) {
                s += ": differences found in " + diffs + " rows.";
            }
            if (exRows != acRows || diffs > 0) {
                msg += s;
            }

        }
        if (0 != allDiffs.length()) {
            msg += "\n" + allDiffs;
            if (totalDiffRows > 0) {
                msg += "\n\nTotal number of differing rows for all tables = "
                    + String.format("%,d", totalDiffRows);
                msg += "\nTotal number of differing values for all tables = "
                    + String.format("%,d", totalDiffValues);
            }
            String comma = "";
            String potentialExcludeColumns = "";
            List<String> tabCols = new ArrayList<String>();
            for (String colName : diffColumns) {
                tabCols.add(colName);
            }
            Collections.sort(tabCols);
            for (String tabCol : tabCols) {
                potentialExcludeColumns += comma + "\"" + tabCol + "\"";
                comma = ",\n";
            }
            msg += "\n\nColumns to consider for exclusion:\n"
                + potentialExcludeColumns;
        }
        if (0 != msg.length()) {
            throw exception(msg);
        }
    }

    private static Exception exception(String msg) throws Exception {
        String fullMsg = "Validation failed:  data files not identical:"
            + "\nExpected data file = " + exFilename
            + "\nActual   data file = " + acFilename + "\nDifferences:" + msg;
        log.error(fullMsg);
        return new Exception(fullMsg);
    }

    /**
     * (Re)connect to the database.
     * 
     * @throws PipelineException
     */
    public void connect() throws PipelineException {
        try {
            Class.forName(connectInfo.getDriverName());
            connection = DriverManager.getConnection(connectInfo.getUrl(),
                connectInfo.getUsername(), connectInfo.getPassword());
        } catch (Exception e) {
            throw new PipelineException("failed to connect to: "
                + connectInfo.getUrl(), e);
        }
    }

    public Connection getConnection() {
        return connection;
    }

    private void updatePatternsByTable() {
        patternsByColumn.clear();
        if (undesiredColumns != null) {
            for (String column : undesiredColumns) {
                int index = column.indexOf(COLUMN_EXPRESSION_SEPARATOR);
                if (index != -1) {
                    String columnName = column.substring(0, index++);
                    String excludeRegex = column.substring(index);
                    String regexWithNonCaptureGroup = "(.*)(?:" + excludeRegex + ")(.*)";
                    Pattern pattern = Pattern.compile(regexWithNonCaptureGroup);
                    patternsByColumn.put(columnName, new Pattern[] { pattern });
                }
            }
        }
    }

    private static final class DumpFile {
        private BufferedReader in = null;
        private boolean eof = false;
        private boolean select = false;
        private boolean waiting = false;
        private String line = "";
        private Set<String> tableNames = new TreeSet<String>();
        private String tableName = "";
        private String[] columnNames = new String[0];
        private int lines = 0;
        private int rowsInTable = 0;
        private Map<String, Integer> rowCount = new HashMap<String, Integer>();

        private DumpFile(String type, File file) throws FileNotFoundException {
            in = new BufferedReader(new FileReader(file));
        }

        public String read() {
            if (waiting) {
                return "";
            }
            try {
                if (null == (line = in.readLine())) {
                    eof = true;
                    line = "";
                }
            } catch (Exception e) {
                eof = true;
                line = "";
            }
            if (eof) {
                return line;
            }
            lines++;
            // if (tableName.length() > 0) {
            // rowCount.put(tableName, rowsInTable);
            // }
            select = false;
            if (line.startsWith("SELECT ")) {
                select = true;
                int i = line.lastIndexOf(" FROM ");
                // skip the 6 characters of " FROM "
                tableName = line.substring(i + 6);
                tableNames.add(tableName);
                columnNames = line.substring(7, i)
                    .split(FIELD_SEPARATOR);
                rowsInTable = 0;
                // rowCount.put(tableName, rowsInTable);
            } else {
                // log.info("line=" + line);
                if (tableName.length() <= 0) {
                    log.error("INTERNAL ERROR: EMPTY TABLE NAME");
                }
                rowsInTable++;
            }
            rowCount.put(tableName, rowsInTable);
            // log.info(inFile.getName() + ": tableName="+tableName+",
            // rowsInTable="+rowsInTable+": line="+line);
            return line;
        }
    }
}
