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

import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.fc.FlatFieldModel;
import gov.nasa.kepler.fc.GainModel;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.fc.ReadNoiseModel;
import gov.nasa.kepler.fc.TwoDBlackModel;
import gov.nasa.kepler.fc.UndershootModel;
import gov.nasa.kepler.mc.gar.RequantTable;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.apache.commons.lang.ArrayUtils;

/**
 * Contains all the configuration parameters and data passed into the PDQ
 * science algorithm.
 * 
 * @author Forrest Girouard
 * 
 */
public class PdqInputs implements Persistable {

    /**
     * The identifier of the pipeline instance of the current pipeline task.
     */
    private long pipelineInstanceId;

    /**
     * All PDQ module parameters.
     */
    private PdqModuleParameters pdqConfiguration = new PdqModuleParameters();

    /**
     * All FC constants.
     */
    private FcConstants fcConstants = new FcConstants();

    /**
     * List of applicable spacecraft configuration maps.
     */
    private List<ConfigMap> configMaps = new ArrayList<ConfigMap>();

    /**
     * Reference pixel time stamps as well as additional information.
     */
    private PdqTimestampSeries pdqTimestampSeries = new PdqTimestampSeries();

    /**
     * A gain model that covers the interval of time for the old and new data.
     */
    private GainModel gainModel = new GainModel();

    /**
     * A read noise model that covers the interval of time for the old and new
     * data.
     */
    private ReadNoiseModel readNoiseModel = new ReadNoiseModel();

    /**
     * A RA/Dec to pixel model that covers the interval of time for the old and
     * new data.
     */
    private RaDec2PixModel raDec2PixModel = new RaDec2PixModel();

    /**
     * A LDE undershoot model that covers the interval of time for the old and
     * new data.
     */
    private UndershootModel undershootModel = new UndershootModel();

    /**
     * A list of files containing pixel response function models, one per module
     * output.
     */
    private String[] prfModelFilenames = ArrayUtils.EMPTY_STRING_ARRAY;

    /**
     * A list of 2D black models, one per module output, that cover the interval
     * of time for the old and new data.
     */
    private TwoDBlackModel[] twoDBlackModels = new TwoDBlackModel[0];

    /**
     * A list of flat field models, one per module output, that cover the
     * interval of time for the old and new data.
     */
    private FlatFieldModel[] flatFieldModels = new FlatFieldModel[0];

    /**
     * A list of the requantization tables that cover the interval of time for
     * the new data.
     */
    private List<RequantTable> requantTables = new ArrayList<RequantTable>();

    /**
     * All existing time series data from previous PDQ runs for the current
     * target table.
     */
    private PdqTsData inputPdqTsData = new PdqTsData();

    /**
     * List of stellar targets and all their required data including module,
     * output, labels, kepler id, ra, dec, kepler magnitude, and fraction of
     * flux in aperture as well as per pixel data including row, column, in
     * optimal aperture, gaps, and reference pixel values.
     */
    private List<PdqStellarTarget> stellarPdqTargets = new ArrayList<PdqStellarTarget>();

    /**
     * List of background targets and all their required data including module,
     * output, and labels as well as per pixel data including row, column, in
     * optimal aperture, gaps, and raw reference pixel values.
     */
    private List<PdqTarget> backgroundPdqTargets = new ArrayList<PdqTarget>();

    /**
     * List of collateral targets and all their required data including module,
     * output, and labels as well as per pixel data including row, column, in
     * optimal aperture, gaps, and raw reference pixel values.
     */
    private List<PdqTarget> collateralPdqTargets = new ArrayList<PdqTarget>();

    public List<PdqTarget> getBackgroundPdqTargets() {
        return backgroundPdqTargets;
    }

    public void setBackgroundPdqTargets(
        final List<PdqTarget> backgroundPdqTargets) {
        this.backgroundPdqTargets = backgroundPdqTargets;
    }

