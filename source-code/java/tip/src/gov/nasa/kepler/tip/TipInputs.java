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

package gov.nasa.kepler.tip;

import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.pa.PaTarget;
import gov.nasa.kepler.mc.pa.SimulatedTransitsModuleParameters;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;

public class TipInputs implements Persistable {

    /**
     * Type of cadence ('LONG' or 'SHORT').
     */
    private String cadenceType = "";

    /**
     * Start cadence (inclusive).
     */
    private int startCadence;

    /**
     * End cadence (inclusive).
     */
    private int endCadence;

    /**
     * The targets are from this sky group.
     */
    private int skyGroupId;

    /**
     * A RA/Dec to pixel model that covers the interval of time for the old and
     * new data.
     */
    private RaDec2PixModel raDec2PixModel = new RaDec2PixModel();

    /**
     * Active spacecraft configuration maps for the given cadence range.
     */
    private List<ConfigMap> configMaps = new ArrayList<ConfigMap>();

    /**
     * Targets with RMS CDPP data.
     */
    private List<PaTarget> targetStarDataStruct = new ArrayList<PaTarget>();

    /**
     * List of KIC entries for given targets.
     */
    private List<CelestialObjectParameters> kics = new ArrayList<CelestialObjectParameters>();

    /**
     * Simulated transits module parameters.
     */
    private SimulatedTransitsModuleParameters simulatedTransitsConfigurationStruct = new SimulatedTransitsModuleParameters();

    /**
     * The file name for storing the TIP outputs.
     */
    private String parameterOutputFilename = "";

    public TipInputs() {
    }

    public TipInputs(String cadenceType, int startCadence, int endCadence,
        int skyGroupId, RaDec2PixModel raDec2PixModel,
        List<ConfigMap> configMaps, List<PaTarget> targets,
        List<CelestialObjectParameters> kics,
        SimulatedTransitsModuleParameters simulatedTransitsParameters,
        String parameterOutputFilename) {

        this.cadenceType = cadenceType;
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.skyGroupId = skyGroupId;
        this.raDec2PixModel = raDec2PixModel;
        this.configMaps = configMaps;
        targetStarDataStruct = targets;
        this.kics = kics;
        simulatedTransitsConfigurationStruct = simulatedTransitsParameters;
        this.parameterOutputFilename = parameterOutputFilename;
    }

    public String getCadenceType() {
        return cadenceType;
    }

    public void setCadenceType(String cadenceType) {
        this.cadenceType = cadenceType;
    }

    public int getStartCadence() {
        return startCadence;
    }

    public void setStartCadence(int startCadence) {
        this.startCadence = startCadence;
    }

    public int getEndCadence() {
        return endCadence;
    }

    public void setEndCadence(int endCadence) {
        this.endCadence = endCadence;
    }

    public int getSkyGroupId() {
        return skyGroupId;
    }

    public void setSkyGroupId(int skyGroupId) {
        this.skyGroupId = skyGroupId;
    }

    public RaDec2PixModel getRaDec2PixModel() {
        return raDec2PixModel;
    }

    public void setRaDec2PixModel(RaDec2PixModel raDec2PixModel) {
        this.raDec2PixModel = raDec2PixModel;
    }

    public List<ConfigMap> getConfigMaps() {
        return configMaps;
    }

    public void setConfigMaps(List<ConfigMap> configMaps) {
        this.configMaps = configMaps;
    }

    public List<PaTarget> getTargets() {
        return targetStarDataStruct;
    }

    public void setTargets(List<PaTarget> targets) {
        targetStarDataStruct = targets;
    }

    public List<CelestialObjectParameters> getKics() {
        return kics;
    }

    public void setKics(List<CelestialObjectParameters> kics) {
        this.kics = kics;
    }

    public SimulatedTransitsModuleParameters getSimulatedTransitsModuleParameters() {
        return simulatedTransitsConfigurationStruct;
    }

    public void setSimulatedTransitsModuleParameters(
        SimulatedTransitsModuleParameters simulatedTransitsModuleParameters) {
        simulatedTransitsConfigurationStruct = simulatedTransitsModuleParameters;
    }

    public String getParameterOutputFilename() {
        return parameterOutputFilename;
    }

    public void setParameterOutputFilename(String parameterOutputFilename) {
        this.parameterOutputFilename = parameterOutputFilename;
    }
}
