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

import gov.nasa.kepler.hibernate.pi.PipelineInstance.State;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;

/**
 * Filter used by the {@link PipelineInstanceCrud.retrieve()} method.
 * 
 * @author tklaus
 *
 */
public class PipelineInstanceFilter {

    private static final String FROM_CLAUSE = "from PipelineInstance pi";
    private static final String ORDER_BY_CLAUSE = "order by pi.id asc";
    private static final long MILLIS_PER_DAY = 24 * 60 * 60 * 1000;

    /** Pass if PipelineInstance.name contains the specified String. 
     *  If empty or null, name is not included in the where clause. */
    private String nameContains = "";
    
    /** Pass if PipelineInstance.state is contained in this Set.
     *  If null, state is not included in the where clause. 
     *  Note that List is used rather than Set in order to make the order
     *  deterministic, which simplifies testing */
    private List<PipelineInstance.State> states = null;
    
    /** Pass if PipelineInstance.startProcessingTime is within ageDays days of the
     * time the query is ran.  If 0, startProcessingTime is not included in the 
     * where clause. */
    private int ageDays = 10;
    
    public PipelineInstanceFilter() {
    }

    public PipelineInstanceFilter(String nameContains, List<State> states, int ageDays) {
        this.nameContains = nameContains;
        this.states = states;
        this.ageDays = ageDays;
    }

    /**
     * Create the Hibernate Query object that implements this filter.
     * Called only by PipelineInstanceCrud.
     * 
     * @param session
     * @return
     */
    Query query(Session session){
        StringBuilder result = new StringBuilder();
        List<Pair<String,Object>> parameters = new ArrayList<Pair<String,Object>>();
        
        if(nameContains != null && nameContains.length() > 0){
            result.append("pi.name like '%" + nameContains + "%'");
        }
        
        if(states != null){

            if(result.length() > 0){
                result.append(" and ");
            }
            
            if(states.size() > 0){
                int statesAdded = 0;
                result.append("pi.state in (");
                for (PipelineInstance.State state : states) {
                    if(statesAdded > 0){
                        result.append(",");
                    }
                    result.append(state.ordinal());
                    statesAdded++;
                }
                result.append(")");
            }else{
                // empty, no matches
                result.append("pi.state = -1");
            }
        }
        
        if(ageDays > 0){
            if(result.length() > 0){
                result.append(" and ");
            }
            result.append("pi.startProcessingTime >= :startProcessingTime");
            long t = System.currentTimeMillis() - ageDays * MILLIS_PER_DAY;
            Date d = new Date(t);
            parameters.add(Pair.of("startProcessingTime", (Object) d));
        }
        
        Query q;
        
        if(result.length() > 0){
            q = session.createQuery(FROM_CLAUSE + " where " + result.toString() + " " + ORDER_BY_CLAUSE);
            for (Pair<String, Object> pair : parameters) {
                q.setParameter(pair.left, pair.right);
            }
        }else{
            // no filters
            q = session.createQuery(FROM_CLAUSE + " " + ORDER_BY_CLAUSE);
        }
        
        return q;
    }
    
    public String getNameContains() {
        return nameContains;
    }

    public void setNameContains(String nameContains) {
        this.nameContains = nameContains;
    }

    public List<PipelineInstance.State> getStates() {
        return states;
    }

    public void setStates(List<PipelineInstance.State> states) {
        this.states = states;
    }

    public int getAgeDays() {
        return ageDays;
    }

    public void setAgeDays(int ageDays) {
        this.ageDays = ageDays;
    }
}
