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

import static org.junit.Assert.assertEquals;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.sql.Connection;
import java.sql.Statement;

import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.junit.Test;

public class DbDumperTest {

    private static final Log log = LogFactory.getLog(DbDumperTest.class);
    static {
        Logger.getLogger(DbDumper.class)
            .setLevel(Level.INFO);
        org.apache.log4j.BasicConfigurator.configure();
    }

    private static final String tablePrefix = "DbDumperTest";
    private static final int NROWS = 5;
    private static final String OUTDIR = Filenames.BUILD_TMP;

    private Connection connection;

    private void dropTable(String table) throws Exception {
        Statement stmt = connection.createStatement();
        String sql = "drop table " + table;
        try {
            stmt.executeQuery(sql);
        } catch (Exception e) {
            log.info("cannot " + sql);
        }
    }

    private void dropTables(int n) throws Exception {
        for (int i = 1; i <= n; i++) {
            dropTable(tablePrefix + i);
        }
    }

    @SuppressWarnings("unused")
    private void createTable(String table, String cols, int nRows,
        String[] valmods) throws Exception {
        dropTable(table);

        String[] columns = cols.split(",");

        Statement stmt = connection.createStatement();
        String sql = "create table " + table + " ( ";
        String comma = "";
        for (String c : columns) {
            sql += comma + c + " varchar(10)";
            comma = ",";
        }
        sql += ")";
        log.info("sql: " + sql);
        stmt.executeQuery(sql);

        for (int i = 0; i < nRows; i++) {
            sql = "insert into " + table + " ( ";
            comma = "";
            for (String c : columns) {
                sql += comma + c;
                comma = ",";
            }
            sql += ") values (";
            comma = "";
            int col = 0;
            for (String c : columns) {
                // sql += comma + "'" + table + "_" + c + "_" + i + ( fiddle &&
                // comma.equals("") ? "X" : "" ) + "'";
                sql += comma + "'" + i;
                if (i < valmods.length && valmods[i].charAt(col) != ' ') {
                    sql += 'X';
                }
                sql += "'";
                comma = ",";
                col++;
            }
            sql += ")";
            if (0 == i % (nRows / 5)) {
                log.info("sql: " + sql);
            }
            stmt.executeQuery(sql);
        }

        stmt.executeQuery("commit");
    }

