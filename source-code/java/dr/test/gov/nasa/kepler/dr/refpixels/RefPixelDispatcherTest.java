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

package gov.nasa.kepler.dr.refpixels;

import gov.nasa.kepler.dr.dispatch.DispatcherAbstractTest;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapper;
import gov.nasa.kepler.dr.dispatch.PipelineLauncher;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;

public class RefPixelDispatcherTest extends DispatcherAbstractTest {

    private static final int EXTERNAL_ID = 1;
    private static final int PIXEL_COUNT = 1449;

    private TargetCrud targetCrud;
    private TargetSelectionCrud targetSelectionCrud;

    public RefPixelDispatcherTest() {
        this.sourceDir = UNIT_TEST_PATH + "/refpixels/";
        this.filename = "kplr2008347160000_rp.rp";
        this.dispatcherType = DispatcherType.REF_PIXEL;
        this.dispatcher = new DispatcherWrapper(new RefPixelDispatcher(),
            dispatcherType, sourceDir, handler);
    }

    @Before
    public void setUp() throws Exception {
        super.setUp();
    }

    @After
    public void tearDown() throws Exception {
        super.tearDown();
    }

    @Test
    public void testDispatch() throws Exception {
        mockPipelineLauncher = mock(PipelineLauncher.class);

        // oneOf(mockPipelineLauncher).launch(dispatcher);

        super.testDispatch();
    }

    @Test
    public void attemptToDispatchNullFile() throws Exception {
        super.attemptToDispatchNullFile();
    }

    @Override
    protected void populateObjects() throws Exception {
        super.populateObjects();

        seedTad();
    }

    private void seedTad() {
        databaseService = DatabaseServiceFactory.getInstance();
        targetCrud = new TargetCrud(databaseService);
        targetSelectionCrud = new TargetSelectionCrud(databaseService);

        seedTargetListSet("rpTls", TargetType.REFERENCE_PIXEL, MaskType.TARGET);
    }

    private TargetListSet seedTargetListSet(String name, TargetType targetType,
        MaskType maskType) {
        MaskTable maskTable = new MaskTable(maskType);
        maskTable.setState(State.UPLINKED);
        maskTable.setExternalId(EXTERNAL_ID);

        List<Offset> offsets = ImmutableList.of();
        for (int i = 0; i < PIXEL_COUNT; i++) {
            offsets.add(new Offset(1, 1));
        }

        List<Mask> masks = ImmutableList.of();
        Mask mask = new Mask(maskTable, offsets);
        masks.add(mask);

        TargetListSet targetListSet = new TargetListSet(name);

        TargetTable targetTable = new TargetTable(targetType);
        targetTable.setState(State.UPLINKED);
        targetTable.setExternalId(EXTERNAL_ID);
        targetTable.setMaskTable(maskTable);

        targetListSet.setTargetTable(targetTable);

        List<ObservedTarget> observedTargets = ImmutableList.of();
        ObservedTarget observedTarget = new ObservedTarget(targetTable, 2, 1, 1);
        observedTargets.add(observedTarget);

        List<TargetDefinition> targetDefs = ImmutableList.of();
        TargetDefinition targetDef = new TargetDefinition(observedTarget);
        targetDef.setMask(mask);
        targetDefs.add(targetDef);

        observedTarget.getTargetDefinitions()
            .add(targetDef);

        // Store objects.
        databaseService.beginTransaction();
        targetCrud.createMaskTable(maskTable);
        targetCrud.createMasks(masks);
        targetCrud.createTargetTable(targetTable);
        targetSelectionCrud.create(targetListSet);
        targetCrud.createObservedTargets(observedTargets);
        databaseService.commitTransaction();

        return targetListSet;
    }

}
