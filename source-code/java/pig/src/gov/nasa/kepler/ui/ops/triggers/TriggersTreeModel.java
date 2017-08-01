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

package gov.nasa.kepler.ui.ops.triggers;

import gov.nasa.kepler.hibernate.pi.Group;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.ui.PigSecurityException;
import gov.nasa.kepler.ui.models.DatabaseModelRegistry;
import gov.nasa.kepler.ui.models.PigDatabaseModel;
import gov.nasa.kepler.ui.ons.outline.Outline;
import gov.nasa.kepler.ui.proxy.TriggerDefinitionCrudProxy;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.swing.tree.AbstractLayoutCache;
import javax.swing.tree.DefaultMutableTreeNode;
import javax.swing.tree.DefaultTreeModel;
import javax.swing.tree.TreePath;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Tree model that groups by Group.  For use in Outline.
 * 
 * TODO: turn this into a generic GroupsTreeModel<T> so it can be shared
 * 
 * @author tklaus
 *
 */
@SuppressWarnings("serial")
public class TriggersTreeModel extends DefaultTreeModel implements PigDatabaseModel{
    private static final Log log = LogFactory.getLog(TriggersTreeModel.class);

    private List<TriggerDefinition> defaultGroupTriggers = new LinkedList<TriggerDefinition>();
    private Map<Group,List<TriggerDefinition>> triggers = new HashMap<Group, List<TriggerDefinition>>();
    private Map<String,TriggerDefinition> triggersByName = new HashMap<String,TriggerDefinition>();
    
    private TriggerDefinitionCrudProxy triggerDefinitionCrud;

    private DefaultMutableTreeNode rootNode;
    private DefaultMutableTreeNode defaultGroupNode;
    private Map<String,DefaultMutableTreeNode> groupNodes;
    
    private boolean modelValid = false;

    private HashMap<String, Boolean> expansionState;
    private boolean defaultGroupExpansionState;

    private Outline triggersOutline;
    
    public TriggersTreeModel() {
        super(new DefaultMutableTreeNode(""));
        rootNode = (DefaultMutableTreeNode) getRoot();
        triggerDefinitionCrud = new TriggerDefinitionCrudProxy();
        DatabaseModelRegistry.registerModel(this);
    }

    public Outline getTriggersOutline() {
        return triggersOutline;
    }

    public void setTriggersOutline(Outline triggersOutline) {
        this.triggersOutline = triggersOutline;
    }

    public void loadFromDatabase() throws PipelineException {
        
        recordExpansionState();
        reloadModel();
        applyExpansionState();

        modelValid = true;
    }

    private void reloadModel(){
        List<TriggerDefinition> allTriggers = null;
        
        try{
            if (triggers != null) {
                log.debug("Clearing the Hibernate cache of all loaded triggers");
                for (List<TriggerDefinition> triggerList : triggers.values()) {
                    triggerDefinitionCrud.evictAll(triggerList); // clear the cache
                }
            }
            
            if(defaultGroupTriggers != null){
                triggerDefinitionCrud.evictAll(defaultGroupTriggers); // clear the cache
            }

            defaultGroupTriggers = new LinkedList<TriggerDefinition>();
            triggers = new HashMap<Group, List<TriggerDefinition>>();
            triggersByName = new HashMap<String,TriggerDefinition>();
            groupNodes = new HashMap<String, DefaultMutableTreeNode>();
            
            allTriggers = triggerDefinitionCrud.retrieveAll();
        }catch(PigSecurityException ignore){
            return;
        }
        
        for (TriggerDefinition trigger : allTriggers) {
            triggersByName.put(trigger.getName(), trigger);
            
            Group group = trigger.getGroup();
            
            if(group == null){
                // default group
                defaultGroupTriggers.add(trigger);
            }else{
                List<TriggerDefinition> groupList = triggers.get(group);
                
                if(groupList == null){
                    groupList = new LinkedList<TriggerDefinition>();
                    triggers.put(group, groupList);
                }
                
                groupList.add(trigger);
            }
        }
        
        // create the tree
        rootNode.removeAllChildren();
        defaultGroupNode = new DefaultMutableTreeNode("<Default Group>");
        insertNodeInto(defaultGroupNode, rootNode, rootNode.getChildCount());
        
        for (TriggerDefinition trigger : defaultGroupTriggers) {
            DefaultMutableTreeNode triggerNode = new DefaultMutableTreeNode(trigger);
            insertNodeInto(triggerNode, defaultGroupNode, defaultGroupNode.getChildCount());
        }
        
        // sort groups alphabetically
        
        Set<Group> groupsSet = triggers.keySet();
        List<Group> groupsList = new ArrayList<Group>();
        groupsList.addAll(groupsSet);
        Collections.sort(groupsList, new Comparator<Group>(){
            @Override
            public int compare(Group o1, Group o2) {
                return o1.getName().compareTo(o2.getName());
            }});
        
        for (Group group : groupsList) {
            DefaultMutableTreeNode groupNode = new DefaultMutableTreeNode(group.getName());
            insertNodeInto(groupNode, rootNode, rootNode.getChildCount());
            groupNodes.put(group.getName(), groupNode);

            List<TriggerDefinition> groupTriggers = triggers.get(group);
            
            for (TriggerDefinition trigger : groupTriggers) {
                DefaultMutableTreeNode triggerNode = new DefaultMutableTreeNode(trigger);
                insertNodeInto(triggerNode, groupNode, groupNode.getChildCount());
            }
        }
        
        reload();
        
        log.debug("triggersTreeModel: done loading");
    }
    
