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

package gov.nasa.kepler.ppa.pmd;

import gov.nasa.kepler.common.AncillaryEngineeringData;
import gov.nasa.kepler.common.AncillaryPipelineData;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.common.pi.AncillaryEngineeringParameters;
import gov.nasa.kepler.common.pi.AncillaryPipelineParameters;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.mc.BadPixel;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;

/**
 * Inputs for the PPA Metrics Determination pipeline module.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard (fgirouard@arc.nasa.gov)
 */
public class PmdInputs implements Persistable {

    /**
     * The CCD module. Only used to debug the bin file.
     */
    private int ccdModule;

    /**
     * The CCD output. Only used to debug the bin file.
     */
    private int ccdOutput;

    /**
     * PMD-specific module parameters set by the PIG.
     */
    private PmdModuleParameters pmdModuleParameters = new PmdModuleParameters();

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
     * RaDec2Pix model.
     */
    private RaDec2PixModel raDec2PixModel = new RaDec2PixModel();

    /**
     * Time series data that is consumed by PMD.
     */
    private PmdInputTsData inputTsData = new PmdInputTsData();

    /**
     * CDPP data per target star.
     */
    private List<PmdCdppTsData> cdppTsData = new ArrayList<PmdCdppTsData>();

    /**
     * All invalid pixels known by FC (from PA).
     */
    private List<BadPixel> badPixels = new ArrayList<BadPixel>();

    /**
     * Background polynomial coefficients (from PA) for this module/output.
     */
    private BlobFileSeries backgroundBlobs = new BlobFileSeries();

    /**
     * Motion polynomial coefficients (from PA) for this module/output.
     */
    private BlobFileSeries motionBlobs = new BlobFileSeries();

    /**
     * Engineering ancillary parameters.
     */
    private AncillaryEngineeringParameters ancillaryEngineeringParameters = new AncillaryEngineeringParameters();

    /**
     * Contains engineering ancillary data from the spacecraft.
     */
    private List<AncillaryEngineeringData> ancillaryEngineeringData = new ArrayList<AncillaryEngineeringData>();

    /**
     * Pipeline ancillary parameters
     */
    private AncillaryPipelineParameters ancillaryPipelineParameters = new AncillaryPipelineParameters();

    /**
     * Contains pipeline ancillary data generated by the pipeline.
     */
    private List<AncillaryPipelineData> ancillaryPipelineData = new ArrayList<AncillaryPipelineData>();

    public int getCcdModule() {
        return ccdModule;
    }

    public void setCcdModule(int ccdModule) {
        this.ccdModule = ccdModule;
    }

    public int getCcdOutput() {
        return ccdOutput;
    }

    public void setCcdOutput(int ccdOutput) {
        this.ccdOutput = ccdOutput;
    }

    public PmdModuleParameters getPmdModuleParameters() {
        return pmdModuleParameters;
    }

    public void setPmdModuleParameters(PmdModuleParameters pmdModuleParameters) {
        this.pmdModuleParameters = pmdModuleParameters;
    }

    public FcConstants getFcConstants() {
        return fcConstants;
    }

    public List<ConfigMap> getSpacecraftConfigMaps() {
        return spacecraftConfigMaps;
    }

    public void setSpacecraftConfigMaps(List<ConfigMap> spacecraftConfigMap) {
        spacecraftConfigMaps = spacecraftConfigMap;
    }

    public TimestampSeries getCadenceTimes() {
        return cadenceTimes;
    }

    public void setCadenceTimes(TimestampSeries cadenceTimes) {
        this.cadenceTimes = cadenceTimes;
    }

    public RaDec2PixModel getRaDec2PixModel() {
        return raDec2PixModel;
    }

    public void setRaDec2PixModel(RaDec2PixModel raDec2PixModel) {
        this.raDec2PixModel = raDec2PixModel;
    }

    public PmdInputTsData getInputTsData() {
        return inputTsData;
    }

    public void setInputTsData(PmdInputTsData inputTsData) {
        this.inputTsData = inputTsData;
    }

    public List<PmdCdppTsData> getCdppTsData() {
        return cdppTsData;
    }

    public void setCdppTsData(List<PmdCdppTsData> cdppTsData) {
        this.cdppTsData = cdppTsData;
    }

    public List<BadPixel> getBadPixels() {
        return badPixels;
    }

    public void setBadPixels(List<BadPixel> badPixels) {
        this.badPixels = badPixels;
    }

    public BlobFileSeries getBackgroundBlobs() {
        return backgroundBlobs;
    }

    public void setBackgroundBlobs(BlobFileSeries backgroundBlobs) {
        this.backgroundBlobs = backgroundBlobs;
    }

    public BlobFileSeries getMotionBlobs() {
        return motionBlobs;
    }

    public void setMotionBlobs(BlobFileSeries motionBlobs) {
        this.motionBlobs = motionBlobs;
    }

    public AncillaryEngineeringParameters getAncillaryEngineeringParameters() {
        return ancillaryEngineeringParameters;
    }

    public void setAncillaryEngineeringParameters(
        AncillaryEngineeringParameters ancillaryEngineeringParameters) {
        this.ancillaryEngineeringParameters = ancillaryEngineeringParameters;
    }

    public List<AncillaryEngineeringData> getAncillaryEngineeringData() {
        return ancillaryEngineeringData;
    }

    public void setAncillaryEngineeringData(
        List<AncillaryEngineeringData> ancillaryEngineeringData) {
        this.ancillaryEngineeringData = ancillaryEngineeringData;
    }

    public AncillaryPipelineParameters getAncillaryPipelineParameters() {
        return ancillaryPipelineParameters;
    }

    public void setAncillaryPipelineParameters(
        AncillaryPipelineParameters ancillaryPipelineParameters) {
        this.ancillaryPipelineParameters = ancillaryPipelineParameters;
    }

    public List<AncillaryPipelineData> getAncillaryPipelineData() {
        return ancillaryPipelineData;
    }

    public void setAncillaryPipelineData(
        List<AncillaryPipelineData> ancillaryPipelineData) {
        this.ancillaryPipelineData = ancillaryPipelineData;
    }
}
