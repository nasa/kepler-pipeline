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

package gov.nasa.kepler.mc;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.fs.DrFsIdFactory.TimeSeriesType;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Sean McCauliff
 * 
 */
public class SciencePixelOperationsTest {

    private static final int CCD_MODULE = 2;
    private static final int CCD_OUTPUT = 1;

    private Map<String, ObservedTarget> observedTargetByName;

    private Map<String, TargetTable> targetTableByName;

    private TargetCrud targetCrud;

    private int lastKeplerId = 3;
    private int lastIndexInModuleOutput = 0;

    private MaskTable targetMaskTable;

    private MaskTable backgroundMaskTable;

    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {

        DatabaseService dbService = DatabaseServiceFactory.getInstance();
        dbService.getDdlInitializer()
            .initDB();

        observedTargetByName = new HashMap<String, ObservedTarget>();
        targetTableByName = new HashMap<String, TargetTable>();

        targetCrud = new TargetCrud();

        dbService.beginTransaction();

        targetMaskTable = new MaskTable(MaskType.TARGET);
        backgroundMaskTable = new MaskTable(MaskType.BACKGROUND);

        targetCrud.createMaskTable(targetMaskTable);
        targetCrud.createMaskTable(backgroundMaskTable);

        dbService.commitTransaction();

    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        DatabaseService dbService = DatabaseServiceFactory.getInstance();
        dbService.rollbackTransactionIfActive();
        dbService.closeCurrentSession();
        dbService.getDdlInitializer()
            .cleanDB();
    }

    /**
     * Test long cadence.
     * 
     * 1 2 3 4 1a0 a0 a1 2a0 a0/b a1/b 3 b b/c b/c 4 c c
     * 
     * Where numbers indicate rows and columns. Letters indicate targets and
     * target definitions. 'a' and 'b' are long cadence targets. a0 is the first
     * target definition, a1 is the second target definition for observed target
     * a. 'c' is a background target. Coordinates with more than one target have
     * overlapping pixels. The upper left pixel is the start ("reference") pixel
     * for that target.
     */
    @Test
    public void longCadenceSciOps() throws Exception {
        DatabaseService dbService = DatabaseServiceFactory.getInstance();
        dbService.beginTransaction();
        parseTargetDefinition("lcTargetTable LONG_CADENCE a 101 101 101 102 102 101 102 102");
        parseTargetDefinition("lcTargetTable LONG_CADENCE a 101 103 102 103");
        parseTargetDefinition("lcTargetTable LONG_CADENCE b 102 102 103 102 102 103 103 103");
        parseTargetDefinition("bkgTargetTable BACKGROUND c 103 103 104 103 103 104 104 104");

        for (TargetTable ttable : targetTableByName.values()) {
            targetCrud.createTargetTable(ttable);
        }
        targetCrud.createObservedTargets(observedTargetByName.values());
        dbService.commitTransaction();

        TargetTable lcTargetTable = targetTableByName.get("lcTargetTable");
        TargetTable bkgTargetTable = targetTableByName.get("bkgTargetTable");

        SciencePixelOperations sciOps = new SciencePixelOperations(
            lcTargetTable, bkgTargetTable, CCD_MODULE, CCD_OUTPUT);
        List<Set<FsId>> idsPerTarget = sciOps.getFsIdsPerTarget();

        Set<Pixel> expectedPixels = new HashSet<Pixel>();
        Set<Pixel> expectedTargetPixels = new HashSet<Pixel>();
        Set<FsId> seta = new HashSet<FsId>();
        int[] seta_pixels = { 101, 101, 101, 102, 102, 101, 102, 102, 101, 103,
            102, 103 };
        for (int i = 0; i < seta_pixels.length; i += 2) {
            FsId fsId = DrFsIdFactory.getSciencePixelTimeSeries(
                TimeSeriesType.ORIG, TargetType.LONG_CADENCE, CCD_MODULE,
                CCD_OUTPUT, seta_pixels[i], seta_pixels[i + 1]);
            seta.add(fsId);
            expectedTargetPixels.add(new Pixel(seta_pixels[i],
                seta_pixels[i + 1], fsId));
        }

        Set<FsId> setb = new HashSet<FsId>();
        int[] setb_pixels = { 102, 102, 103, 102, 102, 103, 103, 103 };
        for (int i = 0; i < setb_pixels.length; i += 2) {
            FsId fsId = DrFsIdFactory.getSciencePixelTimeSeries(
                TimeSeriesType.ORIG, TargetType.LONG_CADENCE, CCD_MODULE,
                CCD_OUTPUT, setb_pixels[i], setb_pixels[i + 1]);
            setb.add(fsId);
            expectedTargetPixels.add(new Pixel(setb_pixels[i],
                setb_pixels[i + 1], fsId));
        }

        Set<FsId> setc = new HashSet<FsId>();
        int[] setc_pixels = { 103, 103, 104, 103, 103, 104, 104, 104 };
        Set<Pixel> expectedBackgroundPixels = new HashSet<Pixel>();
        for (int i = 0; i < setb_pixels.length; i += 2) {
            FsId fsId = DrFsIdFactory.getSciencePixelTimeSeries(
                TimeSeriesType.ORIG, TargetType.BACKGROUND, CCD_MODULE,
                CCD_OUTPUT, setc_pixels[i], setc_pixels[i + 1]);
            setc.add(fsId);
            expectedBackgroundPixels.add(new Pixel(setc_pixels[i],
                setc_pixels[i + 1], fsId));
        }
        expectedPixels.addAll(expectedBackgroundPixels);
        expectedPixels.addAll(expectedTargetPixels);

        assertTrue(idsPerTarget.contains(seta));
        assertTrue(idsPerTarget.contains(setb));
        assertTrue(idsPerTarget.contains(setc));

        Set<Pixel> pixels = sciOps.getPixels();
        assertEquals(expectedPixels, pixels);
        Set<Pixel> backgroundPixels = sciOps.getBackgroundPixels();
        assertEquals(expectedBackgroundPixels, backgroundPixels);
        Set<Pixel> targetPixels = sciOps.getTargetPixels();
        assertEquals(expectedTargetPixels, targetPixels);

    }