    public PdqTimestampSeries getPdqTimestampSeries() {
        return pdqTimestampSeries;
    }

    public void setPdqTimestampSeries(PdqTimestampSeries pdqTimestampSeries) {
        this.pdqTimestampSeries = pdqTimestampSeries;
    }

    public List<PdqTarget> getCollateralPdqTargets() {
        return collateralPdqTargets;
    }

    public void setCollateralPdqTargets(
        final List<PdqTarget> collateralPdqTargets) {
        this.collateralPdqTargets = collateralPdqTargets;
    }

    public List<ConfigMap> getConfigMaps() {
        return configMaps;
    }

    public void setConfigMaps(final List<ConfigMap> configMaps) {
        this.configMaps = configMaps;
    }

    public FcConstants getFcConstants() {
        return fcConstants;
    }

    public FlatFieldModel[] getFlatFieldModels() {
        return Arrays.copyOf(flatFieldModels, flatFieldModels.length);
    }

    public void setFlatFieldModels(final FlatFieldModel[] flatFieldModels) {
        this.flatFieldModels = Arrays.copyOf(flatFieldModels,
            flatFieldModels.length);
    }

    public GainModel getGainModel() {
        return gainModel;
    }

    public void setGainModel(final GainModel gainModel) {
        this.gainModel = gainModel;
    }

    public PdqTsData getInputPdqTsData() {
        return inputPdqTsData;
    }

    public void setInputPdqTsData(final PdqTsData inputPdqTsData) {
        this.inputPdqTsData = inputPdqTsData;
    }

    public PdqModuleParameters getPdqModuleParameters() {
        return pdqConfiguration;
    }

    public void setPdqModuleParameters(
        final PdqModuleParameters pdqConfiguration) {
        this.pdqConfiguration = pdqConfiguration;
    }

    protected long getPipelineInstanceId() {
        return pipelineInstanceId;
    }

    protected void setPipelineInstanceId(final long pipelineInstanceId) {
        this.pipelineInstanceId = pipelineInstanceId;
    }

    public String[] getPrfModelFilenames() {
        return Arrays.copyOf(prfModelFilenames, prfModelFilenames.length);
    }

    public void setPrfModelFilenames(final String[] prfModelFilenames) {
        this.prfModelFilenames = Arrays.copyOf(prfModelFilenames,
            prfModelFilenames.length);
    }

    public RaDec2PixModel getRaDec2PixModel() {
        return raDec2PixModel;
    }

    public void setRaDec2PixModel(final RaDec2PixModel raDec2PixModel) {
        this.raDec2PixModel = raDec2PixModel;
    }

    public ReadNoiseModel getReadNoiseModel() {
        return readNoiseModel;
    }

    public void setReadNoiseModel(final ReadNoiseModel readNoiseModel) {
        this.readNoiseModel = readNoiseModel;
    }

    public List<RequantTable> getRequantTables() {
        return requantTables;
    }

    public void setRequantTables(final List<RequantTable> requantTables) {
        this.requantTables = requantTables;
    }

    public List<PdqStellarTarget> getStellarPdqTargets() {
        return stellarPdqTargets;
    }

    public void setStellarPdqTargets(
        final List<PdqStellarTarget> stellarPdqTargets) {
        this.stellarPdqTargets = stellarPdqTargets;
    }

    public TwoDBlackModel[] getTwoDBlackModels() {
        return Arrays.copyOf(twoDBlackModels, twoDBlackModels.length);
    }

    public void setTwoDBlackModels(final TwoDBlackModel[] twoDBlackModels) {
        this.twoDBlackModels = Arrays.copyOf(twoDBlackModels,
            twoDBlackModels.length);
    }

    public UndershootModel getUndershootModel() {
        return undershootModel;
    }

    public void setUndershootModel(final UndershootModel undershootModel) {
        this.undershootModel = undershootModel;
    }
}
