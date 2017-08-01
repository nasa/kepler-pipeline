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

package gov.nasa.kepler.dv.io;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.SaturationSegmentModuleParameters;
import gov.nasa.kepler.common.pi.AncillaryDesignMatrixParameters;
import gov.nasa.kepler.common.pi.AncillaryEngineeringParameters;
import gov.nasa.kepler.common.pi.AncillaryPipelineParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.mc.BootstrapModuleParameters;
import gov.nasa.kepler.mc.DifferenceImageParameters;
import gov.nasa.kepler.mc.GapFillModuleParameters;
import gov.nasa.kepler.mc.MqTimestampSeries;
import gov.nasa.kepler.mc.PlanetFitModuleParameters;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.dv.DvModuleParameters;
import gov.nasa.kepler.pdc.PdcHarmonicsIdentificationParameters;
import gov.nasa.kepler.pdc.PdcModuleParameters;
import gov.nasa.kepler.tps.TpsHarmonicsIdentificationParameters;
import gov.nasa.kepler.tps.TpsModuleParameters;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnore;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * * Data Validation (DV) module interface inputs.
 * 
 * @author Forrest Girouard
 */
public class DvInputs implements Persistable {

    // N.B. Be sure to update the copy method if fields are added, removed, or
    // modified.

    private AncillaryDesignMatrixParameters ancillaryDesignMatrixConfigurationStruct = new AncillaryDesignMatrixParameters();
    private AncillaryEngineeringParameters ancillaryEngineeringConfigurationStruct = new AncillaryEngineeringParameters();
    private String ancillaryEngineeringDataFileName = new String();
    private AncillaryPipelineParameters ancillaryPipelineConfigurationStruct = new AncillaryPipelineParameters();
    private BootstrapModuleParameters bootstrapConfigurationStruct = new BootstrapModuleParameters();
    private CentroidTestParameters centroidTestConfigurationStruct = new CentroidTestParameters();
    private List<ConfigMap> configMaps = new ArrayList<ConfigMap>();
    private DifferenceImageParameters differenceImageConfigurationStruct = new DifferenceImageParameters();
    private MqTimestampSeries dvCadenceTimes = new MqTimestampSeries();
    private DvModuleParameters dvConfigurationStruct = new DvModuleParameters();
    private FcConstants fcConstants = new FcConstants();
    private FluxTypeParameters fluxTypeConfigurationStruct = new FluxTypeParameters();
    private GapFillModuleParameters gapFillConfigurationStruct = new GapFillModuleParameters();
    private List<CelestialObjectParameters> kics = new ArrayList<CelestialObjectParameters>();
    private PdcModuleParameters pdcConfigurationStruct = new PdcModuleParameters();
    private PdcHarmonicsIdentificationParameters pdcHarmonicsIdentificationConfigurationStruct = new PdcHarmonicsIdentificationParameters();
    private PixelCorrelationParameters pixelCorrelationConfigurationStruct = new PixelCorrelationParameters();
    private PlanetFitModuleParameters planetFitConfigurationStruct = new PlanetFitModuleParameters();
    private RaDec2PixModel raDec2PixModel = new RaDec2PixModel();
    private String[] prfModelFileNames = new String[0];
    private SaturationSegmentModuleParameters saturationSegmentConfigurationStruct = new SaturationSegmentModuleParameters();
    private int skyGroupId;
    private String softwareRevision = new String();
    private String externalTceModelDescription = new String();
    private String transitNameModelDescription = new String();
    private String transitParameterModelDescription = new String();
    private TrapezoidalFitParameters trapezoidalFitConfigurationStruct = new TrapezoidalFitParameters();

    // One entry per keplerId
    private List<DvTarget> targetStruct = newArrayList();

    private List<DvTargetTableData> targetTableDataStruct = new ArrayList<DvTargetTableData>();
    private TpsModuleParameters tpsConfigurationStruct = new TpsModuleParameters();
    private TpsHarmonicsIdentificationParameters tpsHarmonicsIdentificationConfigurationStruct = new TpsHarmonicsIdentificationParameters();
    private String transitInjectionParametersFileName = "";
    private int taskTimeoutSecs;

    @ProxyIgnore
    private Map<Integer, List<CelestialObjectParameters>> kicsByKeplerId = new HashMap<Integer, List<CelestialObjectParameters>>();

