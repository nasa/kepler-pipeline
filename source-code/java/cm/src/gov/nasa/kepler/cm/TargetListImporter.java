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

package gov.nasa.kepler.cm;

import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.TargetList;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.HibernateException;

/**
 * Imports target lists.
 * <p>
 * The {@link #ingestTargetFile(String)} method can be used on one line as
 * follows:
 * 
 * <pre>
 * targets = new ImportTask(targetList).ingestTargetFile(&quot;/path/to/targetFile&quot;);
 * </pre>
 * 
 * However, if the category is desired,
 * 
 * <pre>
 * TargetListImporter importer = new TargetListImporter(targetList);
 * List&lt;PlannedTarget&gt; targets = importer.ingestTargetFile(&quot;/path/to/targetFile&quot;);
 * System.out.println(importer.getCategory());
 * </pre>
 * 
 * See also {@link #setTreatCustomTargetsAsNew(boolean)} and
 * {@link #setImportingTargetList(boolean)} to change the behavior of the
 * {@link #ingestTargetFile(String)} method.
 * 
 * @author Bill Wohler
 */
public class TargetListImporter {
    private static final Log log = LogFactory.getLog(TargetListImporter.class);

    public static final String COMMENT_CHAR = "#";
    public static final String CATEGORY_LABEL = "Category:";

    private static final int MAX_FILE_ERRORS = 100;

    private TargetSelectionOperations targetSelectionOperations = new TargetSelectionOperations();
    private ProgressHandler progressHandler;

    private TargetList targetList;
    private String category;
    private boolean skipMissingKeplerIds;
    private boolean treatCustomTargetsAsNew;
    private boolean importingTargetList = true;
    private boolean canceled;

    /**
     * Creates a {@link TargetListImporter}.
     */
    public TargetListImporter() {
    }

    /**
     * Creates a {@link TargetListImporter}.
     * 
     * @param targetList the destination target list
     */
    public TargetListImporter(TargetList targetList) {
        this.targetList = targetList;
    }

    /**
     * Returns the category read from the import file. Returns {@code null} if
     * the file does not contain a Category label.
     */
    public String getCategory() {
        return category;
    }

    /**
     * If {@code skip} is {@code true}, don't consider Kepler IDs that are
     * missing from the database to be an error. Instead, IDs that aren't found
     * are logged and the planned target is not returned with the target list.
     * This is useful in testing and should be avoided in production code.
     * 
     * @param skip {@code true}, if it is acceptable for Kepler IDs not to be
     * present in database
     */
    public void setSkipMissingKeplerIds(boolean skip) {
        skipMissingKeplerIds = skip;
    }

    /**
     * Treat all custom targets as if they were NEW. This is needed by the dev-
     * and smoke-test pipelines that ingest target list sets that may have a
     * mixture of NEW and previously set custom target IDs. However, in the case
     * of the dev and smoke-test pipelines, those custom target IDs are not yet
     * in their databases. This situation will lead will allow a NEW target to
     * receive a custom target ID that is specified in another target that
     * appears later in the set.
     * <p>
     * This option must <b>not</b> be used in an OPS environment in which the
     * custom target IDs in the target lists must be used.
     * 
     * @param treatCustomTargetsAsNew if {@code true}, consider all custom
     * targets as NEW, even if they have been previously been assigned a custom
     * target ID
     */
    public void setTreatCustomTargetsAsNew(boolean treatCustomTargetsAsNew) {
        this.treatCustomTargetsAsNew = treatCustomTargetsAsNew;
    }

    /**
     * Sets whether the target list that is read is intended to be imported into
     * the database. In this case, custom target IDs are created as needed and
     * checks of the target list are performed such as ensuring that apertures
     * in custom targets are the same as those in existing custom targets.
     * However, if the target list is not to be imported, these actions are
     * unnecessary and may even be deliterious if the database should not be
     * updated. Setting this field to {@code false} will suppress all access of
     * the database. The default is {@code true}.
     * 
     * @param importingTargetList {@code false}, to avoid accessing the database
     */
    public void setImportingTargetList(boolean importingTargetList) {
        this.importingTargetList = importingTargetList;
    }

