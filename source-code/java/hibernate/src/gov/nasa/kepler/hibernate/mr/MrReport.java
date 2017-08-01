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

package gov.nasa.kepler.hibernate.mr;

import gov.nasa.kepler.common.Iso8601Formatter;
import gov.nasa.kepler.hibernate.pi.ModuleName;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineTask;

import java.util.Date;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.OneToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * Metadata about an externally generated report. This is used by MR to display
 * that report.
 * 
 * @author Bill Wohler
 */
@Entity
@Table(name = "MR_REPORT")
public class MrReport implements Comparable<MrReport> {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "MR_REPORT_SEQ")
    @Column(nullable = false)
    private long id; // required by Hibernate

    /**
     * The {@link PipelineInstance} that produced this report. This is
     * initialized from {@code pipelineTask.getPipelineInstance()}. This field
     * can't be lazily loaded as doing so breaks {@link #equals(Object)}.
     */
    @OneToOne
    private PipelineInstance pipelineInstance;

    /**
     * The {@link PipelineInstanceNode} that produced this report. This is
     * initialized from {@code pipelineTask.getPipelineInstanceNode()}.
     */
    @OneToOne(fetch = FetchType.LAZY)
    private PipelineInstanceNode pipelineInstanceNode;

    /**
     * The {@link PipelineTask} that produced this report. This field can't be
     * lazily loaded as doing so breaks {@link #equals(Object)}.
     */
    @OneToOne
    private PipelineTask pipelineTask;

    /**
     * The pipeline module's name. This is initialized from {@code
     * pipelineTask.getPipelineDefinitionNode().getModuleName()}.
     */
    @OneToOne(fetch = FetchType.LAZY)
    private ModuleName moduleName;

    /**
     * The date this report was created.
     */
    private Date created;

    /**
     * If a pipeline task produces multiple reports, this field can be used to
     * distinguish between them.
     */
    private String identifier;

    /**
     * The filename of the stored report.
     */
    private String filename;

    /**
     * The MIME type of the stored report.
     */
    private String mimeType;

    /**
     * The string representation of the {@code FsId} of the stored report.
     */
    private String fsId;

    /**
     * Creates a {@link MrReport}. Required by Hibernate.
     */
    MrReport() {
    }

    /**
     * Creates a {@link MrReport} with the given attributes.
     * 
     * @param pipelineTask the pipeline task that generated the report
     * @param filename the filename of the report
     * @param mimeType the MIME type of the report
     * @param fsId the fsId of the report itself
     * @throws NullPointerException if {@code pipelineTask}, {@code filename},
     * {@code mimeType}, or {@code fsId} are null
     */
    public MrReport(PipelineTask pipelineTask, String filename,
        String mimeType, String fsId) {
        this(pipelineTask, null, filename, mimeType, fsId);
    }

    /**
     * Creates a {@link MrReport} with the given {@link PipelineTask} and fsId.
     * 
     * @param pipelineTask the pipeline task that generated the report
     * @param identifier the report's distinguishing identifier; may be {@code
     * null} or empty if the task has a single report
     * @param filename the filename of the report
     * @param mimeType the MIME type of the report
     * @param fsId the fsId of the report itself
     * @throws NullPointerException if {@code pipelineTask}, {@code filename},
     * {@code mimeType}, or {@code fsId} are null
     */
    public MrReport(PipelineTask pipelineTask, String identifier,
        String filename, String mimeType, String fsId) {

        if (pipelineTask == null) {
            throw new NullPointerException("pipelineTask can not be null");
        }
        if (filename == null) {
            throw new NullPointerException("filename can not be null");
        }
        if (mimeType == null) {
            throw new NullPointerException("mimeType can not be null");
        }
        if (fsId == null) {
            throw new NullPointerException("fsId can not be null");
        }

        this.pipelineTask = pipelineTask;
        pipelineInstance = pipelineTask.getPipelineInstance();
        pipelineInstanceNode = pipelineTask.getPipelineInstanceNode();
        moduleName = pipelineTask.getPipelineDefinitionNode()
            .getModuleName();
        created = new Date();
        this.identifier = identifier;
        this.filename = filename;
        this.mimeType = mimeType;
        this.fsId = fsId;
    }

    public PipelineInstance getPipelineInstance() {
        return pipelineInstance;
    }

    public PipelineInstanceNode getPipelineInstanceNode() {
        return pipelineInstanceNode;
    }

    public PipelineTask getPipelineTask() {
        return pipelineTask;
    }

    public ModuleName getModuleName() {
        return moduleName;
    }

    public Date getCreated() {
        return created;
    }

    public String getIdentifier() {
        return identifier;
    }

    public String getFilename() {
        return filename;
    }

    /**
     * Combines the {@code filename}, {@code pipelineInstance}, and {@code
     * created} fields. This method should be used in lieu of
     * {@link #getFilename()} unless the client is creating their own filename
     * format. If the filename already contains what looks like a date, it will
     * be left alone.
     * 
     * @return a filename in the form {@code
     * filename-piNNNNN-YYYYmmddTHHMMSSZ,sss.ext}
     */
    public String filenameWithDate() {
        Pattern p = Pattern.compile("[0-9]{8}T[0-9]{6}(,[0-9]{3})?Z?");
        Matcher m = p.matcher(getFilename());
        if (m.find()) {
            return getFilename();
        }

        String date = Iso8601Formatter.dateTimeMillisFormatter()
            .format(getCreated());
        StringBuilder s = new StringBuilder(getFilename());
        int dot = s.lastIndexOf(".");
        if (dot < 0) {
            dot = s.length();
        }
        s.insert(dot, String.format("-pi%05d-%s",
            getPipelineInstance().getId(), date));

        return s.toString();
    }

    public String getMimeType() {
        return mimeType;
    }

    public String getFsId() {
        return fsId;
    }

    @Override
    public int compareTo(MrReport other) {
        if (pipelineInstance == null) {
            if (other.pipelineInstance != null) {
                return -1;
            }
        } else if (other.pipelineInstance == null) {
            return 1;
        } else if (pipelineInstance.getId() != other.pipelineInstance.getId()) {
            return (int) (pipelineInstance.getId() - other.pipelineInstance.getId());
        }
        if (pipelineInstanceNode == null) {
            if (other.pipelineInstanceNode != null) {
                return -1;
            }
        } else if (other.pipelineInstanceNode == null) {
            return 1;
        } else if (pipelineInstanceNode.getId() != other.pipelineInstanceNode.getId()) {
            return (int) (pipelineInstanceNode.getId() - other.pipelineInstanceNode.getId());
        }
        if (pipelineTask == null) {
            if (other.pipelineTask != null) {
                return -1;
            }
        } else if (other.pipelineTask == null) {
            return 1;
        } else if (pipelineTask.getId() != other.pipelineTask.getId()) {
            return (int) (pipelineTask.getId() - other.pipelineTask.getId());
        }
        if (identifier == null) {
            if (other.identifier != null) {
                return -1;
            }
        } else if (other.identifier == null) {
            return 1;
        } else if (!identifier.equals(other.identifier)) {
            return identifier.compareTo(other.identifier);
        }

        return 0;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + ((identifier == null) ? 0 : identifier.hashCode());
        result = prime * result
            + ((pipelineTask == null) ? 0 : pipelineTask.hashCode());
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
        if (!(obj instanceof MrReport)) {
            return false;
        }
        MrReport other = (MrReport) obj;
        if (identifier == null) {
            if (other.identifier != null) {
                return false;
            }
        } else if (!identifier.equals(other.identifier)) {
            return false;
        }
        if (pipelineTask == null) {
            if (other.pipelineTask != null) {
                return false;
            }
        } else if (!pipelineTask.equals(other.pipelineTask)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("id", id)
            .append("pipelineInstance",
                pipelineInstance != null ? pipelineInstance.getId() : -1L)
            .append(
                "pipelineInstanceNode",
                pipelineInstanceNode != null ? pipelineInstanceNode.getId()
                    : -1L)
            .append("pipelineTask",
                pipelineTask != null ? pipelineTask.getId() : -1L)
            .append("identifier", identifier)
            .append("moduleName",
                moduleName != null ? moduleName.getName() : "null")
            .append(
                "uow",
                pipelineTask != null && pipelineTask.getUowTask() != null
                    && pipelineTask.getUowTask()
                        .isInitialized() ? pipelineTask.uowTaskInstance()
                    .briefState() : "null")
            .append("created", created)
            .append("filename", filename)
            .append("mimeType", mimeType)
            .append("fsId", fsId)
            .toString();
    }
}
