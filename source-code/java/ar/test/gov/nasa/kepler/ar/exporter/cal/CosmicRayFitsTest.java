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

package gov.nasa.kepler.ar.exporter.cal;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.ar.FitsVerify;
import gov.nasa.kepler.ar.FitsVerify.FitsVerifyResults;
import gov.nasa.kepler.ar.exporter.FileNameFormatter;
import gov.nasa.kepler.ar.exporter.cal.CosmicRayFitsWriter.DataType;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.*;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.util.*;

import nom.tam.util.BufferedFile;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Sean McCauliff
 * 
 */
public class CosmicRayFitsTest {

    private File rootDir;
    private static final short LC_TARGET_DEF = 1;
    private static final short SC_TARGET_DEF = 2;
    private static final short BKG_TARGET_DEF = 3;
    private static final short TARGET_APERTURE_DEF = 4;
    private static final short BKG_APERTURE_DEF = 5;
    private static final short COMPRESS_TBL = 6;
    private static final long TASK_ID = 88L;
    
    private FitsVerify fitsVerify = new FitsVerify();

    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
        rootDir = new File(Filenames.BUILD_TEST,
            "CosmicRayFitsTest.dir");
        rootDir.mkdirs();
    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        FileUtil.removeAll(rootDir);
    }

    private VisibleCosmicRayModuleOutput generateVisibileModOut(int cadence,
        double mjd, DataType type, short module, short output)
        {

        VisibleCosmicRayModuleOutput cosmicRayModuleOutput = new VisibleCosmicRayModuleOutput(
            module, output, cadence, mjd);

        Set<FloatMjdTimeSeries> pixels = new HashSet<FloatMjdTimeSeries>();

        TargetAndApertureIdMap tnaMap = new TargetAndApertureIdMap();
        
        for (short i = 0; i < 10; i++) {
            short row = (short) (300 + i); 
            short column = (short) (250+ i);

            FsId id = PaFsIdFactory.getCosmicRaySeriesFsId(
                TargetType.LONG_CADENCE, module, output, row, column);
            float[] rays = new float[] { 88.0f + i };
            double[] mjd_a = new double[] { mjd };
            FloatMjdTimeSeries raySeries = new FloatMjdTimeSeries(id, 0.0,
                Double.MAX_VALUE, mjd_a, rays, TASK_ID);
            pixels.add(raySeries);
            
            tnaMap.addIds(module, false, output, new short[] { row} , 
                new short[] { column}, new int[] { i}, new short[] { (short) ( i+1)});
 
        }

        ProcessingHistoryFile processingHistoryFile = 
            new ProcessingHistoryFile("do not write", null, null, null, null);
        
        cosmicRayModuleOutput.addPixels(pixels, tnaMap, processingHistoryFile);

        assertEquals(1, processingHistoryFile.testTaskIds().size());
        assertTrue(processingHistoryFile.testTaskIds().contains(TASK_ID));
        return cosmicRayModuleOutput;
    }

    private CollateralCosmicRayModuleOutput generateCollateralCosmicRayModuleOutput(
        int cadence, double mjd, short module, short output)
        {

        CollateralCosmicRayModuleOutput collateralCosmicRayModuleOutput = new CollateralCosmicRayModuleOutput(
            module, output, cadence, mjd);

        Set<FloatMjdTimeSeries> pixels = new HashSet<FloatMjdTimeSeries>();

        for (int i = 0; i < 10; i++) {
            int offset = i;
            CollateralType cType = CollateralType.BLACK_LEVEL;
            CadenceType cadenceType = CadenceType.LONG;

            FsId id = CalFsIdFactory.getCosmicRaySeriesFsId(cType, cadenceType,
                module, output, offset);
            double[] mjd_a = new double[] { mjd };

            float[] rays = new float[] { 999.0f };

            FloatMjdTimeSeries raySeries = new FloatMjdTimeSeries(id, 0.0,
                Double.MAX_VALUE, mjd_a, rays, TASK_ID);

            pixels.add(raySeries);
        }
        
        ProcessingHistoryFile processingHistoryFile =
            new ProcessingHistoryFile(" do not write",  null, null, null, null);

        collateralCosmicRayModuleOutput.addCollateralPixels(pixels, processingHistoryFile);
        
        assertEquals(1, processingHistoryFile.testTaskIds().size());
        assertTrue(processingHistoryFile.testTaskIds().contains(TASK_ID));

        return collateralCosmicRayModuleOutput;
    }

    @Test
    public void readWriteVisibleCosmicRayFile() throws Exception {

        FileNameFormatter fnameFormatter = new FileNameFormatter();
        String cRayName = fnameFormatter.cosmicRayName(false, false, new Date());

        File f = new File(rootDir, cRayName);
        BufferedFile buffile = new BufferedFile(f.toString(), "rw");
        CosmicRayFitsWriter writer = new CosmicRayFitsWriter(1, DataType.LONG,
            LC_TARGET_DEF, SC_TARGET_DEF, BKG_TARGET_DEF, TARGET_APERTURE_DEF,
            BKG_APERTURE_DEF, COMPRESS_TBL, buffile, cRayName, null);

        List<VisibleCosmicRayModuleOutput> modOutList = new ArrayList<VisibleCosmicRayModuleOutput>();

        for (int module : FcConstants.modulesList) {
            for (int output : FcConstants.outputsList) {
                VisibleCosmicRayModuleOutput visModOut = generateVisibileModOut(
                    1, 100.0, DataType.LONG, (short) module, (short) output);
                writer.writeModuleOutput(visModOut);
                modOutList.add(visModOut);
            }
        }

        buffile.flush();
        buffile.close();

        BufferedInputStream bin = new BufferedInputStream(
            new FileInputStream(f));
        CosmicRayFitsReader reader = new CosmicRayFitsReader(bin);
        assertEquals(reader.bkgAperDef, writer.bkgAperDef);
        assertEquals(reader.bkgTargDef, writer.bkgTargDef);
        assertEquals(reader.cadence, writer.cadence);
        assertEquals(reader.compressTbl, writer.compressTbl);
        assertEquals(reader.lcTargDef, writer.lcTargDef);
        assertEquals(reader.scTargDef, writer.scTargDef);
        assertEquals(reader.targAperDef, writer.tarAperDef);

        ReflectionEquals reflectEquals = new ReflectionEquals();
        int listIndex = 0;
        for (@SuppressWarnings("unused")
        int module : FcConstants.modulesList) {
            for (@SuppressWarnings("unused")
            int output : FcConstants.outputsList) {
                CosmicRayFitsModuleOutput readModOut = reader.read();
                // assertEquals(modOutList.get(listIndex++), readModOut);
                reflectEquals.excludeField(".*\\.mjd");
                reflectEquals.assertEquals(modOutList.get(listIndex++),
                    readModOut);
            }
        }

        FitsVerifyResults verification = fitsVerify.verify(f);
        assertEquals(verification.output, 0, verification.returnCode);
        
    }

    @Test
    public void readWriteCollateralCosmicRayFile() throws Exception {
        FileNameFormatter fnameFormatter = new FileNameFormatter();
        String cRayName = fnameFormatter.cosmicRayName(false, true, new Date());

        File f = new File(rootDir, cRayName);
        BufferedFile buffile = new BufferedFile(f.toString(), "rw");
        CosmicRayFitsWriter writer = new CosmicRayFitsWriter(1, DataType.LONG,
            LC_TARGET_DEF, SC_TARGET_DEF, BKG_TARGET_DEF, TARGET_APERTURE_DEF,
            BKG_APERTURE_DEF, COMPRESS_TBL, buffile, cRayName, null);

        List<CollateralCosmicRayModuleOutput> modOutList = new ArrayList<CollateralCosmicRayModuleOutput>();

        for (int module : FcConstants.modulesList) {
            for (int output : FcConstants.outputsList) {
                CollateralCosmicRayModuleOutput collateralCosmicRayModuleOutput = generateCollateralCosmicRayModuleOutput(
                    1, 100.0, (short) module, (short) output);
                writer.writeModuleOutput(collateralCosmicRayModuleOutput);
                modOutList.add(collateralCosmicRayModuleOutput);
            }
        }

        buffile.flush();
        buffile.close();

        BufferedInputStream bin = new BufferedInputStream(
            new FileInputStream(f));
        CosmicRayFitsReader reader = new CosmicRayFitsReader(bin);
        assertEquals(reader.bkgAperDef, writer.bkgAperDef);
        assertEquals(reader.bkgTargDef, writer.bkgTargDef);
        assertEquals(reader.cadence, writer.cadence);
        assertEquals(reader.compressTbl, writer.compressTbl);
        assertEquals(reader.lcTargDef, writer.lcTargDef);
        assertEquals(reader.scTargDef, writer.scTargDef);
        assertEquals(reader.targAperDef, writer.tarAperDef);

        ReflectionEquals reflectEquals = new ReflectionEquals();
        int listIndex = 0;
        for (@SuppressWarnings("unused")
        int module : FcConstants.modulesList) {
            for (@SuppressWarnings("unused")
            int output : FcConstants.outputsList) {
                CosmicRayFitsModuleOutput readModOut = reader.read();
                // assertEquals(modOutList.get(listIndex++), readModOut);
                reflectEquals.excludeField(".*\\.mjd");
                reflectEquals.assertEquals(modOutList.get(listIndex++),
                    readModOut);
            }
        }

        FitsVerifyResults verification = fitsVerify.verify(f);
        assertEquals(verification.output, 0, verification.returnCode);
        
    }

}
