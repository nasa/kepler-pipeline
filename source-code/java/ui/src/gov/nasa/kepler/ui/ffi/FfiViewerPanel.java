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

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.mc.fc.FfiOperations;
import gov.nasa.kepler.ui.common.DatabaseTask;
import gov.nasa.kepler.ui.common.StatusEvent;
import gov.nasa.kepler.ui.common.UiException;
import gov.nasa.kepler.ui.swing.KeplerDialogs;
import gov.nasa.kepler.ui.swing.KeplerInputBlocker;
import gov.nasa.kepler.ui.swing.PanelHeader;
import gov.nasa.kepler.ui.swing.ToolPanel;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.swing.GroupLayout;
import javax.swing.GroupLayout.Alignment;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFileChooser;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JSeparator;
import javax.swing.LayoutStyle.ComponentPlacement;
import javax.swing.filechooser.FileNameExtensionFilter;

import org.bushe.swing.event.EventBus;
import org.bushe.swing.event.EventSubscriber;
import org.jdesktop.application.Action;
import org.jdesktop.application.Task;
import org.jdesktop.application.Task.BlockingScope;

@SuppressWarnings("serial")
public class FfiViewerPanel extends ToolPanel {
    private static final String NAME = "ffiViewerPanel";

    private static final String LOAD_FFI = "loadFfi";
    private static final String LOAD_LOCAL_FFI = "loadLocalFfi";
    private static final String DISPLAY_OUTPUT_DS9 = "displayCcdOutput";
    private static final String DISPLAY_OUTPUT_FTOOLS = "displayFilteredCcdOutput";
    private static final String CLEAR_ALL = "clearAll";
    private static final String SELECT_ALL = "selectAll";
    private static final String SAVE_TO_LOCAL = "saveToLocal";

    /**
     * List of all actions. Note that adding an action here leads to the
     * creation of both menu items and buttons for it.
     */
    private static final String[] actions = new String[] {
        DEFAULT_ACTION_CHAR + DISPLAY_OUTPUT_DS9, DISPLAY_OUTPUT_FTOOLS,
        CLEAR_ALL, SELECT_ALL, SAVE_TO_LOCAL };

    private static final String DISPLAY_ENABLED = "displayEnabled";
    private static final String FFI_SAVE_ENABLED = "ffiSaveEnabled";

    // Bound properties.
    private boolean displayEnabled;
    private boolean ffiSaveEnabled;

    private File workingFfiCopy;
    private KeplerFov keplerFov;
    private Set<CcdOutput> selectedCcdOutputs;
    private EventSubscriber<CcdOutput> ccdOutputListener;
    private boolean isFfiLoaded = false;
    private JComboBox ffiNameComboBox;
    private String ffiName;
    final JFileChooser fileChooser = new JFileChooser();
    private String fselectExpr = "x > 100 && y < 256 && value > 1000";

    /**
     * Creates a {@link FfiViewerPanel}.
     * 
     * @throws UiException if the panel could not be created
     */
    public FfiViewerPanel() throws UiException {
        selectedCcdOutputs = new HashSet<CcdOutput>();
        setName(NAME);
        keplerFov = new KeplerFov(this);
        createUi();
    }

    @Override
    protected List<String> getActionStrings() {
        return Arrays.asList(actions);
    }

    public KeplerFov getKeplerFov() {
        return keplerFov;
    }

    public void setKeplerFov(KeplerFov keplerFov) {
        this.keplerFov = keplerFov;
    }

    public boolean isFfiLoaded() {
        return isFfiLoaded;
    }

    public void setFfiLoaded(boolean isFfiLoaded) {
        this.isFfiLoaded = isFfiLoaded;
    }

    public String getFselectExpr() {
        return fselectExpr;
    }

    public void setFselectExpr(String fselectExpr) {
        this.fselectExpr = fselectExpr;
    }

    @Override
    protected void updateEnabled() {
        setFfiSaveEnabled(isFfiLoaded());
        setDisplayEnabled(isFfiLoaded());
    }

