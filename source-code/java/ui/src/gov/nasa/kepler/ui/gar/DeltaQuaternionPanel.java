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

import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.pdq.AttitudeAdjustment;
import gov.nasa.kepler.ui.common.DatabaseTask;
import gov.nasa.kepler.ui.common.StatusEvent;
import gov.nasa.kepler.ui.common.UiException;
import gov.nasa.kepler.ui.gar.TableExportPanel.Helper;
import gov.nasa.kepler.ui.proxy.AttitudeAdjustmentExporterProxy;
import gov.nasa.kepler.ui.proxy.PdqCrudProxy;
import gov.nasa.kepler.ui.swing.KeplerDialogs;
import gov.nasa.kepler.ui.swing.ToolTable;

import java.awt.Font;
import java.io.File;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.swing.GroupLayout;
import javax.swing.JComponent;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.ListSelectionModel;

import org.bushe.swing.event.EventBus;
import org.bushe.swing.event.EventTopicSubscriber;
import org.jdesktop.application.Action;

/**
 * Exports delta quaternions.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
public class DeltaQuaternionPanel extends ExportTablePanel {

    /** Number of the most recent delta quaternions to display to user. */
    private static final int DELTA_QUATERNION_DISPLAY_COUNT = 10;

    private ToolTable table;
    private DeltaQuaternionTableModel tableModel;

    private AttitudeAdjustment attitudeAdjustment;
    private EventTopicSubscriber attitudeAdjustmentListener;

    /**
     * Creates a {@link DeltaQuaternionPanel}.
     * 
     * @param helper a means for displaying help
     * @throws UiException if the panel could not be created
     */
    public DeltaQuaternionPanel(Helper helper) throws UiException {
        super(helper);
        createUi();
    }

    @Override
    public String toString() {
        return resourceMap.getString("listEntry");
    }

    @Override
    protected JComponent getPanel() {
        JPanel panel = new JPanel();

        JLabel deltaQuaternionTableLabel = new JLabel();
        deltaQuaternionTableLabel.setName("deltaQuaternionTableLabel");
        deltaQuaternionTableLabel.setFont(deltaQuaternionTableLabel.getFont()
            .deriveFont(Font.BOLD));

        table = new ToolTable(this);
        JScrollPane scrollPane = new JScrollPane(table);

        GroupLayout layout = new GroupLayout(panel);
        panel.setLayout(layout);
        layout.setAutoCreateGaps(true);

        layout.setHorizontalGroup(layout.createParallelGroup()
            .addComponent(deltaQuaternionTableLabel)
            .addComponent(scrollPane));

        layout.setVerticalGroup(layout.createSequentialGroup()
            .addComponent(deltaQuaternionTableLabel)
            .addComponent(scrollPane));

        return panel;
    }

    @Override
    protected void configureComponents() throws UiException {
        super.configureComponents();
        table.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        table.setTimeDisplayed(true);
        tableModel = new DeltaQuaternionTableModel();
        table.setModel(tableModel);
    }

    @Override
    protected void addListeners() throws UiException {
        super.addListeners();
        attitudeAdjustmentListener = new EventTopicSubscriber() {
            @Override
            public void onEvent(String topic, Object data) {
                log.debug("topic=" + topic + ", data=" + data);
                @SuppressWarnings("rawtypes")
                List list = (List) data;
                if (list.size() > 0) {
                    attitudeAdjustment = (AttitudeAdjustment) list.get(0);
                }
                updateEnabled();
            }
        };
        EventBus.subscribe(table.getSelectionTopic(),
            attitudeAdjustmentListener);
    }

    @Override
    protected void getData(boolean block) {
        super.getData(block);
        executeDatabaseTask(DeltaQuaternionLoadTask.NAME,
            new DeltaQuaternionLoadTask());
    }

    @Override
    protected boolean readyToExport() {
        return conditionalHelp(attitudeAdjustment != null,
            "selectDeltaQuaternion.help");
    }

    @Override
    @Action(enabledProperty = REFRESH + ENABLED)
    public void refresh() {
        log.info(resourceMap.getString(REFRESH));
        getData(false);
    }

    @Override
    @Action(enabledProperty = EXPORT + ENABLED)
    public void export() {
        log.info(resourceMap.getString(EXPORT, attitudeAdjustment.getId()));
        if (reloadingData()) {
            handleError(null, EXPORT + RELOADING_DATA);
            return;
        }

        try {
            File file = KeplerDialogs.showSaveDirectoryChooserDialog(this);
            if (file == null) {
                return;
            }
            if (!file.canWrite()) {
                throw new IllegalArgumentException(resourceMap.getString(EXPORT
                    + ".cantWrite", file));
            }

            executeDatabaseTask(EXPORT, new ExportTask(file));
        } catch (Exception e) {
            handleError(this, e, EXPORT, attitudeAdjustment.getId());
        }
    }

    /**
     * A task for loading delta quaternion entries from the database in the
     * background.
     * 
     * @author Bill Wohler
     */
    private class DeltaQuaternionLoadTask extends
        DatabaseTask<List<AttitudeAdjustment>, Void> {

        private static final String NAME = "DeltaQuaternionLoadTask";
        private List<Date> dates;

        @Override
        protected List<AttitudeAdjustment> doInBackground() throws Exception {
            log.info(resourceMap.getString(NAME + ".loading"));
            EventBus.publish(new StatusEvent(DeltaQuaternionPanel.this).message(
                resourceMap.getString(NAME + ".retrieving"))
                .started());

            // First, get the delta quaternions and then convert
            // refPixelFileTime (currently in VTC) to Date.
            DatabaseServiceFactory.getInstance()
                .evictAll(tableModel.getDeltaQuaternions());
            PdqCrudProxy pdqCrud = new PdqCrudProxy();
            List<AttitudeAdjustment> attitudeAdjustments = pdqCrud.retrieveLatestAttitudeAdjustments(DELTA_QUATERNION_DISPLAY_COUNT);
            dates = convertStartTime(attitudeAdjustments);
            log.info(resourceMap.getString(NAME + ".loaded",
                attitudeAdjustments.size()));

            return attitudeAdjustments;
        }

        private List<Date> convertStartTime(
            List<AttitudeAdjustment> attitudeAdjustments) {

            List<Date> dates = new ArrayList<Date>();
            for (AttitudeAdjustment attitudeAdjustment : attitudeAdjustments) {
                Date date = ModifiedJulianDate.mjdToDate(attitudeAdjustment.getRefPixelLog()
                    .getMjd());
                dates.add(date);
            }

            return dates;
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleError(DeltaQuaternionPanel.this, e, NAME);
            EventBus.publish(new StatusEvent(DeltaQuaternionPanel.this).message(
                resourceMap.getString(NAME + ".retrieving"))
                .failed());
        }

        @Override
        protected void succeeded(List<AttitudeAdjustment> result) {
            tableModel.setDeltaQuaternions(result, dates);
            if (result.size() > 0) {
                table.getSelectionModel()
                    .setSelectionInterval(0, 0);
            }
            setDataValid(true);

            EventBus.publish(new StatusEvent(DeltaQuaternionPanel.this).message(
                resourceMap.getString(NAME + ".retrieving"))
                .done());
        }
    }

    /**
     * A task for exporting delta quaternion tables. Note that this class
     * updates the {@code attitudeAdjustment} field, so this task must block the
     * UI!
     * 
     * @author Bill Wohler
     */
    private class ExportTask extends DatabaseTask<File, Void> {

        private File file;

        public ExportTask(File file) {
            this.file = file;
            setUserCanCancel(false);
        }

        @Override
        protected File doInBackground() throws Exception {
            log.info(resourceMap.getString(EXPORT + ".exporting"));

            AttitudeAdjustmentExporterProxy exporter = new AttitudeAdjustmentExporterProxy();
            file = exporter.export(file.getAbsolutePath(), attitudeAdjustment);
            log.info(resourceMap.getString(EXPORT + ".exported", file));

            return file;
        }

        @Override
        protected void handleFatalError(Throwable cause) {
            handleError(DeltaQuaternionPanel.this, cause, EXPORT,
                attitudeAdjustment.getId());
        }

        @Override
        protected void interrupted(InterruptedException e) {
            failed(e);
        }

        @Override
        protected void succeeded(File file) {
            EventBus.publish(new StatusEvent(this).message(resourceMap.getString(
                EXPORT + ".exported", file)));
        }
    }
}
