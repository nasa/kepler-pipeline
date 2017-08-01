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

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.ar.exporter.ktc.CompletedKtcEntry;
import gov.nasa.kepler.ar.exporter.ktc.KtcExporter;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.List;

import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class KtcReaderTest {

    @Test
    public void testRead() throws IOException {
        String category = "category";
        Double actualStart = 1.1;
        Double actualStop = 2.2;
        String investigation = "investigation";
        double planStart = 3.3;
        double planStop = 4.4;
        int keplerId = 5;
        TargetType targetType = TargetType.LONG_CADENCE;

        CompletedKtcEntry ktcEntry = new CompletedKtcEntry(category,
            actualStart, actualStop, investigation, planStart, planStop,
            keplerId, targetType);
        List<CompletedKtcEntry> ktcEntries = ImmutableList.of(ktcEntry);

        File file = new File("ktc.txt");
        BufferedWriter writer = new BufferedWriter(new FileWriter(file));
        ktcEntry.printEntry(writer);
        writer.flush();
        writer.close();

        KtcReader ktcReader = new KtcReader();
        List<CompletedKtcEntry> actualKtcEntries = ktcReader.read(file);

        assertEquals(ktcEntries, actualKtcEntries);

        boolean deleted = file.delete();
        if (!deleted) {
            throw new IllegalStateException("File was not deleted.");
        }
        assertTrue(!file.exists());
    }

    @Test
    public void testReadCommentLine() throws IOException {
        File file = new File("ktc.txt");
        BufferedWriter writer = new BufferedWriter(new FileWriter(file));
        writer.append(KtcExporter.COMMENT_CHAR + " Here is a comment.");
        writer.flush();
        writer.close();

        KtcReader ktcReader = new KtcReader();
        List<CompletedKtcEntry> actualKtcEntries = ktcReader.read(file);

        assertEquals(ImmutableList.of(), actualKtcEntries);

        boolean deleted = file.delete();
        if (!deleted) {
            throw new IllegalStateException("File was not deleted.");
        }
        assertTrue(!file.exists());
    }

}
