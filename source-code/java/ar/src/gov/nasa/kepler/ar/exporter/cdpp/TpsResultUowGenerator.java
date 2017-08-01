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

package gov.nasa.kepler.ar.exporter.cdpp;

import gov.nasa.kepler.common.pi.*;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTaskGenerator;
import gov.nasa.kepler.hibernate.tps.TpsCrud;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Generates CdppExporterUowTask objects. This is based on the number of
 * keplerIds in each chunk. The list of valid Kepler Ids is extracted from the
 * list of Kepler IDs stored in TpsDbResult.
 * 
 * @author Sean McCauliff
 * 
 */
public class TpsResultUowGenerator implements UnitOfWorkTaskGenerator {

    @Override
    public List<? extends UnitOfWorkTask> generateTasks(
        Map<Class<? extends Parameters>, Parameters> parameters) {
        TpsResultUowParameters cdppParameters = (TpsResultUowParameters) parameters.get(TpsResultUowParameters.class);
        TpsType tpsType = ((TpsTypeParameters)parameters.get(TpsTypeParameters.class)).toTpsTypeEnumValue();

        int chunkSize = cdppParameters.getChunkSize();
        TpsCrud tpsCrud = tpsCrud();
        List<Integer> resultKeplerIds = null;
        switch (tpsType) {
            case TPS_FULL:
                resultKeplerIds = tpsCrud.retrieveTpsResultKeplerIdsByPipelineInstanceId(0,
                    Integer.MAX_VALUE, cdppParameters.getPipelineInstanceId());
                break;
            case TPS_LITE:
                resultKeplerIds = tpsCrud.retrieveTpsLiteResultKeplerIdsByPipelineInstanceId(0,
                    Integer.MAX_VALUE, cdppParameters.getPipelineInstanceId());
                break;
            default:
                throw new IllegalStateException("Invalid TPS type \"" + tpsType + "\".");
        }
        
        List<TpsResultUowTask> tasks = new ArrayList<TpsResultUowTask>();
        for (int i = 0; i < resultKeplerIds.size(); i += chunkSize) {
            int startKeplerId = resultKeplerIds.get(i);
            int endKeplerId = resultKeplerIds.get(
             Math.min(resultKeplerIds.size() - 1, i + chunkSize - 1));
            TpsResultUowTask task = 
                new TpsResultUowTask(startKeplerId, endKeplerId, 
                                     cdppParameters.getPipelineInstanceId());
            tasks.add(task);
        }
        return tasks;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameterClasses() {
        List<Class<? extends Parameters>> rv = new ArrayList<Class<? extends Parameters>>();
        rv.add(TpsResultUowParameters.class);
        rv.add(TpsTypeParameters.class);
        return rv;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return TpsResultUowTask.class;
    }

    protected TpsCrud tpsCrud() {
        return new TpsCrud();
    }

    public String toString() {
        return "TpsResult";
    }
}
