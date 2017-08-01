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

package gov.nasa.kepler.hibernate.dv;

import javax.persistence.AttributeOverride;
import javax.persistence.AttributeOverrides;
import javax.persistence.Column;
import javax.persistence.Embeddable;
import javax.persistence.Embedded;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * Data pertaining to discriminating eclipsing binaries.
 * 
 * @author Bill Wohler
 */
@Embeddable
@XmlType
public class DvBinaryDiscriminationResults {

    @Embedded
    @AttributeOverrides( {
        @AttributeOverride(name = "planetNumber", column = @Column(name = "SHORTER_PERIOD_PLANET")),
        @AttributeOverride(name = "value", column = @Column(name = "SHORTER_PERIOD_VAL")),
        @AttributeOverride(name = "significance", column = @Column(name = "SHORTER_PERIOD_SIG")) })
    @XmlElement
    private DvPlanetStatistic shorterPeriodComparisonStatistic;

    @Embedded
    @AttributeOverrides( {
        @AttributeOverride(name = "planetNumber", column = @Column(name = "LONGER_PERIOD_PLANET")),
        @AttributeOverride(name = "value", column = @Column(name = "LONGER_PERIOD_VAL")),
        @AttributeOverride(name = "significance", column = @Column(name = "LONGER_PERIOD_SIG")) })
    @XmlElement
    private DvPlanetStatistic longerPeriodComparisonStatistic;

    @Embedded
    @AttributeOverrides( {
        @AttributeOverride(name = "value", column = @Column(name = "ODD_EVEN_TRANSIT_EPOCH_VAL")),
        @AttributeOverride(name = "significance", column = @Column(name = "ODD_EVEN_TRANSIT_EPOCH_SIG")) })
    @XmlElement
    private DvStatistic oddEvenTransitEpochComparisonStatistic;

    @Embedded
    @AttributeOverrides( {
        @AttributeOverride(name = "value", column = @Column(name = "ODD_EVEN_TRANSIT_DEPTH_VAL")),
        @AttributeOverride(name = "significance", column = @Column(name = "ODD_EVEN_TRANSIT_DEPTH_SIG")) })
    @XmlElement
    private DvStatistic oddEvenTransitDepthComparisonStatistic;

    @Embedded
    @AttributeOverrides( {
        @AttributeOverride(name = "value", column = @Column(name = "SINGLE_TRANSIT_DEPTH_VAL")),
        @AttributeOverride(name = "significance", column = @Column(name = "SINGLE_TRANSIT_DEPTH_SIG")) })
    @XmlElement
    private DvStatistic singleTransitDepthComparisonStatistic;

    @Embedded
    @AttributeOverrides( {
        @AttributeOverride(name = "value", column = @Column(name = "SINGLE_TRANSIT_DURATION_VAL")),
        @AttributeOverride(name = "significance", column = @Column(name = "SINGLE_TRANSIT_DURATION_SIG")) })
    @XmlElement
    private DvStatistic singleTransitDurationComparisonStatistic;

    @Embedded
    @AttributeOverrides( {
        @AttributeOverride(name = "value", column = @Column(name = "SINGLE_TRANSIT_EPOCH_VAL")),
        @AttributeOverride(name = "significance", column = @Column(name = "SINGLE_TRANSIT_EPOCH_SIG")) })
    @XmlElement
    private DvStatistic singleTransitEpochComparisonStatistic;

    /**
     * Creates a {@link DvBinaryDiscriminationResults}. For use only by mock
     * objects and Hibernate.
     */
    DvBinaryDiscriminationResults() {
    }

    /**
     * Creates a {@link DvBinaryDiscriminationResults} with the given values.
     * 
     * @throws NullPointerException if any of the arguments are {@code null}
     */
    public DvBinaryDiscriminationResults(
        DvPlanetStatistic shorterPeriodComparisonStatistic,
        DvPlanetStatistic longerPeriodComparisonStatistic,
        DvStatistic oddEvenTransitEpochComparisonStatistic,
        DvStatistic oddEvenTransitDepthComparisonStatistic,
        DvStatistic singleTransitDepthComparisonStatistic,
        DvStatistic singleTransitDurationComparisonStatistic,
        DvStatistic singleTransitEpochComparisonStatistic) {

        if (shorterPeriodComparisonStatistic == null) {
            throw new NullPointerException(
                "shorterPeriodComparisonStatistic can't be null");
        }
        if (longerPeriodComparisonStatistic == null) {
            throw new NullPointerException(
                "longerPeriodComparisonStatistic can't be null");
        }
        if (oddEvenTransitEpochComparisonStatistic == null) {
            throw new NullPointerException(
                "oddEvenTransitEpochComparisonStatistic can't be null");
        }
        if (oddEvenTransitDepthComparisonStatistic == null) {
            throw new NullPointerException(
                "oddEvenTransitDepthComparisonStatistic can't be null");
        }
        if (singleTransitDepthComparisonStatistic == null) {
            throw new NullPointerException(
                "singleTransitDepthComparisonStatistic can't be null");
        }
        if (singleTransitDurationComparisonStatistic == null) {
            throw new NullPointerException(
                "singleTransitDurationComparisonStatistic can't be null");
        }
        if (singleTransitEpochComparisonStatistic == null) {
            throw new NullPointerException(
                "singleTransitEpochComparisonStatistic can't be null");
        }

        this.shorterPeriodComparisonStatistic = shorterPeriodComparisonStatistic;
        this.longerPeriodComparisonStatistic = longerPeriodComparisonStatistic;
        this.oddEvenTransitEpochComparisonStatistic = oddEvenTransitEpochComparisonStatistic;
        this.oddEvenTransitDepthComparisonStatistic = oddEvenTransitDepthComparisonStatistic;
        this.singleTransitDepthComparisonStatistic = singleTransitDepthComparisonStatistic;
        this.singleTransitDurationComparisonStatistic = singleTransitDurationComparisonStatistic;
        this.singleTransitEpochComparisonStatistic = singleTransitEpochComparisonStatistic;
    }

