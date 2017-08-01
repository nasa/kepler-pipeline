/*
 * Copyright 2017 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 * 
 * NASA acknowledges the SETI Institute's primary role in authoring and
 * producing the Kepler Data Processing Pipeline under Cooperative
 * Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
 * NNX11AI14A, NNX13AD01A & NNX13AD16A.
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

package gov.nasa.kepler.gar.huffman;

import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.gar.Histogram;
import gov.nasa.kepler.hibernate.gar.HistogramGroup;
import gov.nasa.kepler.hibernate.gar.HuffmanEntry;
import gov.nasa.kepler.hibernate.gar.HuffmanTable;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.kepler.pi.module.StandardMatlabPipelineModule;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * The Huffman pipeline module.
 * 
 * @author Bill Wohler
 */
public class HuffmanPipelineModule extends StandardMatlabPipelineModule {

    private static final Log log = LogFactory.getLog(HuffmanPipelineModule.class);

    public static final String MODULE_NAME = "huffman";

    private CompressionCrud compressionCrud = new CompressionCrud();

    private long[] histogram;

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return SingleUowTask.class;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> requiredParameters = new ArrayList<Class<? extends Parameters>>();
        requiredParameters.add(HuffmanModuleParameters.class);

        return requiredParameters;
    }

    @Override
    protected Persistable createInputs() {
        return new HuffmanInputs();
    }

    @Override
    protected void retrieveInputs(Persistable inputs) {
        HuffmanInputs huffmanInputs = (HuffmanInputs) inputs;

        HuffmanModuleParameters huffmanModuleParameters = getHuffmanModuleParameters();
        huffmanInputs.setHuffmanModuleParameters(huffmanModuleParameters);
        long histogramPipelineInstanceId = huffmanModuleParameters.getHistogramPipelineInstanceId();
        if (histogramPipelineInstanceId == 0) {
            histogramPipelineInstanceId = retrieveHistogramPipelineInstanceId();
        }
        histogram = retrieveHistogram(histogramPipelineInstanceId,
            huffmanModuleParameters.getBaselineInterval());
        huffmanInputs.setHistogram(histogram);
    }

    /**
     * Returns this task's module parameters.
     */
    private HuffmanModuleParameters getHuffmanModuleParameters() {
        return pipelineTask.getParameters(HuffmanModuleParameters.class);
    }

    /**
     * Retrieves the latest histogram pipeline instance ID.
     */
    private long retrieveHistogramPipelineInstanceId() {
        long id = compressionCrud.retrievePipelineInstanceIdForLatestHistogramGroupForEntireFocalPlane();
        if (id < 0) {
            throw new ModuleFatalProcessingException(
                "No appropriate HistogramGroups were found");
        }

        return id;
    }

    /**
     * Returns the histogram generated by the given pipeline instance at the
     * given baseline interval.
     * 
     * @param pipelineInstanceId the ID of the pipeline instance
     * @param baselineInterval the baseline interval
     * @return a non-{@code null} array containing a single histogram
     */
    private long[] retrieveHistogram(long pipelineInstanceId,
        int baselineInterval) {

        log.info("Retrieving histogram for baselineInterval="
            + baselineInterval + ", pipelineInstanceId=" + pipelineInstanceId
            + "...");

        // Locate the appropriate histogram group.
        HistogramGroup histogramGroup = compressionCrud.retrieveHistogramGroupForEntireFocalPlane(pipelineInstanceId);
        if (histogramGroup == null) {
            throw new ModuleFatalProcessingException(
                "Could not locate a HistogramGroup for pipeline instance "
                    + pipelineInstanceId);
        }

        // Find the histogram for the given baselineInterval.
        Histogram srcHistogram = null;
        for (Histogram histogram : histogramGroup.getHistograms()) {
            if (histogram.getBaselineInterval() == baselineInterval) {
                srcHistogram = histogram;
                break;
            }
        }
        if (srcHistogram == null) {
            throw new ModuleFatalProcessingException(
                "Could not locate a Histogram for the desired baseline interval "
                    + baselineInterval + " for pipeline instance "
                    + pipelineInstanceId);
        }

        // Convert the list to an array.
        List<Long> srcValues = srcHistogram.getHistogram();
        long[] destValues = new long[srcValues.size()];
        for (int i = 0; i < srcValues.size(); i++) {
            destValues[i] = srcValues.get(i);
        }

        log.info("Retrieving histogram for baselineInterval="
            + baselineInterval + ", pipelineInstanceId=" + pipelineInstanceId
            + "...done");

        return destValues;
    }

    @Override
    protected Persistable createOutputs() {
        return new HuffmanOutputs();
    }

    @Override
    protected void storeOutputs(Persistable outputs) {
        HuffmanOutputs huffmanOutputs = (HuffmanOutputs) outputs;

        String[] huffmanCodeStrings = huffmanOutputs.getHuffmanCodeStrings();
        int[] huffmanCodeLengths = huffmanOutputs.getHuffmanCodeLengths();

        if (huffmanCodeStrings.length == 0 || huffmanCodeLengths.length == 0) {
            throw new ModuleFatalProcessingException(
                "No Huffman code strings were generated");
        }
        if (huffmanCodeStrings.length != huffmanCodeLengths.length) {
            throw new ModuleFatalProcessingException(
                "Returned arrays are not of equal length (huffmanCodeStrings="
                    + huffmanCodeStrings.length + ", huffmanCodeLengths="
                    + huffmanCodeLengths.length + ")");
        }

        List<HuffmanEntry> entries = new ArrayList<HuffmanEntry>();
        for (int i = 0; i < huffmanCodeStrings.length; i++) {
            if (huffmanCodeStrings[i].length() != huffmanCodeLengths[i]) {
                throw new ModuleFatalProcessingException("Bitstring \""
                    + huffmanCodeStrings[i] + "\" has an unexpected length "
                    + huffmanCodeLengths[i]);
            }
            entries.add(new HuffmanEntry(huffmanCodeStrings[i], histogram[i]));
        }

        HuffmanTable table = new HuffmanTable();
        table.setPipelineTask(pipelineTask);
        table.setTheoreticalCompressionRate(huffmanOutputs.getTheoreticalCompressionRate());
        table.setEffectiveCompressionRate(huffmanOutputs.getEffectiveCompressionRate());
        table.setEntries(entries);

        compressionCrud.createHuffmanTable(table);
    }

    /**
     * Sets the {@link PipelineTask} object during testing.
     */
    public void setPipelineTask(PipelineTask pipelineTask) {
        this.pipelineTask = pipelineTask;
    }

    /**
     * Sets the {@link CompressionCrud} object during testing.
     */
    void setCompressionCrud(CompressionCrud compressionCrud) {
        this.compressionCrud = compressionCrud;
    }
}
