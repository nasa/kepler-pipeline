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

package gov.nasa.spiffy.common.jmx;


import static org.junit.Assert.assertEquals;
import gov.nasa.spiffy.common.jmx.AbstractCompositeData;
import gov.nasa.spiffy.common.jmx.AnnotationMBean;
import gov.nasa.spiffy.common.jmx.AttributeDescription;
import gov.nasa.spiffy.common.jmx.AutoTabularType;
import gov.nasa.spiffy.common.jmx.CompositeTypeDescription;
import gov.nasa.spiffy.common.jmx.ConstructorDescription;
import gov.nasa.spiffy.common.jmx.ItemDescription;
import gov.nasa.spiffy.common.jmx.MBeanDescription;
import gov.nasa.spiffy.common.jmx.OperationDescription;
import gov.nasa.spiffy.common.jmx.ParameterDescription;
import gov.nasa.spiffy.common.jmx.TableIndex;
import gov.nasa.spiffy.common.jmx.TabularTypeDescription;

import java.io.Serializable;
import java.lang.management.ManagementFactory;

import javax.management.DynamicMBean;
import javax.management.MBeanAttributeInfo;
import javax.management.MBeanInfo;
import javax.management.MBeanOperationInfo;
import javax.management.MBeanParameterInfo;
import javax.management.MBeanServer;
import javax.management.MBeanServerConnection;
import javax.management.ObjectName;
import javax.management.openmbean.CompositeData;
import javax.management.openmbean.OpenDataException;
import javax.management.openmbean.TabularDataSupport;
import javax.management.remote.JMXConnector;
import javax.management.remote.JMXConnectorFactory;
import javax.management.remote.JMXConnectorServer;
import javax.management.remote.JMXConnectorServerFactory;
import javax.management.remote.JMXServiceURL;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Sean McCauliff
 *
 */
public class JmxTest {
    private MBeanServer localServer;
    private MBeanServerConnection remoteConnection;
    private JMXConnector cc;
    private JMXConnectorServer cs;
    
    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
        localServer = ManagementFactory.getPlatformMBeanServer();
        JMXServiceURL url = new JMXServiceURL("service:jmx:rmi://");
        cs =
            JMXConnectorServerFactory.newJMXConnectorServer(url, null, localServer);
        cs.start();
        
        JMXServiceURL addr = cs.getAddress();

