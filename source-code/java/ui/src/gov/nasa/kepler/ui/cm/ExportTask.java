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

package gov.nasa.kepler.ui.cm;

import gov.nasa.kepler.cm.TargetSelectionOperations;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.ui.common.DatabaseTask;
import gov.nasa.kepler.ui.swing.KeplerPanel;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.jdesktop.application.ResourceMap;
import org.jdesktop.application.Task;

/**
 * A task for exporting a target list. Use the
 * {@link ExportTask#ExportTask(KeplerPanel, ResourceMap, String, TargetList, File)}
 * constructor and define a number of resources in addition to the normal
 * {@link Task} resources--examples of all are given here:
 * 
 * <pre>
 *   export.failed=Could not export target list
 *   export.failed.secondary=%s.${exit}
 *   export.BlockingDialog.title=Exporting Target List
 *   export.BlockingDialog.optionPane.message=Exporting target list.\n\
 *      Please wait...
 *   export.exporting=Exporting targets into %s
 *   export.loaded=Loaded %d targets in %d ms
 *   export.exported=Exported %d targets in %d ms
 *   export.cancelled=Export cancelled by user
 * </pre>
 * 
 * Other database tasks which need to export a target list can call
 * {@link #export(List, Map, File)} directly and use the
 * {@link ExportTask#ExportTask()} constructor. No additional resources are
 * needed as the {@code export} method does not make use of any.
 * 
 * @see KeplerPanel#handleError(Throwable, String, Object[])
 * 
 * @author Bill Wohler
 */
public class ExportTask extends DatabaseTask<Void, Void> {
    private static final Log log = LogFactory.getLog(ExportTask.class);

    private static final String CATEGORY = "Category";

    private KeplerPanel panel;
    private String resourcePrefix; // copy because not accessible from Task
    private ResourceMap resourceMap; // Task constructor deprecated
    private TargetList targetList;
    private File file;

    /**
     * Creates a {@link ExportTask}. This constructor differs from
     * {@link #ExportTask(KeplerPanel, ResourceMap, String, TargetList, File)}
     * in that it expects the client to call {@link #export(List, Map, File)}.
     */
    public ExportTask() {
    }

    /**
     * Creates a {@link ExportTask}.
     * 
     * @param panel the calling panel which is the target of progress or error
     * dialogs
     * @param resourceMap the resource map which contains the task's resources
     * @param resourcePrefix the prefix of said resources
     * @param targetList the target list to export
     * @param file the output file
     * @throws NullPointerException if any of the arguments are {@code null}
     */
    public ExportTask(KeplerPanel panel, ResourceMap resourceMap,
        String resourcePrefix, TargetList targetList, File file) {

        if (panel == null) {
            throw new NullPointerException("panel can't be null");
        }
        if (resourceMap == null) {
            throw new NullPointerException("resourceMap can't be null");
        }
        if (resourcePrefix == null) {
            throw new NullPointerException("resourcePrefix can't be null");
        }
        if (targetList == null) {
            throw new NullPointerException("targetList can't be null");
        }
        if (file == null) {
            throw new NullPointerException("file can't be null");
        }

        this.panel = panel;
        this.resourceMap = resourceMap;
        this.resourcePrefix = resourcePrefix;
        this.targetList = targetList;
        this.file = file;
    }

    @Override
    protected Void doInBackground() throws Exception {
        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();

        long start = System.currentTimeMillis();
        List<PlannedTarget> targets = targetSelectionCrud.retrievePlannedTargets(targetList);
        log.info(resourceMap.getString(resourcePrefix + ".loaded",
            targets.size(), System.currentTimeMillis() - start));

        start = System.currentTimeMillis();
        log.info(resourceMap.getString(resourcePrefix + ".exporting",
            file.getAbsolutePath()));
        Map<String, String> targetListFields = new HashMap<String, String>();
        targetListFields.put(CATEGORY, targetList.getCategory());
        export(targets, targetListFields, file);
        log.info(resourceMap.getString(resourcePrefix + ".exported",
            targets.size(), System.currentTimeMillis() - start));

        return null;
    }

    /**
     * Exports the given list of {@link PlannedTarget}s to the given file.
     * 
     * @param targets the list of targets to export
     * @param targetListFields target list fields to prepend to the file. Can be
     * {@code null} if none are desired. The key is the label. If a trailing
     * colon is present in the label, it is used; otherwise, one is added. The
     * value is the category itself. For example, if the key is "Category" and
     * the value is "Planet Detection Targets", then "Category: Planet Detection
     * Targets" will be written to the file
     * @param file the output file
     * @throws NullPointerException if any of the arguments are {@code null}
     * @throws IOException if there were problems opening or writing the file
     */
    public void export(List<PlannedTarget> targets,
        Map<String, String> targetListFields, File file) throws IOException {

        if (targets == null) {
            throw new NullPointerException("targets can't be null");
        }
        if (file == null) {
            throw new NullPointerException("file can't be null");
        }
        TargetSelectionOperations targetSelectionOperations = new TargetSelectionOperations();

        BufferedWriter bw = new BufferedWriter(new FileWriter(file));

        // Add fields.
        if (targetListFields != null) {
            for (Map.Entry<String, String> entry : targetListFields.entrySet()) {
                String label = entry.getKey();
                if (!label.endsWith(":")) {
                    label = label + ":";
                }
                bw.write(label.trim());
                bw.write(" ");
                String field = entry.getValue();
                if (field == null) {
                    field = "";
                }
                bw.write(field.trim());
                bw.write("\n");
            }
        }

        // Add targets.
        for (PlannedTarget target : targets) {
            bw.write(targetSelectionOperations.targetToString(target));
            bw.write("\n");
        }
        bw.close();
    }

    @Override
    protected void handleFatalError(Throwable e) {
        panel.handleError(e, resourcePrefix);
    }

    @Override
    protected void cancelled() {
        log.info(resourceMap.getString(resourcePrefix + ".cancelled"));
        super.cancelled();
    }
}
