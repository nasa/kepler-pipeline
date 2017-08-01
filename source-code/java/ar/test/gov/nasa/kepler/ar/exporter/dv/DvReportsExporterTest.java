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

package gov.nasa.kepler.ar.exporter.dv;

import gov.nasa.kepler.ar.cli.DvReportsExportCli;
import gov.nasa.kepler.ar.exporter.FileNameFormatter;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.hibernate.mr.MrReport;
import gov.nasa.kepler.hibernate.pi.*;
import gov.nasa.kepler.mc.mr.GenericReportOperations;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.lang.TestSystemProvider;

import java.io.File;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import junit.framework.Assert;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

/**
 * 
 * @author Sean McCauliff
 *
 */
@RunWith(JMock.class)
public class DvReportsExporterTest {

    
    private final File outputDir = 
        new File(Filenames.BUILD_TEST, "DvReportsExporterTest");
    
    private TestSystemProvider system;
    private DvReportsExportCli cli;
    private Mockery mockery;
    private PipelineInstanceCrud pipelineInstanceCrud;
    private GenericReportOperations reportOps;
    private FileStoreClient fsClient;
    
    
    @Before
    public void setup() throws Exception {
        FileUtil.mkdirs(outputDir);
        mockery = new Mockery() {
            {
                setImposteriser(ClassImposteriser.INSTANCE);
            }
        };
        pipelineInstanceCrud = mockery.mock(PipelineInstanceCrud.class);
        reportOps = mockery.mock(GenericReportOperations.class);
        
        
        system = new TestSystemProvider(outputDir);
        
        cli = new DvReportsExportCli(system) {
            @Override
            protected PipelineInstanceCrud pipelineInstanceCrud() {
                return pipelineInstanceCrud;
            }
            @Override
            protected GenericReportOperations reportOps() {
                return reportOps;
            }
            @Override
            protected FileStoreClient fsClient() {
                return fsClient;
            }
        };

        
    }
    
    @After
    public void tearDown() throws Exception {
        FileUtil.cleanDir(outputDir);
    }
    
    private void populateByPipelineInstance() throws Exception {
        final long PIPELINE_INSTANCE_ID = 2L;
        final Date PIPELINE_INSTANCE_START = new Date();
        final PipelineInstance pipelineInstance = new PipelineInstance();
        pipelineInstance.setId(PIPELINE_INSTANCE_ID);
        pipelineInstance.setStartProcessingTime(PIPELINE_INSTANCE_START);

        mockery.checking(new Expectations() {{
            one(pipelineInstanceCrud).retrieve(PIPELINE_INSTANCE_ID);
            will(returnValue(pipelineInstance));
        }});
        

        createReports(reportOps,
            PIPELINE_INSTANCE_ID, PIPELINE_INSTANCE_START, new int[] {  3, 4} );
        fsClient = mockery.mock(FileStoreClient.class);
        mockery.checking(new Expectations() {{
            atLeast(1).of(fsClient).disassociateThread();
        }});
    }
    
    @Test
    public void exportDvReportsByPipelineInstance() throws Exception {
        populateByPipelineInstance();
        
        DvReportsExporter dvReportsExporter = 
            new DvReportsExporter(reportOps, pipelineInstanceCrud, outputDir, fsClient);
        
        dvReportsExporter.exportInstances(2L);
        
    }
    
    @Test
    public void exportDvReportsByPipelineInstanceCli() throws Exception {
        populateByPipelineInstance();
        
        cli.parse(new String[] {"-d", outputDir.toString(), "-i", "2"} );
        cli.export();
        
        Assert.assertEquals(0, system.returnCode());
    }
    
    



    
    private void createReports(final GenericReportOperations reportOps,
        final long pipelineInstanceId, final Date pipelineStartDate, int[] reportKeplerIds) 
        throws Exception {
        
        final PipelineDefinitionNode pipelineDefNode = createPipelineDefinitionNode();
        
        final List<MrReport> reports = new ArrayList<MrReport>();
        FileNameFormatter fnameFormatter = new FileNameFormatter();
        final List<File> reportFiles = new ArrayList<File>();
        for (int keplerId : reportKeplerIds) {
            MrReport mrReport = 
                new MrReport(new PipelineTask(null, pipelineDefNode, null), 
                    "" + keplerId, "fname" + keplerId, "application/pdf", "/a/b/"+keplerId);
            reports.add(mrReport);
            
            String reportFname = fnameFormatter.dataValidationReportName(keplerId, pipelineStartDate);
            File reportFile = new File(outputDir, reportFname);
            reportFiles.add(reportFile);
        }
        
        mockery.checking(new Expectations() {{
            one(reportOps).retrieveReports("dv", pipelineInstanceId);
            will(returnValue(reports));
            
            for (int i=0; i < reports.size(); i++) {
                one(reportOps).retrieveBlobResult(reports.get(i), reportFiles.get(i));
            }
        }});
    }

    private PipelineDefinitionNode createPipelineDefinitionNode()
        throws NoSuchMethodException, InstantiationException,
        IllegalAccessException, InvocationTargetException {
        //I'm breaking encapsulation here, but if I don't then I need like 50
        //lines of code to do the same thing.
        Constructor<ModuleName> moduleNameConstructor = 
            ModuleName.class.getDeclaredConstructor(String.class);
        moduleNameConstructor.setAccessible(true);
        ModuleName moduleName = moduleNameConstructor.newInstance("dv");
        final PipelineDefinitionNode pipelineDefNode = new PipelineDefinitionNode(moduleName);
        return pipelineDefNode;
    }
    
    
}
