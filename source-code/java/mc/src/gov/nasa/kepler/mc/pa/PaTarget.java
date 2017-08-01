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

package gov.nasa.kepler.mc.pa;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.tad.KicEntryData;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnore;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * 
 * @author Forrest Girouard (fgirouard)
 * 
 */
public class PaTarget implements Persistable {

    /**
     * The Kepler ID for this target (directly from the KIC).
     */
    private int keplerId;

    /**
     * The magnitude of this target (directly from the KIC)
     */
    private float keplerMag;

    /**
     * The right ascension for this target in hours (directly from the KIC).
     */
    private double raHours;

    /**
     * The declination of this target in degrees (directly from the KIC).
     */
    private double decDegrees;

    /**
     * The row relative to which the pixels in the target are located, typically
     * the row of the target centroid.
     */
    private int referenceRow;

    /**
     * The column relative to which the pixels in the target are located,
     * typically the column of the target centroid.
     */
    private int referenceColumn;

    /**
     * Labels whose values indicate characteristic properties of this target.
     * See {@link gov.nasa.kepler.hibernate.cm.PlannedTarget.TargetLabel}.
     */
    private String[] labels = ArrayUtils.EMPTY_STRING_ARRAY;

    /**
     * The fraction of the flux in the aperture (from TAD). This is used for
     * determining the brightness metric.
     */
    private float fluxFractionInAperture;
    private float signalToNoiseRatio;
    private float crowdingMetric;
    private float skyCrowdingMetric;

    /**
     * List containing one time series per pixel in target.
     */
    private List<PaPixelTimeSeries> pixelDataStruct = newArrayList();

    /**
     * List of rmsCdpp values per trialTransitDurations.
     */
    private List<RmsCdpp> rmsCdppStruct = newArrayList();

    /**
     * For use by PA-COA.
     */
    private List<CelestialObjectParameters> kics = newArrayList();
    private KicEntryData kicEntryData = new KicEntryData();

    private int saturatedRowCount = -1;

    @ProxyIgnore
    private TargetType type;

    @ProxyIgnore
    private Set<Pixel> pixels;

    private static boolean containsFsIds(
        final Map<FsId, FloatTimeSeries> timeSeriesByFsId,
        final List<FsId> fsIds) {

        for (FsId fsId : fsIds) {
            if (!timeSeriesByFsId.containsKey(fsId)) {
                return false;
            }
        }
        return true;
    }

    public PaTarget() {
        super();
    }

    public PaTarget(final int keplerId, final int referenceRow,
        final int referenceColumn, final String[] labels,
        final float fluxFractionInAperture, final float signalToNoiseRatio,
        final float crowdingMetric, final float skyCrowdingMetric,
        final int saturatedRowCount, final TargetType type,
        final Set<Pixel> pixels) {
        this.keplerId = keplerId;
        this.referenceRow = referenceRow;
        this.referenceColumn = referenceColumn;
        if (labels == null) {
            this.labels = new String[0];
        } else {
            this.labels = Arrays.copyOf(labels, labels.length);
        }
        this.fluxFractionInAperture = fluxFractionInAperture;
        this.signalToNoiseRatio = signalToNoiseRatio;
        this.crowdingMetric = crowdingMetric;
        this.skyCrowdingMetric = skyCrowdingMetric;
        this.saturatedRowCount = saturatedRowCount;
        this.type = type;
        this.pixels = pixels;
    }

    public List<FsId> getAllFsIds() {

        if (pixels == null || pixels.isEmpty()) {
            throw new IllegalStateException("no pixel information is available");
        }
        List<FsId> fsIds = newArrayList();
        for (Pixel pixel : pixels) {
            fsIds.addAll(pixel.getFsIds());
        }
        return fsIds;
    }

