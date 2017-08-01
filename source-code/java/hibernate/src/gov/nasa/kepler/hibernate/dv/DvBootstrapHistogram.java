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

import java.util.List;

import javax.persistence.Embeddable;
import javax.persistence.JoinTable;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlList;
import javax.xml.bind.annotation.XmlType;

import org.apache.commons.lang.builder.ToStringBuilder;
import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;
import org.hibernate.annotations.CollectionOfElements;
import org.hibernate.annotations.IndexColumn;

/**
 * The bootstrap histogram.
 * 
 * @author Bill Wohler
 */
@Embeddable
@XmlType
public class DvBootstrapHistogram {

    @CollectionOfElements
    @Cascade(CascadeType.ALL)
    @JoinTable(name = "DV_BH_STATISTICS")
    @IndexColumn(name = "IDX")
    @XmlList
    private List<Float> statistics;

    @CollectionOfElements
    @Cascade(CascadeType.ALL)
    @JoinTable(name = "DV_BH_PROBABILITIES")
    @IndexColumn(name = "IDX")
    @XmlList
    private List<Float> probabilities;

    @XmlAttribute
    private int finalSkipCount;

    /**
     * Creates a {@link DvBootstrapHistogram}. For use only by mock objects and
     * Hibernate.
     */
    DvBootstrapHistogram() {
    }

    /**
     * Creates a {@link DvBootstrapHistogram} with the given values.
     * 
     * @throws NullPointerException if either {@code statistics} or {@code
     * probabilities} are {@code null}
     */
    public DvBootstrapHistogram(List<Float> statistics,
        List<Float> probabilities, int finalSkipCount) {

        if (statistics == null) {
            throw new NullPointerException("statistics can't be null");
        }
        if (probabilities == null) {
            throw new NullPointerException("probabilities can't be null");
        }

        this.statistics = statistics;
        this.probabilities = probabilities;
        this.finalSkipCount = finalSkipCount;
    }

    public List<Float> getStatistics() {
        return statistics;
    }

    public List<Float> getProbabilities() {
        return probabilities;
    }

    public int getFinalSkipCount() {
        return finalSkipCount;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + finalSkipCount;
        result = prime * result
            + (probabilities == null ? 0 : probabilities.hashCode());
        result = prime * result
            + (statistics == null ? 0 : statistics.hashCode());
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
        if (!(obj instanceof DvBootstrapHistogram)) {
            return false;
        }
        DvBootstrapHistogram other = (DvBootstrapHistogram) obj;
        if (finalSkipCount != other.finalSkipCount) {
            return false;
        }
        if (probabilities == null) {
            if (other.probabilities != null) {
                return false;
            }
        } else if (!probabilities.equals(other.probabilities)) {
            return false;
        }
        if (statistics == null) {
            if (other.statistics != null) {
                return false;
            }
        } else if (!statistics.equals(other.statistics)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append(
            String.format("%d values", statistics.size()))
            .append(String.format("%d probabilities", probabilities.size()))
            .toString();
    }
}
