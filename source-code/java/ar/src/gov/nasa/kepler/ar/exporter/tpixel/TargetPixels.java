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

package gov.nasa.kepler.ar.exporter.tpixel;

import gov.nasa.kepler.ar.exporter.PixelByRowColumn;
import gov.nasa.kepler.common.SortedMapSortedKeySet;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesDataType;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;

import java.util.*;

import com.google.common.collect.ImmutableSortedMap;

/**
 * Pixel FsIds for a set of Pixels.
 * 
 * @author Sean McCauliff
 *
 */
final class TargetPixels {

    
    static final class PixelIds {
        final FsId rawId;
        final FsId calibratedId;
        final FsId ummId;
        final FsId cosmicRayId;
        
        
        public PixelIds(FsId rawId, FsId calibratedId, FsId ummId,
            FsId cosmicRayId) {
            this.rawId = rawId;
            this.calibratedId = calibratedId;
            this.ummId = ummId;
            this.cosmicRayId = cosmicRayId;
        }
    }
    
    interface FsIdSelector {
        FsId selectId(PixelIds pixelIds);
    }
    
    private final SortedMap<Pixel, PixelIds> pixelFsIds;
    
    TargetPixels(Collection<Pixel> aperturePixels, int ccdModule, int ccdOutput,
         TargetType targetType, boolean droppedBySupplementalTad) {

        ImmutableSortedMap.Builder<Pixel, PixelIds> pixelFsIdsBuilder  =
            new ImmutableSortedMap.Builder<Pixel, PixelIds>(PixelByRowColumn.INSTANCE);
        
        for (Pixel pixel : aperturePixels) {
            int row = pixel.getRow();
            int column = pixel.getColumn();
            FsId rawId = DrFsIdFactory.getSciencePixelTimeSeries(DrFsIdFactory.TimeSeriesType.ORIG,
                targetType, ccdModule, ccdOutput, row, column);
            FsId calId = CalFsIdFactory.getTimeSeriesFsId(CalFsIdFactory.PixelTimeSeriesType.SOC_CAL,
                targetType, ccdModule, ccdOutput, row, column);
            FsId calUmmId = CalFsIdFactory.getTimeSeriesFsId(CalFsIdFactory.PixelTimeSeriesType.SOC_CAL_UNCERTAINTIES,
                targetType, ccdModule, ccdOutput, row, column);
            FsId cosmicRayId = PaFsIdFactory.getCosmicRaySeriesFsId(targetType, ccdModule, ccdOutput, row, column);
            if (droppedBySupplementalTad) {
                pixel = new Pixel(row, column, false);
            }
            pixelFsIdsBuilder.put(pixel, new PixelIds(rawId, calId, calUmmId, cosmicRayId));
        }
        pixelFsIds = pixelFsIdsBuilder.build();
    }
    
    <T> SortedMap<Pixel,T> extractSeries(Map<FsId,T> allSeries, FsIdSelector selector) {
        SortedMap<Pixel,T> extractedSeries = new TreeMap<Pixel, T>(PixelByRowColumn.INSTANCE);
        
        for (Map.Entry<Pixel,PixelIds> pixelIds : this.pixelFsIds.entrySet()) {
            extractedSeries.put(pixelIds.getKey(), allSeries.get(selector.selectId(pixelIds.getValue())));
        }
        return extractedSeries;
    }
    

    void addTimeSeriesIds(Map<FsId, TimeSeriesDataType> totalSet) {
        for (PixelIds pixelIds : pixelFsIds.values()) {
            totalSet.put(pixelIds.calibratedId, TimeSeriesDataType.FloatType);
            totalSet.put(pixelIds.rawId, TimeSeriesDataType.IntType);
            totalSet.put(pixelIds.ummId, TimeSeriesDataType.FloatType);
        }
    }
    
    void addMjdTimeSeriesIds(Set<FsId> totalSet) {
        for (PixelIds pixelIds : pixelFsIds.values()) {
            totalSet.add(pixelIds.cosmicRayId);
        }
    }
    
    SortedMap<Pixel,TimeSeries> rawPixels(Map<FsId,TimeSeries> allSeries) {
        return extractSeries(allSeries, new FsIdSelector() {
            
            @Override
            public FsId selectId(PixelIds pixelIds) {
                return pixelIds.rawId;
            }
        });
    }
    
    SortedMap<Pixel,TimeSeries> calibratedPixels(Map<FsId,TimeSeries> allSeries) {
        return extractSeries(allSeries, new FsIdSelector() {
            
            @Override
            public FsId selectId(PixelIds pixelIds) {
                return pixelIds.calibratedId;
            }
        });
        
    }
    
    SortedMap<Pixel,TimeSeries> ummPixels(Map<FsId,TimeSeries> allSeries) {
        return extractSeries(allSeries, new FsIdSelector() {
            
            @Override
            public FsId selectId(PixelIds pixelIds) {
                return pixelIds.ummId;
            }
        });
    }
    
    SortedMap<Pixel,FloatMjdTimeSeries> cosmicRays(Map<FsId,FloatMjdTimeSeries> allSeries) {
        return extractSeries(allSeries, new FsIdSelector() {
            
            @Override
            public FsId selectId(PixelIds pixelIds) {
                return pixelIds.cosmicRayId;
            }
        });
    }
    
    SortedMap<Pixel,FloatMjdTimeSeries> optimalApertureCosmicRays(Map<FsId, FloatMjdTimeSeries> allSeries) {

        SortedMap<Pixel,FloatMjdTimeSeries> optimalApertureCosmicRays =
            new TreeMap<Pixel, FloatMjdTimeSeries>(PixelByRowColumn.INSTANCE);
        for (Map.Entry<Pixel, PixelIds> entry : this.pixelFsIds.entrySet()) {
            if (entry.getKey().isInOptimalAperture()) {
                optimalApertureCosmicRays.put(entry.getKey(), allSeries.get(entry.getValue().cosmicRayId));
            }
        }
        return optimalApertureCosmicRays;
    }
    
    SortedSet<Pixel> aperturePixels() {
        return new SortedMapSortedKeySet<Pixel>(pixelFsIds);
    }
    
    boolean hasData(Map<FsId,TimeSeries> allSeries, Map<FsId,FloatMjdTimeSeries> allMjdTimeSeries) {
        for (PixelIds fsIdsForPixel : this.pixelFsIds.values()) {
            if (!allSeries.get(fsIdsForPixel.calibratedId).isEmpty()) {
                return true;
            }
            if (!allSeries.get(fsIdsForPixel.rawId).isEmpty()) {
                return true;
            }
            if (!allSeries.get(fsIdsForPixel.ummId).isEmpty()) {
                return true;
            }
            if (allMjdTimeSeries.get(fsIdsForPixel.cosmicRayId).mjd().length != 0) {
                return true;
            }
        }

        return false;
    }
    
}
