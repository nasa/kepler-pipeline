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

package gov.nasa.kepler.mc.obslog;

import gov.nasa.kepler.hibernate.mc.ObservingLog;
import gov.nasa.kepler.hibernate.mc.ObservingLogModel;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.mc.pi.ModelOperationsFactory;
import gov.nasa.kepler.pi.models.ModelOperations;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class ObservingLogOperations {
    private static final Log log = LogFactory.getLog(ObservingLogOperations.class);

    private List<ObservingLog> cachedResults = null;
    
    public ObservingLogOperations() {
    }
    
    public String generateUowDateString(int cadenceType, int cadenceStart, int cadenceEnd, boolean includeMonths){
        String quarter = "?";
        String month = "?";
        
        List<ObservingLog> obsLogs = matches(cadenceType, cadenceStart, cadenceEnd);
        
        if(!obsLogs.isEmpty()){
            int startQ = obsLogs.get(0).getQuarter();
            int endQ = obsLogs.get(obsLogs.size() - 1).getQuarter();
            
            if(startQ == endQ){
                quarter = String.format("q%02d", startQ);
            }else{
                quarter = String.format("q%02d:q%02d", startQ, endQ);
            }
            
            if(includeMonths){
                int startM = obsLogs.get(0).getMonth();
                int endM = obsLogs.get(obsLogs.size() - 1).getMonth();
                
                if(startM == endM){
                    month = "m" + startM;
                }else{
                    month = "m" + startM + ":" + "m" + endM;
                }
            }
        }else{
            log.warn("No observing log entries found in db");
            return "?";
        }
        
        String uowString = null;
        
        if(includeMonths){
            uowString = quarter + month;
        }else{
            uowString = quarter;
        }
        
        return uowString;
    }
    
    private List<ObservingLog> matches(int cadenceType, int cadenceStart, int cadenceEnd){
        if(cachedResults == null){
            ModelOperations<ObservingLogModel> modelOperations = ModelOperationsFactory.getObservingLogInstance(
                new ModelMetadataRetrieverLatest());
            ObservingLogModel observingLogModel = modelOperations.retrieveModel();
            cachedResults = observingLogModel.getObservingLogs();
        }

        List<ObservingLog> m = new ArrayList<ObservingLog>();
        
        for (ObservingLog obsLog : cachedResults) {
            if(obsLog.matches(cadenceType, cadenceStart, cadenceEnd)){
                m.add(obsLog);
            }
        }
        return m;
    }
}
