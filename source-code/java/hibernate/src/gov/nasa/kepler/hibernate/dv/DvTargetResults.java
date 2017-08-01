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

import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.hibernate.pi.PipelineTask;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.AttributeOverride;
import javax.persistence.AttributeOverrides;
import javax.persistence.Column;
import javax.persistence.Embedded;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinTable;
import javax.persistence.ManyToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlTransient;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;

import org.apache.commons.lang.builder.ToStringBuilder;
import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;
import org.hibernate.annotations.CollectionOfElements;
import org.hibernate.annotations.IndexColumn;

@Entity
@Table(name = "DV_TARGET_RESULTS")
@XmlType
public class DvTargetResults {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "DV_TARGET_RESULTS_SEQ")
    @Column(nullable = false)
    private long id;

    @XmlAttribute
    private int startCadence;

    @XmlAttribute
    private int endCadence;

    @XmlAttribute
    private int keplerId;

    @XmlAttribute
    private String koiId = "";

    @XmlAttribute
    private String keplerName = "";

    @CollectionOfElements
    @Cascade(CascadeType.ALL)
    @JoinTable(name = "DV_TR_MATCHED_KOI_IDS")
    @IndexColumn(name = "IDX")
    @XmlElement
    private List<String> matchedKoiIds = new ArrayList<String>();

    @CollectionOfElements
    @Cascade(CascadeType.ALL)
    @JoinTable(name = "DV_TR_UNMATCHED_KOI_IDS")
    @IndexColumn(name = "IDX")
    @XmlElement
    private List<String> unmatchedKoiIds = new ArrayList<String>();

    @XmlAttribute(required = true)
    private FluxType fluxType;

    @ManyToOne(fetch = FetchType.LAZY)
    @XmlAttribute(name = "pipelineTaskId", required = true)
    @XmlJavaTypeAdapter(PipelineTaskXmlAdapter.class)
    private PipelineTask pipelineTask;

    @XmlAttribute
    private int planetCandidateCount;

    @XmlAttribute
    private String quartersObserved;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "provenance", column = @Column(name = "DEC_DEGREES_PROVEN")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "DEC_DEGREES_UNCERT")),
        @AttributeOverride(name = "value", column = @Column(name = "DEC_DEGREES_VALUE")) })
    @XmlElement
    private DvDoubleQuantityWithProvenance decDegrees;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "provenance", column = @Column(name = "EFFECTIVE_TEMP_PROVEN")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "EFFECTIVE_TEMP_UNCERT")),
        @AttributeOverride(name = "value", column = @Column(name = "EFFECTIVE_TEMP_VALUE")) })
    @XmlElement
    private DvQuantityWithProvenance effectiveTemp;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "provenance", column = @Column(name = "KEPLER_MAG_PROVEN")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "KEPLER_MAG_UNCERT")),
        @AttributeOverride(name = "value", column = @Column(name = "KEPLER_MAG_VALUE")) })
    @XmlElement
    private DvQuantityWithProvenance keplerMag;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "provenance", column = @Column(name = "SURFACE_GRAV_PROVEN")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "SURFACE_GRAV_UNCERT")),
        @AttributeOverride(name = "value", column = @Column(name = "SURFACE_GRAV_VALUE")) })
    @XmlElement
    private DvQuantityWithProvenance log10SurfaceGravity;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "provenance", column = @Column(name = "METALLICITY_PROVEN")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "METALLICITY_UNCERT")),
        @AttributeOverride(name = "value", column = @Column(name = "METALLICITY_VALUE")) })
    @XmlElement
    private DvQuantityWithProvenance log10Metallicity;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "provenance", column = @Column(name = "RADIUS_PROVEN")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "RADIUS_UNCERT")),
        @AttributeOverride(name = "value", column = @Column(name = "RADIUS_VALUE")) })
    @XmlElement
    private DvQuantityWithProvenance radius;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "provenance", column = @Column(name = "RA_HOURS_PROVEN")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "RA_HOURS_UNCERT")),
        @AttributeOverride(name = "value", column = @Column(name = "RA_HOURS_VALUE")) })
    @XmlElement
    private DvDoubleQuantityWithProvenance raHours;

    /**
     * Creates a {@link DvTargetResults}. For use only by the inner
     * {@link Builder} class, mock objects, and Hibernate.
     */
    DvTargetResults() {
    }

    /**
     * Creates a new {@link DvPlanetResults} from the given object.
     */
    private DvTargetResults(Builder builder) {
        id = builder.id;
        startCadence = builder.startCadence;
        endCadence = builder.endCadence;
        keplerId = builder.keplerId;
        koiId = builder.koiId;
        keplerName = builder.keplerName;
        matchedKoiIds = builder.matchedKoiIds;
        unmatchedKoiIds = builder.unmatchedKoiIds;
        fluxType = builder.fluxType;
        pipelineTask = builder.pipelineTask;
        planetCandidateCount = builder.planetCandidateCount;
        quartersObserved = builder.quartersObserved;
        radius = builder.radius;
        effectiveTemp = builder.effectiveTemp;
        log10SurfaceGravity = builder.log10SurfaceGravity;
        log10Metallicity = builder.log10Metallicity;
        decDegrees = builder.decDegrees;
        keplerMag = builder.keplerMag;
        raHours = builder.raHours;
    }

    public long getId() {
        return id;
    }

    public int getStartCadence() {
        return startCadence;
    }

    public int getEndCadence() {
        return endCadence;
    }

    public int getKeplerId() {
        return keplerId;
    }

    public String getKeplerName() {
        return keplerName;
    }

    public String getKoiId() {
        return koiId;
    }

    public List<String> getMatchedKoiIds() {
        return matchedKoiIds;
    }

    public List<String> getUnmatchedKoiIds() {
        return unmatchedKoiIds;
    }

    public FluxType getFluxType() {
        return fluxType;
    }

    public PipelineTask getPipelineTask() {
        return pipelineTask;
    }

    public int getPlanetCandidateCount() {
        return planetCandidateCount;
    }

    public String getQuartersObserved() {
        return quartersObserved;
    }

    public DvQuantityWithProvenance getRadius() {
        return radius;
    }

    public DvQuantityWithProvenance getEffectiveTemp() {
        return effectiveTemp;
    }

    public DvQuantityWithProvenance getLog10SurfaceGravity() {
        return log10SurfaceGravity;
    }

    public DvQuantityWithProvenance getLog10Metallicity() {
        return log10Metallicity;
    }

    public DvDoubleQuantityWithProvenance getDecDegrees() {
        return decDegrees;
    }

    public DvQuantityWithProvenance getKeplerMag() {
        return keplerMag;
    }

    public DvDoubleQuantityWithProvenance getRaHours() {
        return raHours;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + (decDegrees == null ? 0 : decDegrees.hashCode());
        result = prime * result
            + (effectiveTemp == null ? 0 : effectiveTemp.hashCode());
        result = prime * result + endCadence;
        result = prime * result + (fluxType == null ? 0 : fluxType.hashCode());
        result = prime * result + keplerId;
        result = prime * result
            + (keplerMag == null ? 0 : keplerMag.hashCode());
        result = prime * result
            + (keplerName == null ? 0 : keplerName.hashCode());
        result = prime * result + (koiId == null ? 0 : koiId.hashCode());
        result = prime * result
            + (log10Metallicity == null ? 0 : log10Metallicity.hashCode());
        result = prime
            * result
            + (log10SurfaceGravity == null ? 0 : log10SurfaceGravity.hashCode());
        result = prime * result
            + (matchedKoiIds == null ? 0 : matchedKoiIds.hashCode());
        result = prime * result
            + (pipelineTask == null ? 0 : pipelineTask.hashCode());
        result = prime * result + planetCandidateCount;
        result = prime * result
            + (quartersObserved == null ? 0 : quartersObserved.hashCode());
        result = prime * result + (raHours == null ? 0 : raHours.hashCode());
        result = prime * result + (radius == null ? 0 : radius.hashCode());
        result = prime * result + startCadence;
        result = prime * result
            + (unmatchedKoiIds == null ? 0 : unmatchedKoiIds.hashCode());
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
        if (!(obj instanceof DvTargetResults)) {
            return false;
        }
        DvTargetResults other = (DvTargetResults) obj;
        if (decDegrees == null) {
            if (other.decDegrees != null) {
                return false;
            }
        } else if (!decDegrees.equals(other.decDegrees)) {
            return false;
        }
        if (effectiveTemp == null) {
            if (other.effectiveTemp != null) {
                return false;
            }
        } else if (!effectiveTemp.equals(other.effectiveTemp)) {
            return false;
        }
        if (endCadence != other.endCadence) {
            return false;
        }
        if (fluxType != other.fluxType) {
            return false;
        }
        if (keplerId != other.keplerId) {
            return false;
        }
        if (keplerMag == null) {
            if (other.keplerMag != null) {
                return false;
            }
        } else if (!keplerMag.equals(other.keplerMag)) {
            return false;
        }
        if (keplerName == null) {
            if (other.keplerName != null) {
                return false;
            }
        } else if (!keplerName.equals(other.keplerName)) {
            return false;
        }
        if (koiId == null) {
            if (other.koiId != null) {
                return false;
            }
        } else if (!koiId.equals(other.koiId)) {
            return false;
        }
        if (log10Metallicity == null) {
            if (other.log10Metallicity != null) {
                return false;
            }
        } else if (!log10Metallicity.equals(other.log10Metallicity)) {
            return false;
        }
        if (log10SurfaceGravity == null) {
            if (other.log10SurfaceGravity != null) {
                return false;
            }
        } else if (!log10SurfaceGravity.equals(other.log10SurfaceGravity)) {
            return false;
        }
        if (matchedKoiIds == null) {
            if (other.matchedKoiIds != null) {
                return false;
            }
        } else if (!matchedKoiIds.equals(other.matchedKoiIds)) {
            return false;
        }
        if (pipelineTask == null) {
            if (other.pipelineTask != null) {
                return false;
            }
        } else if (!pipelineTask.equals(other.pipelineTask)) {
            return false;
        }
        if (planetCandidateCount != other.planetCandidateCount) {
            return false;
        }
        if (quartersObserved == null) {
            if (other.quartersObserved != null) {
                return false;
            }
        } else if (!quartersObserved.equals(other.quartersObserved)) {
            return false;
        }
        if (raHours == null) {
            if (other.raHours != null) {
                return false;
            }
        } else if (!raHours.equals(other.raHours)) {
            return false;
        }
        if (radius == null) {
            if (other.radius != null) {
                return false;
            }
        } else if (!radius.equals(other.radius)) {
            return false;
        }
        if (startCadence != other.startCadence) {
            return false;
        }
        if (unmatchedKoiIds == null) {
            if (other.unmatchedKoiIds != null) {
                return false;
            }
        } else if (!unmatchedKoiIds.equals(other.unmatchedKoiIds)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("id", id)
            .append("startCadence", startCadence)
            .append("endCadence", endCadence)
            .append("keplerId", keplerId)
            .append("koiId", koiId)
            .append("keplerName", keplerName)
            .append("matchedKoiIds", matchedKoiIds)
            .append("unmatchedKoiIds", unmatchedKoiIds)
            .append("fluxType", fluxType)
            .append("pipelineTaskId", pipelineTask.getId())
            .append("planetCandidateCount", planetCandidateCount)
            .append("quartersObserved", quartersObserved)
            .append("radius", radius)
            .append("effectiveTemp", effectiveTemp)
            .append("log10SurfaceGravity", log10SurfaceGravity)
            .append("log10Metallicity", log10Metallicity)
            .append("decDegrees", decDegrees)
            .append("keplerMag", keplerMag)
            .append("raHours", raHours)
            .toString();
    }

    @XmlTransient
    public static class Builder {
        private long id;
        private int startCadence;
        private int endCadence;
        private int keplerId;
        private String koiId;
        private String keplerName;
        private List<String> matchedKoiIds = new ArrayList<String>();
        private List<String> unmatchedKoiIds = new ArrayList<String>();
        private int planetCandidateCount;
        private String quartersObserved;
        private FluxType fluxType;
        private PipelineTask pipelineTask;
        private DvQuantityWithProvenance radius;
        private DvQuantityWithProvenance effectiveTemp;
        private DvQuantityWithProvenance log10SurfaceGravity;
        private DvQuantityWithProvenance log10Metallicity;
        private DvDoubleQuantityWithProvenance decDegrees;
        private DvQuantityWithProvenance keplerMag;
        private DvDoubleQuantityWithProvenance raHours;

        /**
         * Creates a {@link Builder} object with the given required parameters.
         * 
         * @param startCadence the starting cadence
         * @param endCadence the ending cadence
         * @param keplerId the Kepler ID
         * @param pipelineTask the pipeline task
         * @throws NullPointerException if {@code pipelineTask} is {@code null}
         */
        public Builder(FluxType fluxType, int startCadence, int endCadence,
            int keplerId, PipelineTask pipelineTask) {
            if (pipelineTask == null) {
                throw new NullPointerException("pipelineTask can't be null");
            }

            this.fluxType = fluxType;
            this.startCadence = startCadence;
            this.endCadence = endCadence;
            this.keplerId = keplerId;
            this.pipelineTask = pipelineTask;
        }

        /**
         * For use by tests only.
         */
        Builder id(long id) {
            this.id = id;
            return this;
        }

        public Builder koiId(String koiId) {
            this.koiId = koiId;
            return this;
        }

        public Builder keplerName(String keplerName) {
            this.keplerName = keplerName;
            return this;
        }

        public Builder matchedKoiIds(List<String> matchedKoiIds) {
            this.matchedKoiIds = matchedKoiIds;
            return this;
        }

        public Builder unmatchedKoiIds(List<String> unmatchedKoiIds) {
            this.unmatchedKoiIds = unmatchedKoiIds;
            return this;
        }

        public Builder planetCandidateCount(int planetCandidateCount) {
            this.planetCandidateCount = planetCandidateCount;
            return this;
        }

        public Builder quartersObserved(String quartersObserved) {
            this.quartersObserved = quartersObserved;
            return this;
        }

        public Builder radius(DvQuantityWithProvenance radius) {
            this.radius = radius;
            return this;
        }

        public Builder effectiveTemp(DvQuantityWithProvenance effectiveTemp) {
            this.effectiveTemp = effectiveTemp;
            return this;
        }

        public Builder log10SurfaceGravity(
            DvQuantityWithProvenance log10SurfaceGravity) {
            this.log10SurfaceGravity = log10SurfaceGravity;
            return this;
        }

        public Builder log10Metallicity(
            DvQuantityWithProvenance log10Metallicity) {
            this.log10Metallicity = log10Metallicity;
            return this;
        }

        public Builder decDegrees(DvDoubleQuantityWithProvenance decDegrees) {
            this.decDegrees = decDegrees;
            return this;
        }

        public Builder keplerMag(DvQuantityWithProvenance keplerMag) {
            this.keplerMag = keplerMag;
            return this;
        }

        public Builder raHours(DvDoubleQuantityWithProvenance raHours) {
            this.raHours = raHours;
            return this;
        }

        public DvTargetResults build() {
            return new DvTargetResults(this);
        }
    }

}
