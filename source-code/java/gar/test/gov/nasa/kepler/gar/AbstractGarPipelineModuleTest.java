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

package gov.nasa.kepler.gar;

import gov.nasa.kepler.hibernate.gar.HistogramGroup;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.spiffy.common.jmock.JMockTest;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.Arrays;
import java.util.List;
import java.util.Random;

import org.apache.commons.lang.ArrayUtils;

public abstract class AbstractGarPipelineModuleTest extends JMockTest {

    protected static final int BEST_BASELINE_INTERVAL = 48;
    protected static final float BEST_STORAGE_RATE = 5;
    private static final int HISTOGRAM_COUNT = 2;

    private static final long RANDOM_SEED = -7233005957824308197L;
    private static Random random = new Random(RANDOM_SEED);

    protected PipelineTask createPipelineTask(long id, UnitOfWorkTask uowTask,
        List<Parameters> pipelineParameters, List<Parameters> moduleParameters) {

        PipelineTask task = new PipelineTask(
            createPipelineInstance(pipelineParameters),
            createPipelineDefinitionNode(),
            createPipelineInstanceNode(moduleParameters));
        task.setUowTask(new BeanWrapper<UnitOfWorkTask>(uowTask));
        task.setId(id);

        return task;
    }

    protected PipelineInstance createPipelineInstance(
        List<Parameters> parameterList) {

        PipelineInstance pipelineInstance = new PipelineInstance();

        if (parameterList != null) {
            for (Parameters parameters : parameterList) {
                ParameterSet parameterSet = new ParameterSet(
                    parameters.getClass()
                        .getSimpleName());
                parameterSet.setParameters(new BeanWrapper<Parameters>(
                    parameters));
                pipelineInstance.putParameterSet(new ClassWrapper<Parameters>(
                    parameters.getClass()), parameterSet);
            }
        }

        return pipelineInstance;
    }

    private PipelineDefinitionNode createPipelineDefinitionNode() {
        PipelineDefinitionNode pipelineDefinitionNode = new PipelineDefinitionNode();

        return pipelineDefinitionNode;
    }

    private PipelineInstanceNode createPipelineInstanceNode(
        List<Parameters> parameterList) {

        PipelineInstanceNode pipelineInstanceNode = new PipelineInstanceNode();

        if (parameterList != null) {
            for (Parameters parameters : parameterList) {
                ParameterSet parameterSet = new ParameterSet(
                    parameters.getClass()
                        .getSimpleName());
                parameterSet.setParameters(new BeanWrapper<Parameters>(
                    parameters));
                pipelineInstanceNode.putModuleParameterSet(
                    parameters.getClass(), parameterSet);
            }
        }

        return pipelineInstanceNode;
    }

    protected void createHistograms(List<Histogram> persistableHistograms,
        List<gov.nasa.kepler.hibernate.gar.Histogram> dbHistograms,
        HistogramGroup histogramGroup) {

        for (int i = 0; i < HISTOGRAM_COUNT; i++) {
            Histogram persistableHistogram = new Histogram();
            persistableHistogram.setBaselineInterval(random.nextInt());
            gov.nasa.kepler.hibernate.gar.Histogram dbHistogram = new gov.nasa.kepler.hibernate.gar.Histogram(
                persistableHistogram.getBaselineInterval());
            persistableHistogram.setHistogram(new long[] { random.nextLong(),
                random.nextLong(), random.nextLong() });
            dbHistogram.setHistogram(Arrays.asList(ArrayUtils.toObject(persistableHistogram.getHistogram())));
            persistableHistogram.setTheoreticalCompressionRate(random.nextFloat());
            dbHistogram.setTheoreticalCompressionRate(persistableHistogram.getTheoreticalCompressionRate());
            persistableHistogram.setTotalStorageRate(random.nextFloat());
            dbHistogram.setTotalStorageRate(persistableHistogram.getTotalStorageRate());
            persistableHistogram.setUncompressedBaselineOverheadRate(random.nextFloat());
            dbHistogram.setUncompressedBaselineOverheadRate(persistableHistogram.getUncompressedBaselineOverheadRate());
            persistableHistograms.add(persistableHistogram);
            dbHistograms.add(dbHistogram);
        }

        histogramGroup.setBestBaselineInterval(BEST_BASELINE_INTERVAL);
        histogramGroup.setBestStorageRate(BEST_STORAGE_RATE);
        histogramGroup.setHistograms(dbHistograms);
    }
}