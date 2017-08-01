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

package gov.nasa.kepler.fs.api;
import gov.nasa.kepler.io.DataInputStream;
import gov.nasa.kepler.io.DataOutputStream;


import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import java.io.ByteArrayInputStream;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.io.output.ByteArrayOutputStream;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Sean McCauliff
 *
 */
public class FsIdTest {

    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
    }

    @Test
    public void testValid() {
        FsId fsid = new FsId("/csci_name/some_id");
        assertEquals("/csci_name/", fsid.path());
        assertEquals("some_id", fsid.name());
        fsid = new FsId("/csci_name/", "some_id");
        assertEquals("/csci_name/", fsid.path());
        assertEquals("some_id", fsid.name());
        
        fsid = new FsId("/csci_name/sub_name/some_id");
        assertEquals("/csci_name/sub_name/", fsid.path());
        assertEquals("some_id", fsid.name());
        fsid = new FsId("/dr/pixels/short/23:3:42:235");
        assertEquals("/dr/pixels/short/", fsid.path());
        assertEquals("23:3:42:235", fsid.name());
        fsid = new FsId("/dr/pixels/short", "23:3:42:235");
        assertEquals("/dr/pixels/short/", fsid.path());
        assertEquals("23:3:42:235", fsid.name());
        
        fsid = new FsId("/dr/pixels/short", "23:3:42:235");
        assertEquals("/dr/pixels/short/", fsid.path());
        assertEquals("23:3:42:235", fsid.name());
        fsid = new FsId("/dr/pixels/short/", "23:3:42:235");
        assertEquals("/dr/pixels/short/", fsid.path());
        assertEquals("23:3:42:235", fsid.name());
        fsid = new FsId("/dr/generic/blah-3434.fits");
        
    }
    
    @Test
    public void testInvalid() {
        @SuppressWarnings("unused")
        FsId fsId = null;
        try {
            fsId = new FsId("gak");
            assertTrue("Invalid id should have thrown exception.", false);
        } catch (MalformedFsIdException ok) {
            
        }
        
        try {
             fsId = new FsId("//a/b/c");
             assertTrue("Invalid id should have thrown exception.", false);
        } catch (MalformedFsIdException ok) {
            
        }
        
        try {
            fsId = new FsId("/a/b/c*");
            assertTrue("Invalid id should have thrown exception.", false);
        }catch (MalformedFsIdException ok) {
            
        }
        
        try {
            fsId = new FsId("/csci_name");
            assertTrue("Invalid id should have thrown exception.", false);
        }catch (MalformedFsIdException ok) {
            
        }
       
        try {
            fsId = new FsId("");
            assertTrue("Invalid id should have thrown exception.", false);
        }catch (MalformedFsIdException ok) {
            
        }
        
        try {
            fsId = new FsId("/csci_name/djdj\\");
            assertTrue("Invalid id should have thrown exception.", false);
        }catch (MalformedFsIdException ok) {
            
        }
    } 
    
    @Test
    public void comparator() throws Exception {
        FsId id1 = new FsId("/blah/blah1");
        FsId id2 = new FsId("/blah/blah2");
        FsId id3 = new FsId("/blah/blah1");
        
        assertEquals(id1, id3);
        assertFalse(id1.equals(id2));
        assertEquals(0, id1.compareTo(id3));
        assertTrue(id1.compareTo(id2) != 0);
        assertEquals(id1.hashCode(), id3.hashCode());
        assertTrue(id1.hashCode() != id2.hashCode());
    }
    
    @Test
    public void toByteTest() {
        FsId id = new FsId("/test/id0");
        byte[] b = id.toBytes();
        FsId fromBytes = FsId.valueOf(b);
        assertEquals(id, fromBytes);
    }
    
    @Test
    public void fsIdMemory() {
        final int nids = 100000;
        FsId.pathCache.clear();
        List<FsId> l = new ArrayList<FsId>();
        for (int i=0; i < nids; i++) {
            l.add(new FsId("/klajsflkasjdflaksjdflaksjdflkasjdflaksjdflaskjdflaskjdflaskjdflaskjdflaskdjf/dd"+i));
        }
        for (int i=0; i < nids; i++) {
            assertTrue(l.get(i).path() == l.get(0).path());
        }
        assertEquals(1, FsId.pathCache.size());
    }
   
    @Test
    public void fromToTest() throws Exception {
        ByteArrayOutputStream bout = new ByteArrayOutputStream();
        DataOutputStream dout = new DataOutputStream(bout);
        FsId id = new FsId("/lksdlksldfk/asldfka:lskdfasldf");
        id.writeTo(dout);
        
        ByteArrayInputStream bin = new ByteArrayInputStream(bout.toByteArray());
        DataInputStream din = new DataInputStream(bin);
        FsId readId = FsId.readFrom(din);
        assertEquals(id, readId);
    }
    
    @Test
    public void fsIdIntern() throws Exception {
        FsId id = new FsId();
        Field nameField = FsId.class.getDeclaredField("namePart");
        nameField.setAccessible(true);
        Field pathField = FsId.class.getDeclaredField("pathPart");
        pathField.setAccessible(true);
        nameField.set(id, "before".getBytes("US-ASCII"));
        pathField.set(id, "/this/has/not/been/used/");
        id.intern();
        assertEquals("/this/has/not/been/used/before", id.toString() );
    }
    
    @Test
    public void fsIdWriteToLength() throws Exception {
        FsId id = new FsId("/blah/id0");
        ByteArrayOutputStream bout = new ByteArrayOutputStream();
        id.writeTo(new DataOutputStream(bout));
        assertEquals(id.writeToLength(), bout.size());
    }
    
    @Test
    public void benchmark() {
        long nanoStart = System.nanoTime();
        for (int i=0; i < 1000; i++) {
            @SuppressWarnings("unused")
            FsId fsid = new FsId("/dr/pixels/short/23:3:42:235");
        }
        long nanoEnd = System.nanoTime();
        long nanoInterval = nanoEnd - nanoStart;
        long per  = nanoInterval / 1000;
        System.out.println("" + per + "ns per id");
        assertTrue("Creating a FsId takes too long " + per + "ns" , per < 100000);
    }
}