    /**
     * Returns a copy of the given inputs, but only contains target data for the
     * given Kepler IDs. In addition, this method is also unlike a copy
     * constructor in that it only copies references to the rest of the fields
     * rather than independent copies.
     * <p>
     * N.B. This function must be updated if fields are added, removed, or
     * modified.
     * 
     * @param dvInputs the given inputs
     * @param keplerIds the Kepler IDs to copy
     * @return a copy of the given inputs whose targets are limited to the given
     * Kepler IDs
     */
    public static DvInputs copy(DvInputs dvInputs, List<Integer> keplerIds) {

        DvInputs copy = new DvInputs();

        copy.ancillaryDesignMatrixConfigurationStruct = dvInputs.ancillaryDesignMatrixConfigurationStruct;
        copy.ancillaryEngineeringConfigurationStruct = dvInputs.ancillaryEngineeringConfigurationStruct;
        copy.ancillaryEngineeringDataFileName = dvInputs.ancillaryEngineeringDataFileName;
        copy.ancillaryPipelineConfigurationStruct = dvInputs.ancillaryPipelineConfigurationStruct;
        copy.bootstrapConfigurationStruct = dvInputs.bootstrapConfigurationStruct;
        copy.centroidTestConfigurationStruct = dvInputs.centroidTestConfigurationStruct;
        copy.configMaps = dvInputs.configMaps;
        copy.differenceImageConfigurationStruct = dvInputs.differenceImageConfigurationStruct;
        copy.dvCadenceTimes = dvInputs.dvCadenceTimes;
        copy.dvConfigurationStruct = dvInputs.dvConfigurationStruct;
        copy.fcConstants = dvInputs.fcConstants;
        copy.fluxTypeConfigurationStruct = dvInputs.fluxTypeConfigurationStruct;
        copy.gapFillConfigurationStruct = dvInputs.gapFillConfigurationStruct;
        copy.pdcConfigurationStruct = dvInputs.pdcConfigurationStruct;
        copy.pdcHarmonicsIdentificationConfigurationStruct = dvInputs.pdcHarmonicsIdentificationConfigurationStruct;
        copy.pixelCorrelationConfigurationStruct = dvInputs.pixelCorrelationConfigurationStruct;
        copy.planetFitConfigurationStruct = dvInputs.planetFitConfigurationStruct;
        copy.prfModelFileNames = dvInputs.prfModelFileNames;
        copy.raDec2PixModel = dvInputs.raDec2PixModel;
        copy.saturationSegmentConfigurationStruct = dvInputs.saturationSegmentConfigurationStruct;
        copy.skyGroupId = dvInputs.skyGroupId;
        copy.softwareRevision = dvInputs.softwareRevision;
        copy.externalTceModelDescription = dvInputs.externalTceModelDescription;
        copy.targetTableDataStruct = dvInputs.targetTableDataStruct;
        copy.taskTimeoutSecs = dvInputs.taskTimeoutSecs;
        copy.tpsConfigurationStruct = dvInputs.tpsConfigurationStruct;
        copy.tpsHarmonicsIdentificationConfigurationStruct = dvInputs.tpsHarmonicsIdentificationConfigurationStruct;
        copy.transitInjectionParametersFileName = dvInputs.transitInjectionParametersFileName;
        copy.externalTceModelDescription = dvInputs.externalTceModelDescription;
        copy.transitNameModelDescription = dvInputs.transitNameModelDescription;
        copy.transitParameterModelDescription = dvInputs.transitParameterModelDescription;
        copy.trapezoidalFitConfigurationStruct = dvInputs.trapezoidalFitConfigurationStruct;

        copy.targetStruct = new ArrayList<DvTarget>(keplerIds.size());
        copy.kics = new ArrayList<CelestialObjectParameters>();
        Set<Integer> keplerIdSet = new HashSet<Integer>(keplerIds);
        for (DvTarget target : dvInputs.targetStruct) {
            if (keplerIdSet.contains(target.getKeplerId())) {
                copy.targetStruct.add(target);
                for (CelestialObjectParameters celestialObjectParameters : dvInputs.kicsByKeplerId.get(target.getKeplerId())) {
                    if (!copy.kics.contains(celestialObjectParameters)) {
                        copy.kics.add(celestialObjectParameters);
                    }
                }
            }
        }

        return copy;
    }

    public AncillaryDesignMatrixParameters getAncillaryDesignMatrixParameters() {
        return ancillaryDesignMatrixConfigurationStruct;
    }

    public void setAncillaryDesignMatrixParameters(
        AncillaryDesignMatrixParameters ancillaryDesignMatrixParameters) {
        ancillaryDesignMatrixConfigurationStruct = ancillaryDesignMatrixParameters;
    }

