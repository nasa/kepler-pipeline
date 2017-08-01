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

import java.util.ArrayList;
import java.util.List;

import javax.persistence.Embeddable;
import javax.persistence.JoinTable;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlList;
import javax.xml.bind.annotation.XmlType;

import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;
import org.hibernate.annotations.CollectionOfElements;
import org.hibernate.annotations.IndexColumn;

/**
 * 
 * @author Forrest Girouard
 */
@Embeddable
@XmlType
public class DvRollingBandContaminationHistogram {

    @XmlAttribute
    private int testPulseDurationLc;
    
    @CollectionOfElements
    @Cascade(CascadeType.ALL)
    @JoinTable(name = "DV_SEVERITY_LEVELS")
    @IndexColumn(name = "IDX")
    @XmlList
    private List<Float> severityLevels = new ArrayList<Float>();

    @CollectionOfElements
    @Cascade(CascadeType.ALL)
    @JoinTable(name = "DV_TRANSIT_COUNTS")
    @IndexColumn(name = "IDX")
    @XmlList
    private List<Integer> transitCounts = new ArrayList<Integer>();

    @CollectionOfElements
    @Cascade(CascadeType.ALL)
    @JoinTable(name = "DV_TRANSIT_FRACTIONS")
    @IndexColumn(name = "IDX")
    @XmlList
    private List<Float> transitFractions = new ArrayList<Float>();

    public DvRollingBandContaminationHistogram() {
    }

    public DvRollingBandContaminationHistogram(int testPulseDurationLc,
        List<Float> severityLevels,
        List<Integer> transitCounts, List<Float> transitFractions) {

        this.testPulseDurationLc = testPulseDurationLc;
        this.severityLevels = severityLevels;
        this.transitCounts = transitCounts;
        this.transitFractions = transitFractions;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + ((severityLevels == null) ? 0 : severityLevels.hashCode());
        result = prime * result + testPulseDurationLc;
        result = prime * result
            + ((transitCounts == null) ? 0 : transitCounts.hashCode());
        result = prime * result
            + ((transitFractions == null) ? 0 : transitFractions.hashCode());
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
        if (!(obj instanceof DvRollingBandContaminationHistogram)) {
            return false;
        }
        DvRollingBandContaminationHistogram other = (DvRollingBandContaminationHistogram) obj;
        if (severityLevels == null) {
            if (other.severityLevels != null) {
                return false;
            }
        } else if (!severityLevels.equals(other.severityLevels)) {
            return false;
        }
        if (testPulseDurationLc != other.testPulseDurationLc) {
            return false;
        }
        if (transitCounts == null) {
            if (other.transitCounts != null) {
                return false;
            }
        } else if (!transitCounts.equals(other.transitCounts)) {
            return false;
        }
        if (transitFractions == null) {
            if (other.transitFractions != null) {
                return false;
            }
        } else if (!transitFractions.equals(other.transitFractions)) {
            return false;
        }
        return true;
    }

    public int testPulseDurationLc() {
        return testPulseDurationLc;
    }
    
    public void setTestPulseDurationLc(int testPulseDurationLc) {
        this.testPulseDurationLc = testPulseDurationLc;
    }
    
    public List<Float> severityLevels() {
        return severityLevels;
    }

    public void setSeverityLevels(List<Float> severityLevels) {
        this.severityLevels = severityLevels;
    }

    public List<Integer> transitCounts() {
        return transitCounts;
    }

    public void setTransitCounts(List<Integer> transitCounts) {
        this.transitCounts = transitCounts;
    }

    public List<Float> transitFractions() {
        return transitFractions;
    }

    public void setTransitFractions(List<Float> transitFractions) {
        this.transitFractions = transitFractions;
    }
}
