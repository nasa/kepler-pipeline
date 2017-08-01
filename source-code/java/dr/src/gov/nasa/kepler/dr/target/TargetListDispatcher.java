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

package gov.nasa.kepler.dr.target;

import gov.nasa.kepler.cm.TargetListImporter;
import gov.nasa.kepler.cm.TargetSelectionOperations;
import gov.nasa.kepler.dr.dispatch.Dispatcher;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapper;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetList.SourceType;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.DispatchLog;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * This dispatcher processes and stores target lists sent by the SO.
 * 
 * @author Miles Cote
 */
public class TargetListDispatcher implements Dispatcher {

    private static final String NEW_FILE_SUFFIX = ".new";

    private TargetSelectionCrud targetSelectionCrud;

    public TargetListDispatcher() {
    }

    @Override
    public void dispatch(Set<String> filenames, String sourceDirectory,
        DispatchLog dispatchLog, DispatcherWrapper dispatcherWrapper) {
        targetSelectionCrud = new TargetSelectionCrud(
            DatabaseServiceFactory.getInstance());

        for (String filename : filenames) {
            try {
                dispatcherWrapper.storeFile(filename);

                createTargetList(new File(sourceDirectory + File.separator
                    + filename));
            } catch (Exception e) {
                throw new PipelineException("Unable to process file: "
                    + filename, e);
            }
        }
    }

    private void createTargetList(File targetListFile) throws Exception {
        List<PlannedTarget> plannedTargets = new ArrayList<PlannedTarget>();

        String targetListName = targetListFile.getName();

        TargetList targetList = new TargetList(targetListName);

        if (targetListFile.exists()) {
            TargetListImporter importer = new TargetListImporter(targetList);
            List<PlannedTarget> targets = importer.ingestTargetFile(targetListFile.getAbsolutePath());
            plannedTargets.addAll(targets);

            String category = importer.getCategory();
            if (category == null) {
                throw new IllegalArgumentException(
                    "The category must not be null.  Is there a category specified on the first line "
                        + "of the target list file?\n  targetListFile: "
                        + targetListFile);
            }

            targetList.setCategory(category);
            targetList.setSource(targetListFile.getAbsolutePath());
            targetList.setSourceType(SourceType.FILE);

            // Export the file.
            Map<String, String> targetListFields = new HashMap<String, String>();
            targetListFields.put(TargetListImporter.CATEGORY_LABEL, category);
            export(targets, targetListFields,
                new File(targetListFile.getAbsolutePath() + NEW_FILE_SUFFIX));
        } else {
            throw new IllegalArgumentException(targetListFile
                + ": no such file");
        }

        targetSelectionCrud.create(targetList);
        targetSelectionCrud.create(plannedTargets);
    }

    private void export(List<PlannedTarget> targets,
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

}
