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

package gov.nasa.kepler.hibernate.mc;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.hibernate.pi.Model;
import gov.nasa.kepler.hibernate.pi.ModelMetadata;

import java.util.List;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;

/**
 * Contains a model for {@link ObservingLog}s. The model is simply a collection
 * of {@link ObservingLog}s with a revision for use with {@link ModelMetadata}.
 * 
 * @author Miles Cote
 * 
 */
@Entity
@Table(name = "MC_OBS_LOG_MODEL", uniqueConstraints = { @UniqueConstraint(columnNames = { "revision" }) })
public class ObservingLogModel implements Model {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "MC_OLM_SEQ")
    @Column(nullable = false)
    private long id;

    private int revision;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(name = "MC_OLM_OL")
    private List<ObservingLog> observingLogs;

    /**
     * Only used by hibernate.
     */
    ObservingLogModel() {
    }

    public ObservingLogModel(int revision, List<ObservingLog> observingLogs) {
        this.revision = revision;
        this.observingLogs = observingLogs;
    }
    
    public List<ObservingLog> observingLogsFor(int cadenceType, int cadenceStart, int cadenceEnd){
        List<ObservingLog> list = newArrayList();
        for (ObservingLog observingLog : observingLogs) {
            if (observingLog.getCadenceType() == cadenceType &&
                observingLog.getCadenceStart() <= cadenceEnd &&
                observingLog.getCadenceEnd() >= cadenceStart) {
                list.add(observingLog);
            }
        }
        
        return list;
    }

    public long getId() {
        return id;
    }

    @Override
    public int getRevision() {
        return revision;
    }

    @Override
    public void setRevision(int revision) {
        this.revision = revision;
    }

    public List<ObservingLog> getObservingLogs() {
        return observingLogs;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + ((observingLogs == null) ? 0 : observingLogs.hashCode());
        result = prime * result + revision;
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
        ObservingLogModel other = (ObservingLogModel) obj;
        if (observingLogs == null) {
            if (other.observingLogs != null)
                return false;
        } else if (!observingLogs.equals(other.observingLogs))
            return false;
        if (revision != other.revision)
            return false;
        return true;
    }

    @Override
    public String toString() {
        return "ObservingLogModel [revision=" + revision + ", observingLogs="
            + observingLogs + "]";
    }
}
