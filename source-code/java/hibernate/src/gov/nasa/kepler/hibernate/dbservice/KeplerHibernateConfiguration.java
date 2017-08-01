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

import java.util.Iterator;
import java.util.Properties;
import java.util.Set;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.cfg.AnnotationConfiguration;

/**
 * This class contructs a Hibernate @{link AnnotatedConfiguration} object.
 * 
 * It uses {@link AnnotatedPojoList} to scan the class path for annotated
 * classes and adds them to the configuration.
 * 
 * It also copies all properties that are prefixed with "hibernate." from the
 * configuration service (kepler.properties or system properties) to the
 * Hibernate @{link AnnotatedConfiguration} object.
 * 
 * This class is used by the {@link HibernateDatabaseService} to initialize the
 * {@link DatabaseService}. It is also used by the various ant tasks that
 * create the schema (schema-oracle, schema-hsqldb, etc.)
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class KeplerHibernateConfiguration {
    private static final Log log = LogFactory.getLog(KeplerHibernateConfiguration.class);

    public static final String HIBERNATE_CONNECTION_URL_PROP = "hibernate.connection.url";
    public static final String HIBERNATE_CONNECTION_USERNAME_PROP = "hibernate.connection.username";
    public static final String HIBERNATE_CONNECTION_PASSWORD_PROP = "hibernate.connection.password";

    private static final String KEPLER_SOC_HIBERNATE_PACKAGE_NAME_OVERRIDE_PROP = "kepler.hibernate.config.package";

    private static final String KEPLER_SOC_HIBERNATE_PACKAGE_NAME = "gov.nasa.kepler.hibernate";
    private static final String KEPLER_SOC_HIBERNATE_JAR_NAME = "hibernate.jar";
    private static final String KEPLER_SOC_CLASSPATH_JAR_NAME = "soc-classpath.jar";

    /**
     * Private to prevent instantiation. Static method only
     */
    private KeplerHibernateConfiguration() {
    }

    /**
     * Build a {@link AnnotationConfiguration} instance using Kepler-specific
     * resources.
     * 
     * @return
     * @throws PipelineException
     */
    public static AnnotationConfiguration buildHibernateConfiguration()
        {
        return buildHibernateConfiguration(null);
    }

    /**
     * Build a {@link AnnotationConfiguration} instance using Kepler-specific
     * resources.
     * 
     * @return
     * @throws PipelineException
     */
    public static AnnotationConfiguration buildHibernateConfiguration(
        Properties hibernateProperties) {
        Configuration keplerConfig = ConfigurationServiceFactory.getInstance();

        log.info("Initializing Hibernate");

        AnnotationConfiguration hibernateConfig = new AnnotationConfiguration();

        hibernateConfig.setNamingStrategy(KeplerNamingStrategy.INSTANCE);

        /*
         * Copy hibernate-related properties from the props source to the
         * Hibernate configuration
         */
        if (hibernateProperties != null) {
            /* Use the Properties passed in */
            for (Object okey : hibernateProperties.keySet()) {
                String key = (String) okey;
                String value = hibernateProperties.getProperty(key);

                if (value != null) {
                    log.debug("copying property, key=" + key + ", value="
                        + value);
                    hibernateConfig.setProperty(key, value);
                } else {
                    throw new PipelineException("Property values must not be null, key=" + key);
                }
            }
        } else {
            /*
             * get the props from the from the ConfigurationService
             * (kepler.properties or system props)
             */
            for (Iterator<?> iter = keplerConfig.getKeys("hibernate"); iter.hasNext();) {
                String key = (String) iter.next();
                String value = keplerConfig.getString(key);

                log.debug("copying property, key=" + key + ", value=" + value);
                hibernateConfig.setProperty(key, value);
            }
        }

        log.info("Database URL: " + hibernateConfig.getProperty(HIBERNATE_CONNECTION_URL_PROP));
        log.info("Database User: " + hibernateConfig.getProperty(HIBERNATE_CONNECTION_USERNAME_PROP));
        
        AnnotatedPojoList annotatedPojoList = new AnnotatedPojoList();

        String packageFilterOverride = System.getProperty(KEPLER_SOC_HIBERNATE_PACKAGE_NAME_OVERRIDE_PROP);
        if (packageFilterOverride != null) {
            annotatedPojoList.getPackageFilters().add(packageFilterOverride);
        } else {
            annotatedPojoList.getPackageFilters().add(
                KEPLER_SOC_HIBERNATE_PACKAGE_NAME);
        }

        annotatedPojoList.getJarFilters().add(KEPLER_SOC_HIBERNATE_JAR_NAME);
        annotatedPojoList.getJarFilters().add(KEPLER_SOC_CLASSPATH_JAR_NAME);

        Set<Class<?>> detectedClasses;

        try {
            log.info("Scanning for annotated POJOs");
            detectedClasses = annotatedPojoList.scanForClasses();
        } catch (Exception e) {
            throw new PipelineException(
                "failed to auto-scan for annotated classes, caught e = " + e, e);
        }

        log.info("Adding " + detectedClasses.size()
            + " annotated POJOs to Hibernate");

        for (Class<?> clazz : detectedClasses) {
            hibernateConfig.addAnnotatedClass(clazz);
        }

        // Include Hibernate configuration that can't be handled by annotations.
        // Also uncomment associated line in copy-metadata build.xml target.
        // hibernateConfig.addResource("hbm.cfg.xml");
        // hibernateConfig.addResource("orm.xml");

        return hibernateConfig;
    }
}
