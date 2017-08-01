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

import gov.nasa.kepler.ar.archive.BackgroundPixelValue;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.dr.MjdToCadence;

import java.util.*;

/**
 * Calculates the value of a calibrated target pixel. Subtracts background and 
 * cosmic ray.
 * 
 * @author Sean McCauliff
 *
 */
public class FluxPixelValueCalculator {

    private Set<FsId> seen = new HashSet<FsId>();
    
    /**
     * Calling this method modifies the background and calibrated pixels as it
     * fills them before performing any calculations on them.
     * 
     * @param targetMetadata
     * @param background
     * @param fsIdToTimeSeries
     * @param fsIdToMjdTimeSeries
     * @param mjdToCadence
     * @param gapFill
     */
    public void modifyCalibratedPixels(
        Map<Pixel, TimeSeries> calibratedPixels,
        Map<Pixel, FloatMjdTimeSeries> cosmicRays,
        Map<Pixel, TimeSeries> calibratedUncertainties,
        Map<Pixel, BackgroundPixelValue> background, 
        Map<FsId, TimeSeries> fsIdToTimeSeries,
        Map<FsId, FloatMjdTimeSeries> fsIdToMjdTimeSeries, 
        MjdToCadence mjdToCadence,
        float gapFill) {
       
        
        Iterator<Map.Entry<Pixel,TimeSeries>> it = calibratedPixels.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry<Pixel, TimeSeries> entry = it.next();
            TimeSeries calibratedValues =  entry.getValue();
            if (seen.contains(calibratedValues.id())) {
                continue;
            }
            DoubleTimeSeries calibratedDoubleValues = convertToDouble((FloatTimeSeries) calibratedValues);
            fsIdToTimeSeries.put(calibratedDoubleValues.id(), calibratedDoubleValues);
            
            seen.add(calibratedValues.id());
            Pixel pixel = entry.getKey();
            FloatMjdTimeSeries cosmicThing = cosmicRays.get(pixel);;
            double[] doublePixels = calibratedDoubleValues.dseries();
            double[] cosmicRayMjds = cosmicThing.mjd();
            float[] cosmicRayValues = cosmicThing.values();
            for (int i=0; i < cosmicRayMjds.length; i++) {
                int cadence = mjdToCadence.mjdToCadence(cosmicRayMjds[i]);
                int pixelDataIndex = cadence - calibratedValues.startCadence();
                doublePixels[pixelDataIndex] = 
                    doublePixels[pixelDataIndex] - ((double)cosmicRayValues[i]);
            }
            
            BackgroundPixelValue backgroundPixelValue = background.get(pixel);
            backgroundPixelValue.fillGaps(gapFill);
            double[] backgroundData = backgroundPixelValue.getBackground();
            for (int i=0; i < backgroundData.length; i++) {
                doublePixels[i] = doublePixels[i] - backgroundData[i];
            }
            
            calibratedDoubleValues.fillGaps(gapFill);
            
            DoubleTimeSeries uncertainties = convertToDouble((FloatTimeSeries)calibratedUncertainties.get(pixel));
            fsIdToTimeSeries.put(uncertainties.id(), uncertainties);
            double[] backgroundUncertData = backgroundPixelValue.getBackgroundUncertainties();
            double[] uncertData = uncertainties.dseries();
            
            if (backgroundUncertData.length != uncertData.length) {
                throw new IllegalStateException("backgorundUncertData.length != uncertData.length");
            }
            
            for (int i=0; i < uncertData.length; i++) {
                double uncertSquared = 
                    uncertData[i] * uncertData[i] +
                      backgroundUncertData[i] *  backgroundUncertData[i];
                uncertData[i] = Math.sqrt(uncertSquared);
            }
            
            uncertainties.fillGaps(gapFill);
            
        }
    }
    
    
    private static DoubleTimeSeries convertToDouble(FloatTimeSeries fts) {
        float[] values = fts.fseries();
        double[] doubleValues = new double[values.length];
        for (int i=0; i < values.length; i++) {
            doubleValues[i] = values[i];
        }
        return new DoubleTimeSeries(fts.id(), doubleValues, fts.startCadence(), fts.endCadence(),
            fts.validCadences(), fts.originators());
    }
}
