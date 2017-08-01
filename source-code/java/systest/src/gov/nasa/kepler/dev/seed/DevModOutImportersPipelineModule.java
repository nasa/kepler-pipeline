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

package gov.nasa.kepler.dev.seed;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.primitives.Ints.toArray;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.pi.SkyGroupIdListsParameters;
import gov.nasa.kepler.fc.importer.ImporterParentNonImage;
import gov.nasa.kepler.fc.importer.ImporterPrf;
import gov.nasa.kepler.fc.importer.ImporterSmallFlatField;
import gov.nasa.kepler.fc.importer.ImporterTwoDBlack;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.DataRepoParameters;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.kepler.sggen.SkyGroupGenPipelineModule;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class DevModOutImportersPipelineModule extends PipelineModule {

    public static final String MODULE_NAME = "dev-mod-out-importers";

    private static final Log log = LogFactory.getLog(DevModOutImportersPipelineModule.class);

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
        requiredParams.add(ModelImportParameters.class);
        requiredParams.add(SkyGroupIdListsParameters.class);
        return requiredParams;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {

        try {

            ModelImportParameters modelImport = pipelineTask.getParameters(ModelImportParameters.class);
            DataRepoParameters dataRepoParams = pipelineTask.getParameters(DataRepoParameters.class);
            String dataRepoRootPath = dataRepoParams.getDataRepoPath();
            String reason = "Created by DevModOutImportersPM from: ";

            SkyGroupIdListsParameters skyGroupIdListsParameters = pipelineTask.getParameters(SkyGroupIdListsParameters.class);
            int[] channelArray = getChannelArray(skyGroupIdListsParameters);

            System.setProperty(ImporterParentNonImage.DATA_DIR_PROPERTY_PREFIX
                + "rootdir", dataRepoRootPath);

            // prf
            log.info("importing prf...");
            System.setProperty(ImporterParentNonImage.DATA_DIR_PROPERTY_PREFIX
                + ImporterPrf.DATAFILE_DIRECTORY_NAME, modelImport.getPrfPath());
            ImporterPrf importerPrf = new ImporterPrf();
            importerPrf.rewriteHistory(channelArray,
                reason + modelImport.getPrfPath());

            // two-d-black
            log.info("importing two-d-black...");
            System.setProperty(ImporterParentNonImage.DATA_DIR_PROPERTY_PREFIX
                + ImporterTwoDBlack.DATAFILE_DIRECTORY_NAME,
                modelImport.getTwodBlackPath());
            ImporterTwoDBlack importerTwoDBlack = new ImporterTwoDBlack();
            importerTwoDBlack.rewriteHistory(channelArray,
                reason + modelImport.getTwodBlackPath());

            // small-flat
            log.info("importing small-flat...");
            System.setProperty(ImporterParentNonImage.DATA_DIR_PROPERTY_PREFIX
                + ImporterSmallFlatField.DATAFILE_DIRECTORY_NAME,
                modelImport.getSmallFlatPath());
            ImporterSmallFlatField importerSmallFlatField = new ImporterSmallFlatField();
            importerSmallFlatField.rewriteHistory(channelArray, reason
                + modelImport.getSmallFlatPath());

        } catch (Exception e) {
            throw new PipelineException("Unable to import data.", e);
        }
    }

    private int[] getChannelArray(
        SkyGroupIdListsParameters skyGroupIdListsParameters) {
        KicCrud kicCrud = new KicCrud();

        List<Integer> channels = newArrayList();
        for (int skyGroupId = 1; skyGroupId <= FcConstants.MODULE_OUTPUTS; skyGroupId++) {
            if (skyGroupIdListsParameters.included(skyGroupId)) {
                for (int season = 0; season < SkyGroupGenPipelineModule.SEASON_COUNT; season++) {
                    SkyGroup skyGroup = kicCrud.retrieveSkyGroup(skyGroupId,
                        season);
                    int channel = FcConstants.getChannelNumber(
                        skyGroup.getCcdModule(), skyGroup.getCcdOutput());
                    if (!channels.contains(channel)) {
                        channels.add(channel);
                    }
                }
            }
        }

        return toArray(channels);
    }

}
