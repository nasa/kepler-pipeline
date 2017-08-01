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

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.pi.SkyGroupIdListsParameters;
import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Pipeline module that copies KIC entries from one database to another.
 * 
 * For DEV use only.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class KicCopyPipelineModule extends PipelineModule {
    private static final int MAX_KIC_RESULT_SIZE = 1000000;

    private static final Log log = LogFactory.getLog(KicCopyPipelineModule.class);

    public static final String MODULE_NAME = "kicCopy";

    public KicCopyPipelineModule() {
    }

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
        requiredParams.add(KicCopyParameters.class);
        requiredParams.add(SkyGroupIdListsParameters.class);
        return requiredParams;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) throws PipelineException {

        KicCopyParameters kicCopyParameters = pipelineTask.getParameters(KicCopyParameters.class);
        SkyGroupIdListsParameters skyGroupIdLists = pipelineTask.getParameters(SkyGroupIdListsParameters.class);

        Properties databaseProperties = kicCopyParameters.createProperties();

        DatabaseService srcDatabaseService = DatabaseServiceFactory.getInstance(databaseProperties);

        KicCrud srcKicCrud = new KicCrud(srcDatabaseService);
        srcKicCrud.setKicCacheEnabled(false);
        
        KicCrud destKicCrud = new KicCrud(DatabaseServiceFactory.getInstance());
        destKicCrud.setKicCacheEnabled(false);

        log.info("Copying KICs...");

        // If all skyGroupIds are included, then make sure to copy all kic
        // entries.
        // Note that copySomeKics() will not copy kics with a skyGroupId of 0.
        if (skyGroupIdLists.getSkyGroupIdIncludeArray().length == 0) {
            copyAllKics(skyGroupIdLists, srcKicCrud, destKicCrud);
        } else {
            copySomeKics(skyGroupIdLists, srcKicCrud, destKicCrud);
        }

        log.info("Done creating KIC entries for all specified sky groups");
    }

    private void copyAllKics(SkyGroupIdListsParameters skyGroupIdLists,
        KicCrud srcKicCrud, KicCrud destKicCrud) {
        int i = 0;
        while (true) {
            int minKeplerId = (i * MAX_KIC_RESULT_SIZE) + 1;
            int maxKeplerId = (i + 1) * MAX_KIC_RESULT_SIZE;
            List<Kic> srcKics = srcKicCrud.retrieveKics(minKeplerId,
                maxKeplerId);
            if (srcKics.isEmpty()) {
                break;
            }

            log.info("Creating " + srcKics.size()
                + " KIC entries in keplerId range: " + minKeplerId + " to "
                + maxKeplerId);

            for (Kic kic : srcKics) {
                destKicCrud.create(kic);
            }

            DatabaseServiceFactory.getInstance()
                .flush();
            DatabaseServiceFactory.getInstance()
                .evictAll(srcKics);

            i++;
        }
    }

    private void copySomeKics(SkyGroupIdListsParameters skyGroupIdLists,
        KicCrud srcKicCrud, KicCrud destKicCrud) {
        for (int skyGroupId = 1; skyGroupId <= FcConstants.MODULE_OUTPUTS; skyGroupId++) {
            if (skyGroupIdLists.included(skyGroupId)) {
                List<Kic> srcKics = srcKicCrud.retrieveKics(skyGroupId);

                if (srcKics.size() == 0) {
                    throw new PipelineException(
                        "No kics found for specified criteria");
                }

                log.info("Creating " + srcKics.size()
                    + " KIC entries in sky group " + skyGroupId);

                for (Kic kic : srcKics) {
                    destKicCrud.create(kic);
                }

                DatabaseServiceFactory.getInstance()
                    .flush();
                DatabaseServiceFactory.getInstance()
                    .evictAll(srcKics);
            }
        }
    }

}
