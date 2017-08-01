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

package gov.nasa.kepler.ui.common;

import static gov.nasa.kepler.ui.common.KeplerUtilities.createNewName;
import static org.junit.Assert.assertEquals;

import java.io.IOException;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.junit.Test;

public class KeplerUtilitiesTest {
    private static final String READ_FILE_AS_LIST_TESTFILE = "test/etc/readFileAsListTestFile";

    @Test(expected = NullPointerException.class)
    public void createNewNameTest1() {
        createNewName("a", null);
    }

    //@edu.umd.cs.findbugs.annotations.SuppressWarnings("NP")
    @SuppressWarnings("unchecked")
    @Test(expected = NullPointerException.class)
    public void createNewNameTest2() {
        createNewName(null, Collections.EMPTY_SET);
    }

    @Test
    public void createNewNameTest3() {
        Set<String> names = new HashSet<String>();
        String name = createNewName("a", names);
        assertEquals("a (copy)", name);
        names.add(name);
        name = createNewName(name, names);
        assertEquals("a (another copy)", name);
        names.add(name);
        name = createNewName(name, names);
        assertEquals("a (3rd copy)", name);
        names.add(name);
        name = createNewName(name, names);
        assertEquals("a (4th copy)", name);
        for (int i = 5; i < 20; i++) {
            names.add(name);
            name = createNewName(name, names);
        }
        assertEquals("a (19th copy)", name);
        names.add(name);
        name = createNewName(name, names);
        assertEquals("a (20th copy)", name);
        names.add(name);
        name = createNewName(name, names);
        assertEquals("a (21st copy)", name);
        names.add(name);
        name = createNewName(name, names);
        assertEquals("a (22nd copy)", name);
        names.add(name);
        name = createNewName(name, names);
        assertEquals("a (23rd copy)", name);
        names.add(name);
        name = createNewName(name, names);
        assertEquals("a (24th copy)", name);
        names.add(name);

        name = createNewName("a (copy)", names);
        assertEquals("a (25th copy)", name);
        name = createNewName("a (another copy)", names);
        assertEquals("a (25th copy)", name);
        name = createNewName("a (3rd copy)", names);
        assertEquals("a (25th copy)", name);
        name = createNewName("a (4th copy)", names);
        assertEquals("a (25th copy)", name);
        name = createNewName("a (20th copy)", names);
        assertEquals("a (25th copy)", name);
        name = createNewName("a (21st copy)", names);
        assertEquals("a (25th copy)", name);
        name = createNewName("a (22nd copy)", names);
        assertEquals("a (25th copy)", name);
        name = createNewName("a (23rd copy)", names);
        assertEquals("a (25th copy)", name);
        name = createNewName("a (24th copy)", names);
        assertEquals("a (25th copy)", name);

        name = createNewName("(copy) a", names);
        assertEquals("(copy) a (copy)", name);
    }

    @Test
    public void testReadFileAsList() throws IOException {
        List<String> categories = KeplerUtilities.readFileAsList(READ_FILE_AS_LIST_TESTFILE);

        assertEquals("foo", categories.get(0));
        assertEquals("foo bar", categories.get(1));
        assertEquals("foo  bar", categories.get(2));
        assertEquals("foo bar", categories.get(3));
        assertEquals("foo", categories.get(4));
    }
}
