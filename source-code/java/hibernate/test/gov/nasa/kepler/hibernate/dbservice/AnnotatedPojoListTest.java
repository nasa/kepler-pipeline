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

import static org.junit.Assert.assertTrue;
import gov.nasa.spiffy.common.io.Filenames;

import java.util.HashSet;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Test;

/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class AnnotatedPojoListTest {
    private static final Log log = LogFactory.getLog(AnnotatedPojoListTest.class);

    @Test
    public void testDirClassPathNoFilters() throws Exception {

        log.info("testDirClassPathNoFilters");

        AnnotatedPojoList annotatedPojoList = new AnnotatedPojoList();

        Set<Class<?>> detectedClasses = annotatedPojoList.scanForClasses();

        for (Class<?> clazz : detectedClasses) {
            log.info("found: " + clazz);
            assertTrue("startsWith(gov.nasa.kepler.[hibernate|common])",
                clazz.getName()
                    .startsWith("gov.nasa.kepler.hibernate") || clazz.getName()
                    .startsWith("gov.nasa.kepler.common"));
        }

        assertTrue("at least 20 classes (sanity check)",
            detectedClasses.size() >= 20);
    }

    @Test
    public void testDirClassPathPackageFilters() throws Exception {

        log.info("testDirClassPathPackageFilters");

        AnnotatedPojoList annotatedPojoList = new AnnotatedPojoList();
        Set<String> packageFilters = new HashSet<String>();
        packageFilters.add("gov.nasa.kepler.hibernate.dr");
        annotatedPojoList.setPackageFilters(packageFilters);

        Set<Class<?>> detectedClasses = annotatedPojoList.scanForClasses();

        for (Class<?> clazz : detectedClasses) {
            log.info("found: " + clazz);
            assertTrue("startsWith(gov.nasa.kepler.hibernate.dr)",
                clazz.getName()
                    .startsWith("gov.nasa.kepler.hibernate.dr"));
        }

        assertTrue("at least 10 classes (sanity check)",
            detectedClasses.size() >= 10);
    }

    @Test
    public void testJarClassPathJarFilters() throws Exception {

        log.info("testDirClassPathJarFilters");

        AnnotatedPojoList annotatedPojoList = new AnnotatedPojoList();
        Set<String> jarFilters = new HashSet<String>();
        jarFilters.add("hibernate.jar");
        jarFilters.add("soc-classpath.jar");
        annotatedPojoList.setJarFilters(jarFilters);

        Set<String> classPathToScan = new HashSet<String>();
        classPathToScan.add(Filenames.DIST_ROOT + "/lib/soc-classpath.jar");
        annotatedPojoList.setClassPathToScan(classPathToScan);

        Set<Class<?>> detectedClasses = annotatedPojoList.scanForClasses();

        for (Class<?> clazz : detectedClasses) {
            log.info("found: " + clazz);
            assertTrue("startsWith(gov.nasa.kepler.hibernate)", clazz.getName()
                .startsWith("gov.nasa.kepler.hibernate"));
        }

        assertTrue("at least 10 classes (sanity check)",
            detectedClasses.size() >= 10);
    }

    @Test
    public void testSpecificClassPathJarFilters() throws Exception {

        log.info("testClassPathJar");

        AnnotatedPojoList annotatedPojoList = new AnnotatedPojoList();

        Set<String> jarFilters = new HashSet<String>();
        jarFilters.add("soc-classpath.jar");
        jarFilters.add("hibernate.jar");
        annotatedPojoList.setJarFilters(jarFilters);

        Set<String> packageFilters = new HashSet<String>();
        packageFilters.add("gov.nasa.kepler.hibernate");
        annotatedPojoList.setPackageFilters(packageFilters);

        Set<String> classPathToScan = new HashSet<String>();
        classPathToScan.add(Filenames.DIST_ROOT + "/lib/soc-classpath.jar");
        annotatedPojoList.setClassPathToScan(classPathToScan);

        Set<Class<?>> detectedClasses = annotatedPojoList.scanForClasses();

        for (Class<?> clazz : detectedClasses) {
            log.info("found: " + clazz);
            assertTrue("startsWith(gov.nasa.kepler.hibernate)", clazz.getName()
                .startsWith("gov.nasa.kepler.hibernate"));
        }

        assertTrue("at least 10 classes (sanity check)",
            detectedClasses.size() >= 10);
    }
}
