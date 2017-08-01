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

package gov.nasa.kepler.ar.exporter.arp;

import gov.nasa.kepler.ar.exporter.ParametersUsedInCalibration;
import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.KeplerSocVersion;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dr.DataAnomaly;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.mc.SciencePixelOperations;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.DataAnomalyOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;

import java.util.Collection;
import java.util.List;

import com.google.common.collect.Lists;

/**
 * Some default implementations of the ARP exporter source.
 * 
 * @author Sean McCauliff
 *
 */
public abstract class DefaultArpExporterSource implements ArpExporterSource {

    private static final String ARTIFACT_REMOVAL = "ARTIFACT_REMOVAL";

    private final TargetCrud targetCrud;
    private final SciencePixelOperations sciOps;
    private final TimestampSeries cadenceTimes;
    private final CompressionCrud compressionCrud;
    private final TargetTable targetTable;
    private final ReadNoiseOperations readNoiseOps;
    private final GainOperations gainOps;
    private final DataAnomalyOperations dataAnomalyOps;
    private final ConfigMapOperations configMapOps;
    
    private ParametersUsedInCalibration calibration;
    

    public DefaultArpExporterSource(TargetCrud targetCrud,
        SciencePixelOperations sciOps, TimestampSeries cadenceTimes,
        CompressionCrud compressionCrud, TargetTable targetTable,
        ReadNoiseOperations readNoiseOps, GainOperations gainOps,
        DataAnomalyOperations dataAnomalyOps, ConfigMapOperations configMapOps) {
        super();
        this.targetCrud = targetCrud;
        this.sciOps = sciOps;
        this.cadenceTimes = cadenceTimes;
        this.compressionCrud = compressionCrud;
        this.targetTable = targetTable;
        this.readNoiseOps = readNoiseOps;
        this.gainOps = gainOps;
        this.dataAnomalyOps = dataAnomalyOps;
        this.configMapOps = configMapOps;
    }

    private ParametersUsedInCalibration calibration() {
        if (calibration == null) {
            calibration = new ParametersUsedInCalibration(readNoiseOps, gainOps,
                targetTable, compressionCrud,
                mjdToCadence().cadenceToMjd(startCadence()),
                mjdToCadence().cadenceToMjd(endCadence()),
                ccdModule(), ccdOutput());
        }
        return calibration;
    }

    @Override
    public String subversionUrl() {
        return KeplerSocVersion.getUrl();
    }

    @Override
    public String subversionRevision() {
        return KeplerSocVersion.getRevision();
    }

    @Override
    public ObservedTarget arpObservedTarget() {
        List<ObservedTarget> allTargetsForModOut = 
            targetCrud.retrieveObservedTargets(targetTable, ccdModule(), ccdOutput());
        List<ObservedTarget> arpTargets = Lists.newArrayList();
        for (ObservedTarget ot : allTargetsForModOut) {
            if (ot.getLabels().contains(ARTIFACT_REMOVAL)) {
                arpTargets.add(ot);
            }
        }
        if (arpTargets.size() > 1) {
            throw new IllegalStateException("Expected only a single target, but found " + arpTargets.size() + ".");
        }
        if (arpTargets.isEmpty()) {
            return null;
        }
        return arpTargets.get(0);
    }

    @Override
    public SciencePixelOperations sciencePixelOps() {
        return sciOps;
    }

    @Override
    public FileStoreClient fileStoreClient() {
        return FileStoreClientFactory.getInstance();
    }

    @Override
    public double startMidMjd() {
        return cadenceTimes.midTimestamps[0];
    }

    @Override
    public double endMidMjd() {
        return cadenceTimes.midTimestamps[cadenceTimes.midTimestamps.length - 1];
    }

    @Override
    public List<DataAnomaly> dataAnomalies() {
        return dataAnomalyOps.retrieveDataAnomalies(Cadence.CADENCE_LONG, startCadence(), endCadence());
    }

    @Override
    public TimestampSeries cadenceTimes() {
        return cadenceTimes;
    }
    
    @Override
    public double readNoiseE() {
        return calibration().readNoiseE();
    }

    @Override
    public int meanBlack() {
        return calibration().meanBlackValue();
    }

    @Override
    public double gainEPerCount() {
        return calibration().gainE();
    }

    @Override
    public Collection<ConfigMap> configMaps() {
        return configMapOps.retrieveConfigMaps(startMidMjd(), endMidMjd());
    }
    
    @Override
    public int targetTableId() {
        return targetTable.getExternalId();
    }

}
