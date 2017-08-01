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

package gov.nasa.kepler.ui.config.pipeline;

import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTaskGenerator;
import gov.nasa.kepler.ui.common.ClasspathUtils;

import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import javax.swing.AbstractListModel;
import javax.swing.ComboBoxModel;

/**
 * List model of valid UOW task generators for the specified
 * pipeline module.
 * 
 * @author tklaus
 *
 */
@SuppressWarnings("serial")
public class UowTgListModel extends AbstractListModel implements ComboBoxModel {

    private static List<ClassWrapper<UnitOfWorkTaskGenerator>> masterUowTgList;

    private List<UowTgElement> validUowTgList = new LinkedList<UowTgElement>();
    private UowTgElement selectedUowTg = null;
   
    private ClassWrapper<PipelineModule> pipelineModuleClass;
    
    public UowTgListModel(ClassWrapper<PipelineModule> pipelineModuleClass, ClassWrapper<UnitOfWorkTaskGenerator> currentUow) throws Exception {
        this.pipelineModuleClass = pipelineModuleClass;
        
        initializeList(currentUow);
    }

    private void initializeList(ClassWrapper<UnitOfWorkTaskGenerator> currentUow) throws Exception{
        initializeMasterUowTgList();
        
        validUowTgList = new LinkedList<UowTgElement>();

        PipelineModule moduleInstance = pipelineModuleClass.newInstance();
        Class<? extends UnitOfWorkTask> moduleExpectedUowTaskType = moduleInstance.unitOfWorkTaskType();
        
        for (ClassWrapper<UnitOfWorkTaskGenerator> availableUowTg : masterUowTgList) {
            UnitOfWorkTaskGenerator availableUowTgInstance = availableUowTg.newInstance();
            Class<? extends UnitOfWorkTask> selectedUowTaskType = availableUowTgInstance.unitOfWorkTaskType();

            if (moduleExpectedUowTaskType.equals(selectedUowTaskType)) {
                UowTgElement uowTgElement = new UowTgElement(availableUowTg);
                validUowTgList.add(uowTgElement);
                
                if(availableUowTg.equals(currentUow)){
                    selectedUowTg = uowTgElement; 
                }
            }
        }
        
        if(selectedUowTg == null && validUowTgList.size() > 0){
            selectedUowTg = validUowTgList.get(0);
        }
    }
    
    private void initializeMasterUowTgList() throws Exception{
        if(masterUowTgList == null){
            ClasspathUtils classpathUtils = new ClasspathUtils();
            Set<Class<? extends UnitOfWorkTaskGenerator>> detectedClasses = classpathUtils.scanFully(UnitOfWorkTaskGenerator.class);
            masterUowTgList = new LinkedList<ClassWrapper<UnitOfWorkTaskGenerator>>();
            
            for (Class<? extends UnitOfWorkTaskGenerator> clazz : detectedClasses) {
                ClassWrapper<UnitOfWorkTaskGenerator> wrapper = new ClassWrapper<UnitOfWorkTaskGenerator>(
                    clazz);

                masterUowTgList.add(wrapper);
            }

            Collections.sort(masterUowTgList);
        }
    }
    
    @Override
    public Object getElementAt(int index) {
        return validUowTgList.get(index);
    }

    @Override
    public int getSize() {
        return validUowTgList.size();
    }

    @Override
    public Object getSelectedItem() {
        return selectedUowTg;
    }

    @Override
    public void setSelectedItem(Object anItem) {
        selectedUowTg = (UowTgElement) anItem;
    }
}
