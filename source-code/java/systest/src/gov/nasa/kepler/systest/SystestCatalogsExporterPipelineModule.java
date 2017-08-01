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

package gov.nasa.kepler.systest;

import gov.nasa.kepler.ar.ProgressIndicator;
import gov.nasa.kepler.ar.exporter.CharacteristicExporter;
import gov.nasa.kepler.ar.exporter.ExportOptions;
import gov.nasa.kepler.ar.exporter.InputCatalogExporter;
import gov.nasa.kepler.ar.exporter.ktc.KtcExporter;
import gov.nasa.kepler.ar.exporter.ktc.XaKtcExporter;
import gov.nasa.kepler.etem2.DataGenDirManager;
import gov.nasa.kepler.etem2.DataGenParameters;
import gov.nasa.kepler.etem2.PackerParameters;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.mc.DataRepoParameters;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class SystestCatalogsExporterPipelineModule extends PipelineModule {

    public static final String MODULE_NAME = "catalogs-exporter";

    private static final Log log = LogFactory.getLog(SystestCatalogsExporterPipelineModule.class);

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
        requiredParams.add(DataGenParameters.class);
        requiredParams.add(PackerParameters.class);
        requiredParams.add(TadParameters.class);
        requiredParams.add(DataRepoParameters.class);
        return requiredParams;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {

        try {

            DataGenParameters dataGenParams = pipelineTask.getParameters(DataGenParameters.class);
            PackerParameters packerParams = pipelineTask.getParameters(PackerParameters.class);
            DataGenDirManager dataGenDirManager = new DataGenDirManager(
                dataGenParams, packerParams);

            TadParameters params = pipelineTask.getParameters(TadParameters.class);

            String catalogsExportDir = dataGenDirManager.getCatalogsExportDir();

            // Clean output dir.
            FileUtil.cleanDir(catalogsExportDir);

            TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
            TargetListSet targetListSet = targetSelectionCrud.retrieveTargetListSet(params.getTargetListSetName());

            ProgressIndicator progressIndicator = new ProgressIndicator() {
                public void progress(int progress, String message) {
                    if (progress >= 0) {
                        log.info(message);
                    } else {
                        throw new PipelineException("Unable to process.\n  "
                            + message);
                    }
                }

                public void progress(Throwable t, String message) {
                    throw new PipelineException("Unable to process.", t);
                }
            };

            ExportOptions exportOptions;

            // Export kic.
            InputCatalogExporter inputCatalogExporter = new InputCatalogExporter();
            exportOptions = new ExportOptions(-1, -1, new File(
                catalogsExportDir, "kic.txt"), "v42");
            inputCatalogExporter.export(progressIndicator, exportOptions);

            // Export ktc.
            KtcExporter ktcExporter = new XaKtcExporter(new TargetCrud(),
                new LogCrud());
            ktcExporter.export(targetListSet.getStart(),
                targetListSet.getEnd(), new File(catalogsExportDir, "ktc.txt"),
                Collections.EMPTY_SET);

            // Export char table.
            CharacteristicExporter characteristicExporter = new CharacteristicExporter();
            exportOptions = new ExportOptions(-1, -1, new File(
                catalogsExportDir, "char.txt"), "v42");
            characteristicExporter.export(progressIndicator, exportOptions);
        } catch (Exception e) {
            throw new PipelineException("Unable to export data.", e);
        }
    }

}
