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

import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.persistable.ProxyIgnoreStatics;

import java.io.File;
import java.io.IOException;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang.ArrayUtils;

/**
 * Target data for a single aperture.
 * 
 * @author Forrest Girouard
 */
@ProxyIgnoreStatics
public class DvTargetData extends DvPixelApertureData {

    private static final String PIXEL_DATA_FILENAME = "pixelData/%09d/tt%03d-q%02d.sdf";

    private float crowdingMetric;
    private double endMjd;
    private float fluxFractionInAperture;
    private String[] labels = ArrayUtils.EMPTY_STRING_ARRAY;
    private double startMjd;

    /**
     * Creates a {@link DvTargetData}. For use only by mock objects and
     * Hibernate.
     */
    public DvTargetData() {
    }

    /**
     * Creates a new immutable {@link DvTargetData} object.
     */
    public DvTargetData(int targetTableId, int ccdModule, int ccdOutput,
        int startCadence, int endCadence, double startMjd, double endMjd,
        int quarter, float crowdingMetric, float fluxFractionInAperture,
        String[] labels, Set<Pixel> pixels) {

        super(targetTableId, ccdModule, ccdOutput, startCadence, endCadence,
            quarter, pixels);
        this.crowdingMetric = crowdingMetric;
        this.endMjd = endMjd;
        this.fluxFractionInAperture = fluxFractionInAperture;
        this.labels = labels;
        this.startMjd = startMjd;
    }

    public void setPixelTimeSeries(
        Map<Pair<Integer, Integer>, Map<FsId, TimeSeries>> timeSeries,
        Map<Pair<Double, Double>, Map<FsId, FloatMjdTimeSeries>> mjdTimeSeries) {

        Pair<Integer, Integer> cadenceRange = Pair.of(getStartCadence(),
            getEndCadence());
        Pair<Double, Double> timeRange = Pair.of(getStartMjd(), getEndMjd());
        Map<FsId, TimeSeries> timeSeriesByFsId = timeSeries.get(cadenceRange);
        Map<FsId, FloatMjdTimeSeries> mjdTimeSeriesByFsId = mjdTimeSeries.get(timeRange);
        if (timeSeriesByFsId != null) {
            setPixelData(timeSeriesByFsId, mjdTimeSeriesByFsId);
        }
    }

    public void export(File matlabWorkingDir, int keplerId) throws IOException {

        String path = String.format(PIXEL_DATA_FILENAME, keplerId,
            getTargetTableId(), getQuarter());
        if (!isPopulated()) {
            throw new IllegalStateException(String.format(
                "Target data for %d is not fully populated: ", keplerId));
        }

        File file = new File(matlabWorkingDir, path);
        file.getParentFile()
            .mkdirs();

        writeSdfPixelData(file);
        setPixelDataFileName(path);
        getPixelData().clear();
    }

    public float getCrowdingMetric() {
        return crowdingMetric;
    }

    public double getEndMjd() {
        return endMjd;
    }

    public float getFluxFractionInAperture() {
        return fluxFractionInAperture;
    }

    public String[] getLabels() {
        return labels;
    }

    public double getStartMjd() {
        return startMjd;
    }
}
