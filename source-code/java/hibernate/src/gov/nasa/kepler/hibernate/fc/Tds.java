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

package gov.nasa.kepler.hibernate.fc;

import gov.nasa.kepler.common.FcConstants;

import java.util.Date;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

@Entity
@Table(name = "FC_TDS")
public class Tds {
    
    @Id
    @GeneratedValue(strategy=GenerationType.AUTO, generator="sg")
    @SequenceGenerator(name="sg", sequenceName="FC_TDS_SEQ")
    private long id;
    
    private int ccdModule;
    private int ccdOutput;;
    private Date startTime;
    private double intercept;
    private double slope;

    /**
     * No-op default constructor to make Hibernate happy.
     *
     */
    Tds() {
        ;
    }
    
    /**
     * @param ccdModule
     * @param ccdOutput
     * @param startTime
     * @param intercept
     * @param slope
     */
    public Tds(int module, int output, Date start, double intercept, double slope) {
        super();
        this.ccdModule = module;
        this.ccdOutput = output;
        this.startTime = start;
        this.intercept = intercept;
        this.slope = slope;
    }

    public String queryString() {
        return ccdModule + " == ccdModule && " + ccdOutput + " == ccdOutput && " + "startTime < parameterizedValueStart";
    }

    public String toString() {
        return "startTime " + getStartTime() + "mod " + getCcdModule() + " out " + getCcdOutput() + " intercept " + getIntercept() + " slope " + getSlope();
    }

    public double getIntercept() {
        return this.intercept;
    }

    public void setIntercept(double intercept) {
        this.intercept = intercept;
    }

    public int getCcdModule() {
        return this.ccdModule;
    }

    public void setCcdModule(int module) {
        this.ccdModule = module;
    }

    public int getCcdOutput() {
        return this.ccdOutput;
    }

    public void setCcdOutput(int output) {
        this.ccdOutput = output;
    }

    public double getSlope() {
        return this.slope;
    }

    public void setSlope(double slope) {
        this.slope = slope;
    }

    public Date getStartTime() {
        return this.startTime;
    }

    public void setStartTime(Date start) {
        this.startTime = start;
    }
    
    /**
     * As defined in DMC to SOC ICD, KDMC-10007, rev 001i, pg 41
     * @param time
     * @return
     */
    public double getGainValue(Date mjd) {
        double secsAfterStart = (double) ((this.getStartTime().getTime() - mjd.getTime()) / ((long)1000));
        double val = this.getIntercept() + secsAfterStart * this.getSlope() / FcConstants.CENTIDAYS_PER_YEAR;
        return val;
    }
}
