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

import gov.nasa.spiffy.common.collect.Pair;

import java.io.File;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.TreeMap;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Iterates across sub-task directories. 
 * Returns Pair<groupDir,subTaskDir> for each sub-task dir
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class TaskDirectoryIterator implements Iterator<Pair<File,File>> {
    private static final Log log = LogFactory.getLog(TaskDirectoryIterator.class);
    private static final String SUBTASK_DIR_NAME_PREFIX = "st-";

    private Iterator<Pair<File,File>> dirIterator;
    private LinkedList<Pair<File, File>> directoryList;
    private int currentIndex = -1; // the index of the last item retured by next()
    
	public TaskDirectoryIterator(File taskDirectory) {
        directoryList = new LinkedList<Pair<File,File>>();
        buildDirectoryList(taskDirectory, directoryList);
        dirIterator = directoryList.iterator();
    }

    private void buildDirectoryList(File dir, List<Pair<File,File>> list){
        List<File> files = listFilesNumericallyOrdered(dir);
        
        for (File file : files) {
            if(file.isDirectory()){
                if(file.getName().startsWith(SUBTASK_DIR_NAME_PREFIX)){
                    File groupDir = file.getParentFile();
                    File subTaskDir = file;
                    list.add(Pair.of(groupDir, subTaskDir));
                    log.debug("Adding: " + file);
                }
                buildDirectoryList(file, list);
            }
        }
    }

    /**
     * Return a list of Files in numeric order. Assumes
     * all file names are of the form X-n, where n is an integer.
     * File names that do not match this format are ignored and are
     * not returned in the list.
     *  
     * @param dir
     * @return
     */
    private List<File> listFilesNumericallyOrdered(File dir){
        File[] files = dir.listFiles();
        TreeMap<Integer, File> orderedMap = new TreeMap<Integer,File>();
        
        for (File file : files) {
            int n = isNumeric(file.getName());
            if(n >= 0){
                orderedMap.put(n, file);
            }
        }
        
        List<File> orderedList = new LinkedList<File>();
        
        for (int n : orderedMap.keySet()) {
            orderedList.add(orderedMap.get(n));
        }
        
        return orderedList;
    }
    
    private int isNumeric(String name){
        String[] elements = name.split("-");
        
        if(elements.length == 2){
            int number = -1;
            
            try {
                number = Integer.parseInt(elements[1]);
            } catch (NumberFormatException e) {
            }
            
            return number;
        }else{
            return -1;
        }
    }
    
    public int getCurrentIndex() {
		return currentIndex;
	}

    public int numSubTasks(){
        return directoryList.size();
    }
    
    /* (non-Javadoc)
     * @see java.util.Iterator#hasNext()
     */
    @Override
    public boolean hasNext() {
        return dirIterator.hasNext();
    }

    /* (non-Javadoc)
     * @see java.util.Iterator#next()
     */
    @Override
    public Pair<File, File> next() {
    	currentIndex++;
        return dirIterator.next();
    }

    /* (non-Javadoc)
     * @see java.util.Iterator#remove()
     */
    @Override
    public void remove() {
        throw new IllegalStateException("remove() not supported");
    }
}
