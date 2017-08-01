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

package gov.nasa.kepler.hibernate.pi;

import java.util.HashMap;
import java.util.Map;

/**
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class PipelineTaskAttributes {

    /** Sub-state when state == PROCESSING 
     * The purpose of this field is to provide more fine-grained status for the pipeline operator */
    public enum ProcessingState {
        INITIALIZING,
        MARSHALING,
        SENDING,
        ALGORITHM_EXECUTING,
        RECEIVING,
        STORING,
        COMPLETE,
        ALGORITHM_QUEUED,
        ALGORITHM_COMPLETE;
        
        public String shortName(){
            switch(this){
                case INITIALIZING:
                    return "I";
                case MARSHALING:
                    return "M";
                case SENDING:
                    return "Tx";
                case ALGORITHM_QUEUED:
                    return "Aq";
                case ALGORITHM_EXECUTING:
                    return "Ae";
                case ALGORITHM_COMPLETE:
                    return "Ac";
                case RECEIVING:
                    return "Rx";
                case STORING:
                    return "S";
                case COMPLETE:
                    return "C";
                default:
                    return "?";
            }
        }
    }
    
    private static final String PROCESSING_STATE_ATTR_NAME = "processingState";
    private static final String NUM_ST_TOTAL_ATTR_NAME     = "numSubTasksTotal";
    private static final String NUM_ST_COMPLETE_ATTR_NAME  = "numSubTasksComplete";
    private static final String NUM_ST_FAILED_ATTR_NAME    = "numSubTasksFailed";

    private Map<String,String> attributeMap = new HashMap<String,String>();
    
    public PipelineTaskAttributes() {
    }

    public PipelineTaskAttributes(Map<String, String> attrs) {
        this.attributeMap = attrs;
    }

    public int getNumSubTasksTotal() {
        return getIntValue(NUM_ST_TOTAL_ATTR_NAME);
    }

    public void setNumSubTasksTotal(int numSubTasksTotal) {
        setIntValue(NUM_ST_TOTAL_ATTR_NAME, numSubTasksTotal);
    }

    public int getNumSubTasksComplete() {
        return getIntValue(NUM_ST_COMPLETE_ATTR_NAME);
    }

    public void setNumSubTasksComplete(int numSubTasksComplete) {
        setIntValue(NUM_ST_COMPLETE_ATTR_NAME, numSubTasksComplete);
    }

    public int getNumSubTasksFailed() {
        return getIntValue(NUM_ST_FAILED_ATTR_NAME);
    }

    public void setNumSubTasksFailed(int numSubTasksFailed) {
        setIntValue(NUM_ST_FAILED_ATTR_NAME, numSubTasksFailed);
    }

    public ProcessingState getProcessingState() {
        String pState = getStringValue(PROCESSING_STATE_ATTR_NAME);
        
        if(pState != null && !pState.isEmpty()){
            return ProcessingState.valueOf(pState);
        }else{
            return ProcessingState.INITIALIZING;
        }
    }

    public void setProcessingState(ProcessingState processingState) {
        setStringValue(PROCESSING_STATE_ATTR_NAME, processingState.name());
    }
    
    public Map<String, String> getAttributeMap() {
        return attributeMap;
    }

    private int getIntValue(String name){
        String value = attributeMap.get(name);
        
        int intValue = 0;
        
        try {
            intValue = Integer.parseInt(value);
        } catch (NumberFormatException e) {
        }
        
        return intValue;
    }

    private void setIntValue(String name, int value){
        attributeMap.put(name, Integer.toString(value));
    }

    private String getStringValue(String name){
        return attributeMap.get(name);
    }

    private void setStringValue(String name, String value){
        attributeMap.put(name, value);
    }

    public String processingStateShortLabel(){
        ProcessingState processingState = getProcessingState();
        String pState = "?";
        if(processingState != null){
            pState = processingState.shortName();
        }
        
        StringBuilder sb = new StringBuilder();
        sb.append(pState);
        sb.append(" (");
        sb.append(getNumSubTasksTotal());
        sb.append("/");
        sb.append(getNumSubTasksComplete());
        sb.append("/");
        sb.append(getNumSubTasksFailed());
        sb.append(")");
        
        return sb.toString();
    }
    
}