    /**
     * Cancels the import. Use this method to interrupt the
     * {@link #ingestTargetFile(String)} and {@link #keplerIdsFromFile(String)}
     * methods.
     * 
     * @param canceled if {@code true}, makes {@link #ingestTargetFile(String)}
     * and {@link #keplerIdsFromFile(String)} return {@code null} immediately
     */
    public void setCanceled(boolean canceled) {
        this.canceled = canceled;
    }

    /**
     * Sets the progress handler.
     * 
     * @param progressHandler the progress handler; if {@code null}, progress is
     * not indicated
     */
    public void setProgressHandler(ProgressHandler progressHandler) {
        this.progressHandler = progressHandler;
    }

    /**
     * Ingests target data from the given file for the given target list.
     * Comments are marked with a # in the first column and continue to the end
     * of the line. If the line starts with Category: (ignoring case), the rest
     * of the line (with leading and trailing whitespace trimmed) will be used
     * as the category.
     * <p>
     * This method must be called within a transactional context if the file
     * contains new custom targets.
     * 
     * @param filename the file containing the target data
     * @return a non-{@code null} list of targets, unless
     * {@code setCanceled(true)} has been called
     * @throws IllegalStateException if this object was created with a
     * {@code null} target list, or the target list contains two custom targets
     * with the same ID that have different apertures
     * @throws IOException if there were problems opening or reading the file
     * @throws ParseException if there were problems parsing the content of the
     * file
     * @throws HibernateException if there were problems accessing the database
     */
    public List<PlannedTarget> ingestTargetFile(String filename)
        throws IOException, ParseException {

        if (targetList == null) {
            throw new IllegalStateException("targetList is null");
        }

        Map<Integer, PlannedTarget> targetByKeplerId = new LinkedHashMap<Integer, PlannedTarget>();
        int temporaryCustomTargetId = -1;

        int errorCount = 0;
        int lineNumber = 0;
        long charsRead = 0;
        long length = new File(filename).length();
        StringBuilder errors = new StringBuilder();
        String categoryLabel = CATEGORY_LABEL.toLowerCase();
        BufferedReader br = new BufferedReader(new FileReader(filename));

        try {
            for (String s = br.readLine(); s != null; s = br.readLine()) {
                lineNumber++;
                charsRead += s.length();
                if (s.trim().length() == 0) {
                    continue;
                }
                if (s.trim().startsWith(COMMENT_CHAR)) {
                    continue;
                }
                if (s.toLowerCase()
                    .startsWith(categoryLabel)) {
                    extractCategory(s);
                    continue;
                }
                try {
                    // Convert the string to a PlannedTarget.
                    PlannedTarget target = TargetSelectionOperations.stringToTarget(s);

                    // Merge target into map.
                    target.setTargetList(targetList);
                    int keplerId = target.getKeplerId();
                    if (keplerId == TargetManagementConstants.INVALID_KEPLER_ID) {
                        keplerId = temporaryCustomTargetId--;
                    }
                    TargetSelectionOperations.merge(targetByKeplerId, keplerId,
                        target);
                } catch (Exception e) {
                    if (++errorCount > MAX_FILE_ERRORS) {
                        break;
                    }
                    String message = e.getMessage();
                    if (e instanceof NumberFormatException) {
                        message = message + ", could not parse number";
                    }
                    errors.append(String.format("\nLine %d: %s", lineNumber,
                        message));
                }
                if (canceled) {
                    targetByKeplerId = null;
                    break;
                }
                if (lineNumber % 10 == 0) {
                    setProgress((float) charsRead / length);
                    if (lineNumber % 1000 == 0) {
                        log.info(String.format("Read %d targets", lineNumber));
                    }
                }
            }
        } finally {
            br.close();
        }

        if (errorCount > MAX_FILE_ERRORS) {
            throw new ParseException(String.format(
                "Too many errors in %s:\n%s", filename, errors.toString()), 0);
        }
        if (errorCount > 0) {
            throw new ParseException(String.format(
                "The file %s contains the following errors:\n%s", filename,
                errors.toString()), 0);
        }
        if (category == null) {
            throw new IllegalStateException(
                "Target list file must contain a category");
        }

        List<PlannedTarget> targets = null;
        if (targetByKeplerId != null) {
            // Only null if we've been canceled in which case we want to return
            // null.
            targets = new ArrayList<PlannedTarget>(targetByKeplerId.values());
            if (importingTargetList) {
                if (treatCustomTargetsAsNew) {
                    convertCustomTargetsToNew(targets);
                }
                targets = targetSelectionOperations.validatePlannedTargets(
                    targetList, targets, skipMissingKeplerIds);
            }
        }

        return targets;
    }

