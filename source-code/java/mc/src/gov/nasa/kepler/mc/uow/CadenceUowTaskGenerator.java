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

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.CadenceRangeParameters;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTaskGenerator;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * {@link UnitOfWorkTaskGenerator} for the {@link CadenceUowTask}. Uses
 * {@link CadenceBinner} to bin the specified cadence range into bins.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class CadenceUowTaskGenerator implements UnitOfWorkTaskGenerator {

    private static final Log log = LogFactory.getLog(CadenceUowTaskGenerator.class);

    public CadenceUowTaskGenerator() {
    }

    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return CadenceUowTask.class;
    }

    public List<Class<? extends Parameters>> requiredParameterClasses() {
        List<Class<? extends Parameters>> list = new ArrayList<Class<? extends Parameters>>();
        list.add(CadenceRangeParameters.class);
        list.add(CadenceTypePipelineParameters.class);
        return list;
    }

    public List<? extends UnitOfWorkTask> generateTasks(
        Map<Class<? extends Parameters>, Parameters> parameters) {
        List<CadenceUowTask> tasks = new ArrayList<CadenceUowTask>();
        tasks.add(new CadenceUowTask());

        return generateTasks(parameters, tasks);
    }

    <T extends CadenceBinnable> List<T> generateTasks(
        Map<Class<? extends Parameters>, Parameters> parameters, List<T> tasks) {
        CadenceRangeParameters cadenceRange = (CadenceRangeParameters) parameters.get(CadenceRangeParameters.class);
        for (T task : tasks) {
            task.setStartCadence(cadenceRange.getStartCadence());
            task.setEndCadence(cadenceRange.getEndCadence());
        }

        CadenceTypePipelineParameters cadenceType = (CadenceTypePipelineParameters) parameters.get(CadenceTypePipelineParameters.class);
        
        if (cadenceRange.isBinByTargetTable()) {
            // sub-divide by target table
            tasks = TargetTableBinner.subdivide(tasks,
                cadenceType.cadenceType(), cadenceRange.toExcludeCadences());
            log.info("subdivided by target table, task count = " + tasks.size());
        }

        // sub-divide by cadence
        tasks = CadenceBinner.subdivide(tasks, cadenceRange.getNumberOfBins(),
            cadenceRange.getMinimumBinSize());
        log.info("subdivided by cadenceBinSize, task count = " + tasks.size());
        
        // remove tasks with no cadence data
        tasks = removeTasksWithNoCadenceData(tasks, cadenceType.cadenceType());

        return tasks;
    }
    
    private <T extends CadenceBinnable> List<T> removeTasksWithNoCadenceData(List<T> tasks, CadenceType cadenceType) {
        LogCrud logCrud = new LogCrud();
        
        List<T> newTasks = new ArrayList<T>();
        for (T task : tasks) {
            if (hasCadenceData(task, cadenceType, logCrud)) {
                newTasks.add(task);
            }
        }
        
        return newTasks;
    }
    
    private boolean hasCadenceData(CadenceBinnable cadenceBinnable, CadenceType cadenceType, LogCrud logCrud) {
        int startCadence = cadenceBinnable.getStartCadence();
        int endCadence = cadenceBinnable.getEndCadence();

        // Most cadenceBinnables will find a pixelLog in the first retrieve call.
        List<PixelLog> pixelLogs = logCrud.retrievePixelLog(cadenceType.intValue(), startCadence, startCadence);
        if (!pixelLogs.isEmpty()) {
            return true;
        }

        // If there was no pixelLog for the startCadence, then check all cadences.
        pixelLogs = logCrud.retrievePixelLog(cadenceType.intValue(), startCadence, endCadence);
        return !pixelLogs.isEmpty();
    }

    public String toString() {
        return "Cadence";
    }

}
