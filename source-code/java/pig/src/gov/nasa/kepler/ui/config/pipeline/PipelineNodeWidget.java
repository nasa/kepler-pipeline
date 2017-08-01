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
import gov.nasa.kepler.hibernate.pi.PipelineDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;

import java.awt.Font;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;

import javax.swing.BorderFactory;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.WindowConstants;
import javax.swing.border.BevelBorder;

/**
 * 
 * @author tklaus
 *
 */
@SuppressWarnings("serial")
public class PipelineNodeWidget extends javax.swing.JPanel {
	private JLabel label;
    private PipelineDefinition pipeline = null;
    private PipelineDefinitionNode pipelineNode = null;
	private PipelineDefinitionNode pipelineNodeParent = null;
	
	public PipelineNodeWidget() {
		initGUI();
	}
	
	public PipelineNodeWidget( PipelineDefinitionNode pipelineNode, PipelineDefinitionNode pipelineNodeParent ) {
		this.pipelineNode = pipelineNode;
		this.pipelineNodeParent = pipelineNodeParent;
		initGUI();
	}
	
	public PipelineNodeWidget(PipelineDefinition pipeline) {
        this.pipeline = pipeline;
        initGUI();
    }

    private void initGUI() {
		try {
            JLabel nodeLabel = getLabel();
            
			GridBagLayout thisLayout = new GridBagLayout();
			this.setLayout(thisLayout);
//            this.setPreferredSize(new java.awt.Dimension(180, 25));
            this.setPreferredSize(nodeLabel.getPreferredSize());
			this.setBorder(BorderFactory.createEtchedBorder(BevelBorder.LOWERED));
            this.add(nodeLabel, new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

    public boolean isStartNode(){
        return(pipeline != null);
    }
    
	public PipelineDefinition getPipeline() {
        return pipeline;
    }

    /**
	 * @return Returns the pipelineNode.
	 */
	public PipelineDefinitionNode getPipelineNode() {
		return pipelineNode;
	}

	/**
	 * @return Returns the pipelineNodeParent.
	 */
	public PipelineDefinitionNode getPipelineNodeParent() {
		return pipelineNodeParent;
	}

	private JLabel getLabel() {
		if (label == null) {
			label = new JLabel();
			if(pipelineNode == null){
			    // START node
	            label.setText("START");
	            label.setFont(new java.awt.Font("Dialog",Font.BOLD,16));
			}else{
			    String uowtgShortName = "-";
			    try {
                    uowtgShortName = pipelineNode.getUnitOfWork().newInstance().toString();
                } catch (Exception e) {
                }
	            label.setText( pipelineNode.getModuleName().getName() + " (" + uowtgShortName + ")");
			}
		}
		return label;
	}

	/**
	* Auto-generated main method to display this 
	* JPanel inside a new JFrame.
	*/
	public static void main(String[] args) {
		JFrame frame = new JFrame();
		frame.getContentPane().add(new PipelineNodeWidget());
		frame.setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
		frame.pack();
		frame.setVisible(true);
	}
	
}