    private void extractCategory(String s) {
        String newCategory = s.substring(CATEGORY_LABEL.length())
            .trim();
        if (newCategory.length() == 0) {
            throw new IllegalStateException(
                "Category in target list file can't be empty");
        }
        if (category == null) {
            category = newCategory;
        } else {
            if (!category.equals(newCategory)) {
                throw new IllegalStateException(String.format(
                    "Target list file can only contain a single category "
                        + "but file contained %s and %s categories", category,
                    newCategory));
            }
        }
    }

    private void convertCustomTargetsToNew(List<PlannedTarget> targets) {
        for (PlannedTarget target : targets) {
            if (TargetManagementConstants.isCustomTarget(target.getKeplerId())) {
                target.setKeplerId(TargetManagementConstants.INVALID_KEPLER_ID);
            }
        }
    }

    /**
     * Returns a set of valid Kepler IDs found in the given file. The
     * {@link #TargetListImporter()} constructor can be used to construct this
     * object.
     * 
     * @param filename the filename
     * @return a non-{@code null} set of IDs, unless {@code setCanceled(true)}
     * has been called in which case {@code null} is returned
     * @throws NullPointerException if filename is {@code null}
     * @throws IOException if there was a problem opening or reading the file
     */
    public Set<Integer> keplerIdsFromFile(String filename) throws IOException {
        BufferedReader br = new BufferedReader(new FileReader(filename));
        Set<Integer> keplerIds = new HashSet<Integer>();

        try {
            for (String s = br.readLine(); s != null; s = br.readLine()) {
                if (s.startsWith(COMMENT_CHAR)) {
                    continue;
                }

                String categoryLabel = CATEGORY_LABEL.toLowerCase();
                if (s.toLowerCase()
                    .startsWith(categoryLabel)) {
                    category = s.substring(CATEGORY_LABEL.length())
                        .trim();
                    continue;
                }

                // Convert the string to a PlannedTarget.
                PlannedTarget target = TargetSelectionOperations.stringToTarget(s);

                // Ignore "NEW" items.
                if (target.getKeplerId() != TargetManagementConstants.INVALID_KEPLER_ID) {
                    keplerIds.add(target.getKeplerId());
                }

                if (canceled) {
                    return null;
                }
            }
        } finally {
            br.close();
        }

        return keplerIds;
    }

    private void setProgress(float progress) {
        if (progressHandler != null) {
            progressHandler.setProgress(progress);
        }
    }

    /**
     * Only used for testing.
     */
    void setTargetSelectionOperations(
        TargetSelectionOperations targetSelectionOperations) {
        this.targetSelectionOperations = targetSelectionOperations;
    }

    /**
     * Defines how progress should be handled.
     * 
     * TODO KSOC-500: Move to common?
     * 
     * @author Bill Wohler
     */
    public static interface ProgressHandler {
        /**
         * Indicates how much progress has been made.
         */
        public void setProgress(float progress);
    }
}
