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

package gov.nasa.kepler.ar.exporter.cal;

import static gov.nasa.kepler.common.FitsConstants.*;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;

import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import nom.tam.fits.FitsException;

/**
 * Gets pixels out of the filestore and removes cosmic rays from them.
 * 
 * @author Sean McCauliff
 * 
 */
public class CalibratedPixelExtractor {

    private final FileStoreClient fsClient;

    private final Set<FsId> pixelIds = new HashSet<FsId>();

    private final Set<FsId> cosmicRayIds = new HashSet<FsId>();
    
    private final Set<FsId> ummFsIds = new HashSet<FsId>();
    
    private final Map<FsId, FsId> pixelIdToCosmicRayId = new HashMap<FsId, FsId>();

    /** Also includes uncertainties. */
    private final Map<FsId, FloatTimeSeries> pixels = new HashMap<FsId, FloatTimeSeries>();

    private final Map<FsId, FloatMjdTimeSeries> cosmicRays = new HashMap<FsId, FloatMjdTimeSeries>();
    
    /** Don't ask for more pixels ids if we have already seen them. */
    private final Set<String> pmrfsSeen = new HashSet<String>();

    private final int cadenceStart;
    private final int cadenceEnd;
    private final MjdToCadence mjdToCadence;
    private final double mjdStart;
    private final double mjdEnd;
    private final int module;
    private final int output;

    /**
     * 
     * @param fsClient
     * @param mjdToCadence
     * @param cadenceStart  This must exist.
     * @param cadenceEnd This must exist.
     * @param module
     * @param output
     */
    public CalibratedPixelExtractor(FileStoreClient fsClient,
        MjdToCadence mjdToCadence, int cadenceStart, int cadenceEnd,
        int module, int output) {

        this.cadenceStart = cadenceStart;
        this.cadenceEnd = cadenceEnd;
        this.fsClient = fsClient;
        this.mjdToCadence = mjdToCadence;
        this.module = module;
        this.output = output;

        mjdStart = mjdToCadence.cadenceToMjd(cadenceStart);
        mjdEnd = mjdToCadence.cadenceToMjd(cadenceEnd);
    }

    public Map<FsId, FloatTimeSeries> calibratedPixels() {
        return pixels;
    }

    public Map<FsId, FloatMjdTimeSeries> cosmicRays() {
        return cosmicRays;
    }
    
    /**
     * 
     * @return A map from mjd to the set of time series that have a cosmic ray
     * data point at that mjd time.
     */
    public Map<Double, Set<FloatMjdTimeSeries>> cosmicRaysByMjd() {
        Map<Double, Set<FloatMjdTimeSeries>> byTimeMutable = 
            new HashMap<Double, Set<FloatMjdTimeSeries>>();
        for (FloatMjdTimeSeries crSeries : cosmicRays.values()) {
            for (double cosmicRayMjd : crSeries.mjd()) {
                Set<FloatMjdTimeSeries> setForMjd = byTimeMutable.get(cosmicRayMjd);
                if (setForMjd == null) {
                    setForMjd = new HashSet<FloatMjdTimeSeries>();
                    byTimeMutable.put(cosmicRayMjd, setForMjd);
                }
                setForMjd.add(crSeries);
            }
        }
        
        //Construct an immutable map.
        Map<Double, Set<FloatMjdTimeSeries>> byTimeImmutable = 
            new HashMap<Double, Set<FloatMjdTimeSeries>>(byTimeMutable.size());
        for (Map.Entry<Double, Set<FloatMjdTimeSeries>> entry : byTimeMutable.entrySet()) {
            byTimeImmutable.put(entry.getKey(), Collections.unmodifiableSet(entry.getValue()));
        }
        return Collections.unmodifiableMap(byTimeImmutable);
    }
    
    

