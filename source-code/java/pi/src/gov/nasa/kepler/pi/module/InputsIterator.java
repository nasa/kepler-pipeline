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

package gov.nasa.kepler.pi.module;

import java.io.File;
import java.util.Iterator;

/**
 * Iterate over the sub-task directories as specified in the
 * {@link InputsHandler} object.
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class InputsIterator implements Iterator<File> {

    private InputsHandler inputsHandler;
    
    private int currentGroupIndex = 0;
    private int currentSubTaskIndex = 0;
    
    public InputsIterator(InputsHandler sequence) {
        this.inputsHandler = sequence;
        
        if(sequence.numGroups() > 0){
            currentGroupIndex = 0;
            currentSubTaskIndex = 0;
        }
    }

    /* (non-Javadoc)
     * @see java.util.Iterator#hasNext()
     */
    @Override
    public boolean hasNext() {
        if(inputsHandler.getMode() == InputsHandler.Mode.GROUP){
            if(currentGroupIndex < inputsHandler.numGroups()){
                if(currentSubTaskIndex < inputsHandler.getGroup(currentGroupIndex).numSubTasks()){
                    return true; // more tasks in this group
                }else{
                    return(inputsHandler.numGroups() > (currentGroupIndex + 1));
                }
            }else{
                return false;
            }
        }else{
            return(currentSubTaskIndex < inputsHandler.numSubTasks());
        }
    }

    /* (non-Javadoc)
     * @see java.util.Iterator#next()
     */
    @Override
    public File next() {
        if(inputsHandler.getMode() == InputsHandler.Mode.GROUP){
            if(currentGroupIndex < inputsHandler.numGroups()){
                InputsGroup currentGroup = inputsHandler.getGroup(currentGroupIndex);
                if(currentSubTaskIndex < currentGroup.numSubTasks()){
                   return currentGroup.subTaskDirectoryName(currentSubTaskIndex++); 
                }else{
                    // move on to next group
                    if((currentGroupIndex + 1 ) < inputsHandler.numGroups()){
                        currentGroupIndex++;
                        currentSubTaskIndex = 0;
                        return inputsHandler.getGroup(currentGroupIndex).subTaskDirectoryName(currentSubTaskIndex++);
                    }else{
                        return null;
                    }
                }
            }
            return null;
        }else{
            return InputsHandler.subTaskDirectory(inputsHandler.getTaskDir(), currentSubTaskIndex++); 
        }
    }

    /* (non-Javadoc)
     * @see java.util.Iterator#remove()
     */
    @Override
    public void remove() {
        throw new IllegalStateException("remove() not supported");
    }
}
