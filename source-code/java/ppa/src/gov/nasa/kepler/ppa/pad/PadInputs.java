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

package gov.nasa.kepler.ppa.pad;

import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;

/**
 * PPA.PAD (PPA Attitude Determination) MI Inputs.
 * 
 * @author Forrest Girouard (fgirouard@arc.nasa.gov)
 * 
 */
public class PadInputs implements Persistable {

    /**
     * PAD specific module parameters.
     */
    private PadModuleParameters padModuleParameters = new PadModuleParameters();

    /**
     * Focal plane characterization constants.
     */
    private FcConstants fcConstants = new FcConstants();

    /**
     * Spacecraft configuration parameters.
     */
    private List<ConfigMap> spacecraftConfigMaps = new ArrayList<ConfigMap>();

    /**
     * Time at the start of each cadence in days.
     */
    private TimestampSeries cadenceTimes = new TimestampSeries();

    /**
     * RaDec2PixelModel.
     */
    private RaDec2PixModel raDec2PixModel = new RaDec2PixModel();

    /**
     * Motion polynomial coefficients (from PA) for all module/outputs.
     */
    private BlobFileSeries[] motionBlobs = new BlobFileSeries[0];

    public PadInputs() {
    }

    public PadModuleParameters getPadModuleParameters() {
        return padModuleParameters;
    }

    public void setPadModuleParameters(PadModuleParameters padModuleParameters) {
        this.padModuleParameters = padModuleParameters;
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

    public RaDec2PixModel getRaDec2PixModel() {
        return raDec2PixModel;
    }

    public void setRaDec2PixModel(RaDec2PixModel raDec2PixModel) {
        this.raDec2PixModel = raDec2PixModel;
    }

    public BlobFileSeries[] getMotionBlobs() {
        return motionBlobs;
    }

    public void setMotionBlobs(BlobFileSeries[] motionBlobs) {
        this.motionBlobs = motionBlobs;
    }

}
