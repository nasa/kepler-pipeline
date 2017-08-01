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

package gov.nasa.kepler.ar.exporter;

import gov.nasa.kepler.ar.ProgressIndicator;
import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Date;
import java.util.concurrent.LinkedBlockingQueue;

/**
 * Exports the Kepler Input Catalog (KIC) to '|' delimited file. This class is
 * not MT safe.
 * 
 * @author Sean McCauliff
 * 
 */
public class InputCatalogExporter {

    private static final int PROGRESS_MODULO = 100000;

    // database column name constants
    private static final String KEPLER_ID = "KEPLER_ID";
    private static final String RA = "RA";
    private static final String DEC = "DEC";
    private static final String ALTID = "ALTID";
    private static final String ALTSRC = "ALTSOURCE";
    private static final String AQ = "AQ";
    private static final String AV = "AV";
    private static final String BLEND = "BLEND";
    private static final String CATKEY = "CATKEY";
    private static final String D51MAG = "D51MAG";
    private static final String PMDEC = "PMDEC";
    private static final String EBMINUSV = "EBMINUSV";
    private static final String TEFF = "TEFF";
    private static final String GLAT = "GLAT";
    private static final String GLON = "GLON";
    private static final String GMAG = "GMAG";
    private static final String GALAXY = "GALAXY";
    private static final String GKCOLOR = "GKCOLOR";
    private static final String GRCOLOR = "GRCOLOR";
    private static final String GREDMAG = "GREDMAG";
    private static final String IMAG = "IMAG";
    private static final String SCPID = "SCPID";
    private static final String JKCOLOR = "JKCOLOR";
    private static final String KEPMAG = "KEPMAG";
    private static final String FEH = "FEH";
    private static final String LOGG = "LOGG";
    private static final String PARALLAX = "PARALLAX";
    private static final String PQ = "PQ";
    private static final String RMAG = "RMAG";
    private static final String RADIUS = "RADIUS";
    private static final String PMRA = "PMRA";
    private static final String SCPKEY = "SCPKEY";
    private static final String CQ = "CQ";
    private static final String PMTOTAL = "PMTOTAL";
    private static final String HMAG = "HMAG";
    private static final String TMID = "TMID";
    private static final String JMAG = "JMAG";
    private static final String KMAG = "KMAG";
    private static final String UMAG = "UMAG";
    private static final String VARIABLE = "VARIABLE";
    private static final String ZMAG = "ZMAG";

    public InputCatalogExporter() {
    }

    public String uiDisplayName() {
        return "Input Catalog";
    }

