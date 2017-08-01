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

import java.util.LinkedList;
import java.util.List;

import javax.persistence.Embeddable;
import javax.persistence.JoinTable;

import org.hibernate.annotations.CollectionOfElements;

/**
 * This class models a path to a {@link PipelineDefinitionNode} 
 * in a {@link PipelineDefinition}.  The path is represented with
 * a list of indices (child index), so it does not reference 
 * specific instances of nodes, just their location in the tree.
 * 
 * use cases
 * - construct when creating trigger def
 * - store with trigger def (hibernate pojo)
 * - pipeline launch, binding params to instance node in PipelineExecutor. 
 * - 
 * 
 * @author tklaus
 *
 */
@Embeddable
public class PipelineDefinitionNodePath {

    @CollectionOfElements
    @JoinTable(name = "PI_PDN_PATH_ELEMS")
    List<Integer> path = new LinkedList<Integer>();

    protected PipelineDefinitionNodePath() {
    }

    public PipelineDefinitionNodePath(List<Integer> path) {
        if(path == null || path.size() == 0){
            throw new IllegalStateException("path must be length 1 or greater");
        }
        this.path = path;
    }
    
    /**
     * Copy constructor
     * 
     * @param other
     */
    public PipelineDefinitionNodePath(PipelineDefinitionNodePath other){
        this.path.addAll(other.path);
    }
    
    public PipelineDefinitionNode definitionNodeAt(PipelineDefinition pipelineDefinition){
        return definitionNodeAt(pipelineDefinition.getRootNodes(), 0);
    }
    
    private PipelineDefinitionNode definitionNodeAt(List<PipelineDefinitionNode> nodes, int pathIndex){

        int childIndex = path.get(pathIndex);

        if(childIndex < nodes.size()){
            PipelineDefinitionNode node = nodes.get(childIndex);
            
            if(pathIndex < path.size() - 1){
                return definitionNodeAt(node.getNextNodes(), pathIndex + 1);
            }else{
                // last element of the path
                return node;
            }
        }else{
            return null;
        }
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        boolean first = true;
        for (Integer i : path) {
            if(!first){
                sb.append(",");
            }
            sb.append(i);
            first = false;
        }
        return sb.toString();
    }

    public List<Integer> getPath() {
        return path;
    }

    public void setPath(List<Integer> path) {
        this.path = path;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((path == null) ? 0 : path.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        final PipelineDefinitionNodePath other = (PipelineDefinitionNodePath) obj;
        if (path == null) {
            if (other.path != null)
                return false;
        } else if (!path.equals(other.path))
            return false;
        return true;
    }
}
