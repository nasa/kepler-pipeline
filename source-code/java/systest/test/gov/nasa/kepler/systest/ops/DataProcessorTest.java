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

package gov.nasa.kepler.systest.ops;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.ArrayList;
import java.util.List;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JUnit4Mockery;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests the {@link DataProcessor} class.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public class DataProcessorTest {

    private PipelineInstanceCrud pipelineInstanceCrud;
    private PipelineTaskCrud pipelineTaskCrud;

    private final Mockery mockery = new JUnit4Mockery() {
        {
            setImposteriser(ClassImposteriser.INSTANCE);
        }
    };

    @Before
    public void setUp() throws Exception {
        pipelineInstanceCrud = mockery.mock(PipelineInstanceCrud.class);
        pipelineTaskCrud = mockery.mock(PipelineTaskCrud.class);
    }

    @Test
    public void testRetrieveSoftwareVersions() {
        assertEquals("4.2", retrieveSoftwareVersions(new String[] { "42" }));
        assertEquals("4.2",
            retrieveSoftwareVersions(new String[] { "42", "42" }));
        assertEquals("4.2, 4.3", retrieveSoftwareVersions(new String[] { "43",
            "42" }));

        assertEquals("4.42", retrieveSoftwareVersions(new String[] { "442" }));
        assertEquals("4.42", retrieveSoftwareVersions(new String[] { "442",
            "442" }));
        assertEquals("4.42, 4.43", retrieveSoftwareVersions(new String[] {
            "443", "442" }));

        assertEquals("ksop-4442",
            retrieveSoftwareVersions(new String[] { "4442" }));
        assertEquals("ksop-4442", retrieveSoftwareVersions(new String[] {
            "4442", "4442" }));
        assertEquals("ksop-4442, ksop-4443",
            retrieveSoftwareVersions(new String[] { "4443", "4442" }));

        assertEquals("trunk",
            retrieveSoftwareVersions(new String[] { "44442" }));
        assertEquals("trunk", retrieveSoftwareVersions(new String[] { "44442",
            "44442" }));
        assertEquals("trunk", retrieveSoftwareVersions(new String[] { "44443",
            "44442" }));

        assertEquals("4.2, 4.42, ksop-4442, trunk",
            retrieveSoftwareVersions(new String[] { "44442", "4442", "442",
                "42" }));
    }

    private String retrieveSoftwareVersions(String[] pipelineInstanceIds) {

        Pair<DataProcessor, List<PipelineInstance>> dataProcessorInfo = createDataProcessor(createOptions(pipelineInstanceIds));

        return dataProcessorInfo.left.retrieveSoftwareVersions(dataProcessorInfo.right);
    }

    private ReportGenerationOptions createOptions(String[] pipelineInstanceIds) {
        ReportGenerationOptions options = new ReportGenerationOptions();
        options.setCommand(ReportGenerationOptions.Command.DATA_PROCESSING_SUMMARY);
        options.setDataName("DataName");
        options.setClusterName("ClusterName");
        options.setJiraTicket("JiraTicket");
        options.addPipelineInstanceIds(pipelineInstanceIds);

        return options;
    }

    private Pair<DataProcessor, List<PipelineInstance>> createDataProcessor(
        final ReportGenerationOptions options) {

        DataProcessor dataProcessor = new DataProcessor(options);
        dataProcessor.setPipelineInstanceCrud(pipelineInstanceCrud);
        dataProcessor.setPipelineTaskCrud(pipelineTaskCrud);

        List<PipelineInstance> pipelineInstances = createPipelineInstances(options);

        return Pair.of(dataProcessor, pipelineInstances);
    }

    private List<PipelineInstance> createPipelineInstances(
        final ReportGenerationOptions options) {

        final List<PipelineInstance> pipelineInstances = new ArrayList<PipelineInstance>();

        mockery.checking(new Expectations() {
            {
                for (final Long pipelineInstanceId : options.getPipelineInstanceIds()) {
                    final PipelineInstance pipelineInstance = new PipelineInstance();
                    pipelineInstance.setId(pipelineInstanceId);
                    pipelineInstances.add(pipelineInstance);

                    final List<String> softwareUrls = new ArrayList<String>(1);
                    if (pipelineInstanceId < 100) {
                        softwareUrls.add(String.format(
                            "svn+ssh://host/path/to/code/%.1f@424242",
                            pipelineInstanceId.doubleValue() / 10));
                    } else if (pipelineInstanceId < 1000) {
                        softwareUrls.add(String.format(
                            "svn+ssh://host/path/to/code/%.2f@424242",
                            pipelineInstanceId.doubleValue() / 100));
                    } else if (pipelineInstanceId < 10000) {
                        softwareUrls.add(String.format(
                            "svn+ssh://host/path/to/code/ksop-%d@424242",
                            pipelineInstanceId));
                    } else {
                        softwareUrls.add("svn+ssh://host/path/to/code@424242");
                    }

                    one(pipelineInstanceCrud).retrieve(
                        with(equal(pipelineInstanceId)));
                    will(returnValue(pipelineInstance));

                    one(pipelineTaskCrud).distinctSoftwareRevisions(
                        with(equal(pipelineInstance)));
                    will(returnValue(softwareUrls));
                }
            }
        });

        return pipelineInstances;
    }
}