    /**
     * 
     * @param indicator
     */
    public void export(final ProgressIndicator indicator,
        ExportOptions exportOptions) {

        BufferedWriter out = null;

        // This uses SQL because JPOX can not efficiently handle scrolling
        // through
        // 15M objects.
        Connection conn = null;
        Statement stmt = null;
        ResultSet resultSet = null;
        try {
            conn = DatabaseServiceFactory.getInstance()
                .getConnection();

            stmt = conn.createStatement();
            resultSet = stmt.executeQuery("select * from cm_kic order by kepler_id");

            KicCrud kicCrud = new KicCrud(DatabaseServiceFactory.getInstance());

            out = new BufferedWriter(new FileWriter(exportOptions.destFile()));
            out.write("# timestamp: ");
            Iso8601Formatter timeStampFormatter = new Iso8601Formatter();
            out.write(timeStampFormatter.format(new Date()));
            out.write(" internal-version: ");
            out.write(KicCrud.getKicVersion());
            out.write("\n");
            final int kicCount = kicCrud.kicCount();
            final LinkedBlockingQueue<Kic> queue = new LinkedBlockingQueue<Kic>(
                1000);

            final ResultSet rs = resultSet;
            final StringBuffer done = new StringBuffer();

            Runnable producer = new Runnable() {

                public void run() {
                    int progressCount = 0;
                    try {
                        while (rs.next()) {
                            Kic kic = new Kic.Builder(rs.getInt(KEPLER_ID),
                                rs.getDouble(RA), rs.getDouble(DEC)).alternateId(
                                nullableInteger(rs, ALTID))
                                .alternateSource(nullableInteger(rs, ALTSRC))
                                .astrophysicsQuality(nullableInteger(rs, AQ))
                                .avExtinction(nullableFloat(rs, AV))
                                .blendIndicator(nullableInteger(rs, BLEND))
                                .catalogId(nullableInteger(rs, CATKEY))
                                .d51Mag(nullableFloat(rs, D51MAG))
                                .decProperMotion(nullableFloat(rs, PMDEC))
                                .ebMinusVRedding(nullableFloat(rs, EBMINUSV))
                                .effectiveTemp(nullableInteger(rs, TEFF))
                                .galacticLatitude(nullableDouble(rs, GLAT))
                                .galacticLongitude(nullableDouble(rs, GLON))
                                .galaxyIndicator(nullableInteger(rs, GALAXY))
                                .gkColor(nullableFloat(rs, GKCOLOR))
                                .gMag(nullableFloat(rs, GMAG))
                                .grColor(nullableFloat(rs, GRCOLOR))
                                .gredMag(nullableFloat(rs, GREDMAG))
                                .iMag(nullableFloat(rs, IMAG))
                                .internalScpId(nullableInteger(rs, SCPID))
                                .jkColor(nullableFloat(rs, JKCOLOR))
                                .keplerMag(nullableFloat(rs, KEPMAG))
                                .log10Metallicity(nullableFloat(rs, FEH))
                                .log10SurfaceGravity(nullableFloat(rs, LOGG))
                                .parallax(nullableFloat(rs, PARALLAX))
                                .photometryQuality(nullableInteger(rs, PQ))
                                .radius(nullableFloat(rs, RADIUS))
                                .raProperMotion(nullableFloat(rs, PMRA))
                                .rMag(nullableFloat(rs, RMAG))
                                .scpId(nullableInteger(rs, SCPKEY))
                                .source(nullableString(rs, CQ))
                                .totalProperMotion(nullableFloat(rs, PMTOTAL))
                                .twoMassHMag(nullableFloat(rs, HMAG))
                                .twoMassId(nullableInteger(rs, TMID))
                                .twoMassJMag(nullableFloat(rs, JMAG))
                                .twoMassKMag(nullableFloat(rs, KMAG))
                                .uMag(nullableFloat(rs, UMAG))
                                .variableIndicator(
                                    nullableInteger(rs, VARIABLE))
                                .zMag(nullableFloat(rs, ZMAG))
                                .build();

                            progressCount++;
                            if ((progressCount % PROGRESS_MODULO) == 0) {
                                indicator.progress(progressCount, "Kepler id: "
                                    + kic.getKeplerId());
                            }
                            queue.put(kic);

                        }
                    } catch (SQLException sqle) {
                        indicator.progress(-1, sqle.toString());
                    } catch (InterruptedException interr) {
                        indicator.progress(-1, interr.toString());
                    }

                    if (progressCount != kicCount) {
                        indicator.progress(-1, "Expected to write " + kicCount
                            + " entries, but wrote " + progressCount + ".");
                    } else {
                        indicator.progress(progressCount, "");
                    }
                    done.append("done");
                }
            };
            (new Thread(producer, "KicProducer")).start();

            while (true) {
                Kic kic = queue.poll();
                if (kic == null) {
                    if (done.length() != 0) {
                        break;
                    } else {
                        try {
                            Thread.sleep(50);
                        } catch (InterruptedException ie) {
                            // ok
                        }
                    }
                } else {
                    out.write(kic.toString());
                    out.write('\n');
                }
            }

            out.write("# END\n");
            out.close();

        } catch (IOException ioe) {
            // TODO: How to report this nicely?
            // TODO: Should I clean up output?
            indicator.progress(0, ioe.toString());
        } catch (PipelineException px) {
            px.printStackTrace();
            indicator.progress(0, px.toString());
        } catch (SQLException sqle) {
            indicator.progress(-1, sqle.toString());
        } finally {
            if (out != null) {
                try {
                    out.close();
                } catch (IOException ignore) {
                }
            }
            if (resultSet != null) {
                try {
                    resultSet.close();
                } catch (SQLException ignored) {
                }
            }
            if (stmt != null) {
                try {
                    stmt.close();
                } catch (SQLException ignored) {
                }
            }
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException ignored) {
                }
            }
        }
    }

    /**
     * 
     * @return The number of KIC entries in the database.
     */
    public int lengthOfTask(ExportOptions exportOptions) {
        KicCrud kicCrud = new KicCrud(DatabaseServiceFactory.getInstance());
        return kicCrud.kicCount();
    }

    public static void main(String[] argv) throws Exception {
        ExportOptions xo = new ExportOptions(0, Integer.MAX_VALUE, new File(
            argv[0]), "none");
        InputCatalogExporter exporter = new InputCatalogExporter();
        System.out.println("Exporter found " + exporter.lengthOfTask(xo)
            + " records.");
        exporter.export(new ProgressIndicator() {

            public void progress(int progress, String message) {
                System.out.println("" + progress + " " + message);
            }

            public void progress(Throwable t, String message) {
                System.out.println(message);
                t.printStackTrace();

            }
        }, xo);

    }

    private Float nullableFloat(ResultSet rs, String colName)
        throws SQLException {
        float value = rs.getFloat(colName);
        if (rs.wasNull()) {
            return null;
        }
        return new Float(value);
    }

    private Integer nullableInteger(ResultSet rs, String colName)
        throws SQLException {
        int value = rs.getInt(colName);
        if (rs.wasNull()) {
            return null;
        }
        return value;
    }

    private String nullableString(ResultSet rs, String colName)
        throws SQLException {
        String value = rs.getString(colName);
        if (rs.wasNull()) {
            return null;
        }
        return value;
    }

    private Double nullableDouble(ResultSet rs, String colName)
        throws SQLException {
        double value = rs.getDouble(colName);
        if (rs.wasNull()) {
            return null;
        }
        return new Double(value);
    }

}