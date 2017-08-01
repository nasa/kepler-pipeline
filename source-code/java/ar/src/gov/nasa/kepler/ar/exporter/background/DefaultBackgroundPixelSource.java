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

package gov.nasa.kepler.ar.exporter.background;

import gov.nasa.kepler.ar.exporter.ParametersUsedInCalibration;
import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.KeplerSocVersion;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.dr.DataAnomaly;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.SciencePixelOperations;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.DataAnomalyOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;

import java.util.Collection;
import java.util.List;
import java.util.Set;

/**
 * Some useful defaults for implementing the BackgroundPixelSource.
 * @author Sean McCauliff
 *
 */
public abstract class DefaultBackgroundPixelSource implements BackgroundPixelSource {
    
    private final SciencePixelOperations sciOps;
    private final TargetTable ttable;
    private List<DataAnomaly> anomalies;
    private final DataAnomalyOperations anomalyOps;
    private final ConfigMapOperations configMapOps;
    private final ReadNoiseOperations readNoiseOps;
    private final GainOperations gainOps;
    private final CompressionCrud compressionCrud;
    private final KicCrud kicCrud;
    private ParametersUsedInCalibration calibration;
    private int skyGroup = Integer.MIN_VALUE;
    private final TimestampSeries cadenceTimes;

    
    
    public DefaultBackgroundPixelSource(SciencePixelOperations sciOps,
        TargetTable ttable, DataAnomalyOperations anomalyOps,
        ConfigMapOperations configMapOps, ReadNoiseOperations readNoiseOps,
        GainOperations gainOps, CompressionCrud compressionCrud,
        KicCrud kicCrud, TimestampSeries cadenceTimes) {

        this.sciOps = sciOps;
        this.ttable = ttable;
        this.anomalyOps = anomalyOps;
        this.configMapOps = configMapOps;
        this.readNoiseOps = readNoiseOps;
        this.gainOps = gainOps;
        this.compressionCrud = compressionCrud;
        this.kicCrud = kicCrud;
        this.cadenceTimes = cadenceTimes;
    }

    private ParametersUsedInCalibration calibration() {
        if (ttable == null) {
            targetTableExternalId();
        }
        
        if (calibration == null) {
            calibration = new ParametersUsedInCalibration(readNoiseOps, gainOps,
                ttable, compressionCrud,
                mjdToCadence().cadenceToMjd(startCadence()),
                mjdToCadence().cadenceToMjd(endCadence()),
                ccdModule(), ccdOutput());
        }
        return calibration;
    }
    
    @Override
    public Set<Pixel> backgroundPixels() {
        return sciOps.getBackgroundPixels();
    }

    @Override
    public int targetTableExternalId() {
        return ttable.getExternalId();
    }

    @Override
    public double startStartMjd() {
        return cadenceTimes.startTimestamps[0];
    }

    @Override
    public double endEndMjd() {
        return cadenceTimes.endTimestamps[cadenceTimes.endTimestamps.length - 1];
    }

    @Override
    public List<DataAnomaly> anomalies() {
        if (anomalies == null) {
            anomalies = anomalyOps.retrieveDataAnomalies(Cadence.CADENCE_LONG, startCadence(), endCadence());
        }
        return anomalies;
    }

    @Override
    public Collection<ConfigMap> configMaps() {
        return configMapOps.retrieveConfigMaps(mjdToCadence().cadenceToMjd(startCadence()), mjdToCadence().cadenceToMjd(endCadence()));
    }
    
    @Override
    public int meanBlack() {
        return calibration().meanBlackValue();
    }

    @Override
    public double gainE() {
        return calibration().gainE();
    }

    @Override
    public double readNoseE() {
        return calibration().readNoiseE();
    }
    
    @Override
    public int skyGroup() {
        if (skyGroup == Integer.MIN_VALUE) {
            skyGroup =  kicCrud.retrieveSkyGroupId(ccdModule(), ccdOutput(), ttable.getObservingSeason());
        }
        return skyGroup;
    }
    
    @Override
    public int season() {
        return ttable.getObservingSeason();
    }
    
    @Override
    public String subversionUrl() {
        return KeplerSocVersion.getUrl();
    }
    
    @Override
    public String subversionRevision() {
        return KeplerSocVersion.getRevision();
    }

}
