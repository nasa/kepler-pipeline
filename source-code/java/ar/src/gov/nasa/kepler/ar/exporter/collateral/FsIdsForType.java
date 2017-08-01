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

import static gov.nasa.kepler.ar.exporter.binarytable.SingleCadenceImageWriter.newImageWriter;
import static gov.nasa.kepler.common.CollateralType.BLACK_MASKED;
import static gov.nasa.kepler.common.CollateralType.BLACK_VIRTUAL;
import gov.nasa.kepler.ar.exporter.ExposureCalculator;
import gov.nasa.kepler.ar.exporter.binarytable.ByteCopier;
import gov.nasa.kepler.ar.exporter.binarytable.FloatArrayDataCopier;
import gov.nasa.kepler.ar.exporter.binarytable.FloatMjdArrayDataCopier;
import gov.nasa.kepler.ar.exporter.binarytable.IntArrayDataCopier;
import gov.nasa.kepler.ar.exporter.binarytable.RollingBandVariationCopier;
import gov.nasa.kepler.ar.exporter.binarytable.SingleCadenceImageWriter;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.mc.dr.MjdToCadence;

import java.io.DataOutput;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.google.common.collect.ImmutableList;

/**
 * The FsIdsTo use for some collateral type.
 * 
 * @author Sean McCauliff
 *
 */
final class FsIdsForType {
    /**
     * None of these are allowed to be null.
     */
    final CollateralType collateralType;
    final List<FsId> raw;
    final List<FsId> calibrated;
    final List<FsId> umm;
    final List<FsId> cosmicRay;
    final List<FsId> rollingBandVariation;
    final List<FsId> rollingBandFlags;
    
    FsIdsForType(List<FsId> raw, List<FsId> calibrated,
        List<FsId> umm, List<FsId> cosmicRay, 
        List<FsId> rollingBandVariation,
        List<FsId> rollingBandFlags,
        CollateralType collateralType) {
        
        if (collateralType == null) {
            throw new NullPointerException("collateralType");
        }
        
        if (raw.size() != calibrated.size()) {
            throw new IllegalArgumentException("raw.size() != calibrated.size()");
        }
        if (raw.size() != umm.size()) {
            throw new IllegalArgumentException("raw.size() != umm.size()");
        }
        
        if (raw.size() != cosmicRay.size()) {
            throw new IllegalArgumentException("raw.size() != cosmicRay.size()");
        }
        if (collateralType == BLACK_MASKED || collateralType == BLACK_VIRTUAL) {
            if (raw.size() != 1) {
                throw new IllegalArgumentException("Invalid number of 2d collateral pixels:" + raw.size() + ".");
            }
        }
        if (rollingBandFlags.size() != rollingBandVariation.size()) {
            throw new IllegalArgumentException("Rolling band flags and variation must be of equal size.");
        }

        this.raw = raw;
        this.calibrated = calibrated;
        this.umm = umm;
        this.cosmicRay = cosmicRay;
        this.collateralType = collateralType;
        this.rollingBandFlags = rollingBandFlags;
        this.rollingBandVariation = rollingBandVariation;
    }
    
    public Collection<? extends SingleCadenceImageWriter<?>> imageWriters(
        DataOutput dout, int startCadence, MjdToCadence mjdToCadence,
        ExposureCalculator exposureCalc,
        Map<FsId, TimeSeries> allTimeSeries,
        Map<FsId, FloatMjdTimeSeries> allCosmicRay,
        Map<FsId, byte[]> allRollingBandFlags) {

        SingleCadenceImageWriter<TimeSeries> rawWriter = 
            newImageWriter(raw, allTimeSeries, new IntArrayDataCopier(), dout);
        SingleCadenceImageWriter<TimeSeries> calWriter =
            newImageWriter(calibrated, allTimeSeries, 
                new FloatArrayDataCopier(exposureCalc), dout);
        SingleCadenceImageWriter<TimeSeries> ummWriter = 
            newImageWriter(umm, allTimeSeries,
                new FloatArrayDataCopier(exposureCalc), dout);
        SingleCadenceImageWriter<FloatMjdTimeSeries> cosmicRayWriter =
            newImageWriter(cosmicRay, allCosmicRay,
                new FloatMjdArrayDataCopier(startCadence, mjdToCadence, exposureCalc),
                dout);
        
        if (rollingBandFlags.isEmpty()) {
            return ImmutableList.of(rawWriter, calWriter, ummWriter,
                cosmicRayWriter);
        }
        
        //Collateral type is BLACK_LEVEL and we have rolling band flags.
        @SuppressWarnings("unchecked")
        Map<FsId, DoubleTimeSeries> allTimeSeriesAsDouble = 
            (Map<FsId, DoubleTimeSeries>) ((Map)allTimeSeries);
        SingleCadenceImageWriter<DoubleTimeSeries> rbLevelWriter =
            newImageWriter(rollingBandVariation, allTimeSeriesAsDouble,
                new RollingBandVariationCopier(), dout);
        
        SingleCadenceImageWriter<byte[]> rbFlagWriter = 
            newImageWriter(rollingBandFlags, allRollingBandFlags,
                new ByteCopier(), dout);
        
        return ImmutableList.of(rawWriter, calWriter, ummWriter, cosmicRayWriter, rbLevelWriter, rbFlagWriter);
    }

    public int size() {
        return raw.size();
    }

}