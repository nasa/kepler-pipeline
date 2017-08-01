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

package gov.nasa.kepler.dv;

import static junit.framework.Assert.assertEquals;
import static junit.framework.Assert.assertNotNull;
import static junit.framework.Assert.assertTrue;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.dv.io.DvTarget;
import gov.nasa.kepler.dv.io.DvTargetData;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.MockUtils;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.spiffy.common.jmock.JMockTest;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Test;

/**
 * Test the {@link TargetOperations} class.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class TargetOperationsTest extends JMockTest {

    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(TargetOperationsTest.class);

    private static final int CCD_MODULE = 7;
    private static final int CCD_OUTPUT = 3;
    private static final int START_CADENCE = 1439;
    private static final int END_CADENCE = 1488;
    private static final double START_MJD = 55553.5 + START_CADENCE
        * ModifiedJulianDate.CADENCE_LENGTH_MINUTES / (24 * 60);
    private static final double END_MJD = START_MJD
        + (END_CADENCE - START_CADENCE + 1)
        * ModifiedJulianDate.CADENCE_LENGTH_MINUTES / (24 * 60);
    private static final int QUARTER = 2;

    private static final int TARGET_TABLE_COUNT = 1;
    private static final int TARGETS_PER_TABLE = 2;
    private static final int TARGET_TABLE_ID = 42;
    private static final int MAX_PIXELS_PER_TARGET = 4;
    private static final double CROWDING_METRIC = 1.0F;
    private static final double FLUX_FRACTION = 2.0F;
    private static final double SKY_CROWDING_METRIC = 3.0;
    private static final double SIGNAL_TO_NOISE_RATIO = 4.0;
    private static final int SATURATED_ROW_COUNT = 5;
    private static final String[] LABELS = ArrayUtils.EMPTY_STRING_ARRAY;

    private TargetCrud targetCrud;
    private ReflectionEquals reflectionEquals = new ReflectionEquals();

    private TargetTable targetTable;
    private Set<Pixel> pixelsInUse = new HashSet<Pixel>();
    private Set<FsId> allTargetFsIds = new HashSet<FsId>();

    private List<ObservedTarget> observedTargets;
    Map<Integer, DvTarget> dvTargetsByKeplerId = new HashMap<Integer, DvTarget>();

    @Test
    public void testUpdateAllTargets() throws IllegalAccessException {
        populateObjects();

        TargetOperations targetOperations = new TargetOperations(targetTable,
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE, START_MJD,
            END_MJD, QUARTER, dvTargetsByKeplerId);
        targetOperations.setTargetCrud(targetCrud);
        targetOperations.updateAllTargets();
        validate();
    }

    private void populateObjects() {
        targetCrud = mock(TargetCrud.class);

        targetTable = new TargetTable(TargetType.LONG_CADENCE);
        targetTable.setExternalId(TARGET_TABLE_ID);
        observedTargets = MockUtils.mockTargets(this, targetCrud, null, false,
            targetTable, TARGETS_PER_TABLE, MAX_PIXELS_PER_TARGET, CCD_MODULE,
            CCD_OUTPUT, pixelsInUse, allTargetFsIds);
        for (ObservedTarget target : observedTargets) {
            target.setCrowdingMetric(CROWDING_METRIC);
            target.setFluxFractionInAperture(FLUX_FRACTION);
            target.setSkyCrowdingMetric(SKY_CROWDING_METRIC);
            target.setSaturatedRowCount(SATURATED_ROW_COUNT);
            target.setSignalToNoiseRatio(SIGNAL_TO_NOISE_RATIO);
            dvTargetsByKeplerId.put(target.getKeplerId(), new DvTarget());
        }
    }

    private void validate() throws IllegalAccessException {

        for (DvTarget target : dvTargetsByKeplerId.values()) {
            List<DvTargetData> targetData = target.getTargetData();
            assertNotNull(targetData);
            assertEquals(TARGET_TABLE_COUNT, targetData.size());

            DvTargetData dvTargetData = targetData.get(0);
            assertEquals(CCD_MODULE, dvTargetData.getCcdModule());
            assertEquals(CCD_OUTPUT, dvTargetData.getCcdOutput());
            assertEquals(START_CADENCE, dvTargetData.getStartCadence());
            assertEquals(END_CADENCE, dvTargetData.getEndCadence());
            assertEquals(QUARTER, dvTargetData.getQuarter());
            assertEquals(TARGET_TABLE_ID, dvTargetData.getTargetTableId());
            assertEquals(CROWDING_METRIC, dvTargetData.getCrowdingMetric(), 0);
            assertEquals(FLUX_FRACTION,
                dvTargetData.getFluxFractionInAperture(), 0);
            reflectionEquals.assertEquals(LABELS, dvTargetData.getLabels());

            Set<Pixel> pixels = dvTargetData.getPixels();
            assertTrue(pixels.size() < TARGETS_PER_TABLE
                * MAX_PIXELS_PER_TARGET + TARGETS_PER_TABLE);
            assertTrue(pixels.size() > 0);
            for (Pixel pixel : pixels) {
                assertTrue(pixel.toString(), pixelsInUse.contains(pixel));
                assertNotNull(pixel.toString(), pixel.getFsId());
                assertNotNull(pixel.toString(), pixel.getFsIds());
                assertEquals(pixel.toString(), 2, pixel.getFsIds()
                    .size());
            }
        }
    }
}
