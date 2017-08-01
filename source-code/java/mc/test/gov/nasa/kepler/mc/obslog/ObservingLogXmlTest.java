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

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.hibernate.mc.ObservingLog;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Test;

/**
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class ObservingLogXmlTest {
    private static final Log log = LogFactory.getLog(ObservingLogXmlTest.class);

    @Test
    public void testRoundTrip() throws Exception {
        // create some ObservationIntervals
        List<ObservingLog> expectedList = new ArrayList<ObservingLog>();
        
        expectedList.add(new ObservingLog(Cadence.CADENCE_SHORT, 100, 200, 55000.5, 55030.5, 1, 1, 1, 42));
        expectedList.add(new ObservingLog(Cadence.CADENCE_SHORT, 210, 300, 55031.5, 55060.5, 1, 2, 1, 43));
        expectedList.add(new ObservingLog(Cadence.CADENCE_SHORT, 310, 400, 55061.5, 55090.5, 1, 3, 1, 44));
        expectedList.add(new ObservingLog(Cadence.CADENCE_SHORT, 410, 500, 55091.5, 55120.5, 2, 1, 2, 45));
        expectedList.add(new ObservingLog(Cadence.CADENCE_SHORT, 510, 600, 55121.5, 55150.5, 2, 2, 2, 46));
        expectedList.add(new ObservingLog(Cadence.CADENCE_SHORT, 610, 700, 55151.5, 55180.5, 2, 3, 2, 47));
        
        ObservingLogXml xml = new ObservingLogXml();
        
        File xmlFile = File.createTempFile("ObservingLogXmlTest", ".xml");
        
        log.info("xmlFile: " + xmlFile);
        
        xml.writeToFile(expectedList, xmlFile.getAbsolutePath());
        
        List<ObservingLog> actualList = xml.readFromFile(xmlFile.getAbsolutePath());

        assertEquals("actualList.size()", 6, actualList.size());

        for (int i = 0; i < actualList.size(); i++) {
            ObservingLog expected = expectedList.get(i);
            ObservingLog actual = actualList.get(i);
            
            log.info("actual: " + actual);
            
            ReflectionEquals comparer = new ReflectionEquals();
            comparer.assertEquals("ParameterSet", expected, actual);
        }
    }
}
