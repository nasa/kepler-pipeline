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


import java.io.File;
import java.io.IOException;

/**
 * Removes all the files at a given root.
 *
 *  ------------------>   IMPORTANT <----------------------------
 *  This will follow smbolic links and may destroy unintended files.  Use with
 *  caution.
 *  
 * @author Sean McCauliff
 *
 */
public class RemoveAll implements FileVisitor {

    /** This does nothing.
     * 
     * @see gov.nasa.spiffy.common.io.FileVisitor#enterDirectory(java.io.File)
     */
    @Override
    public void enterDirectory(File newdir) throws IOException {
        //This does nothing.
    }

    /**
     * @see gov.nasa.spiffy.common.io.FileVisitor#exitDirectory(java.io.File)
     */
    @Override
    public void exitDirectory(File exitDir) throws IOException {
        //System.out.println("Removing directory" + exitdir);
        if (!exitDir.delete() && exitDir.exists()) {
            throw new IOException("Unable to delete directory \"" + exitDir + "\".");
        }
    }

    /**
     * This always returns false.
     * @return false
     * @see gov.nasa.spiffy.common.io.FileVisitor#prune()
     */
    @Override
    public boolean prune() {
        return false;
    }

    /**
     * @see gov.nasa.spiffy.common.io.FileVisitor#visitFile(java.io.File, java.io.File)
     */
    @Override
    public void visitFile(File dir, File f) throws IOException {
       // System.out.println("Removing file" + f);
        if (!f.delete()) { 
            throw new IOException("Unable to delete file \"" + f + "\".");
        }
    }

}
