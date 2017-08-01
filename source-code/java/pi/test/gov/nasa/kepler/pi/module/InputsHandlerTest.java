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

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.spiffy.common.junit.ReflectionEquals;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;

import org.junit.Test;

import com.google.common.io.Files;

public class InputsHandlerTest {
    private PipelineTask task = new PipelineTask();

    @Test
    public void testPersitenceNoGroups() throws Exception{
        File dir = Files.createTempDir();
        
        InputsHandler s1 = new InputsHandler(task, dir);
        
        s1.persist(dir);
        
        InputsHandler s2 = InputsHandler.restore(dir);
        
        ReflectionEquals comparator = new ReflectionEquals();
        comparator.assertEquals(s1, s2);
        
        checkInputsHandlers(s1, s2);
    }

    @Test
    public void testPersitenceSingleGroup() throws Exception{
        File dir = Files.createTempDir();

        InputsHandler s1 = new InputsHandler(task, dir);
        InputsGroup g1 = s1.createGroup();
        
        g1.add(0);
        g1.add(1,5);
        g1.add(6);
        
        s1.persist(dir);
        
        InputsHandler s2 = InputsHandler.restore(dir);
        
        ReflectionEquals comparator = new ReflectionEquals();
        comparator.assertEquals(s1, s2);
        
        checkInputsHandlers(s1, s2);
    }
    
    @Test
    public void testPersitenceMultipleGroup() throws Exception{
        File dir = Files.createTempDir();

        InputsHandler s1 = new InputsHandler(task, dir);
        InputsGroup g1 = s1.createGroup();
        
        g1.add(0);
        g1.add(1,5);
        g1.add(6);

        InputsGroup g2 = s1.createGroup();
        g2.add(0,9);

        s1.persist(dir);
        
        InputsHandler s2 = InputsHandler.restore(dir);
        
        ReflectionEquals comparator = new ReflectionEquals();
        comparator.assertEquals(s1, s2);

        checkInputsHandlers(s1, s2);
    }
    
    @Test(expected=PipelineException.class)
    public void testInvalid(){
        InputsHandler s = new InputsHandler();
        InputsGroup g = s.createGroup();

        g.add(0);
        
        s.validate();
    }

    private void checkInputsHandlers(InputsHandler s1, InputsHandler s2) {
        assertEquals(s1.getTaskDir(), s2.getTaskDir());
        for (int i = 0; i < s1.getGroups().size(); i++) {
            assertEquals(s1.getGroups().get(i).getGroupIndex(), s2.getGroups().get(i).getGroupIndex());
            assertEquals(s1.getGroups().get(i).getTaskWorkingDir(), s2.getGroups().get(i).getTaskWorkingDir());
        }
    }
}
