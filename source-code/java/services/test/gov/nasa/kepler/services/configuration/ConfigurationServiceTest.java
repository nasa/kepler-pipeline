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

package gov.nasa.kepler.services.configuration;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DdlInitializer;
import gov.nasa.kepler.hibernate.services.KeyValuePair;
import gov.nasa.kepler.hibernate.services.KeyValuePairCrud;
import gov.nasa.spiffy.common.pi.PipelineException;

import org.apache.commons.configuration.Configuration;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class ConfigurationServiceTest{
    private DatabaseService databaseService;
    private KeyValuePairCrud keyValuePairCrud;
    private DdlInitializer ddlInitializer;

    //private static final Log log = LogFactory.getLog(ConfigurationServiceTest.class);

    @Before
    public void before() throws PipelineException{
        databaseService = DatabaseServiceFactory.getInstance();
        keyValuePairCrud = new KeyValuePairCrud(databaseService);

        ddlInitializer = databaseService.getDdlInitializer();
        ddlInitializer.initDB();

        System.clearProperty(ConfigurationServiceFactory.CONFIG_SERVICE_PROPERTIES_PATH_PROP);
        System.clearProperty(ConfigurationServiceFactory.CONFIG_SERVICE_USE_DB_PROP);
        ConfigurationServiceFactory.reset();
    }
    
    @After
    public void tearDown() throws Exception {
        databaseService.closeCurrentSession();
        ddlInitializer.cleanDB();
    }

    @Test
    public void testSystemProperty() throws PipelineException{
        System.setProperty("my.string.property", "foo");
        System.setProperty("my.boolean.property", "true");
        System.setProperty("my.int.property", "42");
        System.setProperty("my.double.property", "42.42");

        Configuration config = ConfigurationServiceFactory.getInstance();
        
        assertEquals("foo", config.getString("my.string.property"));
        assertEquals(true, config.getBoolean("my.boolean.property"));
        assertEquals(42, config.getInt("my.int.property"));
        assertEquals(42.42, config.getDouble("my.double.property"), 0);
    }
    
    @Test
    public void testFilePropertyOverride() throws PipelineException{
    }
    
    @Test
    public void testSystemPropertyOverride() throws PipelineException{
    }
    
    @Test
    public void testDefaultFileProperty() throws PipelineException{
        Configuration config = ConfigurationServiceFactory.getInstance();
        
        assertEquals("from.default.location", config.getString("test.file.property"));
    }
    
    @Test
    public void testSysPropFileProperty() throws PipelineException{
        
        System.setProperty(ConfigurationServiceFactory.CONFIG_SERVICE_PROPERTIES_PATH_PROP, "testdata/sysprop.kepler.properties");
        
        Configuration config = ConfigurationServiceFactory.getInstance();
        
        assertEquals("from.sysprop.location", config.getString("test.file.property"));
    }
    
    //TODO: can't enable this test because there's no way to set an env var for the current 
    // process.  Maybe launch a sub-process?
    //@Test
    public void testEnvVarFileProperty() throws PipelineException{
        
        Configuration config = ConfigurationServiceFactory.getInstance();
        
        assertEquals("from.envvar.location", config.getString("test.file.property"));
    }
    
    @Test
    public void testDbProperty() throws PipelineException{
        databaseService.beginTransaction();

        keyValuePairCrud.create(new KeyValuePair("my.test.db.prop", "42"));

        databaseService.commitTransaction();

        System.setProperty(ConfigurationServiceFactory.CONFIG_SERVICE_USE_DB_PROP, "true");
        
        Configuration config = ConfigurationServiceFactory.getInstance();
        
        assertEquals(42, config.getInt("my.test.db.prop"));
    }

    @Test
    public void testDbPropertyDbOff() throws PipelineException{
        databaseService.beginTransaction();

        keyValuePairCrud.create(new KeyValuePair("my.test.db.prop", "42"));

        databaseService.commitTransaction();

        Configuration config = ConfigurationServiceFactory.getInstance();
        
        assertEquals(null, config.getProperty("my.test.db.prop"));
    }
    
    @Test
    public void testDbPropertyDbFalse() throws PipelineException{
        databaseService.beginTransaction();

        keyValuePairCrud.create(new KeyValuePair("my.test.db.prop", "42"));

        databaseService.commitTransaction();

        System.setProperty(ConfigurationServiceFactory.CONFIG_SERVICE_USE_DB_PROP, "false");
        
        Configuration config = ConfigurationServiceFactory.getInstance();
        
        assertEquals(null, config.getProperty("my.test.db.prop"));
    }
}