    /**
     * Adds to the list of pixel FsIds, and their associated cosmic rays ids.
     * @param info
     * @param module
     * @param output
     * @param pDataType
     * @throws IOException
     * @throws FitsException 
     */
    public void addPixels(OutputFileInfo info, PixelTypeInterface pDataType)
        throws IOException, FitsException {

    	if (pmrfsSeen.contains(info.pmrfName())) {
    		return;
    	}
    	pmrfsSeen.add(info.pmrfName());
    	
        List<FsId> pixelIdList = 
        	pDataType.pixelIds(info, module, output, FsIdFactoryType.CALIBRATED);
        
        List<FsId> cosmicRayIdList =
        	pDataType.pixelIds(info, module, output, FsIdFactoryType.COSMIC_RAY);
        
        if (pixelIdList.size() != pixelIdList.size()) {
        	throw new IllegalStateException("Pixel id list does not match cosmic ray id list.");
        }

        cosmicRayIds.addAll(cosmicRayIdList);
        pixelIds.addAll(pixelIdList);
        
        List<FsId> ummList = 
        	pDataType.pixelIds(info, module, output, FsIdFactoryType.CALIBRATED_UNCERT);
        
        ummFsIds.addAll(ummList);

        for (int i=0; i < pixelIdList.size(); i++) {
        	pixelIdToCosmicRayId.put(pixelIdList.get(i), cosmicRayIdList.get(i));
        }
        
    }

    @SuppressWarnings("deprecation")
    public void loadPixelsAndRays() {
        FsId[] idArray = new FsId[pixelIds.size() + ummFsIds.size()];
        int i = 0;
        for (FsId id : pixelIds) {
            idArray[i++] = id;
        }
        for (FsId id : ummFsIds) {
            idArray[i++] = id;
        }

        //TODO: When we have collateral uncertainties reenable existsError.
        FloatTimeSeries[] calibratedPixels = fsClient.readTimeSeriesAsFloat(
            idArray, cadenceStart, cadenceEnd, false);
        for (FloatTimeSeries pixelSeries : calibratedPixels) {
        	pixelSeries.fillGaps(MISSING_CAL_PIXEL_VALUE);
            pixels.put(pixelSeries.id(), pixelSeries);
        }
        
        idArray = new FsId[cosmicRayIds.size()];
        i=0;
        for (FsId id: cosmicRayIds) {
            idArray[i++] = id;
        }

        FloatMjdTimeSeries[] mjdSeries = fsClient.readMjdTimeSeries(idArray,
            mjdStart, mjdEnd);
        for (FloatMjdTimeSeries rays : mjdSeries) {
            cosmicRays.put(rays.id(), rays);
        }

        for (FloatTimeSeries pixelSeries : calibratedPixels) {
            if (CalFsIdFactory.isCollateralTimeSeriesFsId(pixelSeries.id())) {
                continue;
            }
            FsId cosmicRayId = pixelIdToCosmicRayId.get(pixelSeries.id());
            FloatMjdTimeSeries cosmicRaySeries = cosmicRays.get(cosmicRayId);
            applyCosmicRayCorrection(pixelSeries, cosmicRaySeries);
        }
    }
    

    /**
     * subtracts cosmic ray values from calibrated pixel values.
     */
    private strictfp void applyCosmicRayCorrection(FloatTimeSeries pixelSeries,
        FloatMjdTimeSeries cosmicRaySeries) {

        //Don't subtract from non-existent pixel series.
        if (!pixelSeries.exists()) {
            return;
        }
        
        //Don't subtract from uncertainty ids
        if (ummFsIds.contains(pixelSeries.id())) {
            return;
        }
        
        float[] pixelValues = pixelSeries.fseries();

        float[] rays = cosmicRaySeries.values();
        double[] mjd = cosmicRaySeries.mjd();

        for (int i = 0; i < rays.length; i++) {
            int cadence = mjdToCadence.mjdToCadence(mjd[i]);
            float ray = rays[i];
            int pixelIndex = cadence - pixelSeries.startCadence();
            pixelValues[pixelIndex] -= ray;
        }
    }

}
