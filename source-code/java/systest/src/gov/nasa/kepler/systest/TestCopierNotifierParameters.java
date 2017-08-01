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

package gov.nasa.kepler.systest;

import gov.nasa.spiffy.common.pi.Parameters;

public class TestCopierNotifierParameters implements Parameters {

    private boolean configMapEnabled;
    private boolean gapReportEnabled;
    private boolean ancillaryEnabled;
    private boolean crctEnabled;
    private boolean ffiEnabled;
    private boolean histogramEnabled;
    private boolean historyEnabled;
    private boolean pmrfEnabled;
    private boolean cadenceFitsEnabled;
    private boolean rpEnabled;
    
    public TestCopierNotifierParameters() {
    }

    public boolean isConfigMapEnabled() {
        return configMapEnabled;
    }

    public void setConfigMapEnabled(boolean configMapEnabled) {
        this.configMapEnabled = configMapEnabled;
    }

    public boolean isGapReportEnabled() {
        return gapReportEnabled;
    }

    public void setGapReportEnabled(boolean gapReportEnabled) {
        this.gapReportEnabled = gapReportEnabled;
    }

    public boolean isAncillaryEnabled() {
        return ancillaryEnabled;
    }

    public void setAncillaryEnabled(boolean ancillaryEnabled) {
        this.ancillaryEnabled = ancillaryEnabled;
    }

    public boolean isCrctEnabled() {
        return crctEnabled;
    }

    public void setCrctEnabled(boolean crctEnabled) {
        this.crctEnabled = crctEnabled;
    }

    public boolean isFfiEnabled() {
        return ffiEnabled;
    }

    public void setFfiEnabled(boolean ffiEnabled) {
        this.ffiEnabled = ffiEnabled;
    }

    public boolean isHistogramEnabled() {
        return histogramEnabled;
    }

    public void setHistogramEnabled(boolean histogramEnabled) {
        this.histogramEnabled = histogramEnabled;
    }

    public boolean isHistoryEnabled() {
        return historyEnabled;
    }

    public void setHistoryEnabled(boolean historyEnabled) {
        this.historyEnabled = historyEnabled;
    }

    public boolean isPmrfEnabled() {
        return pmrfEnabled;
    }

    public void setPmrfEnabled(boolean pmrfEnabled) {
        this.pmrfEnabled = pmrfEnabled;
    }

    public boolean isCadenceFitsEnabled() {
        return cadenceFitsEnabled;
    }

    public void setCadenceFitsEnabled(boolean cadenceFitsEnabled) {
        this.cadenceFitsEnabled = cadenceFitsEnabled;
    }

    public boolean isRpEnabled() {
        return rpEnabled;
    }

    public void setRpEnabled(boolean rpEnabled) {
        this.rpEnabled = rpEnabled;
    }

}
