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

package gov.nasa.kepler.ui.gar;

import gov.nasa.kepler.hibernate.gar.ExportTable;
import gov.nasa.kepler.ui.common.UiException;
import gov.nasa.kepler.ui.gar.TableExportPanel.Helper;
import gov.nasa.kepler.ui.swing.KeplerDialogs;
import gov.nasa.kepler.ui.swing.KeplerPanel;
import gov.nasa.kepler.ui.swing.ToolPanel;

import java.awt.CardLayout;
import java.awt.Component;
import java.util.Arrays;
import java.util.List;
import java.util.Set;

import javax.swing.GroupLayout;
import javax.swing.JButton;
import javax.swing.JComponent;
import javax.swing.JMenuItem;
import javax.swing.JPanel;
import javax.swing.JSeparator;
import javax.swing.LayoutStyle.ComponentPlacement;

/**
 * Common UI elements and layout for table export panels. Subclasses must (in
 * addition to requirements in {@link ToolPanel} and {@link KeplerPanel}):
 * <ol>
 * <li>Override either {@link #getPanel()} to provide a {@link JComponent} for
 * display or {@link #getPanels()} to return a sequence of {@link JComponent}s
 * for display.
 * <li>Override {@link #refresh()} to refresh the data in their initial
 * selection panels.
 * <li>Override {@link #readyForNext()} if they contain multiple panels.
 * <li>Override {@link #readyToExport()} to enable the Export button and
 * {@link #export()} to export the selected items.
 * <li>Call {@code super.updateEnabled()} if they override
 * {@link #updateEnabled()}.
 * </ol>
 * 
 * @author Bill Wohler
 */
public abstract class ExportTablePanel extends ToolPanel {

    private static final long serialVersionUID = 1L;

    protected static final String REFRESH = "refresh";
    protected static final String PREVIOUS = "previous";
    protected static final String NEXT = "next";
    protected static final String EXPORT = "export";
    protected static final String ENABLED = "Enabled";

    private boolean refreshEnabled;
    private boolean previousEnabled;
    private boolean nextEnabled;
    private boolean exportEnabled;

    private JComponent panel;
    private CardLayout cardLayout;
    private int panelIndex;
    private JButton refreshButton;
    private JButton prevButton;
    private JButton nextButton;
    private JButton exportButton;
    private Helper helper;

    /**
     * List of all actions. Note that adding an action here leads to the
     * creation of both menu items and buttons for it.
     */
    private static final String[] actions = new String[] { PREVIOUS, NEXT,
        DEFAULT_ACTION_CHAR + EXPORT };

    /**
     * Creates a {@link ExportTablePanel}.
     * 
     * @param helper a means for displaying help
     * @throws UiException if the panel could not be created
     */
    public ExportTablePanel(Helper helper) throws UiException {
        this.helper = helper;
    }

