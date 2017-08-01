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

package gov.nasa.kepler.sggen;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Test;

/**
 * Tests a full run of the {@link SkyGroupGenPipelineModule}.
 * <p>
 * This class contains mappings between a sky group ID and a representative
 * Kepler ID for the default season for each version of the KIC. These lists
 * were created as follows:
 * <ol>
 * <li>cd cm/bin
 * <li>cc ../../fc/src/ra2pixcgi.c -o ra2pixcgi -lm
 * <li>representativeTargets /path/to/kic/kic-v9
 * </ol>
 * <p>
 * It actually doesn't matter where you run <i>representativeTargets</i> or
 * where <i>ra2pixcgi</i> is located, just so long as both it and ra2pixcgi are
 * in your path. This process takes about 6 hours.
 * 
 * @see SkyGroup#DEFAULT_SEASON
 * 
 * @author Bill Wohler
 */
public class SkyGroupGenTest {

    private static final Log log = LogFactory.getLog(SkyGroupGenTest.class);

    private static final int KIC_V7_COUNT = 15124609;
    private static final int KIC_V7_SKY_GROUP_DATA[][] = { { 1, 13815008 },
        { 2, 13494979 }, { 3, 14017458 }, { 4, 14385481 }, { 5, 12940436 },
        { 6, 12477977 }, { 7, 13104384 }, { 8, 13489833 }, { 9, 11777040 },
        { 10, 11321641 }, { 11, 11906686 }, { 12, 12472041 }, { 13, 12957434 },
        { 14, 13557948 }, { 15, 13877310 }, { 16, 13294299 }, { 17, 12425150 },
        { 18, 12000497 }, { 19, 12701378 }, { 20, 13118199 }, { 21, 11399329 },
        { 22, 10937683 }, { 23, 11591144 }, { 24, 12063088 }, { 25, 10932179 },
        { 26, 10242077 }, { 27, 9746282 }, { 28, 10439779 }, { 29, 9739839 },
        { 30, 8957461 }, { 31, 8216293 }, { 32, 9128349 }, { 33, 11356562 },
        { 34, 12014629 }, { 35, 12441252 }, { 36, 11686964 }, { 37, 10328096 },
        { 38, 11081833 }, { 39, 11476601 }, { 40, 10818625 }, { 41, 9238932 },
        { 42, 9972290 }, { 43, 10454615 }, { 44, 9762776 }, { 45, 9311152 },
        { 46, 8422606 }, { 47, 7782759 }, { 48, 8694685 }, { 49, 7776762 },
        { 50, 6965308 }, { 51, 6217135 }, { 52, 7146443 }, { 53, 9569554 },
        { 54, 10344160 }, { 55, 10767087 }, { 56, 10010496 }, { 57, 8449285 },
        { 58, 9333028 }, { 59, 9777684 }, { 60, 9003043 }, { 61, 8057983 },
        { 62, 8621186 }, { 63, 7716776 }, { 64, 7078369 }, { 65, 6604134 },
        { 66, 7256176 }, { 67, 6235109 }, { 68, 5622491 }, { 69, 5614940 },
        { 70, 4649272 }, { 71, 3547462 }, { 72, 4859276 }, { 73, 7097385 },
        { 74, 7649427 }, { 75, 6650009 }, { 76, 6170471 }, { 77, 5746077 },
        { 78, 6343075 }, { 79, 5326739 }, { 80, 4676180 }, { 81, 3997271 },
        { 82, 4879290 }, { 83, 3422713 }, { 84, 2511417 } };

    private static final int KIC_V9_COUNT = 13523635;
    private static final int KIC_V9_SKY_GROUP_DATA[][] = { { 1, 12230151 },
        { 2, 11914460 }, { 3, 12428448 }, { 4, 12791454 }, { 5, 11369321 },
        { 6, 10931951 }, { 7, 11529367 }, { 8, 11909378 }, { 9, 10249439 },
        { 10, 9812032 }, { 11, 10377217 }, { 12, 10926152 }, { 13, 11385686 },
        { 14, 11976945 }, { 15, 12291101 }, { 16, 11717026 }, { 17, 10880631 },
        { 18, 10468778 }, { 19, 11146059 }, { 20, 11543038 }, { 21, 9887830 },
        { 22, 9442615 }, { 23, 10070603 }, { 24, 10530348 }, { 25, 9437311 },
        { 26, 8761824 }, { 27, 8283724 }, { 28, 8956132 }, { 29, 8277880 },
        { 30, 7518635 }, { 31, 6818962 }, { 32, 7684835 }, { 33, 9845738 },
        { 34, 10482536 }, { 35, 10895948 }, { 36, 10162319 }, { 37, 8846315 },
        { 38, 9580812 }, { 39, 9962442 }, { 40, 9327831 }, { 41, 7791985 },
        { 42, 8500521 }, { 43, 8970836 }, { 44, 8299689 }, { 45, 7862548 },
        { 46, 7013129 }, { 47, 6415347 }, { 48, 7271408 }, { 49, 6409586 },
        { 50, 5642779 }, { 51, 4927669 }, { 52, 5813901 }, { 53, 8113651 },
        { 54, 8862229 }, { 55, 9277731 }, { 56, 8537278 }, { 57, 7038586 },
        { 58, 7883735 }, { 59, 8313807 }, { 60, 7562658 }, { 61, 6670550 },
        { 62, 7204595 }, { 63, 6353091 }, { 64, 5751304 }, { 65, 5296093 },
        { 66, 5916776 }, { 67, 4945253 }, { 68, 4355282 }, { 69, 4347814 },
        { 70, 3411095 }, { 71, 2338099 }, { 72, 3612709 }, { 73, 5768343 },
        { 74, 6288619 }, { 75, 5338873 }, { 76, 4882759 }, { 77, 4476424 },
        { 78, 5050990 }, { 79, 4066528 }, { 80, 3436480 }, { 81, 2775169 },
        { 82, 3632305 }, { 83, 2216341 }, { 84, 1319999 } };

