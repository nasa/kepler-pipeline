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

package gov.nasa.kepler.mc.obslog;

import gov.nasa.kepler.hibernate.mc.ObservingLog;

import java.io.BufferedReader;
import java.io.FileReader;
import java.util.ArrayList;

/**
 * @author Todd Klaus todd.klaus@nasa.gov
 * 
 */
public class GenerateXmlFromCsv {

    private GenerateXmlFromCsv() {
    }

    /**
     * Ex: 
     * test-data/observing-log/observing-log-seed.csv
     * test-data/observing-log/observing-log-seed.xml
     * 
     * @param args
     * @throws Exception
     */
    public static void main(String[] args) throws Exception {
        if (args.length != 2) {
            System.err.println("USAGE: genxml CSVFILE XMLFILE");
            System.exit(1);
        }

        BufferedReader br = null;
        
        try {
            ArrayList<ObservingLog> obsList = new ArrayList<ObservingLog>();
            FileReader fr = new FileReader(args[0]);
            br = new BufferedReader(fr);
            String oneLine = br.readLine(); // skip header
            oneLine = br.readLine();

            while (oneLine != null) {
                String[] elements = oneLine.split(",");

                if (elements.length < 11) {
                    throw new RuntimeException("line too short: " + oneLine);
                }

                int name = Integer.parseInt(elements[0]);
                int quarter = Integer.parseInt(elements[1]);
                int month = Integer.parseInt(elements[2]);
                int season = Integer.parseInt(elements[3]);
                int cadenceType = Integer.parseInt(elements[4]);
                int startCadence = Integer.parseInt(elements[5]);
                int endCadence = Integer.parseInt(elements[6]);
                int nCadences = Integer.parseInt(elements[7]);
                double startMjd = Double.parseDouble(elements[8]);
                double endMjd = Double.parseDouble(elements[9]);
                int tableId = Integer.parseInt(elements[10]);

                ObservingLog obs = new ObservingLog(cadenceType, startCadence, endCadence, startMjd, endMjd, 
                    quarter, month, season, tableId);
                obsList.add(obs);
                
                // read the next line
                oneLine = br.readLine();
            }
            
            ObservingLogXml xml = new ObservingLogXml();
            xml.writeToFile(obsList, args[1]);
            
        } catch (Exception e) {
            System.err.println("caught e: " + e.getMessage());
            System.exit(1);
        } finally {
            br.close();
        }
    }
}