    public boolean isDisplayEnabled() {
        return displayEnabled;
    }

    public void setDisplayEnabled(boolean displayEnabled) {
        keplerFov.setEnabled(displayEnabled); // changes ccdOutput color
        // member variables
        boolean oldValue = this.displayEnabled;

        this.displayEnabled = displayEnabled && isFfiLoaded
            && selectedCcdOutputs.size() > 0;

        firePropertyChange(DISPLAY_ENABLED, oldValue, this.displayEnabled);
        repaint(); // TODO Why is this repaint here?
        // (abs coords9 in ccdOutput)
    }

    public String getFfiName() {
        return ffiName;
    }

    public void setFfiName(String ffiName) {
        this.ffiName = ffiName;
    }

    public boolean isFfiSaveEnabled() {
        return ffiSaveEnabled;
    }

    public void setFfiSaveEnabled(boolean ffiSaveEnabled) {
        boolean oldValue = this.ffiSaveEnabled;

        this.ffiSaveEnabled = ffiSaveEnabled && isFfiLoaded;

        firePropertyChange(FFI_SAVE_ENABLED, oldValue, this.ffiSaveEnabled);
        repaint(); // TODO Why is this repaint here?
        // (abs coords in ccdOutput)
    }

    @Override
    protected void initComponents() throws UiException {
        PanelHeader panelHeader = new PanelHeader();
        panelHeader.setName("header");

        final JButton loadFfiButton = new JButton(actionMap.get(LOAD_FFI));
        final JButton loadLocalFfiButton = new JButton(
            actionMap.get(LOAD_LOCAL_FFI));
        final JLabel ffiNameLabel = new JLabel(
            "Pick filestore FFI, or load local FFI:");

        ffiNameComboBox = new JComboBox();

        final JSeparator separator = new JSeparator();
        final JButton displayDs9Button = new JButton(
            actionMap.get(DISPLAY_OUTPUT_DS9));
        final JButton displayFtoolsButton = new JButton(
            actionMap.get(DISPLAY_OUTPUT_FTOOLS));
        final JButton clearAllButton = new JButton(actionMap.get(CLEAR_ALL));
        final JButton selectAllButton = new JButton(actionMap.get(SELECT_ALL));
        final JButton saveToLocalButton = new JButton(
            actionMap.get(SAVE_TO_LOCAL));

        JPanel panel = new JPanel();
        GroupLayout layout = new GroupLayout(panel);
        panel.setLayout(layout);
        layout.setAutoCreateGaps(true);
        layout.setAutoCreateContainerGaps(true);

        layout.linkSize(displayDs9Button, displayFtoolsButton);
        layout.linkSize(clearAllButton, selectAllButton, saveToLocalButton);

        layout.setHorizontalGroup(layout.createParallelGroup()
            .addGroup(layout.createSequentialGroup()
                .addComponent(ffiNameLabel)
                .addComponent(ffiNameComboBox)
                .addComponent(loadFfiButton)
                .addComponent(loadLocalFfiButton))
            .addComponent(separator)
            .addComponent(keplerFov)
            .addGroup(layout.createSequentialGroup()
                .addComponent(displayDs9Button)
                .addComponent(displayFtoolsButton))
            .addGroup(layout.createSequentialGroup()
                .addComponent(clearAllButton)
                .addComponent(selectAllButton)
                .addComponent(saveToLocalButton)));

        layout.setVerticalGroup(layout.createSequentialGroup()
            .addGroup(
                layout.createParallelGroup(Alignment.BASELINE)
                    .addComponent(ffiNameComboBox, GroupLayout.DEFAULT_SIZE,
                        GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
                    .addComponent(ffiNameLabel)
                    .addComponent(loadFfiButton)
                    .addComponent(loadLocalFfiButton))
            .addPreferredGap(ComponentPlacement.UNRELATED)
            .addComponent(separator, GroupLayout.DEFAULT_SIZE,
                GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
            .addPreferredGap(ComponentPlacement.UNRELATED)
            .addComponent(keplerFov)
            .addGroup(layout.createParallelGroup(Alignment.BASELINE)
                .addComponent(displayDs9Button)
                .addComponent(displayFtoolsButton))
            .addGroup(layout.createParallelGroup(Alignment.BASELINE)
                .addComponent(clearAllButton)
                .addComponent(selectAllButton)
                .addComponent(saveToLocalButton))

            .addPreferredGap(ComponentPlacement.UNRELATED,
                GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE));

        GroupLayout panelLayout = new GroupLayout(this);
        setLayout(panelLayout);

        panelLayout.setHorizontalGroup(panelLayout.createParallelGroup()
            .addComponent(panelHeader)
            .addComponent(panel));
        panelLayout.setVerticalGroup(panelLayout.createSequentialGroup()
            .addComponent(panelHeader)
            .addComponent(panel));
    }

    @Override
    protected void configureComponents() throws UiException {
        // Ensure drop-down combination box has right height.
        ffiNameComboBox.setPrototypeDisplayValue("");
    }

    @Override
    protected void addListeners() throws UiException {
        ccdOutputListener = new EventSubscriber<CcdOutput>() {
            @Override
            public void onEvent(CcdOutput ccdOutput) {
                if (isFfiLoaded()) {
                    if (ccdOutput.isSelected()) {
                        selectedCcdOutputs.add(ccdOutput);
                    } else {
                        selectedCcdOutputs.remove(ccdOutput);
                    }

                    if (ccdOutput.isDoActionNow()) {
                        ccdOutput.setDoActionNow(false);
                        displayCcdOutput();
                    }
                } else {
                    ccdOutput.setSelected(false);
                }

                updateEnabled();
                repaint(); // TODO Why is this repaint here?
                // (abs coords in ccdOutput)
            }
        };
        EventBus.subscribe(CcdOutput.class, ccdOutputListener);
    }

    @Override
    protected void getData(boolean block) {
        executeDatabaseTask(FfiListLoadTask.NAME, new FfiListLoadTask());
    }

    @Action
    public FfiLoadTask loadFfi() {
        if (null == ffiNameComboBox.getSelectedItem() && warnUser(LOAD_FFI)) {
            return null;
        }
        FfiLoadTask task = new FfiLoadTask();
        task.setInputBlocker(new KeplerInputBlocker(resourceMap, LOAD_FFI,
            task, BlockingScope.WINDOW, this));
        clearAll();

        return task;
    }

    @Action
    public FfiLoadLocalTask loadLocalFfi() {
        FfiLoadLocalTask task = new FfiLoadLocalTask();
        task.setInputBlocker(new KeplerInputBlocker(resourceMap,
            LOAD_LOCAL_FFI, task, BlockingScope.WINDOW, this));
        clearAll();

        return task;
    }

    @Action(enabledProperty = DISPLAY_ENABLED)
    public void displayCcdOutput() {
        runShellCommands(getCommands("ds9"));
    }

    @Action(enabledProperty = DISPLAY_ENABLED)
    public void displayFilteredCcdOutput() {
        runShellCommands(getCommands("ftools"));
    }

    @Action(enabledProperty = DISPLAY_ENABLED)
    public void clearAll() {
        keplerFov.setSelected(false);
        selectedCcdOutputs.clear();
        updateEnabled();
        repaint(); // TODO Why is this repaint here?
        // (abs coords in ccdOutput)
    }

    @Action(enabledProperty = FFI_SAVE_ENABLED)
    public void selectAll() {
        keplerFov.setSelected(true);
        selectedCcdOutputs.addAll(keplerFov.getCcdOutputs());
        updateEnabled();
        repaint(); // TODO Why is this repaint here?
        // (abs coords in ccdOutput)
    }

    @Action(enabledProperty = FFI_SAVE_ENABLED)
    public SaveToLocalTask saveToLocal() {
        File destFile = KeplerDialogs.showSaveFileChooserDialog(this,
            new FileNameExtensionFilter("FITS Files", "fits", "fts"));
        if (destFile == null) {
            return null;
        }
        SaveToLocalTask task = new SaveToLocalTask(destFile);
        task.setInputBlocker(new KeplerInputBlocker(resourceMap, SAVE_TO_LOCAL,
            task, BlockingScope.WINDOW, this));

        return task;
    }

    private void runShellCommands(List<String> commands) {
        repaint(); // TODO Why is this repaint here?
        // (abs coords9 in ccdOutput)

        if (0 == selectedCcdOutputs.size()) {
            return;
        }

        // Give user an option to bail out if there are a lot of selected
        // images.
        if (commands.size() > 10 && warnUser(DISPLAY_OUTPUT_DS9)) {
            return;
        }

        // Run the commands:
        try {
            for (String command : commands) {
                log.info(command);
                String[] execArr = { "/bin/sh", "-c", command };
                Runtime.getRuntime()
                    .exec(execArr);
            }
        } catch (IOException e) {
            handleError(e, DISPLAY_OUTPUT_DS9);
        }
    }

    private List<String> getCommands(String type) {
        List<String> commands = new ArrayList<String>();

        if (type.equals("ftools")) {
            String userFselectExpr = (String) KeplerDialogs.showInputDialog(
                this,
                resourceMap.getString(DISPLAY_OUTPUT_FTOOLS + ".Action.text"),
                resourceMap.getString(DISPLAY_OUTPUT_FTOOLS + ".text"), null,
                getFselectExpr());
            if (userFselectExpr == null) {
                log.info(resourceMap.getString(DISPLAY_OUTPUT_FTOOLS
                    + ".cancelled"));
                return commands;
            }
            setFselectExpr(userFselectExpr);
        }

        for (CcdOutput ccdOutput : selectedCcdOutputs) {
            String command = "";
            if (type.equals("ds9")) {
                command = "dist/ui/bin/ds9 -scale log -cmap bb -zoom to fit '"
                    + workingFfiCopy.getAbsolutePath()
                    + "["
                    + FcConstants.getHdu(ccdOutput.getModule(),
                        ccdOutput.getOutput()) + "]'";
            } else if (type.equals("ftools")) {

                command = ". dist/ui/bin/ftools-libc2.2.4/headas-init.sh && "
                    + "dist/ui/bin/ftools-libc2.2.4/bin/fim2lst infile='"
                    + workingFfiCopy.getAbsolutePath()
                    + "["
                    + FcConstants.getHdu(ccdOutput.getModule(),
                        ccdOutput.getOutput())
                    + "]' outfil=-  | "
                    + "dist/ui/bin/ftools-libc2.2.4/bin/fselect - - '"
                    + getFselectExpr()
                    + "' | "
                    + "dist/ui/bin/ftools-libc2.2.4/bin/fcopy '-[bin x,y;value]' - | "
                    + "dist/ui/bin/ds9 -scale log -cmap bb -zoom to fit  -";
            }
            commands.add(command);
        }
        return commands;
    }

    /**
     * A task for loading a list of FFIs from the database.
     * 
     * @author Bill Wohler
     */
    private class FfiListLoadTask extends DatabaseTask<List<String>, Void> {

        private static final String NAME = "FfiListLoadTask";

        public FfiListLoadTask() {
        }

        @Override
        protected List<String> doInBackground() throws Exception {
            return new FfiOperations().getFfiList();
        }

        @Override
        protected void succeeded(List<String> ffiNames) {
            for (String ffiName : ffiNames) {
                ffiNameComboBox.addItem(ffiName);
            }
        }
    }

    /**
     * A task for loading FFIs from the filestore in the background.
     * 
     * @author Kester Allen
     */
    private class FfiLoadTask extends Task<Object, Void> {

        public FfiLoadTask() {
            super(app);
            setFfiName(ffiNameComboBox.getSelectedItem()
                .toString());
        }

        @Override
        protected Object doInBackground() throws Exception {
            EventBus.publish(new StatusEvent(FfiViewerPanel.this).message(
                resourceMap.getString(LOAD_FFI + ".loading"))
                .started());

            workingFfiCopy = new File(Filenames.BUILD_TMP, "ffiv.fits");
            new FfiOperations().copyFfiToLocal(getFfiName(), workingFfiCopy);
            return null;
        }

        @Override
        protected void succeeded(Object result) {
            EventBus.publish(new StatusEvent(this).message("Starting to load FFI"));
            setFfiLoaded(true);
            updateEnabled();
            EventBus.publish(new StatusEvent(FfiViewerPanel.this).message(
                resourceMap.getString(LOAD_FFI + ".loaded", getFfiName()))
                .started());
        }

        @Override
        protected void failed(Throwable cause) {
            EventBus.publish(new StatusEvent(this).message("Loading FFI failed"));
            setFfiLoaded(false);
            handleError(cause, LOAD_FFI, fileChooser.getSelectedFile());
            updateEnabled();
        }

        @Override
        protected void interrupted(InterruptedException e) {
            failed(e);
        }
    }

    /**
     * A task for loading FFIs from the local disk in the background.
     * 
     * @author Kester Allen
     */
    private class FfiLoadLocalTask extends Task<Object, Void> {

        File file;

        public FfiLoadLocalTask() {
            super(app);
            file = KeplerDialogs.showFileChooserDialog(FfiViewerPanel.this);
            setFfiName(file.toString());
        }

        @Override
        protected Object doInBackground() throws Exception {
            EventBus.publish(new StatusEvent(FfiViewerPanel.this).message(
                resourceMap.getString(LOAD_LOCAL_FFI + ".loading"))
                .started());

            workingFfiCopy = new File(Filenames.BUILD_TMP, "ffiv.fits");
            String cmd = "cp " + getFfiName() + " " + workingFfiCopy;
            Runtime.getRuntime()
                .exec(cmd);
            return null;
        }

        @Override
        protected void succeeded(Object result) {
            EventBus.publish(new StatusEvent(this).message("Starting to load local FFI"));
            setFfiLoaded(true);
            updateEnabled();
            EventBus.publish(new StatusEvent(FfiViewerPanel.this).message(
                resourceMap.getString(LOAD_LOCAL_FFI + ".loaded", getFfiName()))
                .started());
        }

        @Override
        protected void failed(Throwable cause) {
            EventBus.publish(new StatusEvent(this).message("Loading local FFI failed"));
            setFfiLoaded(false);
            handleError(cause, LOAD_LOCAL_FFI, fileChooser.getSelectedFile());
            updateEnabled();
        }

        @Override
        protected void interrupted(InterruptedException e) {
            failed(e);
        }
    }

    /**
     * A task for loading FFIs from the filestore in the background.
     * 
     * @author Kester Allen
     */
    private class SaveToLocalTask extends Task<Object, Void> {
        File destFile;

        public SaveToLocalTask(File destFile) {
            super(app);
            this.destFile = destFile;
            setFfiName(ffiNameComboBox.getSelectedItem()
                .toString());
        }

        @Override
        protected Object doInBackground() throws Exception {
            EventBus.publish(new StatusEvent(FfiViewerPanel.this).message(
                resourceMap.getString(SAVE_TO_LOCAL + ".loading"))
                .started());

            new FfiOperations().copyFfiToLocal(getFfiName(), destFile);

            return null;
        }

        @Override
        protected void succeeded(Object result) {
            EventBus.publish(new StatusEvent(this).message("Starting to load FFI"));
            setFfiLoaded(true);
            updateEnabled();
            EventBus.publish(new StatusEvent(FfiViewerPanel.this).message(
                resourceMap.getString(SAVE_TO_LOCAL + ".loaded"))
                .started());
        }

        @Override
        protected void failed(Throwable cause) {
            EventBus.publish(new StatusEvent(this).message("Loading FFI failed"));
            setFfiLoaded(false);
            handleError(cause, SAVE_TO_LOCAL, fileChooser.getSelectedFile());
            updateEnabled();
        }

        @Override
        protected void interrupted(InterruptedException e) {
            failed(e);
        }
    }

}