    public AncillaryEngineeringParameters getAncillaryEngineeringParameters() {
        return ancillaryEngineeringConfigurationStruct;
    }

    public void setAncillaryEngineeringParameters(
        AncillaryEngineeringParameters ancillaryEngineeringParameters) {
        ancillaryEngineeringConfigurationStruct = ancillaryEngineeringParameters;
    }

    public String getAncillaryEngineeringDataFileName() {
        return ancillaryEngineeringDataFileName;
    }

    public void setAncillaryEngineeringDataFileName(
        String ancillaryEngineeringDataFileName) {
        this.ancillaryEngineeringDataFileName = ancillaryEngineeringDataFileName;
    }

    public AncillaryPipelineParameters getAncillaryPipelineParameters() {
        return ancillaryPipelineConfigurationStruct;
    }

    public void setAncillaryPipelineParameters(
        AncillaryPipelineParameters ancillaryPipelineParameters) {
        ancillaryPipelineConfigurationStruct = ancillaryPipelineParameters;
    }

    public BootstrapModuleParameters getBootstrapModuleParameters() {
        return bootstrapConfigurationStruct;
    }

    public void setBootstrapModuleParameters(
        BootstrapModuleParameters bootstrapModuleParameters) {
        bootstrapConfigurationStruct = bootstrapModuleParameters;
    }

    public CentroidTestParameters getCentroidTestParameters() {
        return centroidTestConfigurationStruct;
    }

    public void setCentroidTestParameters(
        CentroidTestParameters centroidTestParameters) {
        centroidTestConfigurationStruct = centroidTestParameters;
    }

    public List<ConfigMap> getConfigMaps() {
        return configMaps;
    }

    public void setConfigMaps(List<ConfigMap> configMaps) {
        this.configMaps = configMaps;
    }

    public DifferenceImageParameters getDifferenceImageParameters() {
        return differenceImageConfigurationStruct;
    }

    public void setDifferenceImageParameters(
        DifferenceImageParameters differenceImageParameters) {
        differenceImageConfigurationStruct = differenceImageParameters;
    }

    public MqTimestampSeries getMqCadenceTimes() {
        return dvCadenceTimes;
    }

    public void setMqCadenceTimes(MqTimestampSeries mqCadenceTimes) {
        dvCadenceTimes = mqCadenceTimes;
    }

    public DvModuleParameters getDvModuleParameters() {
        return dvConfigurationStruct;
    }

    public void setDvModuleParameters(DvModuleParameters dvModuleParameters) {
        dvConfigurationStruct = dvModuleParameters;
    }

    public String getExternalTceModelDescription() {
        return externalTceModelDescription;
    }

    public void setExternalTceModelDescription(
        String externalTceModelDescription) {
        this.externalTceModelDescription = externalTceModelDescription;
    }

    public FcConstants getFcConstants() {
        return fcConstants;
    }

    public void setFcConstants(FcConstants fcConstants) {
        this.fcConstants = fcConstants;
    }

    public FluxTypeParameters getFluxTypeParameters() {
        return fluxTypeConfigurationStruct;
    }

    public void setFluxTypeParameters(FluxTypeParameters fluxTypeParameters) {
        fluxTypeConfigurationStruct = fluxTypeParameters;
    }

    public GapFillModuleParameters getGapFillModuleParameters() {
        return gapFillConfigurationStruct;
    }

    public void setGapFillModuleParameters(
        GapFillModuleParameters gapFillModuleParameters) {
        gapFillConfigurationStruct = gapFillModuleParameters;
    }

    public List<CelestialObjectParameters> getKics() {
        return kics;
    }

    public void setKics(List<CelestialObjectParameters> kics) {
        this.kics = kics;
    }

    public Map<Integer, List<CelestialObjectParameters>> getKicsByKeplerId() {
        return kicsByKeplerId;
    }

    public void setKicsByKeplerId(
        Map<Integer, List<CelestialObjectParameters>> kicsByKeplerId) {
        this.kicsByKeplerId = kicsByKeplerId;
    }

    public PdcModuleParameters getPdcModuleParameters() {
        return pdcConfigurationStruct;
    }

    public void setPdcModuleParameters(PdcModuleParameters pdcModuleParameters) {
        pdcConfigurationStruct = pdcModuleParameters;
    }

    public PdcHarmonicsIdentificationParameters getPdcHarmonicsIdentificationParameters() {
        return pdcHarmonicsIdentificationConfigurationStruct;
    }

