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

package gov.nasa.kepler.pig.pe;
import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.common.pi.AncillaryAttitudeParameters;
import gov.nasa.kepler.common.ui.PropertySheetHelper;
import gov.nasa.kepler.hibernate.CrudFactory;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.gar.ExportTable;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.ui.proxy.PigProxyFactory;

import java.awt.BorderLayout;

import javax.swing.WindowConstants;

import com.l2fprod.common.propertysheet.PropertySheetPanel;

/**
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
@SuppressWarnings("serial")
public class TestPropEditorFrame extends javax.swing.JFrame {
    private PropertySheetPanel propSheetPanel;

    public TestPropEditorFrame() {
        super();
        initData();
        initGUI();
    }
    
    private void initData() {
        DefaultProperties.setPropsHsqldbMem();
        DatabaseService dbService = DatabaseServiceFactory.getInstance();
        dbService.getDdlInitializer().initDB();
        
        TargetCrud targetCrud = new TargetCrud();
        TargetTable ttable = new TargetTable(TargetTable.TargetType.LONG_CADENCE);
        ttable.setExternalId(170);
        ttable.setState(ExportTable.State.UPLINKED);
        
        dbService.beginTransaction();
        
        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
        TargetList targetList = new TargetList("known-planets");
        targetList.setCategory("known-planets");
        targetSelectionCrud.create(targetList);
        targetList = new TargetList("m-dwarves");
        targetList.setCategory("m-dwarves");
        targetSelectionCrud.create(targetList);

        targetCrud.createTargetTable(ttable);
        dbService.commitTransaction();
        
        CrudFactory.setProxyFactory(new PigProxyFactory());
    }
    
    private void initGUI() {
        try {
            setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
            setTitle("Test Property Editor Frame");
            {
                propSheetPanel = new PropertySheetPanel();
//                TargetTableParameters bean = new TargetTableParameters();
//                BeanInfo beanInfo = new DefaultBeanInfoResolver().getBeanInfo(bean);
               
                //TargetListParameters bean = new TargetListParameters();
                AncillaryAttitudeParameters bean = new AncillaryAttitudeParameters();
                
                /*
                BeanInfo beanInfo = 
                    Introspector.getBeanInfo(bean.getClass(), bean.getClass().getSuperclass());
                propSheetPanel.setProperties(beanInfo.getPropertyDescriptors());
                propSheetPanel.readFromObject(bean);
                propSheetPanel.setDescriptionVisible(true);*/
                PropertySheetHelper.populatePropertySheet(bean, propSheetPanel);
                getContentPane().add(propSheetPanel, BorderLayout.CENTER);
            }
            pack();
            setSize(400, 300);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Auto-generated main method to display this JFrame
     */
     public static void main(String[] args) {
         TestPropEditorFrame inst = new TestPropEditorFrame();
         inst.setVisible(true);
     }
     
}
