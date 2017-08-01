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

package gov.nasa.kepler.gar.requant;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.kepler.fc.GainModel;
import gov.nasa.kepler.fc.ReadNoiseModel;
import gov.nasa.kepler.fc.TwoDBlackModel;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.List;

/**
 * Requantization module interface input structure.
 * 
 * @author Bill Wohler
 */
public class RequantInputs implements Persistable {

    /**
     * Requantization module parameters.
     */
    private RequantModuleParameters requantModuleParameters;

    /**
     * Spacecraft configuration parameters.
     */
    private PlannedSpacecraftConfigParameters scConfigParameters;

    /**
     * Focal plane characterization constants.
     */
    private FcConstants fcConstants = new FcConstants();

    /**
     * A gain model that covers all module/outputs.
     */
    private GainModel gainModel;

    /**
     * A read noise model that covers all module/outputs.
     */
    private ReadNoiseModel readNoiseModel;

    /**
     * A list of 2D black models, one per module/output.
     */
    private List<TwoDBlackModel> twoDBlackModels;

    public RequantModuleParameters getRequantModuleParameters() {
        return requantModuleParameters;
    }

    public void setRequantModuleParameters(
        RequantModuleParameters requantModuleParameters) {
        this.requantModuleParameters = requantModuleParameters;
    }

    public PlannedSpacecraftConfigParameters getScConfigParameters() {
        return scConfigParameters;
    }

    public void setScConfigParameters(
        PlannedSpacecraftConfigParameters scConfigParameters) {
        this.scConfigParameters = scConfigParameters;
    }

    public FcConstants getFcConstants() {
        return fcConstants;
    }

    public GainModel getGainModel() {
        return gainModel;
    }

    public void setGainModel(GainModel gainModel) {
        this.gainModel = gainModel;
    }

    public ReadNoiseModel getReadNoiseModel() {
        return readNoiseModel;
    }

    public void setReadNoiseModel(ReadNoiseModel readNoiseModel) {
        this.readNoiseModel = readNoiseModel;
    }

    public List<TwoDBlackModel> getTwoDBlackModels() {
        return twoDBlackModels;
    }

    public void setTwoDBlackModels(List<TwoDBlackModel> twoDBlackModels) {
        this.twoDBlackModels = twoDBlackModels;
    }
}
