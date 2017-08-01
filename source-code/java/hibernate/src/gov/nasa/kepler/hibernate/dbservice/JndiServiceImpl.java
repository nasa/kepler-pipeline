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

package gov.nasa.kepler.hibernate.dbservice;

import gov.nasa.spiffy.common.pi.PipelineException;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.Hashtable;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.naming.spi.InitialContextFactory;

/**
 * @author Sean McCauliff
 *
 */
class JndiServiceImpl implements JndiService {
  //  private final static String JNDI_FACTORY = 
  //         org.codehaus.spice.jndikit.memory.StaticMemoryInitialContextFactory.class.getName();
    private final static String JNDI_FACTORY =
        KeplerJndiFactory.class.getName();
           
    private final Hashtable<Object,Object> jndiInitialContexProperties =
        new Hashtable<Object,Object>();
    
    /**
     * 
     */
    public JndiServiceImpl() {
        System.setProperty(Context.INITIAL_CONTEXT_FACTORY, JNDI_FACTORY);
        jndiInitialContexProperties.put(Context.INITIAL_CONTEXT_FACTORY, JNDI_FACTORY);
        initialContext();
    }

    public InitialContext initialContext() {
        try {
            InitialContext initialContext = new InitialContext(jndiInitialContexProperties);
            return initialContext;
        } catch (NamingException nx) {
            throw new PipelineException("Failed to init naming service.", nx);
        }
    }

    public String initialContextFactoryName() {
        return JNDI_FACTORY;
    }  
    
    /**
     * The Spice in-memory jndi provider nukes everything when close() is called
     * making life difficult later.  The JDK JMX server does this.
     * @author Sean McCauliff
     *
     */
    public static final class KeplerJndiFactory implements InitialContextFactory {
        private  final org.codehaus.spice.jndikit.memory.StaticMemoryInitialContextFactory initialContextFactory;
        
        public KeplerJndiFactory() {
            initialContextFactory = new  org.codehaus.spice.jndikit.memory.StaticMemoryInitialContextFactory();
        }
        
        public Context getInitialContext(Hashtable<?, ?> environment) throws NamingException {
            Context initialContext = initialContextFactory.getInitialContext(environment);
            KeplerJndiFactoryInvocationHandler invocationHandler =
                new KeplerJndiFactoryInvocationHandler(initialContext);
            
            return (Context)
                Proxy.newProxyInstance(getClass().getClassLoader(), new Class[] {Context.class}, invocationHandler);
        }
    }
    
    private static final class KeplerJndiFactoryInvocationHandler implements InvocationHandler {
        private final Context wrappedContext;
        
        public KeplerJndiFactoryInvocationHandler(Context wrappedContext) {
            this.wrappedContext = wrappedContext;
        }
        
        public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
            if (method.getName().equals("close")) {
                return null;
            }
            
            return method.invoke(wrappedContext,args);
        }
    }
}
