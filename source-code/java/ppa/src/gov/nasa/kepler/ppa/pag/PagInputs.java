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

package gov.nasa.kepler.ppa.pag;

import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;

/**
 * PPA.PAG (PMD Aggregator) MI Inputs.
 * 
 * @author Bill Wohler
 */
public class PagInputs implements Persistable {

    /**
     * PAG specific module parameters.
     */
    private PagModuleParameters pagModuleParameters = new PagModuleParameters();

    /**
     * Focal plane characterization constants.
     */
    private FcConstants fcConstants = new FcConstants();

    /**
     * Spacecraft configuration parameters.
     */
    private List<ConfigMap> spacecraftConfigMaps = new ArrayList<ConfigMap>();

    /**
     * Time at the start, middle, and end of each cadence in MJD.
     */
    private TimestampSeries cadenceTimes = new TimestampSeries();

    /**
     * Time series data consumed by PAG for each module/output (when data is
     * available).
     */
    private List<PagInputTsData> inputTsData = new ArrayList<PagInputTsData>();

    /**
     * A PMD report for each module/output (when data is available).
     */
    private List<PagInputReport> reports = new ArrayList<PagInputReport>();

    public PagModuleParameters getPagModuleParameters() {
        return pagModuleParameters;
    }

    public void setPagModuleParameters(PagModuleParameters pagModuleParameters) {
        this.pagModuleParameters = pagModuleParameters;
    }

    public FcConstants getFcConstants() {
        return fcConstants;
    }

    public List<ConfigMap> getSpacecraftConfigMaps() {
        return spacecraftConfigMaps;
    }

    public void setSpacecraftConfigMaps(List<ConfigMap> spacecraftConfigMaps) {
        this.spacecraftConfigMaps = spacecraftConfigMaps;
    }

    public TimestampSeries getCadenceTimes() {
        return cadenceTimes;
    }

    public void setCadenceTimes(TimestampSeries cadenceTimes) {
        this.cadenceTimes = cadenceTimes;
    }

    public List<PagInputTsData> getInputTsData() {
        return inputTsData;
    }

    public void setInputTsData(List<PagInputTsData> inputTsData) {
        this.inputTsData = inputTsData;
    }

    public List<PagInputReport> getReports() {
        return reports;
    }

    public void setReports(List<PagInputReport> reports) {
        this.reports = reports;
    }
}
