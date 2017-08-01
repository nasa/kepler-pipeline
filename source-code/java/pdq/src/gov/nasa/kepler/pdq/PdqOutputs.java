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

import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;

/**
 * Contains all the data and status information returned from the PDQ science
 * algorithm that is to be persisted and/or reported.
 * 
 * @author Forrest Girouard
 * 
 */
public class PdqOutputs implements Persistable {

    /**
     * All the PDQ metric time series. This instance contains the union of the
     * instance of the same type passed on the inputs along with the data
     * derived from the reference pixels passed in the inputs. The exact
     * contents of this instance will be passed as inputs on the subsequent
     * invocation of PDQ on the same target table.
     */
    private PdqTsData outputPdqTsData = new PdqTsData();

    /**
     * The caculated attitude adjustments, one per new reference pixel file.
     */
    private List<PdqAttitudeAdjustment> attitudeAdjustments = new ArrayList<PdqAttitudeAdjustment>();

    /**
     * List of the module output specific summary metrics used to assess the
     * operating condition of the instrument.
     */
    private List<PdqModuleOutputReport> pdqModuleOutputReports = new ArrayList<PdqModuleOutputReport>();

    /**
     * Most recent summary metrics across the whole focal plane used to assess
     * the operating condition of the instrument.
     */
    private PdqFocalPlaneReport pdqFocalPlaneReport = new PdqFocalPlaneReport();

    /**
     * Filename containing the MATLAB generated report. This is just the name of
     * the file in the MATLAB runtime directory, in other words, it does not
     * include the path.
     */
    private String reportFilename = "";

    /**
     * Required by the Persistable interface.
     */
    public PdqOutputs() {
        super();
    }

    public List<PdqAttitudeAdjustment> getAttitudeAdjustments() {
        return attitudeAdjustments;
    }

    public void setAttitudeAdjustments(
        final List<PdqAttitudeAdjustment> attitudeAdjustments) {
        this.attitudeAdjustments = attitudeAdjustments;
    }

    public PdqFocalPlaneReport getPdqFocalPlaneReport() {
        return pdqFocalPlaneReport;
    }

    public void setPdqFocalPlaneReport(
        final PdqFocalPlaneReport pdqFocalPlaneReport) {
        this.pdqFocalPlaneReport = pdqFocalPlaneReport;
    }

    public PdqTsData getOutputPdqTsData() {
        return outputPdqTsData;
    }

    public void setOutputPdqTsData(final PdqTsData outputPdqTsData) {
        this.outputPdqTsData = outputPdqTsData;
    }

    public List<PdqModuleOutputReport> getPdqModuleOutputReports() {
        return pdqModuleOutputReports;
    }

    public void setPdqModuleOutputReports(
        final List<PdqModuleOutputReport> reports) {
        pdqModuleOutputReports = reports;
    }

    public String getReportFilename() {
        return reportFilename;
    }

    public void setReportFilename(final String reportFilename) {
        this.reportFilename = reportFilename;
    }
}
