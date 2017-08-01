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

package gov.nasa.kepler.aft.gar;

import gov.nasa.kepler.aft.AutomatedFeatureTest;
import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.gar.huffman.HuffmanModuleParameters;
import gov.nasa.kepler.gar.huffman.HuffmanPipelineModule;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.gar.Histogram;
import gov.nasa.kepler.hibernate.gar.HistogramGroup;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionCrud;
import gov.nasa.kepler.pi.configuration.PipelineConfigurationOperations;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * AFT for the Huffman pipeline module.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public class HuffmanNominalTest extends AutomatedFeatureTest {

    private static final Log log = LogFactory.getLog(HuffmanNominalTest.class);

    private static final String HUFFMAN_TRIGGER_NAME = "HUFFMAN";

    public HuffmanNominalTest() {
        super(HuffmanPipelineModule.MODULE_NAME, "Nominal");
    }

    @Override
    protected void createDatabaseContents() throws Exception {

        // Only create pipelines if they don't already exist.
        TriggerDefinition trigger = new TriggerDefinitionCrud().retrieve(HUFFMAN_TRIGGER_NAME);
        if (trigger == null) {
            log.info(getLogName() + ": Importing pipeline configuration");
            new PipelineConfigurationOperations().importPipelineConfiguration(new File(
                SocEnvVars.getLocalDataDir(), AFT_PIPELINE_CONFIGURATION_ROOT
                    + HuffmanPipelineModule.MODULE_NAME + ".xml"));
        }

        ParameterSet huffmanParameterSet = retrieveParameterSet("huffman");
        if (huffmanParameterSet == null) {
            throw new NullPointerException("huffman parameter set not found");
        }
        HuffmanModuleParameters huffmanModuleParameters = huffmanParameterSet.parametersInstance();
        // The following makes this AFT run *much* faster.
        setHistogramLength(
            huffmanModuleParameters.getHistogramPipelineInstanceId(),
            huffmanModuleParameters.getBaselineInterval(), 1024);
    }

    public static void setHistogramLength(long pipelineInstanceId,
        int baselineInterval, int length) {

        CompressionCrud compressionCrud = new CompressionCrud();
        long pipelineId = pipelineInstanceId;
        if (pipelineId == 0) {
            pipelineId = compressionCrud.retrievePipelineInstanceIdForLatestHistogramGroupForEntireFocalPlane();
        }
        log.info("Reducing length of histogram associated with pipeline instance "
            + pipelineId
            + " and baseline interval "
            + baselineInterval
            + " to " + length);

        boolean foundHistogramGroup = false;
        List<HistogramGroup> histogramGroups = compressionCrud.retrieveAllHistogramGroups();
        for (HistogramGroup histogramGroup : histogramGroups) {
            if (histogramGroup.getPipelineInstance()
                .getId() == pipelineId) {
                foundHistogramGroup = true;
                boolean foundHistogram = false;
                for (Histogram histogram : histogramGroup.getHistograms()) {
                    if (histogram.getBaselineInterval() == baselineInterval) {
                        foundHistogram = true;
                        List<Long> srcHistogram = histogram.getHistogram();
                        ArrayList<Long> destHistogram = new ArrayList<Long>(
                            length);
                        int skip = (int) Math.ceil(srcHistogram.size()
                            / (length - 1));
                        int maxIndex = srcHistogram.size() - 1;
                        for (int i = 0; i < length; i++) {
                            destHistogram.add(srcHistogram.get(Math.min(i
                                * skip, maxIndex)));
                        }
                        histogram.setHistogram(destHistogram);
                        break;
                    }
                }
                if (!foundHistogram) {
                    String error = "Could not find histogram with baseline interval "
                        + baselineInterval;
                    log.error(error);
                    throw new IllegalStateException(error);
                }
                break;
            }
        }
        if (!foundHistogramGroup) {
            String error = "Could not find histogram group with pipeline instance ID "
                + pipelineInstanceId;
            log.error(error);
            throw new IllegalStateException(error);
        }
    }

    @Override
    protected void process() throws Exception {
        runPipeline(HUFFMAN_TRIGGER_NAME);
    }
}