    public DvPlanetStatistic getShorterPeriodComparisonStatistic() {
        return shorterPeriodComparisonStatistic;
    }

    public DvPlanetStatistic getLongerPeriodComparisonStatistic() {
        return longerPeriodComparisonStatistic;
    }

    public DvStatistic getOddEvenTransitEpochComparisonStatistic() {
        return oddEvenTransitEpochComparisonStatistic;
    }

    public DvStatistic getOddEvenTransitDepthComparisonStatistic() {
        return oddEvenTransitDepthComparisonStatistic;
    }

    public DvStatistic getSingleTransitDepthComparisonStatistic() {
        return singleTransitDepthComparisonStatistic;
    }

    public DvStatistic getSingleTransitDurationComparisonStatistic() {
        return singleTransitDurationComparisonStatistic;
    }

    public DvStatistic getSingleTransitEpochComparisonStatistic() {
        return singleTransitEpochComparisonStatistic;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime
            * result
            + (longerPeriodComparisonStatistic == null ? 0
                : longerPeriodComparisonStatistic.hashCode());
        result = prime
            * result
            + (oddEvenTransitDepthComparisonStatistic == null ? 0
                : oddEvenTransitDepthComparisonStatistic.hashCode());
        result = prime
            * result
            + (oddEvenTransitEpochComparisonStatistic == null ? 0
                : oddEvenTransitEpochComparisonStatistic.hashCode());
        result = prime
            * result
            + (shorterPeriodComparisonStatistic == null ? 0
                : shorterPeriodComparisonStatistic.hashCode());
        result = prime
            * result
            + (singleTransitDepthComparisonStatistic == null ? 0
                : singleTransitDepthComparisonStatistic.hashCode());
        result = prime
            * result
            + (singleTransitDurationComparisonStatistic == null ? 0
                : singleTransitDurationComparisonStatistic.hashCode());
        result = prime
            * result
            + (singleTransitEpochComparisonStatistic == null ? 0
                : singleTransitEpochComparisonStatistic.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (!(obj instanceof DvBinaryDiscriminationResults)) {
            return false;
        }
        DvBinaryDiscriminationResults other = (DvBinaryDiscriminationResults) obj;
        if (longerPeriodComparisonStatistic == null) {
            if (other.longerPeriodComparisonStatistic != null) {
                return false;
            }
        } else if (!longerPeriodComparisonStatistic.equals(other.longerPeriodComparisonStatistic)) {
            return false;
        }
        if (oddEvenTransitDepthComparisonStatistic == null) {
            if (other.oddEvenTransitDepthComparisonStatistic != null) {
                return false;
            }
        } else if (!oddEvenTransitDepthComparisonStatistic.equals(other.oddEvenTransitDepthComparisonStatistic)) {
            return false;
        }
        if (oddEvenTransitEpochComparisonStatistic == null) {
            if (other.oddEvenTransitEpochComparisonStatistic != null) {
                return false;
            }
        } else if (!oddEvenTransitEpochComparisonStatistic.equals(other.oddEvenTransitEpochComparisonStatistic)) {
            return false;
        }
        if (shorterPeriodComparisonStatistic == null) {
            if (other.shorterPeriodComparisonStatistic != null) {
                return false;
            }
        } else if (!shorterPeriodComparisonStatistic.equals(other.shorterPeriodComparisonStatistic)) {
            return false;
        }
        if (singleTransitDepthComparisonStatistic == null) {
            if (other.singleTransitDepthComparisonStatistic != null) {
                return false;
            }
        } else if (!singleTransitDepthComparisonStatistic.equals(other.singleTransitDepthComparisonStatistic)) {
            return false;
        }
        if (singleTransitDurationComparisonStatistic == null) {
            if (other.singleTransitDurationComparisonStatistic != null) {
                return false;
            }
        } else if (!singleTransitDurationComparisonStatistic.equals(other.singleTransitDurationComparisonStatistic)) {
            return false;
        }
        if (singleTransitEpochComparisonStatistic == null) {
            if (other.singleTransitEpochComparisonStatistic != null) {
                return false;
            }
        } else if (!singleTransitEpochComparisonStatistic.equals(other.singleTransitEpochComparisonStatistic)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }
}
