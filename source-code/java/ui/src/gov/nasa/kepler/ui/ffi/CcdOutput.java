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

package gov.nasa.kepler.ui.ffi;

import gov.nasa.kepler.ui.swing.ToolPanel;

import java.awt.Color;
import java.awt.Component;
import java.awt.Font;
import java.awt.event.MouseEvent;

import javax.swing.BorderFactory;
import javax.swing.JLabel;
import javax.swing.JPopupMenu;

import org.bushe.swing.event.EventBus;

@SuppressWarnings("serial")
public class CcdOutput extends JLabel {
    private static Color SELECTED_COLOR = new Color(39, 117, 188);
    private static Color UNSELECTED_COLOR = Color.WHITE;
    private static Color BORDER_COLOR = Color.BLACK;
    private static Color DISABLED_BORDER_COLOR = Color.GRAY;
    private static Color TEXT_COLOR = Color.BLACK;
    private static Color DISABLED_TEXT_COLOR = Color.GRAY;
    private static Color VALID_COLOR = Color.WHITE;

    private Color color;
    private int module;
    private int output;
    private boolean isValid;
    private boolean isSelected;
    private boolean isDoActionNow;
    private FfiViewerPanel parent;

    public CcdOutput(int module, int output, FfiViewerPanel parent) {
        this(module, output, true, parent);
    }

    public CcdOutput(int module, int output, boolean isValid,
        FfiViewerPanel parent) {
        super();
        this.module = module;
        this.output = output;
        this.isValid = isValid;
        isSelected = false;
        this.parent = parent;

        createPopupMenu(this.parent);

        setOpaque(isValid());

        if (this.isValid) {
            color = VALID_COLOR;
            setBackground(color);
            setText(toString());
            setFont(getFont().deriveFont(Font.BOLD, getFont().getSize() * 1.25f));

            setEnabled(false);
        }
    }

    public Color getColor() {
        return color;
    }

    public void setColor(Color color) {
        this.color = color;
    }

    public boolean isSelected() {
        return isSelected;
    }

    public void setSelected(boolean isSelected) {
        this.isSelected = isSelected;
        setColor(isSelected() ? SELECTED_COLOR : UNSELECTED_COLOR);
        setBackground(getColor());
    }

    @Override
    public boolean isValid() {
        return isValid;
    }

    public void setValid(boolean isValid) {
        this.isValid = isValid;
    }

    public int getModule() {
        return module;
    }

    public void setModule(int module) {
        this.module = module;
    }

    public int getOutput() {
        return output;
    }

    public void setOutput(int output) {
        this.output = output;
    }

    public void setDoActionNow(boolean isDoActionNow) {
        this.isDoActionNow = isDoActionNow;
    }

    public boolean isDoActionNow() {
        return isDoActionNow;
    }

    @Override
    public void setEnabled(boolean isEnabled) {
        if (!isValid) {
            return;
        }

        if (isEnabled) {
            setForeground(TEXT_COLOR);
            setBorder(BorderFactory.createLineBorder(BORDER_COLOR));
        } else {
            setForeground(DISABLED_TEXT_COLOR);
            setBorder(BorderFactory.createLineBorder(DISABLED_BORDER_COLOR));
        }
    }

    /**
     * Creates a popup menu for the table.
     */
    private void createPopupMenu(final ToolPanel toolPanel) {
        final JPopupMenu menu = toolPanel.getPopupMenu();
        final Component parent = this;

        addMouseListener(new java.awt.event.MouseAdapter() {
            @Override
            public void mousePressed(java.awt.event.MouseEvent e) {
                if (!isValid) {
                    return;
                }

                if (e.getButton() == MouseEvent.BUTTON1) {
                    switch (e.getClickCount()) {
                        case 1:
                            setSelected(!isSelected());
                            EventBus.publish(CcdOutput.this);
                            break;
                        case 2:
                            setSelected(true);
                            setDoActionNow(true);
                            EventBus.publish(CcdOutput.this);
                            break;
                        default:
                            break;

                    }
                }
                mouseReleased(e);

            }

            @Override
            public void mouseReleased(java.awt.event.MouseEvent e) {
                if (!isValid) {
                    return;
                }

                if (e.isPopupTrigger()) {
                    if (menu != null) {
                        EventBus.publish(CcdOutput.this);
                        menu.show(parent, e.getX(), e.getY());
                    }
                }
            }
        });
    }

    @Override
    public String toString() {
        return "" + getModule() + "/" + getOutput();
    }

}
