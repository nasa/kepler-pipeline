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

import gov.nasa.kepler.common.persistable.SdfPersistableOutputStream;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.mc.CalibratedPixel;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;
import gov.nasa.spiffy.common.SimpleFloatMjdTimeSeries;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.persistable.ProxyIgnore;

import java.io.BufferedOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Pixel data for a single aperture.
 * 
 * @author Forrest Girouard
 */
public class DvPixelApertureData extends DvAbstractTargetTableData {

    private String pixelDataFileName = new String();

    @ProxyIgnore
    private List<DvPixelData> pixelDataStruct = new ArrayList<DvPixelData>();

    @ProxyIgnore
    private Set<Pixel> pixels;

    /**
     * Creates a {@link DvPixelApertureData}. For use only by mock objects and
     * Hibernate.
     */
    public DvPixelApertureData() {
    }

    /**
     * Creates a {@link DvPixelApertureData} object.
     */
    public DvPixelApertureData(int targetTableId, int ccdModule, int ccdOutput,
        int startCadence, int endCadence, int quarter, Set<Pixel> pixels) {

        super(targetTableId, ccdModule, ccdOutput, startCadence, endCadence,
            quarter);
        this.pixels = pixels;
    }

    public boolean isPopulated() {
        return pixelDataStruct != null
            && pixelDataStruct.size() == pixels.size()
            || pixelDataFileName != null && pixelDataFileName.length() > 0;
    }

    public void setPixelData(Map<FsId, TimeSeries> timeSeriesByFsId,
        Map<FsId, FloatMjdTimeSeries> floatMjdTimeSeriesByFsId) {

        pixelDataStruct = new ArrayList<DvPixelData>(pixels.size());
        for (Pixel pixel : pixels) {
            CalibratedPixel calibratedPixel = (CalibratedPixel) pixel;
            FloatTimeSeries values = (FloatTimeSeries) timeSeriesByFsId.get(calibratedPixel.getFsId());
            FloatTimeSeries uncertainties = (FloatTimeSeries) timeSeriesByFsId.get(calibratedPixel.getUncertaintiesFsId());
            FloatMjdTimeSeries cosmicRayEvents = floatMjdTimeSeriesByFsId.get(calibratedPixel.getCosmicRayEventsFsId());

            // If this pixel is in the optimal aperture, then it can remain in
            // the optimal aperture as long as its timeseries exists.
            pixelDataStruct.add(new DvPixelData(calibratedPixel.getRow(),
                calibratedPixel.getColumn(),
                calibratedPixel.isInOptimalAperture() && values.exists(),
                new CompoundFloatTimeSeries(values.fseries(),
                    uncertainties.fseries(), values.getGapIndicators()),
                cosmicRayEvents != null ? new SimpleFloatMjdTimeSeries(
                    cosmicRayEvents.values(), cosmicRayEvents.mjd())
                    : new SimpleFloatMjdTimeSeries()));
        }
    }

    public void writeSdfPixelData(File file) throws IOException {

        DataOutputStream dataOutputStream = null;
        try {
            dataOutputStream = new DataOutputStream(new BufferedOutputStream(
                new FileOutputStream(file)));
            DvPixelDataContainer pixelData = new DvPixelDataContainer(
                getPixelData());
            new SdfPersistableOutputStream(dataOutputStream).save(pixelData);
        } catch (Exception e) {
            throw new IOException(String.format(
                "Failed to write sdf file[%s], e = %s", file, e), e);
        } finally {
            FileUtil.close(dataOutputStream);
        }
    }

    public List<DvPixelData> getPixelData() {
        return pixelDataStruct;
    }

    public Set<Pixel> getPixels() {
        return pixels;
    }

    public String getPixelDataFileName() {
        return pixelDataFileName;
    }

    public void setPixelDataFileName(String pixelDataFileName) {
        this.pixelDataFileName = pixelDataFileName;
    }
}
