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

import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.ParameterSetCrud;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.TargetListSetOperations;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.kepler.ops.seed.TadQuarterlyPipelineSeedData;
import gov.nasa.kepler.pi.pipeline.PipelineOperations;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.List;

/**
 * This {@link PipelineModule} copies the dev {@link TargetListSet}s to
 * supplemental dev {@link TargetListSet}s to support importing flight data into
 * the dev pipeline.
 * 
 * @author Miles Cote
 * 
 */
public class SupplementalTargetImportPipelineModule extends PipelineModule {

    public static final String MODULE_NAME = "supplementalTargetImport";

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
        requiredParams.add(TadParameters.class);
        return requiredParams;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {
        try {
            // Param sets.
            TadParameters tadParameters = pipelineTask.getParameters(TadParameters.class);
            String tlsName = tadParameters.getTargetListSetName();
            if (tlsName == null || tlsName.isEmpty()) {
                throw new IllegalArgumentException(
                    "target list set name is null");
            }

            TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
            TargetListSet tls = targetSelectionCrud.retrieveTargetListSet(tlsName);
            if (tls == null) {
                throw new IllegalArgumentException(tlsName
                    + ": no such target list set"
                    + TargetListSetOperations.getTlsInfo(tls));
            }

            String suppTlsName = getSupplementalName(tls.getName());
            TargetListSet suppTls = new TargetListSet(suppTlsName, tls);
            suppTls.setState(State.LOCKED);
            suppTls.clearTadFields();
            targetSelectionCrud.create(suppTls);

            String suppTadPsName = null;
            if (suppTlsName.contains(TadQuarterlyPipelineSeedData.LC)) {
                suppTadPsName = SupplementalTadPipelineSeedData.TAD_PARAMETERS_LC_SUPPLEMENTAL;
            } else if (suppTlsName.contains(TadQuarterlyPipelineSeedData.SC1)) {
                suppTadPsName = SupplementalTadPipelineSeedData.TAD_PARAMETERS_SC1_SUPPLEMENTAL;
            } else if (suppTlsName.contains(TadQuarterlyPipelineSeedData.SC2)) {
                suppTadPsName = SupplementalTadPipelineSeedData.TAD_PARAMETERS_SC2_SUPPLEMENTAL;
            } else if (suppTlsName.contains(TadQuarterlyPipelineSeedData.SC3)) {
                suppTadPsName = SupplementalTadPipelineSeedData.TAD_PARAMETERS_SC3_SUPPLEMENTAL;
            }

            ParameterSetCrud parameterSetCrud = new ParameterSetCrud();
            ParameterSet suppTadPs = parameterSetCrud.retrieveLatestVersionForName(suppTadPsName);
            TadParameters suppTadBean = suppTadPs.parametersInstance();
            suppTadBean.setTargetListSetName(suppTlsName);

            String assocLcTlsName = tadParameters.getAssociatedLcTargetListSetName();
            if (!assocLcTlsName.isEmpty()) {
                suppTadBean.setAssociatedLcTargetListSetName(getSupplementalName(assocLcTlsName));
            }

            PipelineOperations pipelineOperations = new PipelineOperations();
            pipelineOperations.updateParameterSet(suppTadPs, suppTadBean, false);
        } catch (Exception e) {
            throw new PipelineException("Unable to process task.", e);
        }
    }

    private String getSupplementalName(String name) {
        return name + "_supplemental";
    }

}
