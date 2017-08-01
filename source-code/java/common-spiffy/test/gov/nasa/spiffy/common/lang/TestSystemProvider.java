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

package gov.nasa.spiffy.common.lang;


import gov.nasa.spiffy.common.lang.SystemProvider;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.InputStream;
import java.io.PrintStream;

/**
 * A kind of redirect of standard output.
 * 
 * @author Sean McCauliff
 *
 */
public class TestSystemProvider implements SystemProvider {

    private int returnCode = 0;
    private boolean returnCodeAssigned = false;
    private ByteArrayOutputStream bout = new ByteArrayOutputStream();
    private ByteArrayOutputStream berr = new ByteArrayOutputStream();
    private ByteArrayInputStream bin = new ByteArrayInputStream(new byte[0]);
    private PrintStream pout = new PrintStream(bout);
    private PrintStream perr = new PrintStream(berr);
    private String userdir;
    
    public TestSystemProvider(File testRoot) {
        userdir = testRoot.getAbsolutePath();
    }
    
    @Override
    public PrintStream err() {
        return perr;
    }

    @Override
    public void exit(int returnCode) {
        if (returnCodeAssigned) return;
        
        this.returnCode = returnCode;
        this.returnCodeAssigned = true;
    }

    @Override
    public String getProperty(String propName) {
        if (propName == null) {
            throw new IllegalArgumentException("propName cannot be null.");
        }
        
        if (propName.equals("user.dir")) {
            return userdir;
        }
        return System.getProperty(propName);         
    }

    @Override
    public InputStream in() {
        return bin;
    }

    @Override
    public PrintStream out() {
        return pout;
    }
    
    public String errors() {
        return new String(berr.toByteArray());
    }
    
    public String stdout() {
        return new String(bout.toByteArray());
    }
    
    public int returnCode() {
        return returnCode;
    }
    
    public boolean returnCodeAssigned() {
        return returnCodeAssigned;
    }
}