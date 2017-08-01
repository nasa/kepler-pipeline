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

package gov.nasa.kepler.ar.exporter.collateral;

import gov.nasa.kepler.ar.exporter.ParametersUsedInCalibration;
import gov.nasa.kepler.cm.TargetSelectionOperations;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.pmrf.CollateralPmrfTable;
import gov.nasa.kepler.mc.pmrf.PmrfOperations;

import java.util.Collection;

/**
 * Some useful default implementations for the CollateralPixelExporterSource
 * @author Sean McCauliff
 *
 */
public abstract class DefaultCollateralPixelExporterSource 
    implements CollateralPixelExporterSource {

    private final MjdToCadence mjdToCadence;
    private final ConfigMapOperations configMapOps;
    private final TargetTable ttable;
    private final PmrfOperations pmrfOps;
    private final ReadNoiseOperations readNoiseOps;
    private final GainOperations gainOps;
    private final CompressionCrud compressionCrud;
    private final TargetSelectionOperations targetSelectionOps;
    
    private ParametersUsedInCalibration calibration;

    private double startMjd = Double.NaN;
    private double endMjd = Double.NaN;
    

    

    public DefaultCollateralPixelExporterSource(MjdToCadence mjdToCadence,
        ConfigMapOperations configMapOps, TargetTable ttable,
        PmrfOperations pmrfOps, ReadNoiseOperations readNoiseOps,
        GainOperations gainOps, CompressionCrud compressionCrud,
        TargetSelectionOperations targetSelectionOps) {
        super();
        this.mjdToCadence = mjdToCadence;
        this.configMapOps = configMapOps;
        this.ttable = ttable;
        this.pmrfOps = pmrfOps;
        this.readNoiseOps = readNoiseOps;
        this.gainOps = gainOps;
        this.compressionCrud = compressionCrud;
        this.targetSelectionOps = targetSelectionOps;
    }

    private ParametersUsedInCalibration calibration() {
        if (calibration == null) {
            calibration = new ParametersUsedInCalibration(readNoiseOps, gainOps,
                ttable, compressionCrud, startMidMjd(), endMidMjd(), 
                ccdModule(), ccdOutput());
        }
        return calibration;
    }
    
    @Override
    public CollateralPmrfTable prmfTable() {
        return pmrfOps.getCollateralPmrfTable(cadenceType(), ttable.getExternalId(),
            ccdModule(), ccdOutput());
    }

    @Override
    public FileStoreClient fileStoreClient() {
        return FileStoreClientFactory.getInstance();
    }

    @Override
    public double startMidMjd() {
        if (Double.isNaN(startMjd)) {
            startMjd = mjdToCadence.cadenceToMjd(startCadence());
        }
        return startMjd;
    }

    @Override
    public double endMidMjd() {
        if (Double.isNaN(endMjd)) {
            endMjd = mjdToCadence.cadenceToMjd(endCadence());
        }
        return endMjd;
    }

    @Override
    public CadenceType cadenceType() {
        return mjdToCadence.cadenceType();
    }
    
    @Override
    public Collection<ConfigMap> configMaps() {
        return configMapOps.retrieveConfigMaps(mjdToCadence().cadenceToMjd(startCadence()), mjdToCadence().cadenceToMjd(endCadence()));
    }

    @Override
    public int skyGroup() {
        return targetSelectionOps.skyGroupIdFor(ccdModule(), ccdOutput(), ttable.getObservingSeason());
    }

    @Override
    public int season() {
        return ttable.getObservingSeason();
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
    public MjdToCadence mjdToCadence() {
        return mjdToCadence;
    }

}
