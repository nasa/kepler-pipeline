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
import gov.nasa.kepler.hibernate.tad.ModOut;
import gov.nasa.kepler.hibernate.tad.ModOutsFactory;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.jmock.JMockTest;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.util.Date;
import java.util.List;

import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class TargetWriterReaderTest extends JMockTest {

    private static final MaskTable MASK_TABLE = new MaskTable(
        TargetReader.DEFAULT_MASK_TYPE) {
        {
            setExternalId(2);
        }
    };
    private static final TargetTable TARGET_TABLE = new TargetTable(
        TargetType.LONG_CADENCE) {
        {
            setExternalId(3);
            setMaskTable(MASK_TABLE);
            setPlannedStartTime(new Date(4000));
            setPlannedEndTime(new Date(5000));
        }
    };
    private static final Mask MASK = new Mask() {
        {
            setIndexInTable(6);
        }
    };
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
    private static final File FILE = new File(Filenames.BUILD_TMP,
        "file");

    private ModOutsFactory modOutsFactory = mock(ModOutsFactory.class);

    private TargetWriter targetWriter;
    private TargetReader targetReader;

    @Before
    public void setUp() throws FileNotFoundException {
        targetWriter = new TargetWriter(new FileOutputStream(FILE),
            modOutsFactory);
        targetReader = new TargetReader(new FileInputStream(FILE));
    }

    @Test
    public void testWriteRead() throws IllegalAccessException {
        setAllowances();

        targetWriter.write(IMPORTED_TARGET_TABLE);

        ImportedTargetTable actualImportedTargetTable = targetReader.read();

        new ReflectionEquals().assertEquals(IMPORTED_TARGET_TABLE,
            actualImportedTargetTable);
    }

    private void setAllowances() {
        allowing(modOutsFactory).create();
        will(returnValue(ImmutableList.of(MOD_OUT)));
    }

}
