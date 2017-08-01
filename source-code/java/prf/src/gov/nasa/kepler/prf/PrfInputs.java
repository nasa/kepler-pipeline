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

package gov.nasa.kepler.prf;

import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.fpg.FpgAttitudeSolution;
import gov.nasa.kepler.mc.BrysonianCosmicRayModuleParameters;
import gov.nasa.kepler.mc.PouModuleParameters;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.pa.MotionModuleParameters;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.Collections;
import java.util.List;


/**
 * Contains all the configuration parameters and data passed into the PRF
 * science algorithm.
 * 
 * @author Sean McCauliff
 * @author Forrest Girouard
 * 
 */
public class PrfInputs implements Persistable {

    /**
     * 4 - debug level.
     */
    private String inputsVersion = "PRF Inputs Version 4";
    
    /**
     * CCD module for this run.
     */
    private int ccdModule;

    /**
     * CCD output for this run.
     */
    private int ccdOutput;

    /**
     * Starting cadence for this run.
     */
    private int startCadence;

    /**
     * Ending cadence for this run.
     */
    private int endCadence;

    /**
     * Mid-cadence MJDs.
     */
    private TimestampSeries cadenceTimes;

    /**
     * All FC constants.
     */
    private FcConstants fcConstants = new FcConstants();

    /**
     * List of applicable spacecraft configuration maps.
     */
    private List<ConfigMap> configMaps;

    /**
     * PRF-specific module parameters.
     */
    private PrfModuleParameters prfConfigurationStruct;

    /**
     * POU-specific module parameters.
     */
    private PouModuleParameters pouConfigurationStruct;

    /**
     * Cosmic ray related module parameters.
     */
    private BrysonianCosmicRayModuleParameters cosmicRayConfigurationStruct;

    private MotionModuleParameters motionConfigurationStruct;

    /**
     * A RA/Dec to pixel model that covers the cadence times.
     */
    private RaDec2PixModel raDec2PixModel;

    /**
     * Contains background polynomial information.
     */
    private BlobFileSeries backgroundBlobsStruct;

    /**
     * Contains image motion polynomial information.
     */
    private BlobFileSeries motionBlobsStruct;

    private BlobFileSeries fpgGeometryBlobsStruct;

    private BlobFileSeries calUncertaintyBlobsStruct;
    
    /**
     * Contains the attitude solution calculated by PPA.
     */
    private FpgAttitudeSolution spacecraftAttitudeStruct;

    /**
     * Sets of pixel time series for each target.
     */
    private List<PrfTarget> targetStarsStruct;
    
    private List<PrfCentroidTimeSeries>  previousCentroids = Collections.EMPTY_LIST;
    
    /**
     * @param ccdModule
     * @param ccdOutput
     * @param startCadence
     * @param endCadence
     * @param cadenceTimes
     * @param fcConstants
     * @param configMaps
     * @param prfConfigurationStruct
     * @param pouConfigurationStruct
     * @param cosmicRayConfigurationStruct
     * @param motionConfigurationStruct
     * @param raDec2PixModel
     * @param backgroundBlobsStruct
     * @param motionBlobsStruct
     * @param fpgGeometryBlobsStruct
     * @param spacecraftAttitudeStruct
     * @param targetStarsStruct
     * @param calUncertaintyBlobsStruct
     */
    public PrfInputs(int ccdModule, int ccdOutput, int startCadence,
        int endCadence, TimestampSeries cadenceTimes,
        List<ConfigMap> configMaps, PrfModuleParameters prfConfigurationStruct,
        PouModuleParameters pouConfigurationStruct,
        BrysonianCosmicRayModuleParameters cosmicRayConfigurationStruct,
        MotionModuleParameters motionConfigurationStruct,
        RaDec2PixModel raDec2PixModel, BlobFileSeries backgroundBlobsStruct,
        BlobFileSeries motionBlobsStruct,
        BlobFileSeries fpgGeometryBlobsStruct,
        FpgAttitudeSolution spacecraftAttitudeStruct,
        List<PrfTarget> targetStarsStruct,
        BlobFileSeries calUncertaintyBlobsStruct,
        List<PrfCentroidTimeSeries> previousCentroids) {
        super();
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.cadenceTimes = cadenceTimes;
        this.configMaps = configMaps;
        this.prfConfigurationStruct = prfConfigurationStruct;
        this.pouConfigurationStruct = pouConfigurationStruct;
        this.cosmicRayConfigurationStruct = cosmicRayConfigurationStruct;
        this.motionConfigurationStruct = motionConfigurationStruct;
        this.raDec2PixModel = raDec2PixModel;
        this.backgroundBlobsStruct = backgroundBlobsStruct;
        this.motionBlobsStruct = motionBlobsStruct;
        this.fpgGeometryBlobsStruct = fpgGeometryBlobsStruct;
        this.spacecraftAttitudeStruct = spacecraftAttitudeStruct;
        this.targetStarsStruct = targetStarsStruct;
        this.calUncertaintyBlobsStruct = calUncertaintyBlobsStruct;
        this.previousCentroids = previousCentroids;
    }

    PrfInputs() {
        
    }
    
    public int getCcdModule() {
        return ccdModule;
    }

    public int getCcdOutput() {
        return ccdOutput;
    }

    public int getStartCadence() {
        return startCadence;
    }

    public int getEndCadence() {
        return endCadence;
    }

    public TimestampSeries getCadenceTimes() {
        return cadenceTimes;
    }

    public FcConstants getFcConstants() {
        return fcConstants;
    }

    public List<ConfigMap> getConfigMaps() {
        return configMaps;
    }

    public PrfModuleParameters getPrfConfigurationStruct() {
        return prfConfigurationStruct;
    }

    public PouModuleParameters getPouConfigurationStruct() {
        return pouConfigurationStruct;
    }

    public BrysonianCosmicRayModuleParameters getCosmicRayConfigurationStruct() {
        return cosmicRayConfigurationStruct;
    }

    public MotionModuleParameters getMotionConfigurationStruct() {
        return motionConfigurationStruct;
    }

    public RaDec2PixModel getRaDec2PixModel() {
        return raDec2PixModel;
    }

    public BlobFileSeries getBackgroundBlobsStruct() {
        return backgroundBlobsStruct;
    }

    public BlobFileSeries getMotionBlobsStruct() {
        return motionBlobsStruct;
    }

    public BlobFileSeries getFpgGeometryBlobsStruct() {
        return fpgGeometryBlobsStruct;
    }

    public FpgAttitudeSolution getSpacecraftAttitudeStruct() {
        return spacecraftAttitudeStruct;
    }

    public List<PrfTarget> getTargetStarsStruct() {
        return targetStarsStruct;
    }

    public BlobFileSeries getCalUncertaintyBlobsStruct() {
        return calUncertaintyBlobsStruct;
    }

}
