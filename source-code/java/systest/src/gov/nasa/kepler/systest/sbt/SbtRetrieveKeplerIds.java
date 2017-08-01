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

package gov.nasa.kepler.systest.sbt;

import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

public class SbtRetrieveKeplerIds extends AbstractSbt {
    private static final String SDF_FILE_NAME = "/tmp/sbt-retrieve-kepler-ids.sdf";
    private static final boolean REQUIRES_DATABASE = true;
    private static final boolean REQUIRES_FILESTORE = false;

    public static class SingleTargetList implements Persistable {
        public String name;
        public String category;
        public String source;
        
        public SingleTargetList() {
        }
    }
    
    public static class PlannedTargetContainer implements Persistable {
        public int keplerId;
        public String[] labels;
        public int skyGroupId;
        public SingleTargetList singleTargetList;
        
        public PlannedTargetContainer() {
            this.singleTargetList = new SingleTargetList();
        }
    }
    
    public static class TargetsContainer implements Persistable {
        public List<PlannedTargetContainer> targets;

        public TargetsContainer(Collection<PlannedTarget> targets) {
            this.targets = new LinkedList<PlannedTargetContainer>();
            
            for (PlannedTarget plannedTarget : targets) {
                PlannedTargetContainer plannedTargetContainer = new PlannedTargetContainer();
                
                plannedTargetContainer.keplerId = plannedTarget.getKeplerId();
                plannedTargetContainer.skyGroupId = plannedTarget.getSkyGroupId();
                plannedTargetContainer.labels = plannedTarget.getLabels().toArray(new String[0]);    
                TargetList targetList = plannedTarget.getTargetList();
                plannedTargetContainer.singleTargetList.name = targetList.getName();
                plannedTargetContainer.singleTargetList.category = plannedTarget.getTargetList().getCategory();
                plannedTargetContainer.singleTargetList.source = plannedTarget.getTargetList().getSource();
                
                this.targets.add(plannedTargetContainer);                
            }
            
        }
    }

    public SbtRetrieveKeplerIds() {
        super(REQUIRES_DATABASE, REQUIRES_FILESTORE);
    }

    public String retrieveKeplerIds(String targetListSetName, List<String> labels, List<String> categories, boolean labelsAndCategoriesAreSubstrings) throws Exception {
        if (! validateDatastores()) {
            return "";
        }
        
        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
        List<PlannedTarget> plannedTargets = targetSelectionCrud.retrievePlannedTargets(targetListSetName, labels, categories, labelsAndCategoriesAreSubstrings);
        
        Map<Integer, PlannedTarget> uniquePlannedTargetsMap = new HashMap<Integer, PlannedTarget>();
        for (PlannedTarget plannedTarget : plannedTargets) {
            uniquePlannedTargetsMap.put(plannedTarget.getKeplerId(), plannedTarget);
        }
        TargetsContainer targetContainer = new TargetsContainer(uniquePlannedTargetsMap.values());
        
        return makeSdf(targetContainer, SDF_FILE_NAME);
    }
    
    public String retrieveKeplerIds(String targetListSetName, List<String> labels, List<String> categories) throws Exception {
        return retrieveKeplerIds(targetListSetName, labels, categories, false);
    }
    
    public String retrieveKeplerIds(String targetListSetName, List<String> labelsOrCategories, boolean isSecondArgumentLabels, boolean labelsAndCategoriesAreSubstrings) throws Exception {
        if (! validateDatastores()) {
            return "";
        }
        
        List<String> labels = new ArrayList<String>();
        List<String> categories = new ArrayList<String>();
        
        if (isSecondArgumentLabels) {
            labels = labelsOrCategories;
            categories = new ArrayList<String>(); // TODO: verify this is the right thing to do for the no-categories case
        } else {
            labels = new ArrayList<String>(); // TODO: verify this is the right thing to do for the no-labels case
            categories = labelsOrCategories;
        }
        return retrieveKeplerIds(targetListSetName, labels, categories, labelsAndCategoriesAreSubstrings);
    }
    
    public String retrieveKeplerIds(String targetListSetName, List<String> labelsOrCategories, boolean isSecondArgumentLabels) throws Exception {
        return retrieveKeplerIds(targetListSetName, labelsOrCategories, isSecondArgumentLabels, false);
    }
    
    public String retrieveKeplerIds(String targetListSetName) throws Exception {
        List<String> labels = new ArrayList<String>(); // TODO: verify this is the right thing to do for the no-categories case
        List<String> categories = new ArrayList<String>(); // TODO: verify this is the right thing to do for the no-categories case
        return retrieveKeplerIds(targetListSetName, labels, categories);
    }    


    public static void main(String[] args) throws Exception {
        String targetListSetName = "quarter1_spring2009_lc";
        List<String> twoLabels = new ArrayList<String>(Arrays.asList("TAD_ONE_HALO", "ASTERO_LC"));
        List<String> categories = new ArrayList<String>(Arrays.asList("PLANETARY"));
        SbtRetrieveKeplerIds sbt = new SbtRetrieveKeplerIds();
        
        String path1 = sbt.retrieveKeplerIds(targetListSetName, twoLabels, categories, false);
        System.out.println(path1);
        
        String path2 = sbt.retrieveKeplerIds(targetListSetName);
        System.out.println(path2);
    }
}