    private void parseTargetDefinition(String targetDefString) {
        String[] parts = targetDefString.split("\\s+");
        String targetTableName = parts[0];
        String targetTableType = parts[1];
        String observedTargetName = parts[2];

        TargetTable targetTable = targetTableByName.get(targetTableName);
        if (targetTable == null) {
            targetTable = new TargetTable(TargetType.valueOf(targetTableType));
            targetTableByName.put(targetTableName, targetTable);
        }

        ObservedTarget oTarget = observedTargetByName.get(observedTargetName);
        if (oTarget == null) {
            oTarget = new ObservedTarget(targetTable, CCD_MODULE, CCD_OUTPUT,
                ++lastKeplerId);
            oTarget.setAperture(new Aperture(false, 0, 0, null));
            observedTargetByName.put(observedTargetName, oTarget);
        }

        TargetDefinition tDef = new TargetDefinition(oTarget);
        tDef.setIndexInModuleOutput(++lastIndexInModuleOutput);

        List<Offset> offsets = new ArrayList<Offset>();
        int startRow = -1;
        int startCol = -1;
        for (int i = 3; i < parts.length; i++) {
            int rowOffset = Integer.parseInt(parts[i]);
            int colOffset = Integer.parseInt(parts[++i]);
            if (startRow == -1) {
                startRow = rowOffset;
                startCol = colOffset;
            }
            rowOffset -= startRow;
            colOffset -= startCol;
            offsets.add(new Offset(rowOffset, colOffset));
        }
        tDef.setReferenceRow(startRow);
        tDef.setReferenceColumn(startCol);

        MaskTable maskTable = targetTable.getType() == TargetType.BACKGROUND ? backgroundMaskTable
            : targetMaskTable;
        Mask mask = new Mask(maskTable, offsets);
        targetCrud.createMasks(Collections.singleton(mask));
        tDef.setMask(mask);

        oTarget.getTargetDefinitions()
            .add(tDef);
    }
}