    private static final int KIC_V10_COUNT = 13161029;
    private static final int KIC_V10_SKY_GROUP_DATA[][] = { { 1, 11912487 },
        { 2, 11605707 }, { 3, 12104996 }, { 4, 12457063 }, { 5, 11075379 },
        { 6, 10652268 }, { 7, 11231235 }, { 8, 11600807 }, { 9, 9995594 },
        { 10, 9569880 }, { 11, 10119000 }, { 12, 10646800 }, { 13, 11091272 },
        { 14, 11666321 }, { 15, 11971764 }, { 16, 11413919 }, { 17, 10602872 },
        { 18, 10206867 }, { 19, 10858314 }, { 20, 11244450 }, { 21, 9643600 },
        { 22, 9210014 }, { 23, 9821385 }, { 24, 10266163 }, { 25, 9204919 },
        { 26, 8547323 }, { 27, 8081702 }, { 28, 8736724 }, { 29, 8076092 },
        { 30, 7339899 }, { 31, 6665221 }, { 32, 7499869 }, { 33, 9602654 },
        { 34, 10220148 }, { 35, 10617561 }, { 36, 9910755 }, { 37, 8629608 },
        { 38, 9344612 }, { 39, 9716179 }, { 40, 9098331 }, { 41, 7602904 },
        { 42, 8292908 }, { 43, 8750818 }, { 44, 8097252 }, { 45, 7671209 },
        { 46, 6852347 }, { 47, 6271942 }, { 48, 7101515 }, { 49, 6266407 },
        { 50, 5515542 }, { 51, 4814603 }, { 52, 5683320 }, { 53, 7916016 },
        { 54, 8645161 }, { 55, 9049602 }, { 56, 8328860 }, { 57, 6876992 },
        { 58, 7691853 }, { 59, 8111099 }, { 60, 7382202 }, { 61, 6521228 },
        { 62, 7037035 }, { 63, 6210910 }, { 64, 5621739 }, { 65, 5175615 },
        { 66, 5783907 }, { 67, 4831677 }, { 68, 4253695 }, { 69, 4246414 },
        { 70, 3328636 }, { 71, 2283787 }, { 72, 3526336 }, { 73, 5638421 },
        { 74, 6147808 }, { 75, 5217528 }, { 76, 4770425 }, { 77, 4372192 },
        { 78, 4935132 }, { 79, 3970844 }, { 80, 3353447 }, { 81, 2708528 },
        { 82, 3545410 }, { 83, 2165283 }, { 84, 1293707 } };

    private static final SkyGroupData[] SKY_GROUP_DATA = {
        new SkyGroupData(7, KIC_V7_COUNT, KIC_V7_SKY_GROUP_DATA),
        new SkyGroupData(9, KIC_V9_COUNT, KIC_V9_SKY_GROUP_DATA),
        new SkyGroupData(10, KIC_V10_COUNT, KIC_V10_SKY_GROUP_DATA) };

    private CelestialObjectOperations celestialObjectOperations = new CelestialObjectOperations(
        new ModelMetadataRetrieverLatest(), false);

    @Test
    public void testSkyGroupGen() throws Exception {
        for (int[] skyGroupMap : getSkyGroupData()) {
            int expectedSkyGroupId = skyGroupMap[0];
            int keplerId = skyGroupMap[1];
            Kic kic = (Kic) celestialObjectOperations.retrieveCelestialObject(keplerId);
            assertNotNull("No KIC entry for Kepler ID " + keplerId, kic);
            log.info("Checking keplerId=" + kic.getKeplerId() + " at ra="
                + kic.getRa() + " (" + 15 * kic.getRa() + " degrees) dec="
                + kic.getDec() + ", expected skyGroupId=" + expectedSkyGroupId
                + ", actual=" + kic.getSkyGroupId());
            assertEquals("Sky group for Kepler ID " + kic.getKeplerId(),
                expectedSkyGroupId, kic.getSkyGroupId());
        }
    }

    /**
     * Determines which KIC is in use and returns the appropriate data for that
     * KIC. This method makes this determination by counting the number of
     * records in the KIC since this tends to change each release.
     * 
     * @return a non-{@code null} 2D array of sky group IDs and Kepler IDs.
     * @throws IllegalStateException if the loaded KIC isn't recognized by this
     * program
     */
    private int[][] getSkyGroupData() {
        int kicCount = new KicCrud().kicCount();

        for (SkyGroupData skyGroupData : SKY_GROUP_DATA) {
            if (kicCount == skyGroupData.getKicCount()) {
                log.info("Testing KIC version " + skyGroupData.getKicVersion());
                return skyGroupData.getSkyGroupData();
            }
        }
        throw new IllegalStateException("Unknown KIC");
    }

    private static class SkyGroupData {
        private int kicVersion;
        private int kicCount;
        private int[][] skyGroupData;

        public SkyGroupData(int kicVersion, int kicCount,
            int[][] kicV10SkyGroupData) {
            this.kicVersion = kicVersion;
            this.kicCount = kicCount;
            skyGroupData = kicV10SkyGroupData;
        }

        public int getKicVersion() {
            return kicVersion;
        }

        public int getKicCount() {
            return kicCount;
        }

        public int[][] getSkyGroupData() {
            return skyGroupData;
        }
    }
}