    public DefaultMutableTreeNode groupNode(String groupName){
        return groupNodes.get(groupName);
    }
    
    public Map<String, DefaultMutableTreeNode> getGroupNodes() {
        return groupNodes;
    }

    /**
     * Returns true if a trigger already exists with the specified name. checked
     * when the operator changes the trigger name so we can warn them before we
     * get a database constraint violation.
     * 
     * @param name
     * @return
     */
    public TriggerDefinition triggerByName(String name) {
        return triggersByName.get(name);
    }

    @Override
    public void invalidateModel() {
        modelValid = false;
    }

    /**
     * Reload the model if it has been marked invalid
     * Should only be called by TriggersRowModel
     */
    void validityCheck(){
        if(!modelValid){
            log.debug("Model invalid for "+ this.getClass().getSimpleName() +", loading data from database...");
            loadFromDatabase();
        }
    }

    public DefaultMutableTreeNode getDefaultGroupNode() {
        return defaultGroupNode;
    }

    public DefaultMutableTreeNode getRootNode() {
        return rootNode;
    }
    
    private void recordExpansionState(){
        expansionState = new HashMap<String, Boolean>();
        if(triggersOutline != null){
            AbstractLayoutCache layoutCache = triggersOutline.getLayoutCache();
            
            Map<String, DefaultMutableTreeNode> groupNodes = getGroupNodes();
            for (String groupName : groupNodes.keySet()) {
                DefaultMutableTreeNode node = groupNodes.get(groupName);
                boolean isExpanded = layoutCache.isExpanded(new TreePath(node.getPath()));
                
                expansionState.put(groupName, isExpanded);
            }
            
            defaultGroupExpansionState = layoutCache.isExpanded(new TreePath(getDefaultGroupNode().getPath())); 
        }
    }
    
    private void applyExpansionState(){
        if(triggersOutline != null){
            Map<String, DefaultMutableTreeNode> groupNodes = getGroupNodes();
            
            for (String groupName : expansionState.keySet()) {
                DefaultMutableTreeNode node = groupNodes.get(groupName);
                if(node != null){
                    boolean shouldExpand = expansionState.get(groupName);
                    if(shouldExpand){
                        triggersOutline.expandPath(new TreePath(node.getPath()));
                    }else{
                        triggersOutline.collapsePath(new TreePath(node.getPath()));
                    }
                }
            }
            
            if(defaultGroupExpansionState){
                triggersOutline.expandPath(new TreePath(getDefaultGroupNode().getPath()));
            }else{
                triggersOutline.collapsePath(new TreePath(getDefaultGroupNode().getPath()));
            }
        }
    }
}
