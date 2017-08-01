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

package gov.nasa.kepler.systest.flight;

import gov.nasa.kepler.gar.xml.HuffmanImporter;
import gov.nasa.kepler.gar.xml.RequantImporter;
import gov.nasa.kepler.gar.xmlbean.HuffmanTableDocument;
import gov.nasa.kepler.gar.xmlbean.HuffmanTableXB;
import gov.nasa.kepler.gar.xmlbean.RequantTableDocument;
import gov.nasa.kepler.gar.xmlbean.RequantTableXB;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.gar.HuffmanTable;
import gov.nasa.kepler.hibernate.gar.RequantTable;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.kepler.tad.xml.TadXmlFileOperations;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.xmlbeans.XmlException;

/**
 * This {@link PipelineModule} imports compression xml files into the database.
 * It sets the externalId to the value in the xml files.
 * 
 * @author Miles Cote
 * 
 */
public class CompressionXmlImportPipelineModule extends PipelineModule {

    public static final String MODULE_NAME = "compressionXmlImport";

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
        List<Class<? extends Parameters>> requiredParams = new ArrayList<Class<? extends Parameters>>();
        requiredParams.add(CompressionXmlImportParameters.class);
        return requiredParams;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {
        try {
            CompressionXmlImportParameters compressionXmlImportParameters = pipelineTask.getParameters(CompressionXmlImportParameters.class);

            File srcDir = new File(
                compressionXmlImportParameters.getCompressionXmlAbsPath());

            storeRequantData(pipelineTask, srcDir);

            storeHuffmanData(pipelineTask, srcDir);
        } catch (Exception e) {
            throw new PipelineException("Unable to process task.", e);
        }
    }

    private void storeRequantData(PipelineTask pipelineTask, File srcDir)
        throws XmlException, IOException {
        File requantXmlFile = new TadXmlFileOperations().getFile(srcDir, "rq",
            null);

        RequantImporter requantImporter = new RequantImporter();
        RequantTable requantTable = requantImporter.importFile(requantXmlFile);

        RequantTableDocument doc = RequantTableDocument.Factory.parse(requantXmlFile);
        RequantTableXB requantTableXB = doc.getRequantTable();

        requantTable.setExternalId(requantTableXB.getTableId());
        requantTable.setPlannedStartTime(requantTableXB.getPlannedStartTime()
            .getTime());
        requantTable.setPipelineTask(pipelineTask);
        requantTable.setState(State.UPLINKED);

        CompressionCrud compressionCrud = new CompressionCrud();
        compressionCrud.createRequantTable(requantTable);
    }

    private void storeHuffmanData(PipelineTask pipelineTask, File srcDir)
        throws XmlException, IOException {
        File huffmanXmlFile = new TadXmlFileOperations().getFile(srcDir, "he",
            null);

        HuffmanImporter huffmanImporter = new HuffmanImporter();
        HuffmanTable huffmanTable = huffmanImporter.importFile(huffmanXmlFile);

        HuffmanTableDocument doc = HuffmanTableDocument.Factory.parse(huffmanXmlFile);
        HuffmanTableXB huffmanTableXB = doc.getHuffmanTable();

        huffmanTable.setExternalId(huffmanTableXB.getTableId());
        huffmanTable.setPlannedStartTime(huffmanTableXB.getPlannedStartTime()
            .getTime());
        huffmanTable.setPipelineTask(pipelineTask);
        huffmanTable.setState(State.UPLINKED);

        CompressionCrud compressionCrud = new CompressionCrud();
        compressionCrud.createHuffmanTable(huffmanTable);
    }
}