    public boolean setAllTimeSeries(final int ccdModule, final int ccdOutput,
        final Map<FsId, FloatTimeSeries> timeSeriesByFsId) {

        if (containsFsIds(timeSeriesByFsId, getAllFsIds())) {
            List<PaPixelTimeSeries> paPixelTimeSeries = newArrayList();
            for (Pixel pixel : pixels) {
                PaPixelTimeSeries pixelTimeSeries = new PaPixelTimeSeries(
                    pixel.getRow(), pixel.getColumn(),
                    pixel.isInOptimalAperture());
                pixelTimeSeries.setAllTimeSeries(type, ccdModule, ccdOutput,
                    timeSeriesByFsId);
                paPixelTimeSeries.add(pixelTimeSeries);
            }
            setPaPixelTimeSeries(paPixelTimeSeries);
            return true;
        }
        return false;
    }

    public boolean isPopulated() {
        return pixelDataStruct != null && !pixelDataStruct.isEmpty();
    }

    public double getDecDegrees() {
        return decDegrees;
    }

    public void setDecDegrees(double decDegrees) {
        this.decDegrees = decDegrees;
    }

    public float getFluxFractionInAperture() {
        return fluxFractionInAperture;
    }

    public float getSignalToNoiseRatio() {
        return signalToNoiseRatio;
    }

    public float getCrowdingMetric() {
        return crowdingMetric;
    }

    public float getSkyCrowdingMetric() {
        return skyCrowdingMetric;
    }

    public String[] getLabels() {
        return Arrays.copyOf(labels, labels.length);
    }

    public int getKeplerId() {
        return keplerId;
    }

    public List<PaPixelTimeSeries> getPaPixelTimeSeries() {
        return pixelDataStruct;
    }

    public void setPaPixelTimeSeries(
        final List<PaPixelTimeSeries> paPixelTimeSeries) {
        pixelDataStruct = paPixelTimeSeries;
    }

    public List<RmsCdpp> getRmsCdpp() {
        return rmsCdppStruct;
    }

    public void setRmsCdpp(List<RmsCdpp> rmsCdpp) {
        rmsCdppStruct = rmsCdpp;
    }

    public Set<Pixel> getPixels() {
        return pixels;
    }

    public double getRaHours() {
        return raHours;
    }

    public void setRaHours(double raHours) {
        this.raHours = raHours;
    }

    public int getReferenceColumn() {
        return referenceColumn;
    }

    public int getReferenceRow() {
        return referenceRow;
    }

    public List<CelestialObjectParameters> getKics() {
        return kics;
    }

    public void setKics(List<CelestialObjectParameters> kics) {
        this.kics = kics;
    }

    public KicEntryData getKicEntryData() {
        return kicEntryData;
    }

    public void setKicEntryData(KicEntryData kicEntryData) {
        this.kicEntryData = kicEntryData;
    }

    public float getKeplerMag() {
        return keplerMag;
    }

    public void setKeplerMag(float keplerMag) {
        this.keplerMag = keplerMag;
    }

    public int getSaturatedRowCount() {
        return saturatedRowCount;
    }

    public void setSaturatedRowCount(int saturatedRowCount) {
        this.saturatedRowCount = saturatedRowCount;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + keplerId;
        result = prime * result + (pixels == null ? 0 : pixels.hashCode());
        result = prime * result + referenceColumn;
        result = prime * result + referenceRow;
        return result;
    }

    @Override
    public boolean equals(final Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        PaTarget other = (PaTarget) obj;
        if (keplerId != other.keplerId) {
            return false;
        }
        if (pixels == null) {
            if (other.pixels != null) {
                return false;
            }
        } else if (!pixels.equals(other.pixels)) {
            return false;
        }
        if (referenceColumn != other.referenceColumn) {
            return false;
        }
        if (referenceRow != other.referenceRow) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("keplerId", keplerId)
            .append("keplerMag", keplerMag)
            .append("raHours", raHours)
            .append("decDegrees", decDegrees)
            .append("referenceRow", referenceRow)
            .append("referenceColumn", referenceColumn)
            .append("labels", labels)
            .append("fluxFractionInAperture", fluxFractionInAperture)
            .append("pixelDataStruct.size",
                pixelDataStruct != null ? pixelDataStruct.size() : 0)
            .append("rmsCdppStruct",
                rmsCdppStruct != null ? rmsCdppStruct.size() : 0)
            .toString();
    }
}
