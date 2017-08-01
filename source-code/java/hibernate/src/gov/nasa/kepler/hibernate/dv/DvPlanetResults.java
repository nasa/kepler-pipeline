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
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.OneToOne;
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
import org.hibernate.annotations.Fetch;
import org.hibernate.annotations.FetchMode;
import org.hibernate.annotations.IndexColumn;

/**
 * All threshold crossing events and transit models associated with a particular
 * planet.
 * <p>
 * Developers' note: The {@link #hashCode} and {@link #equals} methods compare
 * the pipelineTasks ID directly instead of using hashCode and equals. Since its
 * equals method uses getClass instead of instanceof, it returns the wrong
 * answer when obtained via Hibernate. Be sure to catch this if you recreate
 * these methods.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
@Entity
@Table(name = "DV_PLANET_RESULTS")
@XmlType
public class DvPlanetResults {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "DV_PLANET_RESULTS_SEQ")
    @Column(nullable = false)
    private long id;

    @XmlAttribute
    private int startCadence;

    @XmlAttribute
    private int endCadence;

    @XmlAttribute
    private int keplerId;

    @XmlAttribute
    private int planetNumber;

    @XmlAttribute
    private String keplerName = "";

    @XmlAttribute
    private String koiId = "";

    @XmlAttribute
    private float koiCorrelation;

    @XmlAttribute
    private int detrendFilterLength;

    @OneToOne
    @Cascade(CascadeType.ALL)
    @XmlElement
    private DvPlanetCandidate planetCandidate;

    @Embedded
    @XmlElement
    private DvCentroidResults centroidResults;

    @Embedded
    @XmlElement
    private DvBinaryDiscriminationResults binaryDiscriminationResults;

    @OneToOne
    @Cascade(CascadeType.ALL)
    @JoinColumn(name = "DV_PLANET_MODEL_FIT_ALL_ID")
    @XmlElement
    private DvPlanetModelFit allTransitsFit;

    @OneToOne
    @Cascade(CascadeType.ALL)
    @JoinColumn(name = "DV_PLANET_MODEL_FIT_EVEN_ID")
    @XmlElement
    private DvPlanetModelFit evenTransitsFit;

    @OneToOne
    @Cascade(CascadeType.ALL)
    @JoinColumn(name = "DV_PLANET_MODEL_FIT_ODD_ID")
    @XmlElement
    private DvPlanetModelFit oddTransitsFit;

    @OneToOne
    @Cascade(CascadeType.ALL)
    @JoinColumn(name = "DV_PLANET_MODEL_FIT_TRAP_ID")
    @XmlElement
    private DvPlanetModelFit trapezoidalFit;

    @Embedded
    @Cascade(CascadeType.ALL)
    @JoinColumn(name = "DV_SECONDARY_EVENTS_ID")
    @XmlElement
    private DvSecondaryEventResults secondaryEventResults = new DvSecondaryEventResults();

    @OneToMany(fetch = FetchType.EAGER)
    @Fetch(value = FetchMode.SUBSELECT)
    @Cascade(CascadeType.ALL)
    @JoinTable(name = "DV_PR_SINGLE_TRANSIT_FITS")
    @IndexColumn(name = "IDX")
    @XmlElement
    private List<DvPlanetModelFit> singleTransitFits = new ArrayList<DvPlanetModelFit>();

    @OneToMany(fetch = FetchType.EAGER)
    @Fetch(value = FetchMode.SUBSELECT)
    @Cascade(CascadeType.ALL)
    @JoinTable(name = "DV_PR_REDUCED_PARAMETER_FITS")
    @IndexColumn(name = "IDX")
    @XmlElement
    private List<DvPlanetModelFit> reducedParameterFits = new ArrayList<DvPlanetModelFit>();

    @Embedded
    @XmlElement
    private DvGhostDiagnosticResults ghostDiagnosticResults;

    @Cascade(CascadeType.ALL)
    @OneToMany(fetch = FetchType.EAGER)
    @Fetch(value = FetchMode.SUBSELECT)
    @JoinTable(name = "DV_PR_PIXEL_CORREL_RESULTS")
    @IndexColumn(name = "IDX")
    @XmlElement
    private List<DvPixelCorrelationResults> pixelCorrelationResults = new ArrayList<DvPixelCorrelationResults>();

    @Cascade(CascadeType.ALL)
    @OneToMany(fetch = FetchType.EAGER)
    @Fetch(value = FetchMode.SUBSELECT)
    @JoinTable(name = "DV_PR_DIFF_IMG_RESULTS")
    @IndexColumn(name = "IDX")
    @XmlElement
    private List<DvDifferenceImageResults> differenceImageResults = new ArrayList<DvDifferenceImageResults>();

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "rollingBandContaminationHistogram.severityLevels", column = @Column(name = "DV_IMG_ART_ROLL_BAND_SEC_LEVS")),
        @AttributeOverride(name = "rollingBandContaminationHistogram.transitCounts", column = @Column(name = "DV_IMG_ART_ROLL_BAND_TRNS_CNTS")),
        @AttributeOverride(name = "rollingBandContaminationHistogram.transitFractions", column = @Column(name = "DV_IMG_ART_ROLL_BAND_TRNS_FRAC")) })
    @XmlElement
    private DvImageArtifactResults imageArtifactResults = new DvImageArtifactResults();

    @XmlAttribute(required = true)
    private FluxType fluxType;

    @ManyToOne(fetch = FetchType.LAZY)
    @XmlAttribute(name = "pipelineTaskId", required = true)
    @XmlJavaTypeAdapter(PipelineTaskXmlAdapter.class)
    private PipelineTask pipelineTask;

    /**
     * Creates a {@link DvPlanetResults}. For use only by the inner
     * {@link Builder} class, mock objects, and Hibernate.
     */
    DvPlanetResults() {
    }

    /**
     * Creates a new {@link DvPlanetResults} from the given object.
     */
    private DvPlanetResults(Builder builder) {
        id = builder.id;
        startCadence = builder.startCadence;
        endCadence = builder.endCadence;
        keplerId = builder.keplerId;
        planetNumber = builder.planetNumber;
        keplerName = builder.keplerName;
        koiId = builder.koiId;
        koiCorrelation = builder.koiCorrelation;
        detrendFilterLength = builder.detrendFilterLength;
        planetCandidate = builder.planetCandidate;
        centroidResults = builder.centroidResults;
        binaryDiscriminationResults = builder.binaryDiscriminationResults;
        allTransitsFit = builder.allTransitsFit;
        evenTransitsFit = builder.evenTransitsFit;
        oddTransitsFit = builder.oddTransitsFit;
        trapezoidalFit = builder.trapezoidalFit;
        secondaryEventResults = builder.secondaryEventResults;
        imageArtifactResults = builder.imageArtifactResults;
        singleTransitFits = builder.singleTransitFits;
        reducedParameterFits = builder.reducedParameterFits;
        ghostDiagnosticResults = builder.ghostDiagnosticResults;
        pixelCorrelationResults = builder.pixelCorrelationResults;
        differenceImageResults = builder.differenceImageResults;
        fluxType = builder.fluxType;
        pipelineTask = builder.pipelineTask;
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

    public int getPlanetNumber() {
        return planetNumber;
    }

    public String getKeplerName() {
        return keplerName;
    }

    public String getKoiId() {
        return koiId;
    }

    public float getKoiCorrelation() {
        return koiCorrelation;
    }

    public int getDetrendFilterLength() {
        return detrendFilterLength;
    }

    public DvPlanetCandidate getPlanetCandidate() {
        return planetCandidate;
    }

    public DvCentroidResults getCentroidResults() {
        return centroidResults;
    }

    public DvBinaryDiscriminationResults getBinaryDiscriminationResults() {
        return binaryDiscriminationResults;
    }

    public DvPlanetModelFit getAllTransitsFit() {
        return allTransitsFit;
    }

    public DvPlanetModelFit getEvenTransitsFit() {
        return evenTransitsFit;
    }

    public DvPlanetModelFit getOddTransitsFit() {
        return oddTransitsFit;
    }

    public DvPlanetModelFit getTrapezoidalFit() {
        return trapezoidalFit;
    }

    public DvSecondaryEventResults getSecondaryEventResults() {
        return secondaryEventResults;
    }

    public DvImageArtifactResults getImageArtifactResults() {
        return imageArtifactResults;
    }

    public List<DvPlanetModelFit> getSingleTransitFits() {
        return singleTransitFits;
    }

    public List<DvPlanetModelFit> getReducedParameterFits() {
        return reducedParameterFits;
    }

    public DvGhostDiagnosticResults getGhostDiagnosticResults() {
        return ghostDiagnosticResults;
    }

    public List<DvPixelCorrelationResults> getPixelCorrelationResults() {
        return pixelCorrelationResults;
    }

    public List<DvDifferenceImageResults> getDifferenceImageResults() {
        return differenceImageResults;
    }

    public FluxType getFluxType() {
        return fluxType;
    }

    public PipelineTask getPipelineTask() {
        return pipelineTask;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + (allTransitsFit == null ? 0 : allTransitsFit.hashCode());
        result = prime
            * result
            + (binaryDiscriminationResults == null ? 0
                : binaryDiscriminationResults.hashCode());
        result = prime * result
            + (centroidResults == null ? 0 : centroidResults.hashCode());
        result = prime * result + detrendFilterLength;
        result = prime
            * result
            + (differenceImageResults == null ? 0
                : differenceImageResults.hashCode());
        result = prime * result + endCadence;
        result = prime * result
            + (evenTransitsFit == null ? 0 : evenTransitsFit.hashCode());
        result = prime * result + (fluxType == null ? 0 : fluxType.hashCode());
        result = prime
            * result
            + (ghostDiagnosticResults == null ? 0
                : ghostDiagnosticResults.hashCode());
        result = prime
            * result
            + (imageArtifactResults == null ? 0
                : imageArtifactResults.hashCode());
        result = prime * result + keplerId;
        result = prime * result
            + (keplerName == null ? 0 : keplerName.hashCode());
        result = prime * result + Float.floatToIntBits(koiCorrelation);
        result = prime * result + (koiId == null ? 0 : koiId.hashCode());
        result = prime * result
            + (oddTransitsFit == null ? 0 : oddTransitsFit.hashCode());
        result = prime * result
            + (pipelineTask == null ? 0 : pipelineTask.hashCode());
        result = prime
            * result
            + (pixelCorrelationResults == null ? 0
                : pixelCorrelationResults.hashCode());
        result = prime * result
            + (planetCandidate == null ? 0 : planetCandidate.hashCode());
        result = prime * result + planetNumber;
        result = prime
            * result
            + (reducedParameterFits == null ? 0
                : reducedParameterFits.hashCode());
        result = prime
            * result
            + (secondaryEventResults == null ? 0
                : secondaryEventResults.hashCode());
        result = prime * result
            + (singleTransitFits == null ? 0 : singleTransitFits.hashCode());
        result = prime * result + startCadence;
        result = prime * result
            + (trapezoidalFit == null ? 0 : trapezoidalFit.hashCode());
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
        if (!(obj instanceof DvPlanetResults)) {
            return false;
        }
        DvPlanetResults other = (DvPlanetResults) obj;
        if (allTransitsFit == null) {
            if (other.allTransitsFit != null) {
                return false;
            }
        } else if (!allTransitsFit.equals(other.allTransitsFit)) {
            return false;
        }
        if (binaryDiscriminationResults == null) {
            if (other.binaryDiscriminationResults != null) {
                return false;
            }
        } else if (!binaryDiscriminationResults.equals(other.binaryDiscriminationResults)) {
            return false;
        }
        if (centroidResults == null) {
            if (other.centroidResults != null) {
                return false;
            }
        } else if (!centroidResults.equals(other.centroidResults)) {
            return false;
        }
        if (detrendFilterLength != other.detrendFilterLength) {
            return false;
        }
        if (differenceImageResults == null) {
            if (other.differenceImageResults != null) {
                return false;
            }
        } else if (!differenceImageResults.equals(other.differenceImageResults)) {
            return false;
        }
        if (endCadence != other.endCadence) {
            return false;
        }
        if (evenTransitsFit == null) {
            if (other.evenTransitsFit != null) {
                return false;
            }
        } else if (!evenTransitsFit.equals(other.evenTransitsFit)) {
            return false;
        }
        if (fluxType != other.fluxType) {
            return false;
        }
        if (ghostDiagnosticResults == null) {
            if (other.ghostDiagnosticResults != null) {
                return false;
            }
        } else if (!ghostDiagnosticResults.equals(other.ghostDiagnosticResults)) {
            return false;
        }
        if (imageArtifactResults == null) {
            if (other.imageArtifactResults != null) {
                return false;
            }
        } else if (!imageArtifactResults.equals(other.imageArtifactResults)) {
            return false;
        }
        if (keplerId != other.keplerId) {
            return false;
        }
        if (keplerName == null) {
            if (other.keplerName != null) {
                return false;
            }
        } else if (!keplerName.equals(other.keplerName)) {
            return false;
        }
        if (Float.floatToIntBits(koiCorrelation) != Float.floatToIntBits(other.koiCorrelation)) {
            return false;
        }
        if (koiId == null) {
            if (other.koiId != null) {
                return false;
            }
        } else if (!koiId.equals(other.koiId)) {
            return false;
        }
        if (oddTransitsFit == null) {
            if (other.oddTransitsFit != null) {
                return false;
            }
        } else if (!oddTransitsFit.equals(other.oddTransitsFit)) {
            return false;
        }
        if (pipelineTask == null) {
            if (other.pipelineTask != null) {
                return false;
            }
        } else if (!pipelineTask.equals(other.pipelineTask)) {
            return false;
        }
        if (pixelCorrelationResults == null) {
            if (other.pixelCorrelationResults != null) {
                return false;
            }
        } else if (!pixelCorrelationResults.equals(other.pixelCorrelationResults)) {
            return false;
        }
        if (planetCandidate == null) {
            if (other.planetCandidate != null) {
                return false;
            }
        } else if (!planetCandidate.equals(other.planetCandidate)) {
            return false;
        }
        if (planetNumber != other.planetNumber) {
            return false;
        }
        if (reducedParameterFits == null) {
            if (other.reducedParameterFits != null) {
                return false;
            }
        } else if (!reducedParameterFits.equals(other.reducedParameterFits)) {
            return false;
        }
        if (secondaryEventResults == null) {
            if (other.secondaryEventResults != null) {
                return false;
            }
        } else if (!secondaryEventResults.equals(other.secondaryEventResults)) {
            return false;
        }
        if (singleTransitFits == null) {
            if (other.singleTransitFits != null) {
                return false;
            }
        } else if (!singleTransitFits.equals(other.singleTransitFits)) {
            return false;
        }
        if (startCadence != other.startCadence) {
            return false;
        }
        if (trapezoidalFit == null) {
            if (other.trapezoidalFit != null) {
                return false;
            }
        } else if (!trapezoidalFit.equals(other.trapezoidalFit)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("id", id)
            .append("keplerId", keplerId)
            .append("planetNumber", planetNumber)
            .append("keplerName", keplerName)
            .append("koiId", koiId)
            .append("koiCorrelation", koiCorrelation)
            .append("detrendFilterLength", detrendFilterLength)
            .append("planetCandidate", planetCandidate)
            .append("centroidResults", centroidResults)
            .append("binaryDiscriminationResults", binaryDiscriminationResults)
            .append("allTransitsFit", allTransitsFit)
            .append("evenTransitsFit", evenTransitsFit)
            .append("oddTransitsFit", oddTransitsFit)
            .append("trapezoidalFit", trapezoidalFit)
            .append("singleTransitFits", singleTransitFits)
            .append("reducedParameterFits", reducedParameterFits)
            .append("ghostDiagnosticResults", ghostDiagnosticResults)
            .append("pixelCorrelationResults", pixelCorrelationResults)
            .append("differenceImageResults", differenceImageResults)
            .append("secondaryEventResults", secondaryEventResults)
            .append("imageArtifactResults", imageArtifactResults)
            .append("fluxType", fluxType)
            .append("pipelineTaskId", pipelineTask.getId())
            .toString();
    }

    /**
     * Used to construct a {@link DvPlanetResults} object. To use this class, a
     * {@link Builder} object is created with the required parameter
     * pipelineTask. Then non-null fields are set using the available builder
     * methods. Finally, a {@link DvPlanetResults} object is created using the
     * build method. For example:
     * 
     * <pre>
     * DvPlanetResults planetResults = new DvPlanetResults.Builder(pipelineTask).keplerId(
     *     12345678)
     *     .build();
     * </pre>
     * 
     * This pattern is based upon <a href=
     * "http://developers.sun.com/learning/javaoneonline/2006/coreplatform/TS-1512.pdf"
     * > Josh Bloch's JavaOne 2006 talk, Effective Java Reloaded, TS-1512</a>.
     * 
     * @author Bill Wohler
     */
    @XmlTransient
    public static class Builder {
        private long id;
        private int startCadence;
        private int endCadence;
        private int keplerId;
        private int planetNumber;
        private String koiId = "";
        private String keplerName = "";
        private float koiCorrelation = -1;
        private int detrendFilterLength;
        private DvPlanetCandidate planetCandidate;
        private DvCentroidResults centroidResults;
        private DvBinaryDiscriminationResults binaryDiscriminationResults;
        private DvPlanetModelFit allTransitsFit;
        private DvPlanetModelFit evenTransitsFit;
        private DvPlanetModelFit oddTransitsFit;
        private DvPlanetModelFit trapezoidalFit;
        private DvSecondaryEventResults secondaryEventResults;
        private DvImageArtifactResults imageArtifactResults;
        private List<DvPlanetModelFit> singleTransitFits = new ArrayList<DvPlanetModelFit>();
        private List<DvPlanetModelFit> reducedParameterFits = new ArrayList<DvPlanetModelFit>();
        private DvGhostDiagnosticResults ghostDiagnosticResults;
        private List<DvPixelCorrelationResults> pixelCorrelationResults = new ArrayList<DvPixelCorrelationResults>();
        private List<DvDifferenceImageResults> differenceImageResults = new ArrayList<DvDifferenceImageResults>();
        private FluxType fluxType;
        private PipelineTask pipelineTask;

        /**
         * Creates a {@link Builder} object with the given required parameters.
         * 
         * @param startCadence the starting cadence
         * @param endCadence the ending cadence
         * @param keplerId the Kepler ID
         * @param planetNumber the planet number
         * @param pipelineTask the pipeline task
         * @throws NullPointerException if {@code pipelineTask} is {@code null}
         */
        public Builder(int startCadence, int endCadence, int keplerId,
            int planetNumber, PipelineTask pipelineTask) {
            if (pipelineTask == null) {
                throw new NullPointerException("pipelineTask can't be null");
            }

            this.startCadence = startCadence;
            this.endCadence = endCadence;
            this.keplerId = keplerId;
            this.planetNumber = planetNumber;
            this.pipelineTask = pipelineTask;
        }

        /**
         * For use by tests only.
         */
        Builder id(long id) {
            this.id = id;
            return this;
        }

        public Builder planetCandidate(DvPlanetCandidate planetCandidate) {
            this.planetCandidate = planetCandidate;
            return this;
        }

        public Builder centroidResults(DvCentroidResults centroidResults) {
            this.centroidResults = centroidResults;
            return this;
        }

        public Builder binaryDiscriminationResults(
            DvBinaryDiscriminationResults binaryDiscriminationResults) {
            this.binaryDiscriminationResults = binaryDiscriminationResults;
            return this;
        }

        public Builder allTransitsFit(DvPlanetModelFit allTransitsFit) {
            this.allTransitsFit = allTransitsFit;
            return this;
        }

        public Builder evenTransitsFit(DvPlanetModelFit evenTransitsFit) {
            this.evenTransitsFit = evenTransitsFit;
            return this;
        }

        public Builder oddTransitsFit(DvPlanetModelFit oddTransitsFit) {
            this.oddTransitsFit = oddTransitsFit;
            return this;
        }

        public Builder trapezoidalFit(DvPlanetModelFit trapezoidalFit) {
            this.trapezoidalFit = trapezoidalFit;
            return this;
        }

        public Builder secondaryEventResults(
            DvSecondaryEventResults secondaryEventResults) {
            this.secondaryEventResults = secondaryEventResults;
            return this;
        }

        public Builder singleTransitFits(
            List<DvPlanetModelFit> singleTransitFits) {
            this.singleTransitFits = singleTransitFits;
            return this;
        }

        public Builder reducedParameterFits(
            List<DvPlanetModelFit> reducedParameterFits) {
            this.reducedParameterFits = reducedParameterFits;
            return this;
        }

        public Builder ghostDiagnosticResults(
            DvGhostDiagnosticResults ghostDiagnosticResults) {
            this.ghostDiagnosticResults = ghostDiagnosticResults;
            return this;
        }

        public Builder pixelCorrelationResults(
            List<DvPixelCorrelationResults> pixelCorrelationResults) {
            this.pixelCorrelationResults = pixelCorrelationResults;
            return this;
        }

        public Builder imageArtifactResults(
            DvImageArtifactResults imageArtifactResults) {
            this.imageArtifactResults = imageArtifactResults;
            return this;
        }

        public Builder differenceImageResults(
            List<DvDifferenceImageResults> differenceImageResults) {
            this.differenceImageResults = differenceImageResults;
            return this;
        }

        public Builder fluxType(FluxType fluxType) {
            this.fluxType = fluxType;
            return this;
        }

        public Builder keplerName(String keplerName) {
            this.keplerName = keplerName;
            return this;
        }

        public Builder koiCorrelation(float koiCorrelation) {
            this.koiCorrelation = koiCorrelation;
            return this;
        }

        public Builder koiId(String koiId) {
            this.koiId = koiId;
            return this;
        }

        public Builder detrendFilterLength(int detrendFilterLength) {
            this.detrendFilterLength = detrendFilterLength;
            return this;
        }

        public DvPlanetResults build() {
            return new DvPlanetResults(this);
        }
    }
}
