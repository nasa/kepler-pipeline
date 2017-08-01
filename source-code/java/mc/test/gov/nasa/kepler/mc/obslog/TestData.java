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

import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.mc.uow.ModOutCadenceUowTask;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

/**
 * Generate a .csv file that contains:
 * 
 * TaskId, startCadence, endCadence, channel
 * 
 * These data can then be used to drive unit tests.
 *  
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class TestData {

    private static final String CSV_PATH = "test-data/observing-log/test-tasks.csv";
    private static final int INSTANCE_ID = 7170; // spq
    
    public TestData() {
    }

    public static void generate() throws Exception{
        PipelineInstanceCrud instanceCrud = new PipelineInstanceCrud();
        PipelineInstance instance = instanceCrud.retrieve(INSTANCE_ID);
        
        PipelineTaskCrud taskCrud = new PipelineTaskCrud();
        List<PipelineTask> tasks = taskCrud.retrieveAll(instance);
        
        File testDataFile = new File(CSV_PATH);
        PrintWriter writer = new PrintWriter(new FileWriter(testDataFile));
        
        for (PipelineTask task : tasks) {
            ModOutCadenceUowTask uow = (ModOutCadenceUowTask) task.getUowTask().getInstance();
            long id = task.getId();
            int startCadence = uow.getStartCadence();
            int endCadence = uow.getEndCadence();
            int[] channels = uow.getChannels();
            
            for (int channelIdx = 0; channelIdx < channels.length; channelIdx++) {
                writer.println(id + "," + startCadence + "," + endCadence + "," + channels[channelIdx]);
            }
        }
        writer.close();
    }
    
    public static List<TaskData> parse() throws Exception {
        List<TaskData> data = new ArrayList<TaskData>();
        File testDataFile = new File(CSV_PATH);
        BufferedReader reader = new BufferedReader(new FileReader(testDataFile));
    
        String line;
        
        while ((line = reader.readLine()) != null) {
            String[] elements = line.split(",");
            
            if(elements.length != 4){
                reader.close();        
                throw new PipelineException("unparsable line: " + line);
            }
            
            try{
                TaskData td = new TaskData();
                td.id = Integer.parseInt(elements[0]);
                td.startCadence = Integer.parseInt(elements[1]);
                td.endCadence = Integer.parseInt(elements[2]);
                td.channel = Integer.parseInt(elements[1]);
                
                data.add(td);
            }catch(NumberFormatException e){
                reader.close();        
                throw new PipelineException("unparsable line: " + line, e);
            }
        }
        reader.close();        
        
        return data;
    }
}
