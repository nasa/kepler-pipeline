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

package gov.nasa.kepler.tad.xml;

import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.ModOut;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.io.File;
import java.util.Date;
import java.util.List;

import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class TargetExporterTest extends JMockTest {

    private static final Date TIME_GENERATED = new Date(2000);

    private static final String EXPORT_PATH = Filenames.BUILD_TMP;

    private static final MaskTable MASK_TABLE = new MaskTable(MaskType.TARGET) {
        {
            setExternalId(3);
            setPlannedStartTime(new Date(4000));
            setPlannedEndTime(new Date(5000));
        }
    };
    private static final TargetTable TARGET_TABLE = new TargetTable(
        TargetType.LONG_CADENCE) {
        {
            setExternalId(3);
            setMaskTable(MASK_TABLE);
            setPlannedStartTime(new Date(4000));
            setPlannedEndTime(new Date(5000));
            setState(gov.nasa.kepler.hibernate.gar.ExportTable.State.LOCKED);
        }
    };
    private static final Mask MASK = new Mask() {
        {
            setIndexInTable(6);
        }
    };
    private static final List<Mask> MASKS = ImmutableList.of(MASK);
    private static final ImportedMaskTable IMPORTED_MASK_TABLE = new ImportedMaskTable(
        MASK_TABLE, MASKS);
    private static final ModOut MOD_OUT = ModOut.of(7, 8);
    private static final TargetDefinition TARGET_DEFINITION = new TargetDefinition() {
        {
            setModOut(MOD_OUT);
            setIndexInModuleOutput(10);
            setKeplerId(11);
            setMask(MASK);
            setReferenceColumn(14);
            setReferenceRow(15);
            setTargetTable(TARGET_TABLE);
        }
    };
    private static final List<TargetDefinition> TARGET_DEFINITIONS = ImmutableList.of(TARGET_DEFINITION);
    private static final ImportedTargetTable IMPORTED_TARGET_TABLE = new ImportedTargetTable(
        TARGET_TABLE, TARGET_DEFINITIONS);

    private static final File MASK_FILE = new File(EXPORT_PATH,
        MASK_TABLE.generateFileName(TIME_GENERATED));
    private static final File TARGET_FILE = new File(EXPORT_PATH,
        TARGET_TABLE.generateFileName(TIME_GENERATED));

    private MaskWriter maskWriter = mock(MaskWriter.class);
    private TargetWriter targetWriter = mock(TargetWriter.class);

    private TargetCrud targetCrud = mock(TargetCrud.class);
    private MaskWriterFactory maskWriterFactory = mock(MaskWriterFactory.class);
    private TargetWriterFactory targetWriterFactory = mock(TargetWriterFactory.class);

    private TargetExporter targetExporter = new TargetExporter(targetCrud,
        maskWriterFactory, targetWriterFactory, TIME_GENERATED);

    @Test
    public void testExportMaskTable() {
        setAllowances();

        oneOf(maskWriter).write(IMPORTED_MASK_TABLE);

        targetExporter.export(null, null, MASK_TABLE, null, null, null, null,
            null, EXPORT_PATH);
    }

    @Test
    public void testExportTargetTable() {
        setAllowances();

        oneOf(targetWriter).write(IMPORTED_TARGET_TABLE);

        targetExporter.export(TARGET_TABLE, null, null, null, null, null, null,
            null, EXPORT_PATH);
    }

    private void setAllowances() {
        allowing(targetCrud).retrieveMasks(MASK_TABLE);
        will(returnValue(MASKS));

        allowing(maskWriterFactory).create(MASK_FILE);
        will(returnValue(maskWriter));

        allowing(targetCrud).retrieveTargetDefinitions(TARGET_TABLE);
        will(returnValue(TARGET_DEFINITIONS));

        allowing(targetWriterFactory).create(TARGET_FILE);
        will(returnValue(targetWriter));
    }

}