    @Override
    protected void initComponents() {
        GroupLayout layout = new GroupLayout(this);
        setLayout(layout);

        if (getPanels() != null) {
            panel = new JPanel();
            cardLayout = new CardLayout();
            panel.setLayout(cardLayout);
            for (JComponent element : getPanels()) {
                panel.add(element, element.toString());
            }
            cardLayout.first(panel);
        } else {
            panel = getPanel();
        }

        JPanel buttons = getButtons();

        JSeparator separator = new JSeparator();

        layout.setAutoCreateGaps(true);

        layout.setHorizontalGroup(layout.createSequentialGroup()
            .addGroup(
                layout.createParallelGroup()
                    .addComponent(panel, GroupLayout.PREFERRED_SIZE,
                        GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(separator, GroupLayout.Alignment.LEADING,
                        GroupLayout.DEFAULT_SIZE, GroupLayout.DEFAULT_SIZE,
                        Short.MAX_VALUE)
                    .addGroup(
                        layout.createSequentialGroup()
                            .addPreferredGap(ComponentPlacement.UNRELATED,
                                GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(buttons))));

        layout.setVerticalGroup(layout.createSequentialGroup()
            .addComponent(panel, GroupLayout.PREFERRED_SIZE,
                GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addPreferredGap(ComponentPlacement.UNRELATED,
                GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(separator, GroupLayout.PREFERRED_SIZE,
                GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
            .addPreferredGap(ComponentPlacement.UNRELATED)
            .addComponent(buttons));
    }

    /**
     * Creates previous, next, and export buttons.
     * 
     * @return a panel containing the buttons.
     */
    private JPanel getButtons() {
        JPanel panel = new JPanel();
        GroupLayout layout = new GroupLayout(panel);
        panel.setLayout(layout);

        refreshButton = new JButton();
        refreshButton.setAction(actionMap.get(REFRESH));
        prevButton = new JButton();
        prevButton.setAction(actionMap.get(PREVIOUS));
        nextButton = new JButton();
        nextButton.setAction(actionMap.get(NEXT));
        exportButton = new JButton();
        exportButton.setAction(actionMap.get(EXPORT));
        layout.linkSize(refreshButton, prevButton, nextButton, exportButton);

        if (getPanels() == null) {
            prevButton.setVisible(false);
            nextButton.setVisible(false);
        }

        layout.setAutoCreateGaps(true);
        layout.setHorizontalGroup(layout.createSequentialGroup()
            .addComponent(refreshButton)
            .addComponent(prevButton)
            .addComponent(nextButton)
            .addComponent(exportButton));

        layout.setVerticalGroup(layout.createParallelGroup()
            .addComponent(refreshButton)
            .addComponent(prevButton)
            .addComponent(nextButton)
            .addComponent(exportButton));

        return panel;
    }

    @Override
    protected void configureComponents() throws UiException {
        super.configureComponents();

        if (getPanels() == null) {
            // "Remove" the next and previous menu items which will just be
            // blank.
            for (Component component : getPopupMenu().getComponents()) {
                JMenuItem menuItem = (JMenuItem) component;
                if (menuItem.getText() == null) {
                    menuItem.setVisible(false);
                }
            }
        }
    }

    /**
     * Creates a panel for display. The default implementation returns
     * {@code null}. Only one of {@link #getPanel()} or {@link #getPanels()}
     * should be overridden.
     * 
     * @return a panel
     * @see #getPanels()
     */
    protected JComponent getPanel() {
        return panel;
    }

    /**
     * Returns a list of panels to display. The default implementation returns
     * {@code null}. Only one of {@link #getPanel()} or {@link #getPanels()}
     * should be overridden.
     * 
     * @return a list of panels
     * @see #getPanel()
     */
    protected List<JComponent> getPanels() {
        return null;
    }

    /**
     * Returns the currently visible panel.
     */
    protected JComponent currentPanel() {
        return getPanels() != null ? getPanels().get(panelIndex) : panel;
    }

    /**
     * Called by {@link #createUi()} to update the actions' enabled state.
     * Subclasses must call {@code super.updateEnabled()} to ensure that the
     * Export button is enabled properly.
     */
    @Override
    protected void updateEnabled() {
        setHelpText(null);
        setRefreshEnabled(true);
        setExportEnabled(true);
        if (getPanels() != null) {
            setPreviousEnabled(true);
            setNextEnabled(true);
        }
        if (!isUiInitializing()) {
            helper.contextHelp(getHelpText());
        }
    }

    @Override
    protected List<String> getActionStrings() {
        return Arrays.asList(actions);
    }

    /**
     * Displays the given panel. This provides a means for subclasses to skip
     * panels that are not needed in a particular context.
     */
    public void show(JComponent panel) {
        int index = getPanels().indexOf(panel);
        if (index < 0) {
            throw new IllegalArgumentException("This panel is not in the cards");
        }
        panelIndex = index;
        cardLayout.show(this.panel, getPanels().get(panelIndex)
            .toString());
        updateEnabled();
    }

    /**
     * Refreshes the data on the current panel. The refresh button is only
     * enabled for the first panel. Refreshing on later panels doesn't make
     * sense and causes problems since it clears the original selection of
     * items.
     */
    // @Action(enabledProperty = REFRESH + ENABLED)
    public abstract void refresh();

    public boolean isRefreshEnabled() {
        return refreshEnabled;
    }

    public void setRefreshEnabled(boolean refreshEnabled) {
        boolean oldValue = this.refreshEnabled;
        this.refreshEnabled = refreshEnabled && panelIndex == 0;
        firePropertyChange(REFRESH + ENABLED, oldValue, this.refreshEnabled);
    }

    /**
     * Displays the previous panel, if any.
     */
    // @Action(enabledProperty = PREVIOUS + ENABLED)
    public void previous() {
        cardLayout.show(panel, getPanels().get(--panelIndex)
            .toString());
        updateEnabled();
    }

    public boolean isPreviousEnabled() {
        return previousEnabled;
    }

    public void setPreviousEnabled(boolean previousEnabled) {
        boolean oldValue = this.previousEnabled;
        this.previousEnabled = previousEnabled && panelIndex > 0;
        firePropertyChange(PREVIOUS + ENABLED, oldValue, this.previousEnabled);
    }

    /**
     * Displays the next panel, if any.
     */
    // @Action(enabledProperty = NEXT + ENABLED)
    public void next() {
        cardLayout.show(panel, getPanels().get(++panelIndex)
            .toString());
        updateEnabled();
    }

    public boolean isNextEnabled() {
        return nextEnabled;
    }

    public void setNextEnabled(boolean nextEnabled) {
        boolean oldValue = this.nextEnabled;
        this.nextEnabled = nextEnabled && panelIndex < getPanels().size() - 1
            && readyForNext();
        firePropertyChange(NEXT + ENABLED, oldValue, this.nextEnabled);
    }

    /**
     * Checks whether the Next button can be enabled. By default, this method
     * returns {@code false}; subclasses with multiple panels should override
     * this method.
     * <p>
     * If {@code false} is returned, consider setting {@link #helpText} to
     * explain to the user why the Next button is disabled.
     * 
     * @return {@code true} if the Next button can be enabled; otherwise
     * {@code false}
     */
    protected boolean readyForNext() {
        return false;
    }

    /**
     * Performs the export action. Subclasses must mark this method with the
     * {@code @Action(enabledProperty = EXPORT + ENABLED)} annotation. The
     * constant {@link #EXPORT} contains the action's name which can be used for
     * resource lookup. Use
     * {@link KeplerDialogs#showSaveDirectoryChooserDialog(JComponent)} to query
     * the user for the export directory.
     */
    public abstract void export();

    public boolean isExportEnabled() {
        return exportEnabled;
    }

    public void setExportEnabled(boolean exportEnabled) {
        boolean oldValue = this.exportEnabled;
        this.exportEnabled = exportEnabled && readyToExport();
        firePropertyChange(EXPORT + ENABLED, oldValue, this.exportEnabled);
    }

    /**
     * Checks whether the Export button can be enabled.
     * 
     * @return {@code true} if the Export button can be enabled; otherwise
     * {@code false}
     */
    protected abstract boolean readyToExport();

    /**
     * Returns the export button.
     * 
     * @return the export button
     */
    protected JComponent getExportButton() {
        return exportButton;
    }

    protected int lowestAvailableExternalId(Set<Integer> externalIdsInUse,
        Set<Integer> uplinkedExternalIds) {

        // Find the lowest unused ID.
        for (int i = 1; i <= ExportTable.MAX_EXTERNAL_ID; i++) {
            if (!externalIdsInUse.contains(i)) {
                return i;
            }
        }

        // Find the lowest ID that hasn't been uplinked.
        for (int i = 1; i <= ExportTable.MAX_EXTERNAL_ID; i++) {
            if (!uplinkedExternalIds.contains(i)) {
                return i;
            }
        }

        // Game over.
        return ExportTable.INVALID_EXTERNAL_ID;
    }
}
