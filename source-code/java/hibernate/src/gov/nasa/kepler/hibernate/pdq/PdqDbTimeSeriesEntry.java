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

package gov.nasa.kepler.hibernate.pdq;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;

import org.hibernate.annotations.Index;

/**
 * Double precision time series entry for PDQ.
 * 
 * @author Forrest Girouard
 */
@Entity
@Table(name = "PDQ_DOUBLE_TS", uniqueConstraints = { @UniqueConstraint(columnNames = {
    "timeSeriesType", "cadence", "targetTableId" }) })
public class PdqDbTimeSeriesEntry {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "pdqdoubleseq")
    @SequenceGenerator(name = "pdqdoubleseq", sequenceName = "PDQ_DOUBLE_TS_SEQ")
    private long id;

    @Index(name = "PDQ_DOUBLE_TS_IDX")
    private PdqDoubleTimeSeriesType timeSeriesType;

    @Index(name = "PDQ_DOUBLE_TS_IDX")
    private int cadence;

    @Index(name = "PDQ_DOUBLE_TS_IDX")
    private int targetTableId;

    private long originator;
    private double value;
    private double uncertainty;

    public PdqDbTimeSeriesEntry() {
    }

    public PdqDbTimeSeriesEntry(PdqDoubleTimeSeriesType timeSeriesType,
        int targetTableId, int cadence, double value, double uncertainty,
        long originator) {

        this.timeSeriesType = timeSeriesType;
        this.targetTableId = targetTableId;
        this.cadence = cadence;
        this.value = value;
        this.uncertainty = uncertainty;
        this.originator = originator;
    }

    public PdqDoubleTimeSeriesType getTimeSeriesType() {
        return timeSeriesType;
    }

    public void setTimeSeriesType(PdqDoubleTimeSeriesType timeSeriesType) {
        this.timeSeriesType = timeSeriesType;
    }

    public int getCadence() {
        return cadence;
    }

    public void setCadence(int cadence) {
        this.cadence = cadence;
    }

    public int getTargetTableId() {
        return targetTableId;
    }

    public void setTargetTableId(int targetTableId) {
        this.targetTableId = targetTableId;
    }

    public long getOriginator() {
        return originator;
    }

    public void setOriginator(long originator) {
        this.originator = originator;
    }

    public double getUncertainty() {
        return uncertainty;
    }

    public void setUncertainty(double uncertainty) {
        this.uncertainty = uncertainty;
    }

    public double getValue() {
        return value;
    }

    public void setValue(double value) {
        this.value = value;
    }

}
