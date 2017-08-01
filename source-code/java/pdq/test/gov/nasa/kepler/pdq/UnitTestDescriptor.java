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

package gov.nasa.kepler.pdq;

import gov.nasa.kepler.common.FcConstants;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang.ArrayUtils;

public class UnitTestDescriptor {

    private static final List<Integer> ALL_MODULE_OUTPUTS = new ArrayList<Integer>();
    static {
        for (int i = 1; i <= FcConstants.MODULE_OUTPUTS; i++) {
            ALL_MODULE_OUTPUTS.add(i);
        }
    }
    private static final int NUM_OLD_REF_LOGS = 4;
    private static final int NUM_NEW_REF_LOGS = 4;

    private List<Integer> moduleOutputs = ALL_MODULE_OUTPUTS;
    private boolean validate;
    private boolean forceAlert;
    private boolean forceFatalException;
    private boolean forceReprocessing;
    private boolean forceUpdates;
    private boolean reportEnabled = true;
    private int[] excludeCadences = ArrayUtils.EMPTY_INT_ARRAY;
    private boolean oldExcludedCadencesProcessed = true;
    private boolean outputExpectations = true;
    private boolean executeAlgorithmEnabled = true;

    private int numOldRefLogs = NUM_OLD_REF_LOGS;
    private int numNewRefLogs = NUM_NEW_REF_LOGS;

    protected boolean isForceAlert() {
        return forceAlert;
    }

    protected void setForceAlert(boolean forceAlert) {
        this.forceAlert = forceAlert;
    }

    protected boolean isForceFatalException() {
        return forceFatalException;
    }

    protected void setForceFatalException(boolean forceFatalException) {
        this.forceFatalException = forceFatalException;
    }

    public int[] getExcludeCadences() {
        return excludeCadences;
    }

    public void setExcludeCadences(int[] excludeCadences) {
        this.excludeCadences = excludeCadences;
    }

    public boolean isForceReprocessing() {
        return forceReprocessing;
    }

    public void setForceReprocessing(boolean forceReprocessing) {
        this.forceReprocessing = forceReprocessing;
    }

    public boolean isForceUpdates() {
        return forceUpdates;
    }

    public void setForceUpdates(boolean forceUpdates) {
        this.forceUpdates = forceUpdates;
    }

    public List<Integer> getModuleOutputs() {
        return moduleOutputs;
    }

    public void setModuleOutputs(List<Integer> moduleOutputs) {
        this.moduleOutputs = moduleOutputs;
    }

    public int getNumNewRefLogs() {
        return numNewRefLogs;
    }

    public void setNumNewRefLogs(int numNewRefLogs) {
        this.numNewRefLogs = numNewRefLogs;
    }

    public int getNumOldRefLogs() {
        return numOldRefLogs;
    }

    public void setNumOldRefLogs(int numOldRefLogs) {
        this.numOldRefLogs = numOldRefLogs;
    }

    public boolean isOldExcludedCadencesProcessed() {
        return oldExcludedCadencesProcessed;
    }

    public void setOldExcludedCadencesProcessed(
        boolean oldExcludedCadencesProcessed) {
        this.oldExcludedCadencesProcessed = oldExcludedCadencesProcessed;
    }

    public boolean isOutputExpectations() {
        return outputExpectations;
    }

    public void setOutputExpectations(boolean outputExpectations) {
        this.outputExpectations = outputExpectations;
    }

    public boolean isExecuteAlgorithmEnabled() {
        return executeAlgorithmEnabled;
    }

    public void setExecuteAlgorithmEnabled(boolean executeAlgorithmEnabled) {
        this.executeAlgorithmEnabled = executeAlgorithmEnabled;
    }

    public boolean isReportEnabled() {
        return reportEnabled;
    }

    public void setReportEnabled(boolean reportEnabled) {
        this.reportEnabled = reportEnabled;
    }

    public int getTotalRefLogs() {
        return numOldRefLogs + numNewRefLogs;
    }

    public boolean isValidate() {
        return validate;
    }

    public void setValidate(boolean validate) {
        this.validate = validate;
    }

}
