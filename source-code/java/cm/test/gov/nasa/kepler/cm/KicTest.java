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

package gov.nasa.kepler.cm;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;

import org.junit.Test;

/**
 * Smoke test for the CM_KIC table. This test also requires the CM_SKY_GROUP
 * table which in turn requires the FC_ROLLTIME table. But that is all.
 * 
 * @author Bill Wohler
 */
public class KicTest {

    /** The season when module/output 2/1 is sky group 1. */
    private static int STARTING_SEASON = 1;

    // Each element in this array contains module/output/KeplerId.
    // These are representative stars near the middle of each module/output.
    private int[][] kicData = { { 2, 1, 9497693 }, { 2, 2, 10276029 },
        { 2, 3, 10621002 }, { 2, 4, 9867944 }, { 3, 1, 11225273 },
        { 3, 2, 11944058 }, { 3, 3, 12300549 }, { 3, 4, 11622867 },
        { 4, 1, 12899518 }, { 4, 2, 13505077 }, { 4, 3, 13772995 },
        { 4, 4, 13238902 }, { 6, 1, 7003680 }, { 6, 2, 7477332 },
        { 6, 3, 6554271 }, { 6, 4, 6072902 }, { 7, 1, 8357833 },
        { 7, 2, 9254670 }, { 7, 3, 9703596 }, { 7, 4, 8825295 },
        { 8, 1, 10260256 }, { 8, 2, 11015515 }, { 8, 3, 11347288 },
        { 8, 4, 10674731 }, { 9, 1, 12354102 }, { 9, 2, 11929142 },
        { 9, 3, 12558661 }, { 9, 4, 13006407 }, { 10, 1, 13761992 },
        { 10, 2, 13386610 }, { 10, 3, 13913921 }, { 10, 4, 14277573 },
        { 11, 1, 5530037 }, { 11, 2, 6250637 }, { 11, 3, 5217696 },
        { 11, 4, 4563993 }, { 12, 1, 7880636 }, { 12, 2, 8438155 },
        { 12, 3, 7544256 }, { 12, 4, 6985910 }, { 13, 1, 9900898 },
        { 13, 2, 10320115 }, { 13, 3, 9688890 }, { 13, 4, 9153059 },
        { 14, 1, 11335073 }, { 14, 2, 10869449 }, { 14, 3, 11459419 },
        { 14, 4, 11921597 }, { 15, 1, 12881197 }, { 15, 2, 12406054 },
        { 15, 3, 12992171 }, { 15, 4, 13381285 }, { 16, 1, 3710760 },
        { 16, 2, 4664715 }, { 16, 3, 3269041 }, { 16, 4, 2372767 },
        { 17, 1, 6413017 }, { 17, 2, 7068028 }, { 17, 3, 6140906 },
        { 17, 4, 5512062 }, { 18, 1, 9144602 }, { 18, 2, 8233636 },
        { 18, 3, 7695246 }, { 18, 4, 8599907 }, { 19, 1, 10793785 },
        { 19, 2, 10173679 }, { 19, 3, 9672001 }, { 19, 4, 10372432 },
        { 20, 1, 11713075 }, { 20, 2, 11190048 }, { 20, 3, 11772832 },
        { 20, 4, 12330696 }, { 22, 1, 5504142 }, { 22, 2, 4412469 },
        { 22, 3, 3396641 }, { 22, 4, 4750472 }, { 23, 1, 7602559 },
        { 23, 2, 6784555 }, { 23, 3, 6123029 }, { 23, 4, 7050656 },
        { 24, 1, 9592698 }, { 24, 2, 8778474 }, { 24, 3, 8121803 },
        { 24, 4, 9038918 } };

    private DatabaseService databaseService;
    private KicCrud kicCrud;

    public KicTest() {
        databaseService = DatabaseServiceFactory.getInstance();
        kicCrud = new KicCrud(databaseService);
    }

    @Test
    public void testSkyGroups() throws Exception {
        for (int[] kicInfo : kicData) {
            int ccdModule = kicInfo[0];
            int ccdOutput = kicInfo[1];
            int keplerId = kicInfo[2];
            int skyGroupId = kicCrud.retrieveSkyGroupId(ccdModule, ccdOutput,
                STARTING_SEASON);
            Kic kic = kicCrud.retrieveKic(keplerId);
            assertNotNull(kic);
            assertEquals(skyGroupId, kic.getSkyGroupId());
        }
    }
}
