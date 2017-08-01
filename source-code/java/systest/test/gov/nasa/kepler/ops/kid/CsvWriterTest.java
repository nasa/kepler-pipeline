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

package gov.nasa.kepler.ops.kid;

import static com.google.common.collect.Lists.newArrayList;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.List;

import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class CsvWriterTest {

    @Test
    public void testWrite() throws IOException {
        testWriteInternal("a", "b", "c", "d");
    }

    @Test
    public void testWriteWithCommaInValue() throws IOException {
        testWriteInternal("a", "b", "c", "d, e");
    }

    @Test
    public void testWriteWithNullValue() throws IOException {
        testWriteInternal("a", "b", "c", null);
    }

    private void testWriteInternal(String a, String b, String c, String d)
        throws IOException, FileNotFoundException {

        List<String> ab = newArrayList(a, b);

        List<String> cd = newArrayList(c, d);

        List<List<String>> table = ImmutableList.of(ab, cd);

        CsvWriter csvWriter = new CsvWriter();
        File file = csvWriter.write(table);

        BufferedReader br = new BufferedReader(new FileReader(file));
        String actualLine1 = br.readLine();
        String actualLine2 = br.readLine();
        String actualLine3 = br.readLine();
        br.close();

        String expectedLine1 = CsvWriter.VALUE_WRAPPER + a
            + CsvWriter.VALUE_WRAPPER + CsvWriter.VALUE_SEPARATOR
            + CsvWriter.VALUE_WRAPPER + b + CsvWriter.VALUE_WRAPPER
            + CsvWriter.VALUE_SEPARATOR;
        String expectedLine2 = CsvWriter.VALUE_WRAPPER + c
            + CsvWriter.VALUE_WRAPPER + CsvWriter.VALUE_SEPARATOR
            + CsvWriter.VALUE_WRAPPER + d + CsvWriter.VALUE_WRAPPER
            + CsvWriter.VALUE_SEPARATOR;
        String expectedLine3 = null;

        assertEquals(expectedLine1, actualLine1);
        assertEquals(expectedLine2, actualLine2);
        assertEquals(expectedLine3, actualLine3);

        boolean deleted = file.delete();
        if (!deleted) {
            throw new IllegalStateException("File was not deleted.");
        }
        assertTrue(!file.exists());
    }

}