    public void setPdcHarmonicsIdentificationParameters(
        PdcHarmonicsIdentificationParameters pdcHarmonicsIdentificationParameters) {
        pdcHarmonicsIdentificationConfigurationStruct = pdcHarmonicsIdentificationParameters;
    }

    public PixelCorrelationParameters getPixelCorrelationParameters() {
        return pixelCorrelationConfigurationStruct;
    }

    public void setPixelCorrelationParameters(
        PixelCorrelationParameters pixelCorrelationParameters) {
        pixelCorrelationConfigurationStruct = pixelCorrelationParameters;
    }

    public PlanetFitModuleParameters getPlanetFitModuleParameters() {
        return planetFitConfigurationStruct;
    }

    public void setPlanetFitModuleParameters(
        PlanetFitModuleParameters planetFitModuleParameters) {
        planetFitConfigurationStruct = planetFitModuleParameters;
    }

    public RaDec2PixModel getRaDec2PixModel() {
        return raDec2PixModel;
    }

    public void setRaDec2PixModel(RaDec2PixModel raDec2PixModel) {
        this.raDec2PixModel = raDec2PixModel;
    }

    public String[] getPrfModelFileNames() {
        return prfModelFileNames;
    }

    public void setPrfModelFileNames(String[] prfModels) {
        prfModelFileNames = prfModels;
    }

    public SaturationSegmentModuleParameters getSaturationSegmentModuleParameters() {
        return saturationSegmentConfigurationStruct;
    }

    public void setSaturationSegmentModuleParameters(
        SaturationSegmentModuleParameters saturationSegmentModuleParameters) {
        saturationSegmentConfigurationStruct = saturationSegmentModuleParameters;
    }

    public int getSkyGroupId() {
        return skyGroupId;
    }

    public void setSkyGroupId(int skyGroupId) {
        this.skyGroupId = skyGroupId;
    }

    public String getSoftwareRevision() {
        return softwareRevision;
    }

    public void setSoftwareRevision(String softwareRevision) {
        this.softwareRevision = softwareRevision;
    }

    public List<DvTarget> getTargets() {
        return targetStruct;
    }

    public void setTargets(List<DvTarget> targets) {
        targetStruct = targets;
    }

    public List<DvTargetTableData> getTargetTableData() {
        return targetTableDataStruct;
    }

    public void setTargetTableData(List<DvTargetTableData> targetTableData) {
        targetTableDataStruct = targetTableData;
    }

    public int getTaskTimeoutSecs() {
        return taskTimeoutSecs;
    }

    public void setTaskTimeoutSecs(int taskTimeoutSecs) {
        this.taskTimeoutSecs = taskTimeoutSecs;
    }

    public TpsModuleParameters getTpsModuleParameters() {
        return tpsConfigurationStruct;
    }

    public void setTpsModuleParameters(TpsModuleParameters tpsModuleParameters) {
        tpsConfigurationStruct = tpsModuleParameters;
    }

    public TpsHarmonicsIdentificationParameters getTpsHarmonicsIdentificationParameters() {
        return tpsHarmonicsIdentificationConfigurationStruct;
    }

    public void setTpsHarmonicsIdentificationParameters(
        TpsHarmonicsIdentificationParameters tpsHarmonicsIdentificationParameters) {
        tpsHarmonicsIdentificationConfigurationStruct = tpsHarmonicsIdentificationParameters;
    }

    public String getTransitInjectionParametersFileName() {
        return transitInjectionParametersFileName;
    }

    public void setTransitInjectionParametersFileName(
        String transitInjectionParametersFileName) {
        this.transitInjectionParametersFileName = transitInjectionParametersFileName;
    }

    public String getTransitNameModelDescription() {
        return transitNameModelDescription;
    }

    public void setTransitNameModelDescription(
        String transitNameModelDescription) {
        this.transitNameModelDescription = transitNameModelDescription;
    }

    public String getTransitParameterModelDescription() {
        return transitParameterModelDescription;
    }

    public void setTransitParameterModelDescription(
        String transitParameterModelDescription) {
        this.transitParameterModelDescription = transitParameterModelDescription;
    }

    public TrapezoidalFitParameters getTrapezoidalFitParameters() {
        return trapezoidalFitConfigurationStruct;
    }

    public void setTrapezoidalFitParameters(
        TrapezoidalFitParameters trapezoidalFitParameters) {
        this.trapezoidalFitConfigurationStruct = trapezoidalFitParameters;
    }
}
