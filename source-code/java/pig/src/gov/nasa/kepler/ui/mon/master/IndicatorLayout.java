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

package gov.nasa.kepler.ui.mon.master;

import java.awt.Component;
import java.awt.Container;
import java.awt.Dimension;
import java.awt.Insets;
import java.awt.LayoutManager;

public class IndicatorLayout implements LayoutManager {

	private int numRows = 3;
	private int hGap = 10;
	private int vGap = 10;
	
	/**
	 * 
	 */
	public IndicatorLayout() {
	}

	/**
	 * 
	 */
	public void addLayoutComponent(String name, Component comp) {
	}

	/**
	 * 
	 */
	public void removeLayoutComponent(Component comp) {
	}

	/**
	 * 
	 */
	public Dimension preferredLayoutSize(Container parent) {
		
		int width = 0;
		int height = 0;
		int columnHeight = 0;
		int columnWidth = 0;
		int currentRow = 0;
		
		for (int i = 0; i < parent.getComponentCount(); i++) {
			Component c = parent.getComponent(i);
			Dimension d = c.getPreferredSize();

			columnWidth = (int) Math.max( columnWidth, d.getWidth() + hGap );
			columnHeight += d.getHeight() + vGap;
			
			if( currentRow + 1 == numRows ){
				// last row
				width += columnWidth;
				height = Math.max( height, columnHeight);
				currentRow = 0;
				columnWidth = 0;
				columnHeight = 0;
			}else{
				currentRow++;
			}
		}
		
		Insets insets = parent.getInsets();
		return new Dimension( width+insets.left+insets.right, height+insets.top+insets.bottom);
	}

	/**
	 * 
	 */
	public Dimension minimumLayoutSize(Container parent) {
		return preferredLayoutSize(parent);
	}

	/**
	 * 
	 */
	public void layoutContainer(Container parent) {

		Insets insets = parent.getInsets();
		int x = insets.left + hGap;
		int y = insets.top + vGap;
		int currentRow = 0;
		int columnWidth = 0;
		
		for (int i = 0; i < parent.getComponentCount(); i++) {
			Component c = parent.getComponent(i);
			Dimension d = c.getPreferredSize();

			c.setBounds( x, y, d.width, d.height );

			columnWidth = (int) Math.max( columnWidth, d.getWidth() + hGap );

			if( currentRow + 1 == numRows ){
				// last row
				x += columnWidth + hGap;
				y = insets.top + vGap;
				currentRow = 0;
				columnWidth = 0;
			}else{
				currentRow++;
				y += d.height + vGap;
			}
		}
	}

	/**
	 * @return Returns the hGap.
	 */
	public int getHGap() {
		return hGap;
	}

	/**
	 * @param gap The hGap to set.
	 */
	public void setHGap(int gap) {
		hGap = gap;
	}

	/**
	 * @return Returns the numRows.
	 */
	public int getNumRows() {
		return numRows;
	}

	/**
	 * @param numRows The numRows to set.
	 */
	public void setNumRows(int numRows) {
		this.numRows = numRows;
	}

	/**
	 * @return Returns the vGap.
	 */
	public int getVGap() {
		return vGap;
	}

	/**
	 * @param gap The vGap to set.
	 */
	public void setVGap(int gap) {
		vGap = gap;
	}

}
