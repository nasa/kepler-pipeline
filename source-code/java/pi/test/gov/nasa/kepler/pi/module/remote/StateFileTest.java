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

package gov.nasa.kepler.pi.module.remote;

import static org.junit.Assert.*;

import gov.nasa.kepler.pi.module.remote.StateFile;
import gov.nasa.kepler.pi.module.remote.StateFile.State;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.io.File;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

import org.junit.Test;



/**
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class StateFileTest {

    @Test
    public void testParse(){
        String name = "kepler.10.11.pi.PROCESSING_5-1-3";
        StateFile stateFile = new StateFile(name);
        
        assertEquals("pipelineInstanceId", 10, stateFile.getPipelineInstanceId());
        assertEquals("pipelineTaskId", 11, stateFile.getPipelineTaskId());
        assertEquals("exeName", "pi", stateFile.getExeName());
        assertEquals("state", StateFile.State.PROCESSING, stateFile.getState());
        assertEquals("numTotal", 5, stateFile.getNumTotal());
        assertEquals("numComplete", 1, stateFile.getNumComplete());
        assertEquals("numFailed", 3, stateFile.getNumFailed());
    }
    
    @Test
    public void testPersist(){
        
    }
    
    @Test
    public void testFromDirectoryNoFilter() throws Exception{
        List<StateFile> expectedStateFiles = new LinkedList<StateFile>();
        expectedStateFiles.add(new StateFile(100,1,"pi",30,4.2,2.5,"wes",StateFile.State.COMPLETE,10,10,0,true,"24:00:00", false,"myGroup", "kepler", true, true));
        expectedStateFiles.add(new StateFile(100,2,"pi",30,4.2,2.5,"wes",StateFile.State.COMPLETE,10,10,0,true,"24:00:00", false,"myGroup", "kepler", true, true));
        expectedStateFiles.add(new StateFile(100,3,"pi",30,4.2,2.5,"wes",StateFile.State.SUBMITTED,20,0,0,true,"24:00:00", false,"myGroup", "kepler", true, true));
        expectedStateFiles.add(new StateFile(100,4,"pi",30,4.2,2.5,"wes",StateFile.State.ERRORSRUNNING,15,5,5,true,"24:00:00", false,"myGroup", "kepler", true, true));
        expectedStateFiles.add(new StateFile(100,5,"pi",30,4.2,2.5,"wes",StateFile.State.PROCESSING,25,10,0,true,"24:00:00", false,"myGroup", "kepler", true, true));
        expectedStateFiles.add(new StateFile(100,6,"pi",30,4.2,2.5,"wes",StateFile.State.FAILED,10,5,5,true,"24:00:00", false,"myGroup", "kepler", true, true));
        
        List<StateFile> actualStateFiles = StateFile.fromDirectory(new File("testdata/StateFile"));
        
        ReflectionEquals comparator = new ReflectionEquals();
        comparator.excludeField(".*\\.props"); // PropertiesConfiguration does not define equals()
        for (int i = 0; i < expectedStateFiles.size(); i++) {
            comparator.assertEquals("i="+i,expectedStateFiles.get(i), actualStateFiles.get(i));
            assertEquals("props.foo", 42.2, actualStateFiles.get(i).getProps().getFloat("foo"), 0.01);
        }
    }
    
    @Test
    public void testFromDirectoryFiltered() throws Exception{
        List<StateFile> expectedStateFiles = new LinkedList<StateFile>();
        expectedStateFiles.add(new StateFile(100,1,"pi",30,4.2,2.5,"wes",StateFile.State.COMPLETE,10,10,0,true,"24:00:00", false,"myGroup", "kepler", true, true));
        expectedStateFiles.add(new StateFile(100,2,"pi",30,4.2,2.5,"wes",StateFile.State.COMPLETE,10,10,0,true,"24:00:00", false,"myGroup", "kepler", true, true));
        
        List<State> stateFilters = new ArrayList<State>();
        stateFilters.add(StateFile.State.COMPLETE);
        List<StateFile> actualStateFiles = StateFile.fromDirectory(new File("testdata/StateFile"), stateFilters);
        
        ReflectionEquals comparator = new ReflectionEquals();
        comparator.excludeField(".*\\.props"); // PropertiesConfiguration does not define equals()
        for (int i = 0; i < expectedStateFiles.size(); i++) {
            comparator.assertEquals("i="+i,expectedStateFiles.get(i), actualStateFiles.get(i));
        }
    }
    
    @Test
    public void testFromFileListNoFilter() throws IllegalAccessException{
        List<StateFile> expectedStateFiles = new LinkedList<StateFile>();
        expectedStateFiles.add(new StateFile(100,1,"pi",-1,-1.0,-1.0,"wes",StateFile.State.COMPLETE,10,10,0,true,"24:00:00", false,"none", "none", true, false));
        expectedStateFiles.add(new StateFile(100,2,"pi",-1,-1.0,-1.0,"wes",StateFile.State.COMPLETE,10,10,0,true,"24:00:00", false,"none", "none", true, false));
        expectedStateFiles.add(new StateFile(100,3,"pi",-1,-1.0,-1.0,"wes",StateFile.State.SUBMITTED,20,0,0,true,"24:00:00", false,"none", "none", true, false));
        expectedStateFiles.add(new StateFile(100,4,"pi",-1,-1.0,-1.0,"wes",StateFile.State.ERRORSRUNNING,15,5,5,true,"24:00:00", false,"none", "none", true, false));
        expectedStateFiles.add(new StateFile(100,5,"pi",-1,-1.0,-1.0,"wes",StateFile.State.PROCESSING,25,10,0,true,"24:00:00", false,"none", "none", true, false));
        expectedStateFiles.add(new StateFile(100,6,"pi",-1,-1.0,-1.0,"wes",StateFile.State.FAILED,10,5,5,true,"24:00:00", false,"none", "none", true, false));

        List<String> files = new LinkedList<String>();
        files.add("kepler.100.1.pi.COMPLETE_10-10-0");
        files.add("kepler.100.2.pi.COMPLETE_10-10-0");
        files.add("kepler.100.3.pi.SUBMITTED_20-0-0");
        files.add("kepler.100.4.pi.ERRORSRUNNING_15-5-5");
        files.add("kepler.100.5.pi.PROCESSING_25-10-0");
        files.add("kepler.100.6.pi.FAILED_10-5-5");
        files.add("some-other_random_file.txt");
        
        List<StateFile> actualStateFiles = StateFile.fromList(files);
        
        ReflectionEquals comparator = new ReflectionEquals();
        comparator.excludeField(".*\\.props"); // PropertiesConfiguration does not define equals()
        for (int i = 0; i < expectedStateFiles.size(); i++) {
            comparator.assertEquals("stateFile, i="+i,expectedStateFiles.get(i), actualStateFiles.get(i));
            assertEquals("stateFile.name(), i="+i, files.get(i), actualStateFiles.get(i).name());
        }
    }
    
    @Test
    public void testFromFileListFiltered() throws IllegalAccessException{
        List<StateFile> expectedStateFiles = new LinkedList<StateFile>();
        expectedStateFiles.add(new StateFile(100,1,"pi",-1,-1.0,-1.0,"wes",StateFile.State.COMPLETE,10,10,0,true,"24:00:00", false,"none", "none", true, false));
        expectedStateFiles.add(new StateFile(100,2,"pi",-1,-1.0,-1.0,"wes",StateFile.State.COMPLETE,10,10,0,true,"24:00:00", false, "none", "none", true, false));

        List<String> files = new LinkedList<String>();
        files.add("kepler.100.1.pi.COMPLETE_10-10-0");
        files.add("kepler.100.2.pi.COMPLETE_10-10-0");
        files.add("kepler.100.3.pi.SUBMITTED_20-0-0");
        files.add("kepler.100.4.pi.ERRORSRUNNING_15-5-5");
        files.add("kepler.100.5.pi.PROCESSING_25-10-0");
        files.add("kepler.100.6.pi.FAILED_10-5-5");
        files.add("some-other_random_file.txt");
        
        List<State> stateFilters = new ArrayList<State>();
        stateFilters.add(StateFile.State.COMPLETE);
        List<StateFile> actualStateFiles = StateFile.fromList(files, stateFilters);
        
        ReflectionEquals comparator = new ReflectionEquals();
        comparator.excludeField(".*\\.props"); // PropertiesConfiguration does not define equals()
        for (int i = 0; i < expectedStateFiles.size(); i++) {
            comparator.assertEquals("i="+i,expectedStateFiles.get(i), actualStateFiles.get(i));
        }
    }
}
