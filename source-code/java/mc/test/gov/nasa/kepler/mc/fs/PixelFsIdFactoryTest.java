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

package gov.nasa.kepler.mc.fs;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.fs.PixelFsIdFactory;
import gov.nasa.spiffy.common.lang.StringUtils;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.List;

import org.junit.Test;

public class PixelFsIdFactoryTest {

    private TargetTable targetTable1;
    private Mask maskAperture1;
    private TargetDefinition targetDefinition1;
    private ObservedTarget target1;

    private void populateObjects() {
        targetTable1 = new TargetTable(TargetType.LONG_CADENCE);
        
        MaskTable maskTable = new MaskTable(MaskType.TARGET);
        
        List<Offset> offsets = new ArrayList<Offset>();
        offsets.add(new Offset(0, 0));
        
        maskAperture1 = new Mask(maskTable, offsets);
        
        targetDefinition1 = new TargetDefinition(0, 0, 0, null);
        targetDefinition1.setReferenceRow(500);
        targetDefinition1.setReferenceColumn(500);
        targetDefinition1.setMask(maskAperture1);
        
        target1 = new ObservedTarget(null, 2, 1, 1);
        target1.setTargetTable(targetTable1);
        target1.getTargetDefinitions().add(targetDefinition1);
        target1.setCcdModule(2);
        target1.setCcdOutput(1);
    }

    @Test
    public void translateConstantToAcronymName() {

        assertEquals("j", StringUtils.constantToAcronym("JACK"));
        assertEquals("awanp", StringUtils.constantToAcronym("ALL_WORK_AND_NO_PLAY"));
        assertEquals("abc", StringUtils.constantToAcronym("A_B_C"));
        assertEquals("ab", StringUtils.constantToAcronym("A_B_"));
        assertEquals("bc", StringUtils.constantToAcronym("_B_C"));
    }

    @Test
    public void translateConstantToCamelName() {

        assertEquals("Jack", StringUtils.constantToCamel("JACK"));
        assertEquals("AllWorkAndNoPlay", StringUtils.constantToCamel("ALL_WORK_AND_NO_PLAY"));
        assertEquals("ABC", StringUtils.constantToCamel("A_B_C"));
        assertEquals("AB", StringUtils.constantToCamel("A_B_"));
        assertEquals("BC", StringUtils.constantToCamel("_B_C"));
    }

    @Test
    public void getPixelGuid() {
        populateObjects();

        FsId fsid = 
            PixelFsIdFactory.getPixelFsId("/path/", TargetType.LONG_CADENCE,
                                                         2, 1, 500, 500);

        assertEquals("/path/lct/2/1/500:500", fsid.toString());
    }

    @Test(expected = PipelineException.class)
    public void invalidTargetTableType() {
        populateObjects();

        PixelFsIdFactory.getPixelFsId("/path/", null, 2, 1, 1, 1);
    }

    @Test(expected = PipelineException.class)
    public void invalidCcdModule() {
        populateObjects();

        PixelFsIdFactory.getPixelFsId("/path/", TargetType.LONG_CADENCE, 1, 1, 1, 1);
    }

    @Test(expected = PipelineException.class)
    public void invalidCcdOutput() {
        populateObjects();

        PixelFsIdFactory.getPixelFsId("/path/", TargetType.LONG_CADENCE, 2, 0, 1, 1);
    }

    @Test(expected = PipelineException.class)
    public void invalidRow() {
        populateObjects();

        PixelFsIdFactory.getPixelFsId("/path/", TargetType.LONG_CADENCE, 2, 1, -1, 1);
    }

    @Test(expected = PipelineException.class)
    public void invalidColumn() {
        populateObjects();

        PixelFsIdFactory.getPixelFsId("/path/", TargetType.LONG_CADENCE, 2, 1, 1, -1);
    }

    @Test
    public void getPixelGuids() {
        populateObjects();

        List<FsId> fsIds = PixelFsIdFactory.getPixelFsIdsForTarget("/path/", target1);

        assertEquals("/path/lct/2/1/500:500", fsIds.get(0).toString());
    }

    @Test(expected = PipelineException.class)
    public void invalidTarget() {
        populateObjects();

        PixelFsIdFactory.getPixelFsIdsForTarget("/path/", null);
    }

    @Test
    public void getCollateralPixelGuid() {
        populateObjects();

        FsId fsid = PixelFsIdFactory.getCollateralPixelFsId("/path/", CollateralType.BLACK_LEVEL, 2, 1, 1);

        assertEquals("/path/BlackLevel:2:1:1", fsid.toString());
    }

    @Test(expected = PipelineException.class)
    public void invalidCcdModuleCollateral() {
        populateObjects();

        PixelFsIdFactory.getCollateralPixelFsId("/path/", CollateralType.BLACK_LEVEL, -1, 1, 1);
    }

    @Test(expected = PipelineException.class)
    public void invalidCcdOutputCollateral() {
        populateObjects();

        PixelFsIdFactory.getCollateralPixelFsId("/path/", CollateralType.BLACK_LEVEL, 2, -1, 1);
    }

    @Test(expected = PipelineException.class)
    public void invalidRowOrColumn() {
        populateObjects();

        PixelFsIdFactory.getCollateralPixelFsId("/path/", CollateralType.BLACK_LEVEL, 2, 1, -1);
    }
}
