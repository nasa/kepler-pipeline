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
import gov.nasa.kepler.hibernate.cm.Characteristic;
import gov.nasa.kepler.hibernate.cm.CharacteristicCrud;
import gov.nasa.kepler.hibernate.cm.CharacteristicType;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Exports all the characteristics to a file.
 * 
 * @author Sean McCauliff
 */
public class CharacteristicExporter {
    private static final Log log = LogFactory.getLog(CharacteristicExporter.class);
    // These are names of columns in the query below. This is not concatenated
    // into the string to improve readability of query.
    private static final String KEPLERID = "keplerId";
    private static final String TYPENAME = "typeName";
    private static final String CHARVALUE = "charValue";

    private static final String CHAR_QUERY = "select c.kepler_id as keplerId, t.name as typeName, c.value as charValue"
        + " from cm_char c "
        + "inner join cm_char_type t "
        + " on c.type_Id = t.id " + " order by c.kepler_id, c.type_Id";

    private static final int PROGRESS_MODULO = 100000;

    /**
     * 
     * @param indicator
     */
    public void export(ProgressIndicator indicator, ExportOptions exportOptions) {
        BufferedWriter bw = null;
        Connection conn = null;
        Statement stmt = null;
        ResultSet resultSet = null;

        try {
            DatabaseService dbService = DatabaseServiceFactory.getInstance();
            CharacteristicCrud charCrud = new CharacteristicCrud(dbService);
            Collection<CharacteristicType> charTypesColl = charCrud.retrieveAllCharacteristicTypes();
            Map<String, CharacteristicType> typeIdToType = new HashMap<String, CharacteristicType>();

            for (CharacteristicType type : charTypesColl) {
                typeIdToType.put(type.getName(), type);
            }

            bw = new BufferedWriter(new FileWriter(exportOptions.destFile()));

            // This uses SQL because JPOX can not efficently handle scrolling
            // through
            // 15M objects.
            conn = DatabaseServiceFactory.getInstance()
                .getConnection();

            stmt = conn.createStatement();

            resultSet = stmt.executeQuery(CHAR_QUERY);

            int count = 0;
            while (resultSet.next()) {
                int keplerId = resultSet.getInt(KEPLERID);
                String typeName = resultSet.getString(TYPENAME);
                double value = resultSet.getDouble(CHARVALUE);
                CharacteristicType type = typeIdToType.get(typeName);
                Characteristic c = new Characteristic(keplerId, type, value);
                bw.write(c.toString());
                bw.write("\n");
                count++;
                if (count % PROGRESS_MODULO == 0) {
                    indicator.progress(count, c.toString());
                }
            }

            indicator.progress(count, "Done.");

        } catch (Exception ex) {
            log.error(ex);
            indicator.progress(-1, ex.toString());
        } finally {
            try {
                if (bw != null) {
                    bw.close();
                }
            } catch (IOException iox) {
                indicator.progress(-1, iox.toString());
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
     * @return Returns the number of characteristics or 0 if no characteristics
     * are present.
     */
    public int lengthOfTask(ExportOptions exportOptions) {
        CharacteristicCrud charOps = new CharacteristicCrud(
            DatabaseServiceFactory.getInstance());
        return charOps.characteristicCount();
    }
}
