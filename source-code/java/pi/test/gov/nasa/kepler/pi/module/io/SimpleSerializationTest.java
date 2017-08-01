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

package gov.nasa.kepler.pi.module.io;

import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.persistable.BinaryPersistableInputStream;
import gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import junit.framework.TestCase;

public class SimpleSerializationTest extends TestCase {
    
    private static final File dirRoot = 
        new File(Filenames.BUILD_TMP, "SimpleSerializationTest.test");
    
    @Override
    public void setUp() throws Exception {
        super.setUp();
        dirRoot.mkdirs();
    }
    
    @Override
    public void tearDown() throws Exception {
        super.tearDown();
        FileUtil.removeAll(dirRoot);
    }
    
    public void test1() throws Exception  {
        B0gus innerB0gus = 
            new B0gus("string",(byte)1,2,(short)3,0xAFFEAFFEAFFEAFFEL,
                new ArrayList<B0gus>(), new float[]{});
        ArrayList<B0gus> list = new ArrayList<B0gus>();
        list.add(innerB0gus);
        B0gus outerB0gus = 
            new B0gus("outer",(byte)5,6,(short)7,8L,list, new float[]{1.0f, 5.0f});
        File testFile = new File(dirRoot, "binary");
        FileOutputStream fos = new FileOutputStream(testFile);
        DataOutputStream dos = new DataOutputStream(fos);
        BinaryPersistableOutputStream bpos = 
            new BinaryPersistableOutputStream(dos);
        bpos.save(outerB0gus);
        dos.flush();
        fos.close();
    
        // load
        
        B0gus loaded = new B0gus();
        FileInputStream fis = new FileInputStream(testFile);
        DataInputStream dis = new DataInputStream(fis);
        BinaryPersistableInputStream bpis = 
            new BinaryPersistableInputStream(dis);
    
        
        bpis.load(loaded);
    
        assertEquals("outputs does not match inputs", outerB0gus, loaded );
    }
    
    public static class B0gus implements Persistable {
        private String s;
        private byte b;
        private int i;
        private short h;
        private long l;
        @SuppressWarnings("unused")
        private String nullString = "notnull";  //There is no representation for null.
        private List<B0gus> list;
        private float[] fa;
        
        public B0gus() {
        }
        
        B0gus(String s, byte b, int i, short h, long l, ArrayList<B0gus> list, float[] fa) {
            this.s = s;
            this.b = b;
            this.i = i;
            this.h = h;
            this.l = l;
            this.list = list;
            this.fa = fa;
        }

        @Override
        public int hashCode() {
            final int prime = 31;
            int result = 1;
            result = prime * result + b;
            result = prime * result + Arrays.hashCode(fa);
            result = prime * result + h;
            result = prime * result + i;
            result = prime * result + (int) (l ^ (l >>> 32));
            result = prime * result + ((list == null) ? 0 : list.hashCode());
            result = prime * result + ((s == null) ? 0 : s.hashCode());
            return result;
        }
        
        @Override
        public boolean equals(Object o) {
            B0gus other = (B0gus) o;
            try {
                return other.b == this.b && other.i == this.i && other.h == this.h &&
                    other.l == this.l && other.s.equals(this.s) && other.list.equals(this.list) &&
                    Arrays.equals(other.fa, this.fa);
            } catch (NullPointerException npe) {
                return false;
            }
        }
    }
}
