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

package gov.nasa.kepler.ui.swing;

import gov.nasa.kepler.ui.common.UiException;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Graphics;

import javax.swing.GroupLayout;
import javax.swing.GroupLayout.Alignment;
import javax.swing.ImageIcon;
import javax.swing.JComponent;
import javax.swing.JEditorPane;
import javax.swing.JLabel;
import javax.swing.JSeparator;
import javax.swing.LayoutStyle.ComponentPlacement;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * A header for all main panels. It's white, displays some instruction and an
 * icon, and can also display additional information to aid the user when
 * filling out fields (TBD).
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
public class PanelHeader extends KeplerPanel {

    private static final Log log = LogFactory.getLog(PanelHeader.class);

    /** The message to display. */
    private String text;

    // UI components.
    private JLabel titleLabel;
    private IconPanel helpIconPanel;
    private JEditorPane messageArea;
    private IconPanel iconPanel;

    /**
     * Creates a {@link PanelHeader}.
     * 
     * @throws UiException if the panel could not be created
     */
    public PanelHeader() throws UiException {
        createUi();
    }

    @Override
    protected void initComponents() {
        GroupLayout layout = new GroupLayout(this);
        setLayout(layout);

        titleLabel = new JLabel();
        titleLabel.setFont(titleLabel.getFont()
            .deriveFont(Font.BOLD));

        helpIconPanel = new IconPanel();

        messageArea = new JEditorPane() {
            private Dimension preferredSize = new Dimension(0, 0);

            @Override
            public Dimension getPreferredSize() {
                // Minimize size changes whenever text changes. The component
                // can get bigger, but never smaller.
                Dimension desiredSize = super.getPreferredSize();
                if (desiredSize.height > preferredSize.height) {
                    preferredSize = desiredSize;
                }

                return preferredSize;
            }
        };
        messageArea.setFocusable(false);

        iconPanel = new IconPanel();
        JSeparator separator = new JSeparator();

        layout.setHorizontalGroup(layout.createParallelGroup()
            .addGroup(
                layout.createSequentialGroup()
                    .addContainerGap()
                    .addGroup(
                        layout.createParallelGroup()
                            .addComponent(titleLabel)
                            .addGroup(
                                layout.createSequentialGroup()
                                    .addComponent(helpIconPanel,
                                        GroupLayout.DEFAULT_SIZE,
                                        GroupLayout.DEFAULT_SIZE,
                                        GroupLayout.PREFERRED_SIZE)
                                    .addComponent(messageArea)))
                    .addPreferredGap(ComponentPlacement.UNRELATED,
                        GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(iconPanel, GroupLayout.DEFAULT_SIZE,
                        GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
                    .addContainerGap())
            .addComponent(separator));

        layout.setVerticalGroup(layout.createSequentialGroup()
            .addContainerGap()
            .addGroup(
                layout.createParallelGroup()
                    .addGroup(
                        layout.createSequentialGroup()
                            .addComponent(titleLabel)
                            .addPreferredGap(ComponentPlacement.UNRELATED)
                            .addGroup(
                                layout.createParallelGroup(Alignment.BASELINE)
                                    .addComponent(helpIconPanel,
                                        GroupLayout.DEFAULT_SIZE,
                                        GroupLayout.DEFAULT_SIZE,
                                        GroupLayout.PREFERRED_SIZE)
                                    .addComponent(messageArea,
                                        GroupLayout.PREFERRED_SIZE,
                                        GroupLayout.DEFAULT_SIZE,
                                        GroupLayout.DEFAULT_SIZE))
                            .addContainerGap())
                    .addComponent(iconPanel))
            .addComponent(separator, GroupLayout.DEFAULT_SIZE,
                GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE));
    }

    /**
     * Provide additional configuration not already found in
     * {@link #initComponents()}.
     */
    @Override
    protected void configureComponents() {
        setBackground(Color.WHITE);
        helpIconPanel.setVisible(false);
        messageArea.setBackground(Color.WHITE);
        messageArea.setEditable(false);
        messageArea.setContentType("text/html");
    }

    @Override
    protected void updateEnabled() {
    }

    /**
     * Returns this header's title.
     * 
     * @return the title
     */
    public String getTitle() {
        return titleLabel.getText();
    }

    /**
     * Sets this header's title.
     * 
     * @param title the title
     */
    public void setTitle(String title) {
        titleLabel.setText(title);
    }

    /**
     * Returns this header's text.
     * 
     * @return the text
     */
    public String getText() {
        return text;
    }

    /**
     * Sets this header's text.
     * 
     * @param text the text
     */
    public void setText(String text) {
        log.debug(text);
        this.text = text;
        updateMessageArea();
    }

    /**
     * Updates the message area with the title and text.
     */
    private void updateMessageArea() {
        messageArea.setText("<html>"
            + (getHelpText() != null ? getHelpText() : text != null ? text : "")
            + "</html>");
    }

    /**
     * Returns this header's icon.
     * 
     * @return the icon
     */
    public ImageIcon getIcon() {
        return iconPanel.getIcon();
    }

    /**
     * Sets this header's icon.
     * 
     * @param icon the icon
     */
    public void setIcon(ImageIcon icon) {
        iconPanel.setIcon(icon);
    }

    /**
     * Returns the maximum size of this panel. This returns the preferred size
     * height to keep the panel from getting bigger than it needs to be.
     */
    @Override
    public Dimension getMaximumSize() {
        return new Dimension(super.getMaximumSize().width,
            getPreferredSize().height);
    }

    /**
     * Displays context help with an error icon which occludes the existing
     * text.
     * 
     * @param text the help text to display. Use {@code null} to revert to the
     * original text
     */
    public void displayHelp(String text) {
        displayHelp(HelpType.ERROR, text);
    }

    /**
     * Displays context help with an icon appropriate to the given type which
     * occludes the existing text.
     * 
     * @param text the help text to display. Use {@code null} to revert to the
     * original text
     */
    public void displayHelp(HelpType type, String text) {
        log.debug(text);
        setHelpText(text);
        setHelpIconType(text != null ? type : null);
        updateMessageArea();
    }

    private void setHelpIconType(HelpType helpIconType) {
        if (helpIconType != null) {
            switch (helpIconType) {
                case INFORMATION:
                    helpIconPanel.setIcon(informationIcon24);
                    break;
                case WARNING:
                    helpIconPanel.setIcon(warningIcon24);
                    break;
                case ERROR:
                    helpIconPanel.setIcon(errorIcon24);
                    break;
            }
            helpIconPanel.setVisible(true);
        } else {
            helpIconPanel.setVisible(false);
        }
    }

    /**
     * Icon widget.
     * 
     * @author Bill Wohler
     */
    private static class IconPanel extends JComponent {

        private static final int MAX_ICON_WIDTH = 160;
        private static final int MAX_ICON_HEIGHT = 100;

        private ImageIcon icon;
        private int preferredWidth = -1;
        private int preferredHeight = -1;

        /**
         * Creates an {@link IconPanel}.
         */
        public IconPanel() {
        }

        @Override
        protected void paintComponent(Graphics g) {
            if (icon == null) {
                return;
            }

            icon.paintIcon(this, g, 0, 0);
        }

        @Override
        public Dimension getPreferredSize() {
            if (icon == null) {
                return new Dimension(0, 0);
            }

            if (preferredWidth < 0) {
                preferredWidth = icon.getIconWidth();
                preferredHeight = icon.getIconHeight();
                double aspectRatio = (double) preferredWidth / preferredHeight;
                boolean update = false;
                if (preferredWidth > MAX_ICON_WIDTH) {
                    preferredWidth = MAX_ICON_WIDTH;
                    preferredHeight = (int) (preferredWidth / aspectRatio);
                    update = true;
                }
                if (preferredHeight > MAX_ICON_HEIGHT) {
                    preferredHeight = MAX_ICON_HEIGHT;
                    preferredWidth = (int) (preferredHeight * aspectRatio);
                    update = true;
                }
                if (update) {
                    icon = KeplerSwingUtilities.scaleIcon(icon, preferredWidth,
                        preferredHeight);
                }
            }

            Dimension size = new Dimension(preferredWidth, preferredHeight);

            return size;
        }

        @Override
        public Dimension getMinimumSize() {
            return getPreferredSize();
        }

        public ImageIcon getIcon() {
            return icon;
        }

        public void setIcon(ImageIcon icon) {
            this.icon = icon;
        }
    }
}
