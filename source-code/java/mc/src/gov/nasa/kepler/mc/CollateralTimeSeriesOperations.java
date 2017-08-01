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

package gov.nasa.kepler.mc;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.mc.dr.PixelTimeSeriesOperations;
import gov.nasa.kepler.mc.dr.PixelTimeSeriesReader;
import gov.nasa.kepler.mc.pmrf.PmrfOperations;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.HashSet;
import java.util.Set;
import java.util.TreeSet;

/**
 * Operations on {@link FsId}s and {@link TimeSeries} for collateral pixels.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public class CollateralTimeSeriesOperations extends TimeSeriesOperations {

    private CadenceType cadenceType;
    private int targetTableId;
    private int ccdModule;
    private int ccdOutput;

    private Set<FsId> collateralFsIds;
    private Set<FsId> maskedSmearFsIds;
    private Set<FsId> virtualSmearFsIds;
    private Set<FsId> blackLevelFsIds;
    private Set<FsId> maskedBlackFsIds;
    private Set<FsId> virtualBlackFsIds;

    private PmrfOperations pmrfOperations;

    /**
     * Creates a {@link CollateralTimeSeriesOperations} object which can be used
     * to access {@link FsId}s and {@link TimeSeries} associated with the given
     * parameters.
     */
    public CollateralTimeSeriesOperations(CadenceType cadenceType,
        int targetTableId, int ccdModule, int ccdOutput) {
        this(cadenceType, targetTableId, ccdModule, ccdOutput,
            new PixelTimeSeriesOperations());
    }

    public CollateralTimeSeriesOperations(CadenceType cadenceType,
        int targetTableId, int ccdModule, int ccdOutput,
        PixelTimeSeriesReader pixelTimeSeriesReader) {
        super(pixelTimeSeriesReader);
        this.cadenceType = cadenceType;
        this.targetTableId = targetTableId;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
    }

    /**
     * Collects all of the collateral {@link FsId}s.
     * 
     * @throws PipelineException if there were problems accessing the data
     * store.
     */
    private void collectFsIds() {
        collateralFsIds = new TreeSet<FsId>();

        maskedSmearFsIds = new HashSet<FsId>();
        maskedSmearFsIds.addAll(getPmrfOperations().getCollateralPixelFsIds(
            cadenceType, targetTableId, ccdModule, ccdOutput,
            CollateralType.MASKED_SMEAR));
        collateralFsIds.addAll(maskedSmearFsIds);

        virtualSmearFsIds = new HashSet<FsId>();
        virtualSmearFsIds.addAll(getPmrfOperations().getCollateralPixelFsIds(
            cadenceType, targetTableId, ccdModule, ccdOutput,
            CollateralType.VIRTUAL_SMEAR));
        collateralFsIds.addAll(virtualSmearFsIds);

        blackLevelFsIds = new HashSet<FsId>();
        blackLevelFsIds.addAll(getPmrfOperations().getCollateralPixelFsIds(
            cadenceType, targetTableId, ccdModule, ccdOutput,
            CollateralType.BLACK_LEVEL));
        collateralFsIds.addAll(blackLevelFsIds);

        maskedBlackFsIds = new HashSet<FsId>();
        maskedBlackFsIds.addAll(getPmrfOperations().getCollateralPixelFsIds(
            cadenceType, targetTableId, ccdModule, ccdOutput,
            CollateralType.BLACK_MASKED));
        collateralFsIds.addAll(maskedBlackFsIds);

        virtualBlackFsIds = new HashSet<FsId>();
        virtualBlackFsIds.addAll(getPmrfOperations().getCollateralPixelFsIds(
            cadenceType, targetTableId, ccdModule, ccdOutput,
            CollateralType.BLACK_VIRTUAL));
        collateralFsIds.addAll(virtualBlackFsIds);
    }

    /**
     * Returns all of the collateral time series over the given duration.
     * 
     * @return a non-{@code null} time series.
     * @throws PipelineException if there were problems accessing the data
     * store.
     */
    public IntTimeSeries[] readCollateralTimeSeries(int startCadence,
        int endCadence) {

        if (collateralFsIds == null) {
            collectFsIds();
        }

        return readPixelTimeSeriesAsInt(collateralFsIds.toArray(new FsId[0]),
            startCadence, endCadence);
    }

    /**
     * Returns all of the collateral {@link FsId}s.
     * 
     * @return a non-{@code null} set of {@link FsId}s.
     * @throws PipelineException if there were problems accessing the data
     * store.
     */
    public Set<FsId> getCollateralFsIds() {
        if (collateralFsIds == null) {
            collectFsIds();
        }

        return collateralFsIds;
    }

    /**
     * Returns all of the masked smear {@link FsId}s.
     * 
     * @return a non-{@code null} set of {@link FsId}s.
     * @throws PipelineException if there were problems accessing the data
     * store.
     */
    public Set<FsId> getMaskedSmearFsIds() {
        if (maskedSmearFsIds == null) {
            collectFsIds();
        }

        return maskedSmearFsIds;
    }

    /**
     * Returns all of the virtual smear {@link FsId}s.
     * 
     * @return a non-{@code null} set of {@link FsId}s.
     * @throws PipelineException if there were problems accessing the data
     * store.
     */
    public Set<FsId> getVirtualSmearFsIds() {
        if (virtualSmearFsIds == null) {
            collectFsIds();
        }

        return virtualSmearFsIds;
    }

    /**
     * Returns all of the black level {@link FsId}s.
     * 
     * @return a non-{@code null} set of {@link FsId}s.
     * @throws PipelineException if there were problems accessing the data
     * store.
     */
    public Set<FsId> getBlackLevelFsIds() {
        if (blackLevelFsIds == null) {
            collectFsIds();
        }

        return blackLevelFsIds;
    }

    /**
     * Returns all of the masked black {@link FsId}s.
     * 
     * @return a non-{@code null} set of {@link FsId}s.
     * @throws PipelineException if there were problems accessing the data
     * store.
     */
    public Set<FsId> getMaskedBlackFsIds() {
        if (maskedBlackFsIds == null) {
            collectFsIds();
        }

        return maskedBlackFsIds;
    }

    /**
     * Returns all of the virtual black {@link FsId}s.
     * 
     * @return a non-{@code null} set of {@link FsId}s.
     * @throws PipelineException if there were problems accessing the data
     * store.
     */
    public Set<FsId> getVirtualBlackFsIds() {
        if (virtualBlackFsIds == null) {
            collectFsIds();
        }

        return virtualBlackFsIds;
    }

    /**
     * Returns the {@link PmrfOperations} object used by this object.
     * 
     * @throws PipelineException if there problems creating the initial instance
     * of the {@link PmrfOperations} object.
     */
    public PmrfOperations getPmrfOperations() {
        if (pmrfOperations == null) {
            pmrfOperations = new PmrfOperations();
        }
        return pmrfOperations;
    }

    /**
     * Sets the {@link PmrfOperations} for this object. This method is typically
     * only needed for testing.
     * 
     * @param pmrfOperations the {@link PmrfOperations} object.
     */
    public void setPmrfOperations(PmrfOperations pmrfOperations) {
        this.pmrfOperations = pmrfOperations;
    }
}