        // Now make a connector client using the server's address
        cc = JMXConnectorFactory.connect(addr);
        remoteConnection = 
            cc.getMBeanServerConnection();
        
    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        cc.close();
        cs.stop();
    }
    
    /**
     * Verifies that all the correct descriptions will show up.
     * @throws Exception
     */
    @Test
    public void mbeanDescriptionTest() throws Exception {
        
        TestImplementation testImpl = new TestImplementation();
        ObjectName oName = 
            new ObjectName("gov.nasa.kepler.common.jmx;:type=Test");
        localServer.registerMBean(testImpl, oName);
        
        MBeanInfo minfo = remoteConnection.getMBeanInfo(oName);
        assertEquals("A test implementation description.", minfo.getDescription());
        MBeanAttributeInfo[] attrInfo = minfo.getAttributes();
        assertEquals(3, attrInfo.length);
        assertEquals("Stuff description.", attrByName(attrInfo, "Stuff").getDescription());
        assertEquals("A test composite data object.", attrByName(attrInfo, "SomeKindOfBlah").getDescription());
        
        MBeanOperationInfo[] ops = minfo.getOperations();
        assertEquals(1, ops.length);
        assertEquals("Sets flag to true.", ops[0].getDescription());
        MBeanParameterInfo[] params = ops[0].getSignature();
        assertEquals(5, params.length);
        assertEquals("A byte.", params[0].getDescription());
        assertEquals("An int.", params[1].getDescription());
        assertEquals("A long.", params[2].getDescription());
        assertEquals("A string.", params[3].getDescription());
        assertEquals("A boolean.", params[4].getDescription());
        
        Object[] paramValues = new Object[5];
        paramValues[0] = new Byte((byte)1);
        paramValues[1] = new Integer(2);
        paramValues[2] = new Long(3);
        paramValues[3] = "string param value";
        paramValues[4] = Boolean.TRUE;
        
        String[] invokeSig = new String[params.length];
        for (int i=0; i < params.length; i++) {
            invokeSig[i] = params[i].getType();
            System.out.println("Param type \"" + params[i].getType() + "\".");
        }
        remoteConnection.invoke(oName, "op", paramValues, invokeSig);
                
        CompositeData cData = (CompositeData) remoteConnection.getAttribute(oName, "SomeKindOfBlah");
        String blahValue = (String) cData.get("Blah");
        assertEquals("blah, blah, blah", blahValue);

        
        //Thread.sleep(120*1000);
       
    }
        
    private MBeanAttributeInfo attrByName(MBeanAttributeInfo[] attrInfo, String attrName) {
        for (MBeanAttributeInfo info : attrInfo) {
            if (info.getName().equals(attrName)) {
                return info;
            }
        }
        return null;
    }

    @MBeanDescription("A test implementation description.")
    public static class TestImplementation 
        extends AnnotationMBean
        implements DynamicMBean {
        
        public boolean opExecuted = false;
        
        @AttributeDescription("Stuff description.")
        public String getStuff() {
            return "stuff return value";
        }

        @SuppressWarnings("unused")
        @OperationDescription("Sets flag to true.")
        public void op(@ParameterDescription(name="b",desc="A byte.") int b, 
                                  @ParameterDescription(name="i",desc="An int.") int i, 
                                  @ParameterDescription(name="l",desc="A long.") long l, 
                                  @ParameterDescription(name="s",desc="A string.") String s, 
                                  @ParameterDescription(name="bool",desc="A boolean.") boolean bool) {
            opExecuted = true;
        }

        @ConstructorDescription("Default no-arg constructor")
        public TestImplementation() {
            
        }
        
        @AttributeDescription("A test composite data object.")
        public TestCompositeData getSomeKindOfBlah() {
            try {
                return new TestCompositeData("blah, blah, blah", 0);
            } catch (OpenDataException ode) {
                ode.printStackTrace();
                throw new IllegalStateException("Failed to get composite test data.", ode);
            }
        }
        
        @AttributeDescription("A test tabular data object.")
        public TestTabularData getTabularData() {
            try {
                TestTabularData tData = new TestTabularData();
                tData.put(new TestCompositeData("blah0", 0));
                tData.put(new TestCompositeData("blah1", 1));
                return tData;
            } catch (OpenDataException ode) {
                ode.printStackTrace();
                throw new IllegalStateException("Bad.", ode);
            }
        }   
    }
    
    @TabularTypeDescription(desc="This is a test of tabular data.", rowClass=TestCompositeData.class)
    public static class TestTabularData extends TabularDataSupport {
        /**
         * 
         */
        private static final long serialVersionUID = 4922669198867166235L;

        public TestTabularData() throws OpenDataException {
            super(AutoTabularType.newAutoTabularType(TestTabularData.class).tabularType);
        }
    }
    
    @CompositeTypeDescription("This is a test of a composite type.")
    public static class TestCompositeData 
        extends AbstractCompositeData
        implements CompositeData, Serializable {
        
        /**
         * 
         */
        private static final long serialVersionUID = -5796938803588308932L;
        
        private final String blah;
        private final int index;
        
        TestCompositeData(String blah, int index) throws OpenDataException{
            this.blah = blah;
            this.index = index;
        }
        
        @ItemDescription("A blah")
        public String getBlah() {
            return blah;
        }
        
        @TableIndex(0)
        @ItemDescription("Index")
        public int getIndex() {
            return index;
        }
    }

}
