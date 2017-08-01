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

package gov.nasa.kepler.ui.ops.parameters;

import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSetName;
import gov.nasa.kepler.ui.common.HtmlLabelBuilder;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.HashSet;
import java.util.LinkedList;
import java.util.Map;
import java.util.Set;

import javax.swing.table.AbstractTableModel;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * 
 * @author tklaus
 * 
 */
@SuppressWarnings("serial")
public class ParameterSetNamesTableModel extends AbstractTableModel {
    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(ParameterSetNamesTableModel.class);

    private LinkedList<ParameterSetAssignment> paramSetAssignments = new LinkedList<ParameterSetAssignment>();

    public ParameterSetNamesTableModel(Map<ClassWrapper<Parameters>, ParameterSetName> currentParameters,
        Set<ClassWrapper<Parameters>> requiredParameters,
        Map<ClassWrapper<Parameters>, ParameterSetName> currentPipelineParameters) {

        update(currentParameters, requiredParameters, currentPipelineParameters);
    }

    /**
     * for each required param create a ParameterSetAssignment 
     * if reqd param exists in current params, use that name 
     * if reqd param exists in current pipeline params, use that name with '(pipeline)' 
     * if there are any left in current params (not reqd), add those
     * 
     * @param currentParameters
     * @param requiredParameters
     * @param currentPipelineParameters
     */
    public void update(Map<ClassWrapper<Parameters>, ParameterSetName> currentParameters,
        Set<ClassWrapper<Parameters>> requiredParameters,
        Map<ClassWrapper<Parameters>, ParameterSetName> currentPipelineParameters) {

        paramSetAssignments.clear();
        Set<ClassWrapper<Parameters>> types = new HashSet<ClassWrapper<Parameters>>();

        // for each required param type, create a ParameterSetAssignment
        for (ClassWrapper<Parameters> requiredType : requiredParameters) {
            ParameterSetAssignment param = new ParameterSetAssignment(requiredType);

            // if required param type exists in current params, use that
            // ParameterSetName
            ParameterSetName currentAssignment = currentParameters.get(requiredType);
            if (currentAssignment != null) {
                param.setAssignedName(currentAssignment);
            }

            // if required param type exists in current *pipeline* params,
            // display that (read-only)
            if (currentPipelineParameters.containsKey(requiredType)) {
                param.setAssignedName(currentPipelineParameters.get(requiredType));
                param.setAssignedAtPipelineLevel(true);
                
                if(currentAssignment != null){
                    param.setAssignedAtBothLevels(true);
                }
            }

            if(param.isAssignedAtPipelineLevel() || param.isAssignedAtBothLevels()){
                paramSetAssignments.addFirst(param);
            }else{
                paramSetAssignments.add(param);
            }
            
            types.add(requiredType);
        }

        // If there are any param types left over in current params (not
        // required), add those
        // This also covers the case where empty lists are passed in for
        // required params and
        // current pipeline params (when using this model to edit pipeline
        // params on the EditTriggerDialog
        for (ClassWrapper<Parameters> currentParam : currentParameters.keySet()) {
            if (!types.contains(currentParam)) {
                ParameterSetAssignment param = new ParameterSetAssignment(currentParam,
                    currentParameters.get(currentParam), false, false);
                paramSetAssignments.add(param);
            }
        }

        fireTableDataChanged();
    }

    public ParameterSetName getParamSetAtRow(int rowIndex) {
        return paramSetAssignments.get(rowIndex)
            .getAssignedName();
    }

    public ParameterSetAssignment getParamAssignmentAtRow(int rowIndex) {
        return paramSetAssignments.get(rowIndex);
    }

    /**
     * @return the paramSetAssignments
     */
    public LinkedList<ParameterSetAssignment> getParamSetAssignments() {
        return paramSetAssignments;
    }

    public int getRowCount() {
        return paramSetAssignments.size();
    }

    public int getColumnCount() {
        return 2;
    }

    public Object getValueAt(int rowIndex, int columnIndex) {

        ParameterSetAssignment assignment = paramSetAssignments.get(rowIndex);
        ClassWrapper<Parameters> assignmentType = assignment.getType();
        ParameterSetName assignedName = assignment.getAssignedName();

        HtmlLabelBuilder displayName = new HtmlLabelBuilder();
        
        if (assignedName != null) {
            displayName.append(assignedName.getName());
        }else{
            displayName.appendColor("--- not set ---", "red");
        }

        if (assignment.isAssignedAtBothLevels()) {
            displayName.appendColor(" (ERROR: set at BOTH levels)", "red");
        }else if (assignment.isAssignedAtPipelineLevel()) {
            displayName.appendItalic(" (set at pipeline level)");
        }

        switch (columnIndex) {
            case 0:
                Class<?> clazz = null;
                try {
                    clazz = assignmentType.getClazz();
                } catch (RuntimeException e) {
                    return "<deleted>: " + assignmentType.getClassName();
                }
                return clazz.getSimpleName();
            case 1:
                return displayName;
        }

        return "huh?";
    }

    /*
     * (non-Javadoc)
     * 
     * @see javax.swing.table.AbstractTableModel#getColumnName(int)
     */
    @Override
    public String getColumnName(int column) {
        switch (column) {
            case 0:
                return "Type";
            case 1:
                return "Name";
        }
        return "huh?";
    }
}
