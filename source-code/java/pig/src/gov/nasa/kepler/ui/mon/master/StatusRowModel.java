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

package gov.nasa.kepler.ui.mon.master;

import gov.nasa.kepler.ui.ons.outline.RowModel;
import gov.nasa.spiffy.common.lang.StringUtils;

import javax.swing.tree.DefaultMutableTreeNode;

public class StatusRowModel implements RowModel {

    @Override
    public Class<String> getColumnClass(int column) {
        return String.class;
    }

    @Override
    public int getColumnCount() {
        return 6;
    }

    @Override
    public String getColumnName(int column) {
        
        switch (column) {
            case 0:
                return "State";
            case 1:
                return "Age";
            case 2:
                return "Instance";
            case 3:
                return "Task";
            case 4:
                return "Module";
            case 5:
                return "UOW";
            default:
                return "huh?";
        }
    }

    @Override
    public Object getValueFor(Object treeNode, int column) {
        
        Object node = ((DefaultMutableTreeNode)treeNode).getUserObject();
        if(node instanceof ProcessNode){
            ProcessNode processNode = (ProcessNode) node;
            switch (column) {
                case 0:
                    return processNode.getState();
                case 1:
                    return(StringUtils.elapsedTime(processNode.getUptime().getTime(), System.currentTimeMillis()));
                case 2:
                    return "";
                case 3:
                    return "";
                case 4:
                    return "";
                case 5:
                    return "";
                default:
                    break;
            }
        }else if(node instanceof WorkerThreadNode){
            WorkerThreadNode workerThreadNode = (WorkerThreadNode) node;
            switch (column) {
                case 0:
                    return workerThreadNode.getState();
                case 1:
                    return(StringUtils.elapsedTime(workerThreadNode.getProcessingStartTime(), System.currentTimeMillis()));
                case 2:
                    return workerThreadNode.getInstanceId();
                case 3:
                    return workerThreadNode.getTaskId();
                case 4:
                    return workerThreadNode.getModule();
                case 5:
                    return workerThreadNode.getModuleUow();
                default:
                    break;
            }
        }
        return null;
    }

    @Override
    public boolean isCellEditable(Object node, int column) {
        return false;
    }

    @Override
    public void setValueFor(Object node, int column, Object value) {
    }
}
