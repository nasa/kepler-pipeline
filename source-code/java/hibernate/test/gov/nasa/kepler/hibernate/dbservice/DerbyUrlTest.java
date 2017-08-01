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

import org.junit.Test;

/**
 * @author Sean McCauliff
 * 
 */
public class DerbyUrlTest {

    @Test
    public void derbyUrlTest() {
        DerbyUrl parsed = DerbyUrl.parseDerbyUrl("jdbc:derby:db");
        assertEquals("db", parsed.databaseName);
        assertEquals("", parsed.attributes);

        parsed = DerbyUrl.parseDerbyUrl("jdbc:derby:path/to/db");
        assertEquals("path/to/db", parsed.databaseName);

        parsed = DerbyUrl.parseDerbyUrl("jdbc:derby:path/to/db;create=true,shutdown=false");
        assertEquals("path/to/db", parsed.databaseName);
        assertEquals("create=true,shutdown=false", parsed.attributes);

        parsed = DerbyUrl.parseDerbyUrl("jdbc:derby://192.168.1.1/db/name");
        assertEquals("db/name", parsed.databaseName);
        assertEquals("", parsed.attributes);
        assertEquals(DerbyUrl.DERBY_DEFAULT_PORT, parsed.portNumber);
        assertEquals("192.168.1.1", parsed.hostName);

        parsed = DerbyUrl.parseDerbyUrl("jdbc:derby://host:1234/db;option=yes");
        assertEquals("db", parsed.databaseName);
        assertEquals("option=yes", parsed.attributes);
        assertEquals(1234, parsed.portNumber);
        assertEquals("host", parsed.hostName);

    }
}
