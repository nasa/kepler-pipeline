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

package gov.nasa.kepler.dr.target;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.TargetListSetValidator;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.jmock.JMockTest;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.Date;

import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class TargetListSetImporterTest extends JMockTest {

    private static final String TLS_NAME = "TLS_NAME";
    private static final String PLANETARY = "PLANETARY";
    private static final String EB = "EB";
    private static final String EXCLUDE = "EXCLUDE";

    private TargetList targetList;
    private TargetList ebTargetList;
    private TargetList excludeTargetList;
    private TargetListSet targetListSet;
    private File xmlFile;
    private TargetListSet actualTargetListSet;

    @Test
    public void testImport() throws IOException {
        populateObjects();

        TargetListSetImporter tlsImporter = new TargetListSetImporter();
        tlsImporter.setTargetSelectionCrud(createMockTargetSelectionCrud());
        tlsImporter.setTargetListSetValidator(createMockTargetListSetValidator());
        actualTargetListSet = tlsImporter.importFile(xmlFile, true);

        validateObjects();
    }

    @Test(expected = PipelineException.class)
    public void testImportWithTargetListNotInDatabase() throws IOException {
        populateObjects();

        TargetListSetImporter tlsImporter = new TargetListSetImporter();
        tlsImporter.setTargetSelectionCrud(createMockTargetSelectionCrudWithNullTargetLists());
        actualTargetListSet = tlsImporter.importFile(xmlFile, true);
    }

    private void validateObjects() {
        assertEquals(targetListSet.getName(), actualTargetListSet.getName());
        assertEquals(targetListSet.getType(), actualTargetListSet.getType());
        assertEquals(targetListSet.getStart(), actualTargetListSet.getStart());
        assertEquals(targetListSet.getEnd(), actualTargetListSet.getEnd());
        assertEquals(targetListSet.getTargetLists(),
            actualTargetListSet.getTargetLists());
        assertEquals(targetListSet.getExcludedTargetLists(),
            actualTargetListSet.getExcludedTargetLists());
        assertEquals(actualTargetListSet.getState(), State.LOCKED);
    }

    private void populateObjects() throws IOException {
        targetList = new TargetList(PLANETARY);
        ebTargetList = new TargetList(EB);
        excludeTargetList = new TargetList(EXCLUDE);

        targetListSet = new TargetListSet(TLS_NAME);
        targetListSet.setType(TargetType.LONG_CADENCE);
        targetListSet.setStart(new Date());
        targetListSet.setEnd(new Date());
        targetListSet.getTargetLists()
            .add(targetList);
        targetListSet.getTargetLists()
            .add(ebTargetList);
        targetListSet.getExcludedTargetLists()
            .add(excludeTargetList);

        TargetListSetExporter tlsExporter = new TargetListSetExporter();
        xmlFile = tlsExporter.export(targetListSet,
            Filenames.BUILD_TMP, true);
    }

    private TargetSelectionCrud createMockTargetSelectionCrud() {
        TargetSelectionCrud mockTargetSelectionCrud = mock(TargetSelectionCrud.class);

        allowing(mockTargetSelectionCrud).retrieveTargetList(PLANETARY);
        will(returnValue(targetList));

        allowing(mockTargetSelectionCrud).retrieveTargetList(EB);
        will(returnValue(ebTargetList));

        allowing(mockTargetSelectionCrud).retrieveTargetList(EXCLUDE);
        will(returnValue(excludeTargetList));

        return mockTargetSelectionCrud;
    }

    private TargetListSetValidator createMockTargetListSetValidator() {
        TargetListSetValidator mockTargetListSetValidator = mock(TargetListSetValidator.class);

        oneOf(mockTargetListSetValidator).validate(
            ImmutableList.of(new TargetListSet(TLS_NAME)));

        return mockTargetListSetValidator;
    }

    private TargetSelectionCrud createMockTargetSelectionCrudWithNullTargetLists() {
        TargetSelectionCrud mockTargetSelectionCrud = mock(TargetSelectionCrud.class);

        allowing(mockTargetSelectionCrud).retrieveTargetList(PLANETARY);
        will(returnValue(null));

        return mockTargetSelectionCrud;
    }

}
