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

import java.sql.Connection;
import java.util.Collection;
import java.util.Properties;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.FlushMode;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.AnnotationConfiguration;

public abstract class HibernateDatabaseServiceBase implements DatabaseService {

    private static final Log log = LogFactory.getLog(HibernateDatabaseServiceBase.class);

    /**
     * If set, these properties are used to initialize Hibernate. If null, the
     * properties are fetched from the config service
     */
    protected Properties alternatePropertiesSource = null;

    protected AnnotationConfiguration hibernateConfig = null;

    public HibernateDatabaseServiceBase() {
        super();
    }

    /**
     * @see gov.nasa.kepler.hibernate.dbservice.DatabaseService#flush()
     */
    @Override
    public void flush() {
        getSession().flush();
    }

    /**
     * @see gov.nasa.kepler.hibernate.dbservice.DatabaseService#turnAutoFlushOff()
     */
    public void setAutoFlush(boolean active) {
        if (active) {
            getSession().setFlushMode(FlushMode.AUTO);
        } else {
            getSession().setFlushMode(FlushMode.MANUAL);
        }
    }

    public DdlInitializer getDdlInitializer() {

        DdlInitializer ddlInitializer = null;

        String dialect = getPropertyChecked(HibernateConstants.HIBERNATE_DIALECT_PROP);
        String url = getPropertyChecked(HibernateConstants.HIBERNATE_URL_PROP);
        String driver = getPropertyChecked(HibernateConstants.HIBERNATE_DRIVER_PROP);
        String username = getPropertyChecked(HibernateConstants.HIBERNATE_USERNAME_PROP);
        String password = hibernateConfig.getProperty(HibernateConstants.HIBERNATE_PASSWD_PROP);

        if (log.isDebugEnabled()) {
            log.debug(String.format("%s=%s",
                HibernateConstants.HIBERNATE_DIALECT_PROP, dialect));
            log.debug(String.format("%s=%s",
                HibernateConstants.HIBERNATE_URL_PROP, url));
            log.debug(String.format("%s=%s",
                HibernateConstants.HIBERNATE_DRIVER_PROP, driver));
            log.debug(String.format("%s=%s",
                HibernateConstants.HIBERNATE_USERNAME_PROP, username));
            log.debug(String.format("%s=********",
                HibernateConstants.HIBERNATE_PASSWD_PROP, password));
        }
        
        SqlDialect sqlDialect = getSqlDialect();

        switch (sqlDialect) {
            case HSQLDB:
                ddlInitializer = new HsqldbDdlInitializer(url, driver, username, password);
                break;
            case ORACLE:
                if (username.equals("kepler") || username.equals("stable") || username.equals("test")) {
                    throw new PipelineException("DdlInitializer not allowed to run against Oracle DB with user="
                        + username);
                }
                ddlInitializer = new OracleDdlInitializer(url, driver, username, password);
                break;
            default:
                throw new PipelineException("No DdlInitializer available for unknown dialect = " + dialect);
        }

        log.info("Created " + ddlInitializer.getClass().getSimpleName() + " for url:" + url + ", user:" + username);

        return ddlInitializer;
    }

    @Override
    public SqlDialect getSqlDialect() {
        String dialect = getPropertyChecked(HibernateConstants.HIBERNATE_DIALECT_PROP);
        SqlDialect sqlDialect = null;
        try {
            sqlDialect = SqlDialect.fromDialectString(dialect);
        } catch (IllegalArgumentException iae) {
            throw new PipelineException("Unknown dialect = " + dialect);
        }

        return sqlDialect;
    }

    protected String getPropertyChecked(String name) {
        String value = hibernateConfig.getProperty(name);

        if (value == null) {
            throw new PipelineException("Required property " + name + " not set!");
        }
        return value;
    }

    public void evictAll(Collection<?> collection) {
        Session session = getSession();
        for (Object object : collection) {
            session.evict(object);
        }
    }

    public void evict(Object object) {
        Session session = getSession();
        session.evict(object);
    }

    public void clear() {
        Session session = getSession();
        session.clear();
    }

    /**
     * @see gov.nasa.kepler.hibernate.dbservice.DatabaseService#getConnection()
     */
    public Connection getConnection() {
        return getSession().connection();
    }

    /**
     * The underlying Hibernate implementation of
     * javax.persistence.EntityManagerFactory. We use this to get direct access
     * to the Hibernate APIs rather than using the JPA (which is a subset of the
     * Hibernate functionality)
     */
    protected abstract SessionFactory sessionFactory();

    public void setPropertiesSource(Properties properties) {
        this.alternatePropertiesSource = properties;
    }
}