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

package gov.nasa.spiffy.common.io;

import static org.junit.Assert.assertEquals;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Reader;
import java.io.Writer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.junit.Test;

/**
 * This test was split from {@link FileUtilTest} because it takes 2+ minutes to run.
 * 
 * @author Miles Cote
 *
 */
public class FileUtilIntegrationTest extends FileUtilTest {
    @Test
    public void testTarWithLargeFile() throws IOException {
        List<String> filenames = Arrays.asList("largeFile");

        List<PermissionFile> files = new ArrayList<PermissionFile>(
            filenames.size());
        for (String filename : filenames) {
            files.add(new PermissionFile(filename, -1));
        }

        FileUtils.deleteDirectory(archiveDir);

        char charToWrite = 'a';
        int lengthToWrite = Integer.MAX_VALUE;
        int bufferLength = FileUtil.BUFFER_SIZE;
        int writeBinCount = (lengthToWrite / bufferLength) + 1;

        // Write more than MAX_VALUE bytes to a file.
        for (PermissionFile permissionFile : files) {
            File file = new File(archiveDir, permissionFile.getFilename());
            File directory = file.getParentFile();
            if (directory != null && !directory.exists()) {
                FileUtil.mkdirs(directory);
            }
            Writer w = new FileWriter(file);

            for (int j = 0; j < writeBinCount; j++) {
                char[] charArray = new char[bufferLength];
                for (int i = 0; i < bufferLength; i++) {
                    charArray[i] = charToWrite;
                }

                w.write(charArray);
            }

            w.close();
            if (permissionFile.getMode() != -1) {
                FileUtil.setMode(file, permissionFile.getMode());
            }
        }

        // Create the archive for the large file.
        File archive = FileUtil.createArchive(archiveDir);
        FileUtils.deleteDirectory(archiveDir);
        FileUtil.extractArchive(testDir, archive);

        // Read the large file from the archive.
        for (PermissionFile permissionFile1 : files) {
            File file = new File(archiveDir, permissionFile1.getFilename());
            Reader r = new FileReader(file);

            for (int j = 0; j < writeBinCount; j++) {
                char[] buffer = new char[bufferLength];
                int length = r.read(buffer);

                for (int i = 0; i < length; i++) {
                    assertEquals(charToWrite, buffer[i]);
                }
            }

            r.close();
            if (permissionFile1.getMode() != -1) {
                assertEquals(permissionFile1.getMode(), FileUtil.getMode(file));
            }
        }
        
        FileUtils.deleteDirectory(archiveDir);
    }
}