    @Test
    public void test() throws Exception {

        // open a connection to the database
        DbDumper d = new DbDumper();
        connection = d.getConnection();

        dropTables(5);

        log.info("++++++++++++++++++++ round 1:  create tables, run dumper,");
        log.info("assert that an exception was thrown indicating expected.dump was created along with actual.dump");
        for (int i = 1; i <= 2; i++) {
            createTable(tablePrefix + i, "a,b", NROWS, new String[] { "  ",
                "  " });
        }

        d.setTablePrefixes(tablePrefix);
        d.setUndesiredColumnNames(new String[] {});

        File expected = new File(OUTDIR, "expected.dump");
        File actual = new File(OUTDIR, "actual.dump");
        expected.delete();
        actual.delete();

        d.writeDesiredTableData(actual);
        assert actual.exists();

        boolean threw = false;
        try {
            d.validateDatabase(expected, actual);
        } catch (Exception e) {
            log.info("EXCEPTION MESSAGE=" + e.getMessage());
            threw = true;
        }
        assertEquals(threw, true);
        assert actual.exists();
        log.info("copying actual to expected");
        FileUtils.copyFile(actual, expected);
        assert expected.exists();

        log.info("++++++++++++++++++++ round 2:  recreate tables with slightly different data, run dumper,");
        log.info("assert that an exception was thrown indicating dump files differ");
        for (int i = 1; i <= 2; i++) {
            createTable(tablePrefix + i, "a,b", NROWS, new String[] { "XX",
                " X" });
        }

        d.writeDesiredTableData(actual);

        threw = false;
        try {
            d.validateDatabase(expected, actual);
        } catch (Exception e) {
            // log.info("EXCEPTION MESSAGE="+e.getMessage());
            threw = true;
        }
        // log.info("threw="+threw);
        assertEquals(threw, true);
        assert actual.exists();
        assert expected.exists();

        log.info("++++++++++++++++++++ round 3:  recreate tables with original data, run dumper,");
        log.info("assert that no exception was thrown (files match)");
        for (int i = 1; i <= 2; i++) {
            createTable(tablePrefix + i, "a,b", NROWS, new String[] { "  ",
                "  " });
        }

        d.writeDesiredTableData(actual);

        threw = false;
        try {
            d.validateDatabase(expected, actual);
        } catch (Exception e) {
            log.info("EXCEPTION MESSAGE=" + e.getMessage());
            threw = true;
        }
        assertEquals(threw, false);
        assert actual.exists();
        assert expected.exists();

        log.info("++++++++++++++++++++ round 4:  recreate tables with diff # rows, run dumper,");
        log.info("assert that an exception was thrown (row count diff)");
        createTable(tablePrefix + 1, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 1, "a,b", NROWS + 1, new String[] { "  ",
            "  " });

        d.writeDesiredTableData(actual);

        threw = false;
        try {
            d.validateDatabase(expected, actual);
        } catch (Exception e) {
            log.info("EXCEPTION MESSAGE=" + e.getMessage());
            threw = true;
        }
        assertEquals(threw, true);
        assert actual.exists();
        assert expected.exists();

        log.info("++++++++++++++++++++ round 5:  recreate tables with extra table, run dumper,");
        log.info("assert that an exception was thrown ()");
        createTable(tablePrefix + 1, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 2, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 3, "a,b", NROWS, new String[] { "  ", "  " });

        d.writeDesiredTableData(actual);

        threw = false;
        try {
            d.validateDatabase(expected, actual);
        } catch (Exception e) {
            log.info("EXCEPTION MESSAGE=" + e.getMessage());
            threw = true;
        }
        assertEquals(threw, true);
        assert actual.exists();
        assert expected.exists();

        log.info("++++++++++++++++++++ round 6:  recreate tables with missing table, run dumper,");
        log.info("assert that an exception was thrown ()");

        log.info("copying actual to expected");
        FileUtils.copyFile(actual, expected);

        dropTables(5);
        createTable(tablePrefix + 1, "a,b", NROWS, new String[] { "X ", "X " });
        createTable(tablePrefix + 3, "a,b", NROWS, new String[] { " X", "  " });

        d.writeDesiredTableData(actual);

        threw = false;
        try {
            d.validateDatabase(expected, actual);
        } catch (Exception e) {
            log.info("EXCEPTION MESSAGE=" + e.getMessage());
            threw = true;
        }
        assertEquals(threw, true);
        assert actual.exists();
        assert expected.exists();

        log.info("++++++++++++++++++++ round 7:  create pattern of alternating tables, run dumper,");
        log.info("assert that an exception was thrown ()");

        dropTables(5);
        createTable(tablePrefix + 1, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 2, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 3, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 5, "a,b", NROWS, new String[] { "  ", "  " });
        d.writeDesiredTableData(actual);
        log.info("copying actual to expected");
        FileUtils.copyFile(actual, expected);
        dropTables(5);
        createTable(tablePrefix + 1, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 3, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 4, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 5, "a,b", NROWS, new String[] { "  ", "  " });
        d.writeDesiredTableData(actual);

        threw = false;
        try {
            d.validateDatabase(expected, actual);
        } catch (Exception e) {
            log.info("EXCEPTION MESSAGE=" + e.getMessage());
            threw = true;
        }
        assertEquals(threw, true);
        assert actual.exists();
        assert expected.exists();

        log.info("++++++++++++++++++++ round 8A:  empty table test, run dumper,");
        log.info("assert that an exception was thrown ()");

        dropTables(5);
        createTable(tablePrefix + 1, "a,b", 0, new String[] { "  ", "  " });
        createTable(tablePrefix + 2, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 3, "a,b", NROWS, new String[] { "  ", "  " });
        d.writeDesiredTableData(actual);
        log.info("copying actual to expected");
        FileUtils.copyFile(actual, expected);
        dropTables(5);
        createTable(tablePrefix + 1, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 2, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 3, "a,b", NROWS, new String[] { "  ", "  " });
        d.writeDesiredTableData(actual);

        threw = false;
        try {
            d.validateDatabase(expected, actual);
        } catch (Exception e) {
            log.info("EXCEPTION MESSAGE=" + e.getMessage());
            threw = true;
        }
        assertEquals(threw, true);
        assert actual.exists();
        assert expected.exists();

        log.info("++++++++++++++++++++ round 8B:  empty table test, run dumper,");
        log.info("assert that an exception was thrown ()");

        dropTables(5);
        createTable(tablePrefix + 1, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 2, "a,b", 0, new String[] { "  ", "  " });
        createTable(tablePrefix + 3, "a,b", NROWS, new String[] { "  ", "  " });
        d.writeDesiredTableData(actual);
        log.info("copying actual to expected");
        FileUtils.copyFile(actual, expected);
        dropTables(5);
        createTable(tablePrefix + 1, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 2, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 3, "a,b", NROWS, new String[] { "  ", "  " });
        d.writeDesiredTableData(actual);

        threw = false;
        try {
            d.validateDatabase(expected, actual);
        } catch (Exception e) {
            log.info("EXCEPTION MESSAGE=" + e.getMessage());
            threw = true;
        }
        assertEquals(threw, true);
        assert actual.exists();
        assert expected.exists();

        log.info("++++++++++++++++++++ round 8C:  empty table test, run dumper,");
        log.info("assert that an exception was thrown ()");

        dropTables(5);
        createTable(tablePrefix + 1, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 2, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 3, "a,b", 0, new String[] { "  ", "  " });
        d.writeDesiredTableData(actual);
        log.info("copying actual to expected");
        FileUtils.copyFile(actual, expected);
        dropTables(5);
        createTable(tablePrefix + 1, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 2, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 3, "a,b", NROWS, new String[] { "  ", "  " });
        d.writeDesiredTableData(actual);

        threw = false;
        try {
            d.validateDatabase(expected, actual);
        } catch (Exception e) {
            log.info("EXCEPTION MESSAGE=" + e.getMessage());
            threw = true;
        }
        assertEquals(threw, true);
        assert actual.exists();
        assert expected.exists();

        log.info("++++++++++++++++++++ round 8D:  empty table test, run dumper,");
        log.info("assert that an exception was thrown ()");

        dropTables(5);
        createTable(tablePrefix + 1, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 2, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 3, "a,b", NROWS, new String[] { "  ", "  " });
        d.writeDesiredTableData(actual);
        log.info("copying actual to expected");
        FileUtils.copyFile(actual, expected);
        dropTables(5);
        createTable(tablePrefix + 1, "a,b", 0, new String[] { "  ", "  " });
        createTable(tablePrefix + 2, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 3, "a,b", NROWS, new String[] { "  ", "  " });
        d.writeDesiredTableData(actual);

        threw = false;
        try {
            d.validateDatabase(expected, actual);
        } catch (Exception e) {
            log.info("EXCEPTION MESSAGE=" + e.getMessage());
            threw = true;
        }
        assertEquals(threw, true);
        assert actual.exists();
        assert expected.exists();

        log.info("++++++++++++++++++++ round 8E:  empty table test, run dumper,");
        log.info("assert that an exception was thrown ()");

        dropTables(5);
        createTable(tablePrefix + 1, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 2, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 3, "a,b", NROWS, new String[] { "  ", "  " });
        d.writeDesiredTableData(actual);
        log.info("copying actual to expected");
        FileUtils.copyFile(actual, expected);
        dropTables(5);
        createTable(tablePrefix + 1, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 2, "a,b", 0, new String[] { "  ", "  " });
        createTable(tablePrefix + 3, "a,b", NROWS, new String[] { "  ", "  " });
        d.writeDesiredTableData(actual);

        threw = false;
        try {
            d.validateDatabase(expected, actual);
        } catch (Exception e) {
            log.info("EXCEPTION MESSAGE=" + e.getMessage());
            threw = true;
        }
        assertEquals(threw, true);
        assert actual.exists();
        assert expected.exists();

        log.info("++++++++++++++++++++ round 8F:  empty table test, run dumper,");
        log.info("assert that an exception was thrown ()");

        dropTables(5);
        createTable(tablePrefix + 1, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 2, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 3, "a,b", NROWS, new String[] { "  ", "  " });
        d.writeDesiredTableData(actual);
        log.info("copying actual to expected");
        FileUtils.copyFile(actual, expected);
        dropTables(5);
        createTable(tablePrefix + 1, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 2, "a,b", NROWS, new String[] { "  ", "  " });
        createTable(tablePrefix + 3, "a,b", 0, new String[] { "  ", "  " });
        d.writeDesiredTableData(actual);

        threw = false;
        try {
            d.validateDatabase(expected, actual);
        } catch (Exception e) {
            log.info("EXCEPTION MESSAGE=" + e.getMessage());
            threw = true;
        }
        assertEquals(threw, true);
        assert actual.exists();
        assert expected.exists();

        log.info("++++++++++++++++++++ done, dropping tables");

        dropTables(5);

        log.info("END TEST");
    }
}
