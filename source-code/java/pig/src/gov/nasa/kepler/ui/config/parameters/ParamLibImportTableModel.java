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

package gov.nasa.kepler.ui.config.parameters;

import gov.nasa.kepler.pi.parameters.ParameterSetDescriptor;
import gov.nasa.kepler.pi.parameters.ParameterSetDescriptor.State;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

import javax.swing.table.AbstractTableModel;

/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
@SuppressWarnings("serial")
public class ParamLibImportTableModel extends AbstractTableModel {

    private List<ParameterSetDescriptor> paramMap = new LinkedList<ParameterSetDescriptor>();
    //private ArrayList<String> names = new ArrayList<String>();
    private ArrayList<Boolean> includeFlags = new ArrayList<Boolean>();
    
    public ParamLibImportTableModel() {
    }

    public ParamLibImportTableModel(List<ParameterSetDescriptor> paramMap) {
        this.paramMap = paramMap;
        
//        names  = new ArrayList<String>(paramMap.keySet());
        // initially in alphabetical order (until the user sorts by some other column)
//        Collections.sort(names);
        
        // everything included by default
        includeFlags = new ArrayList<Boolean>();
        for (int i = 0; i < paramMap.size(); i++) {
            includeFlags.add(true);
        }
    }
    
    public List<String> getExcludeList(){
        LinkedList<String> excludeList = new LinkedList<String>();
        
        for(int index = 0; index < paramMap.size(); index++){
            if(!includeFlags.get(index)){
                excludeList.add(paramMap.get(index).getName());
            }
        }
        return excludeList;
    }
    
    public ParameterSetDescriptor getDescriptorAt(int rowIndex){
//        String name = names.get(rowIndex);
//        ParameterSetDescriptor param = paramMap.get(name);
        
        return paramMap.get(rowIndex);
    }

    @Override
    public int getColumnCount() {
        return 4;
    }

    @Override
    public int getRowCount() {
        return paramMap.size();
    }

    @Override
    public Object getValueAt(int rowIndex, int columnIndex) {
//        String name = names.get(rowIndex);
        boolean include = includeFlags.get(rowIndex);
        ParameterSetDescriptor param = paramMap.get(rowIndex);
        String className = param.shortClassName();
        
        switch (columnIndex) {
            case 0:
                return include;
            case 1:
                return param.getName();
            case 2:
                return className;
            case 3:
                State state = param.getState();
                String color = "black";
                
                switch(state){
                    case CREATE:
                        color = "blue";
                        break;
                        
                    case IGNORE:
                    case CLASS_MISSING:
                        color = "maroon";
                        break;
                        
                    case SAME:
                        color = "green";
                        break;
                        
                    case UPDATE:
                        color = "red";
                        break;
                        
                    case LIBRARY_ONLY:
                        color = "purple";
                        break;
                        
                    case NONE:
                        color = "black";
                        break;
                        
                    default:
                }
                
                return ("<html><b><font color=" + color + ">" + state.toString() + "</font></b></html>");
        }

        return "huh?";
    }

    @Override
    public String getColumnName(int column) {
        switch (column) {
            case 0:
                return "Include";
            case 1:
                return "Parameter Set Name";
            case 2:
                return "Class";
            case 3:
                return "Action";
        }

        return "huh?";
    }

    @Override
    public boolean isCellEditable(int rowIndex, int columnIndex) {
        if(columnIndex == 0){
            return true;
        }else{
            return super.isCellEditable(rowIndex, columnIndex);
        }
    }

    @Override
    public void setValueAt(Object value, int rowIndex, int columnIndex) {
        if(columnIndex == 0){
            Boolean newInclude = (Boolean) value;
            includeFlags.set(rowIndex, newInclude);
        }else{
            throw new IllegalArgumentException("read-only columnIndex = " + columnIndex);
        }
    }

    @Override
    public Class<?> getColumnClass(int columnIndex) {
        if(columnIndex == 0){
            return Boolean.class;
        }else{
            return super.getColumnClass(columnIndex);
        }
    }
}
