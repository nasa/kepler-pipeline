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

package gov.nasa.kepler.hibernate.pa;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.hibernate.dv.DvPixelCorrelationResults;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.TargetTable;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.ManyToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.apache.commons.lang.builder.ToStringBuilder;
import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;
import org.hibernate.annotations.CollectionOfElements;
import org.hibernate.annotations.Fetch;
import org.hibernate.annotations.FetchMode;
import org.hibernate.annotations.Index;
import org.hibernate.annotations.IndexColumn;

/**
 * 
 * @author Forrest Girouard
 */
@Entity
@Table(name = "PA_APERTURE")
public class TargetAperture {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "PA_APERTURE_SEQ")
    private long id; // required by Hibernate

    /**
     * The {@link PipelineTask} of the {@link PipelineModule} that produced this
     * data.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    private PipelineTask pipelineTask;

    @ManyToOne(optional = false)
    @Cascade(CascadeType.EVICT)
    private TargetTable targetTable;

    /**
     * Target for this pixel aperture.
     */
    @Index(name = "PA_TARGET_APERTURE_IDX")
    private int keplerId;

    /**
     * CCD Module covered by this pixel aperture.
     */
    @Index(name = "PA_APERTURE_IDX")
    private int ccdModule;

    /**
     * CCD Output covered by this pixel aperture.
     */
    @Index(name = "PA_APERTURE_IDX")
    private int ccdOutput;

    /**
     * The aperture pixels.
     */
    @CollectionOfElements(fetch = FetchType.EAGER)
    @Fetch(value = FetchMode.SUBSELECT)
    @IndexColumn(name = "IDX")
    @Cascade(CascadeType.ALL)
    private List<CentroidPixel> centroidPixels = new ArrayList<CentroidPixel>();

    TargetAperture() {
    }

    public TargetAperture(Builder builder) {

        pipelineTask = builder.pipelineTask;
        keplerId = builder.keplerId;
        ccdModule = builder.ccdModule;
        ccdOutput = builder.ccdOutput;
        targetTable = builder.targetTable;
        centroidPixels = builder.centroidPixels;
    }

    public List<CentroidPixel> getCentroidPixels() {
        return centroidPixels;
    }

    public void setCentroidPixels(List<CentroidPixel> centroidPixels) {
        this.centroidPixels = centroidPixels;
    }

    public long getId() {
        return id;
    }

    public PipelineTask getPipelineTask() {
        return pipelineTask;
    }

    public int getKeplerId() {
        return keplerId;
    }

    public int getCcdModule() {
        return ccdModule;
    }

    public int getCcdOutput() {
        return ccdOutput;
    }

    public TargetTable getTargetTable() {
        return targetTable;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("pipelineTask.id",
            pipelineTask == null ? "null" : pipelineTask.getId())
            .append("keplerId", keplerId)
            .append("ccdModule", ccdModule)
            .append("ccdOutput", ccdOutput)
            .append("targetTable.externalId", targetTable.getExternalId())
            .append("centroidPixels.size", centroidPixels.size())
            .toString();
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ccdModule;
        result = prime * result + ccdOutput;
        result = prime * result + keplerId;
        result = prime * result
            + (targetTable == null ? 0 : targetTable.hashCode());
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
        if (!(obj instanceof TargetAperture)) {
            return false;
        }
        TargetAperture other = (TargetAperture) obj;
        if (ccdModule != other.ccdModule) {
            return false;
        }
        if (ccdOutput != other.ccdOutput) {
            return false;
        }
        if (keplerId != other.keplerId) {
            return false;
        }
        if (targetTable == null) {
            if (other.targetTable != null) {
                return false;
            }
        } else if (!targetTable.equals(other.targetTable)) {
            return false;
        }
        return true;
    }

    /**
     * Used to construct a {@link DvPixelCorrelationResults} object. To use this
     * class, a {@link Builder} object is created with the required parameter
     * pipelineTask. Then non-null fields are set using the available builder
     * methods. Finally, a {@link DvPixelCorrelationResults} object is created
     * using the build method. For example:
     * 
     * <pre>
     * DvPixelCorrelationResults pixelCorrelationResults = new DvPixelCorrelationResults(
     *     targetTableId).ccdModule(2)
     *     .ccdOutput(1)
     *     .pixelCorrelationStatistics(statistics)
     *     .build();
     * </pre>
     * 
     * This pattern is based upon <a href=
     * "http://developers.sun.com/learning/javaoneonline/2006/coreplatform/TS-1512.pdf"
     * > Josh Bloch's JavaOne 2006 talk, Effective Java Reloaded, TS-1512</a>.
     * 
     * @author Forrest Girouard
     */
    public static class Builder {
        private PipelineTask pipelineTask;
        private TargetTable targetTable;
        private int keplerId;
        private int ccdModule;
        private int ccdOutput;
        private List<CentroidPixel> centroidPixels = new ArrayList<CentroidPixel>();

        /**
         * Creates a {@link Builder} object with the given required parameter.
         * 
         * @param targetTableId the target table ID
         */
        public Builder(PipelineTask pipelineTask, TargetTable targetTable,
            int keplerId) {
            this.pipelineTask = pipelineTask;
            this.targetTable = targetTable;
            this.keplerId = keplerId;
        }

        public Builder ccdModule(int ccdModule) {

            if (!FcConstants.validCcdModule(ccdModule)) {
                throw new IllegalArgumentException("invalid CCD module: "
                    + ccdModule);
            }

            this.ccdModule = ccdModule;
            return this;
        }

        public Builder ccdOutput(int ccdOutput) {

            if (!FcConstants.validCcdOutput(ccdOutput)) {
                throw new IllegalArgumentException("invalid CCD output: "
                    + ccdOutput);
            }

            this.ccdOutput = ccdOutput;
            return this;
        }

        public Builder pixels(List<CentroidPixel> centroidPixels) {
            this.centroidPixels = centroidPixels;
            return this;
        }

        public TargetAperture build() {
            return new TargetAperture(this);
        }
    }
}
