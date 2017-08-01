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

package gov.nasa.kepler.fs.perf;

import gov.nasa.spiffy.common.metrics.ValueMetric;

import java.util.HashSet;
import java.util.Set;
import java.util.concurrent.atomic.AtomicInteger;

import javax.management.NotCompliantMBeanException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.Signature;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;

/**
 * An aspect to add a static AtomicLong to the class this is woven
 * into.  This is used to count method calls so you can do logging
 * or performance monitoring.
 * 
 * @author Sean McCauliff
 *
 */
@Aspect("pertypewithin(*)")
public abstract class PerformanceMetricPollerAspect {
    private static final Log log = LogFactory.getLog(PerformanceMetricPollerAspect.class);
    
    private final AtomicInteger count = new AtomicInteger();
    private volatile int reportingInterval = 73;
    private volatile String metricPrefix = null;
    private final Set<Signature> seen = new HashSet<Signature>();
    
    @Pointcut
    public abstract void metricMe();
    
    @Around("metricMe()")
    public Object sendTimeMetric(ProceedingJoinPoint pjp) throws Throwable {
        if (reportingInterval == 0 || 
            (count.getAndIncrement() % reportingInterval != 0)) {
            return pjp.proceed();
        }
        
        final long startuS = System.nanoTime() / 1000;
        try {
            return pjp.proceed();
        } finally {
            Signature sig = pjp.getSignature();
            if (metricPrefix == null) {
                if (sig.getDeclaringTypeName().contains("fs.server") ||
                    sig.getDeclaringTypeName().contains("fs.storage")) {
                    metricPrefix = "fs.server.";
                } else if (sig.getDeclaringTypeName().contains("fs.client")) {
                    metricPrefix = "fs.client.";
                } else if (sig.getDeclaringTypeName().contains(".fs.")) {
                    metricPrefix = "fs.";
                } else {
                    metricPrefix = "";
                }
            }
            final long enduS = System.nanoTime() / 1000;
            final long durationuS = enduS - startuS;
            ValueMetric.addValue(metricPrefix + sig.toShortString(), durationuS);
            initMBean(pjp, sig);
        }
    }

    private void initMBean(ProceedingJoinPoint pjp, Signature sig)
        throws NotCompliantMBeanException {
        if (!seen.contains(sig)) {
            final Class<?> executingObjectClass = pjp.getThis().getClass();
            PerformanceCounterMBean.instance().registerInstrumentedMetric(new InstrumentedMetric() {
                
                @Override
                public void setReportingInterval(int newInterval) {
                    PerformanceMetricPollerAspect.this.reportingInterval = newInterval;
                }
                
                @Override
                public String name() {
                    return executingObjectClass.getName();
                }
                
                @Override
                public int getReportingInterval() {
                    return PerformanceMetricPollerAspect.this.reportingInterval;
                }
            });
            log.info(sig.toShortString() + " has been instrumented.");
            seen.add(sig);
        }
    }
}
