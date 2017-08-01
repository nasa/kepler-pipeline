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

package gov.nasa.kepler.fs.client;

import static gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory.CONFIG_SERVICE_PROPERTIES_PATH_PROP;
import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FileStoreTestInterface;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.Set;

import org.apache.commons.configuration.Configuration;
import org.junit.After;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

/**
 * @author Sean McCauliff
 *
 */
public class QueryTest {

    private static Configuration config;
    
    @BeforeClass
    public static void setUpBeforeClass() throws Exception {
        System.setProperty(CONFIG_SERVICE_PROPERTIES_PATH_PROP, "etc/kepler.properties");
        
        try {
            config = ConfigurationServiceFactory.getInstance();
        } catch (PipelineException e) {
            e.printStackTrace();
        }
    }
   
    private FileStoreClient fsClient;
    
    protected FileStoreClient constructTimeSeriesClient()
        throws Exception {
        FileStoreClientFactory.setInstance(null);
        return FileStoreClientFactory.getInstance(config);
    }

    @Before
    public void setUp() throws Throwable {
        fsClient = constructTimeSeriesClient();
        
        FsId id = new FsId("/project/a/1/2/3:4");
        FloatTimeSeries[] fts = new FloatTimeSeries[1];
        fts[0] = new FloatTimeSeries(id, new float[] { 73.1f}, 10, 10, new boolean[1], 888L);
        
        FsId blobFsId = new FsId("/project/a/1/2/3");
        
        FsId mjdId = new FsId("/project/a/type:1:2:3");
        FloatMjdTimeSeries mts = 
            new FloatMjdTimeSeries(mjdId, 0.0, 1.0, new double[1], new float[1], 9090909999L);
        
        try {
            fsClient.beginLocalFsTransaction();
            fsClient.writeTimeSeries(fts);
            fsClient.writeBlob(blobFsId, 55L, new byte[42]);
            fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { mts});
            fsClient.commitLocalFsTransaction();
        } catch (Throwable t) {
            throw t;
        }
    }
    
    @After
    public void after() throws Exception {
        ((FileStoreTestInterface)fsClient).cleanFileStore();
    }
    
    @SuppressWarnings("deprecation")
	@Test
    public void queryFsId() throws Exception {
        Set<FsId> ids = fsClient.queryIds("TimeSeries@/project/a/\\d/\\d/\\d:\\d");
        assertEquals(1, ids.size());
        ids = fsClient.queryIds("blob@/project/*");
        assertEquals(1, ids.size());
        ids = fsClient.queryIds("m@/project/a/type:1:2:\\d");
        assertEquals(1, ids.size());
    }
    
    @Test
    public void queryFsId2() throws Exception {
        Set<FsId> ids = fsClient.queryIds2("TimeSeries@/project/a/\\d/\\d/\\d:\\d");
        assertEquals(1, ids.size());
        ids = fsClient.queryIds2("blob@/project/*");
        assertEquals(1, ids.size());
        ids = fsClient.queryIds2("m@/project/a/type:1:2:\\d");
        assertEquals(1, ids.size());
    }
    
    @Test
    public void queryFsIdPath() throws Exception {
        Set<FsId> ids = fsClient.queryPaths("t@/project/[a,b]/\\d/\\d/*");
        assertEquals(1, ids.size());
        
        ids = fsClient.queryPaths("t@/project/*/\\d/\\d");
        assertEquals(1, ids.size());
        
        ids = fsClient.queryPaths("b@/project/*");
        assertEquals(1, ids.size());
        
        ids = fsClient.queryPaths("m@/project/a/*");
        assertEquals(1, ids.size());
    }
}
