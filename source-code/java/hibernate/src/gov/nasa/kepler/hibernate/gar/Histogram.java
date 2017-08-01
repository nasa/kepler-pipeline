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

package gov.nasa.kepler.hibernate.gar;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinTable;
import javax.persistence.SequenceGenerator;

import org.hibernate.annotations.CollectionOfElements;
import org.hibernate.annotations.Fetch;
import org.hibernate.annotations.FetchMode;
import org.hibernate.annotations.IndexColumn;

/**
 * A histogram for a single baseline interval. The {@code histogram} field is
 * ordered the same way as the {@link RequantEntry}s in the {@link RequantTable}
 * . Each entry in the {@code histogram} field is the count of the associated
 * {@link RequantEntry}s (typically for a single CCD module/output) for the
 * number of cadences defined in the {@code #baselineInterval}.
 * <p>
 * TODO Talk to Joe and make this documentation accurate.
 * 
 * @author Bill Wohler
 */
@Entity(name = "GAR_HISTOGRAM")
public class Histogram {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "GAR_HISTOGRAM_SEQ")
    private long id;

    /**
     * The particular baseline interval (cadence range) that this histogram
     * represents.
     */
    private int baselineInterval;

    /**
     * Overhead for storage of the uncompressed baseline once per baseline
     * interval, amortized over all cadences (bits per pixel per cadence).
     */
    @Column(name = "UNCMP_BASELINE_OVERHEAD_RATE")
    private float uncompressedBaselineOverheadRate;

    /**
     * Predicted compression rate for the residual requantized pixels (bits per
     * pixel per cadence).
     */
    private float theoreticalCompressionRate;

    /**
     * The total storage requirement is equal to the sum of the uncompressed
     * baseline overhead rate and the theoretical compression rate (bits per
     * pixel per cadence).
     */
    private float totalStorageRate;

    /**
     * Counts of requantized residual pixel values (Huffman symbols). For a
     * requantization table with 2^16 entries, there are 2^17 1 bins in the
     * histogram for each baseline interval.
     */
    @CollectionOfElements(fetch = FetchType.EAGER)
    @Fetch(value = FetchMode.SUBSELECT)
    @JoinTable(name = "GAR_HISTOGRAM_VALUES")
    @IndexColumn(name = "IDX")
    private List<Long> histogram = new ArrayList<Long>();

    /**
     * For use by mock objects and Hibernate only.
     */
    Histogram() {
    }

    /**
     * Creates a {@link Histogram} for the given baseline interval.
     * 
     * @param baselineInterval the baseline interval.
     */
    public Histogram(int baselineInterval) {
        this.baselineInterval = baselineInterval;
    }

    public int getBaselineInterval() {
        return baselineInterval;
    }

    public void setBaselineInterval(int baselineInterval) {
        this.baselineInterval = baselineInterval;
    }

    public float getUncompressedBaselineOverheadRate() {
        return uncompressedBaselineOverheadRate;
    }

    public void setUncompressedBaselineOverheadRate(
        float uncompressedBaselineOverheadRate) {
        this.uncompressedBaselineOverheadRate = uncompressedBaselineOverheadRate;
    }

    public float getTheoreticalCompressionRate() {
        return theoreticalCompressionRate;
    }

    public void setTheoreticalCompressionRate(float theoreticalCompressionRate) {
        this.theoreticalCompressionRate = theoreticalCompressionRate;
    }

    public float getTotalStorageRate() {
        return totalStorageRate;
    }

    public void setTotalStorageRate(float totalStorageRate) {
        this.totalStorageRate = totalStorageRate;
    }

    public List<Long> getHistogram() {
        return histogram;
    }

    public void setHistogram(List<Long> histogram) {
        this.histogram = histogram;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + baselineInterval;
        result = prime * result
            + ((histogram == null) ? 0 : histogram.hashCode());
        result = prime * result
            + Float.floatToIntBits(theoreticalCompressionRate);
        result = prime * result + Float.floatToIntBits(totalStorageRate);
        result = prime * result
            + Float.floatToIntBits(uncompressedBaselineOverheadRate);
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        final Histogram other = (Histogram) obj;
        if (baselineInterval != other.baselineInterval)
            return false;
        if (histogram == null) {
            if (other.histogram != null)
                return false;
        } else if (!histogram.equals(other.histogram))
            return false;
        if (Float.floatToIntBits(theoreticalCompressionRate) != Float.floatToIntBits(other.theoreticalCompressionRate))
            return false;
        if (Float.floatToIntBits(totalStorageRate) != Float.floatToIntBits(other.totalStorageRate))
            return false;
        if (Float.floatToIntBits(uncompressedBaselineOverheadRate) != Float.floatToIntBits(other.uncompressedBaselineOverheadRate))
            return false;
        return true;
    }
}
