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

package gov.nasa.kepler.mc.uow;

import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributes;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.obslog.ObservingLogOperations;
import gov.nasa.kepler.pi.worker.TaskFileCopyParameters;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * {@link UnitOfWorkTask} for pipelines that divide up the work using cadence
 * range bins and module/output bins.
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 * @author Miles Cote
 * 
 */
public class ModOutCadenceUowTask extends ModOutUowTask implements ModOutBinnable, CadenceBinnable {
    private static final Log log = LogFactory.getLog(ModOutCadenceUowTask.class);

    private int startCadence;
    private int endCadence;

    public ModOutCadenceUowTask makeCopy() {
        return new ModOutCadenceUowTask(modOuts, startCadence, endCadence);
    }

    public String briefState() {
        return "[" + startCadence + "," + endCadence + "]" + super.briefState();
    }

    @Override
    public String toString() {
        return briefState();
    }

    public ModOutCadenceUowTask() {
        super();
    }

    public ModOutCadenceUowTask(int ccdModule, int ccdOutput, int startCadence,
        int endCadence) {
        super(ccdModule, ccdOutput);
        this.startCadence = startCadence;
        this.endCadence = endCadence;
    }

    public ModOutCadenceUowTask(int[] channels, int startCadence, int endCadence) {
        super(channels);
        this.startCadence = startCadence;
        this.endCadence = endCadence;
    }

    private ModOutCadenceUowTask(List<Pair<Integer, Integer>> modOuts,
        int startCadence, int endCadence) {
        super(modOuts);
        this.startCadence = startCadence;
        this.endCadence = endCadence;
    }

    @Override
    public Pair<List<String>, Boolean> makeUowSymlinks(PipelineTask task, PipelineTaskAttributes taskAttrs, 
        Map<Class<? extends Parameters>, Parameters> parameterOverrides) {
        
        List<String> uowDescriptors = new LinkedList<String>();
        ObservingLogOperations ops = new ObservingLogOperations();
        int cadenceType = Cadence.CADENCE_LONG;
        // does not allow overrides
        CadenceTypePipelineParameters cadenceTypeParams = task.getParameters(CadenceTypePipelineParameters.class);
        boolean makeLinksToTaskDir = true;
        
        if(cadenceTypeParams != null){
            cadenceType = cadenceTypeParams.cadenceType().intValue();
        }
        
        TaskFileCopyParameters taskCopyParams = (TaskFileCopyParameters) parameterOverrides.get(TaskFileCopyParameters.class);
        if(taskCopyParams == null){
            taskCopyParams = task.getParameters(TaskFileCopyParameters.class, false);
        }
        
        if(taskCopyParams == null){
            log.warn("Required TaskFileCopyParameters not present in task or overrides");
            return Pair.of(uowDescriptors, makeLinksToTaskDir);
        }
        
        boolean includeMonths = taskCopyParams.isUowSymlinksIncludeMonths();
        
        String uowDateString = ops.generateUowDateString(cadenceType, startCadence, endCadence, includeMonths);

        for (int channel : getChannels()) {
            Pair<Integer, Integer> modOut = FcConstants.getModuleOutput(channel);

            String symlinkName = String.format("%s-%02d.%02d", uowDateString, modOut.left, modOut.right);
            
            if (taskCopyParams.isUowSymlinksIncludeCadenceRange()) {
                symlinkName = symlinkName + "-" + startCadence + "-" + endCadence;
            }
          
            uowDescriptors.add(symlinkName);
        }

        return Pair.of(uowDescriptors, false);
    }

    public int getEndCadence() {
        return endCadence;
    }

    public void setEndCadence(int endCadence) {
        this.endCadence = endCadence;
    }

    public int getStartCadence() {
        return startCadence;
    }

    public void setStartCadence(int startCadence) {
        this.startCadence = startCadence;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = super.hashCode();
        result = prime * result + endCadence;
        result = prime * result + startCadence;
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (!super.equals(obj))
            return false;
        if (getClass() != obj.getClass())
            return false;
        ModOutCadenceUowTask other = (ModOutCadenceUowTask) obj;
        if (endCadence != other.endCadence)
            return false;
        if (startCadence != other.startCadence)
            return false;
        return true;
    }
}
