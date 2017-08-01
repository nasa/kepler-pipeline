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

package gov.nasa.kepler.ar.exporter;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dr.DataAnomaly;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.DataAnomalyOperations;
import gov.nasa.kepler.mc.pi.OriginatorsModelRegistryChecker;

import java.util.Collection;
import java.util.List;

/**
 * Implementation common to single and multiquarter target exporters.
 * 
 * @author Sean McCauliff
 *
 */
public abstract class DefaultTargetExporterSource implements BaseExporterSource {

    protected final TargetCrud targetCrud;
    protected final int startKeplerId;
    protected final int endKeplerId;
    
    protected final LogCrud logCrud;
    protected final DataAnomalyOperations anomalyOperations;
    protected final ConfigMapOperations configMapOps;
    protected final CelestialObjectOperations celestialObjectOps;
    
    private final FileStoreClient fsClient;
    
    private List<DataAnomaly> anomalies;

    /**
     * None of these should be null, but they are not checked to allow for
     * more flexible testing.
     * 
     * @param targetCrud
     * @param startKeplerId
     * @param endKeplerId
     * @param logCrud
     * @param anomalyOperations
     * @param configMapOps
     * @param celestialObjectOps
     * @param fsClient
     */
    public DefaultTargetExporterSource(TargetCrud targetCrud,
        int startKeplerId, int endKeplerId,
        LogCrud logCrud, DataAnomalyOperations anomalyOperations,
        ConfigMapOperations configMapOps,
        CelestialObjectOperations celestialObjectOps,
        FileStoreClient fsClient) {

        this.targetCrud = targetCrud;
        this.startKeplerId = startKeplerId;
        this.endKeplerId = endKeplerId;
        this.logCrud = logCrud;
        this.anomalyOperations = anomalyOperations;
        this.configMapOps = configMapOps;
        this.celestialObjectOps = celestialObjectOps;
        this.fsClient = fsClient;
    }

    @Override
    public OriginatorsModelRegistryChecker originatorsModelRegistryChecker() {
        return new OriginatorsModelRegistryChecker();
    }

    @Override
    public List<DataAnomaly> anomalies() {
        if (anomalies == null) {
            anomalies = anomalyOperations.retrieveDataAnomalies(mjdToCadence().cadenceType().intValue(), startCadence(), endCadence());
        }
        return anomalies;
    }

    @Override
    public Collection<ConfigMap> configMaps() {
        return configMapOps.retrieveConfigMaps(mjdToCadence().cadenceToMjd(startCadence()), mjdToCadence().cadenceToMjd(endCadence()));
    }

    @Override
    public FileStoreClient fsClient() {
        return fsClient;
    }

    @Override
    public int cadenceCount() {
        return endCadence() - startCadence() + 1;
    }

    @Override
    public CadenceType cadenceType() {
        return mjdToCadence().cadenceType();
    }
    

}
