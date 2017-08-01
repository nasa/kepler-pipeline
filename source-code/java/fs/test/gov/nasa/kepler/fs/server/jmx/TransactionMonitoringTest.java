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

package gov.nasa.kepler.fs.server.jmx;

import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.api.FileStoreTransactionTimeOut;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.util.PersistableXid;
import gov.nasa.kepler.fs.server.FileTransactionManagerInterface;
import gov.nasa.kepler.fs.server.scheduler.FsIdLocationFactory;
import gov.nasa.kepler.fs.server.xfiles.TransactionalFile;
import gov.nasa.kepler.fs.server.xfiles.TransactionalMjdTimeSeriesFile;
import gov.nasa.kepler.fs.server.xfiles.TransactionalRandomAccessFile;
import gov.nasa.kepler.fs.server.xfiles.TransactionalStreamFile;

import java.io.IOException;
import java.lang.management.ManagementFactory;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.net.InetAddress;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ExecutorService;

import javax.management.MBeanServer;
import javax.management.MBeanServerConnection;
import javax.management.ObjectName;
import javax.management.openmbean.OpenDataException;
import javax.management.remote.JMXConnector;
import javax.management.remote.JMXConnectorFactory;
import javax.management.remote.JMXConnectorServer;
import javax.management.remote.JMXConnectorServerFactory;
import javax.management.remote.JMXServiceURL;
import javax.transaction.xa.XAException;
import javax.transaction.xa.Xid;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Sean McCauliff
 *
 */
public class TransactionMonitoringTest {

    private MBeanServer localServer;
    @SuppressWarnings("unused")
    private MBeanServerConnection remoteConnection;
    private JMXConnector cc;
    private JMXConnectorServer cs;
    
   @Before
   public void setUp() throws Exception {
        localServer = ManagementFactory.getPlatformMBeanServer();
        JMXServiceURL url = new JMXServiceURL("service:jmx:rmi://host");
        cs =
            JMXConnectorServerFactory.newJMXConnectorServer(url, null, localServer);
        cs.start();
        
        JMXServiceURL addr = cs.getAddress();
    
        // Now make a connector client using the server's address
        cc = JMXConnectorFactory.connect(addr);
        remoteConnection =  cc.getMBeanServerConnection();

    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        cc.close();
        cs.stop();
    }
    

    @Test
    public void transactionMonitoringInfoTest() throws Exception {
        //Just registering runs through some introspection code.
        ObjectName oName = new ObjectName("gov.nasa.kepler.fs.jmx;:type=TransactionMonitoring");
        
        InvocationHandler xfileHandler = new InvocationHandler() {

            @Override
            public Object invoke(Object proxy, Method method, Object[] args)
                throws Throwable {

                if (method.getName().equals("transactionMonitoringInfo")) {
                    return transactionMonitoringInfo();
                }
                
                throw new IllegalStateException("Shoulllllld never reach here.");
            }
            
        };
        
        FileTransactionManagerInterface xInterface  = 
            (FileTransactionManagerInterface) Proxy.newProxyInstance(getClass().getClassLoader(), new   Class[] { FileTransactionManagerInterface.class }, xfileHandler);
        
        TransactionMonitoring xMonitor =  new TransactionMonitoring(xInterface);
        localServer.registerMBean(xMonitor, oName);
    }
    
    private List<TransactionMonitoringInfo> transactionMonitoringInfo() throws FileStoreException {
        List<TransactionMonitoringInfo> rv = new ArrayList<TransactionMonitoringInfo>();
        try {
            rv.add(new TransactionMonitoringInfo("b0gus.arc.nasa.gov", 
                            "xid string", 77, false, new Date(), new Date(), 
                            "current state" ));
        } catch (OpenDataException e) {
            throw new FileStoreException("Failed to create new TransactionMonitoringInfo", e);
        }
        return rv;
    }
    
}
