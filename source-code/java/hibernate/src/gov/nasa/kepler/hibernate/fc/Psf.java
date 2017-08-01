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

import java.util.ArrayList;
import java.util.List;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinTable;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.hibernate.annotations.CollectionOfElements;
import org.hibernate.annotations.IndexColumn;

@Entity
@Table(name = "FC_PSF")
public class Psf {
    
    @Id
    @GeneratedValue(strategy=GenerationType.AUTO, generator="sg")
    @SequenceGenerator(name="sg", sequenceName="FC_PSF_SEQ")
    private long id;
    
    private long targetId;
    private double startTime;
    private double endTime;
    private String specType;
    
    @CollectionOfElements
    @JoinTable(name="FC_PSF_COEFFS")
    @IndexColumn(name="IDX")
    private List<Double> coeffs;

    public Psf() {
        setStartTime(-200);
        setEndTime(-100);

        coeffs = new ArrayList<Double>();
        for (int ii = 0; ii < 100; ++ii) {
            coeffs.add(0.0);
        }
    }

    public Psf(long newTargetId) {
        this();
        setTargetId(newTargetId);
    }

    public Psf(long newTargetId, double start, double stop, String type) {
        this();
        targetId = newTargetId;
        startTime = start;
        endTime = stop;
        specType = type;
    }
        
    public Psf(long newTargetId, double start, double stop, List<Double> newCoeffs,
        String type) {
        this();
        targetId = newTargetId;
        startTime = start;
        endTime = stop;
        coeffs = newCoeffs;
        specType = type;
    }
    
    public Psf(long newTargetId, double start, double stop, double[] newCoeffs,
            String type) {
            this();
            targetId = newTargetId;
            startTime = start;
            endTime = stop;
            for (int ii = 0; ii < newCoeffs.length; ++ii) {
            	coeffs.set(ii, newCoeffs[ii]);
            }
            specType = type;
        }

    public List<Double> getPsfCoeffs() {
        return coeffs;
    }

    public void setPsfCoeffs(List<Double> newCoeffs) {
        coeffs = newCoeffs;
    }

    public String getSpecType() {
        return specType;
    }

    public void setSpecType(String type) {
        specType = type;
    }

    public double getStartTime() {
        return startTime;
    }

    public void setStartTime(double start) {
        startTime = start;
    }

    public double getEndTIme() {
        return endTime;
    }

    public void setEndTime(double stop) {
        endTime = stop;
    }

    public long getTargetId() {
        return targetId;
    }

    public void setTargetId(long newTargetId) {
        targetId = newTargetId;
    }

    public String toString() {
        String psfString = "";
        for (Object val : coeffs) {
            psfString += val.toString() + "|";
        }
        return "PSF: " + targetId + " " + startTime + " " + endTime + " "
            + specType + " " + psfString;
    }

    public String queryString() {
        return "targetId == " + getTargetId();
    }

    public String queryStringBefore() {
        return "select from gov.nasa.kepler.jdo.fc.Psf "
            + "where startTime < parameterizedValue && " + queryString();
    }

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((coeffs == null) ? 0 : coeffs.hashCode());
		long temp;
		temp = Double.doubleToLongBits(endTime);
		result = prime * result + (int) (temp ^ (temp >>> 32));
		result = prime * result
				+ ((specType == null) ? 0 : specType.hashCode());
		temp = Double.doubleToLongBits(startTime);
		result = prime * result + (int) (temp ^ (temp >>> 32));
		result = prime * result + (int) (targetId ^ (targetId >>> 32));
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
		final Psf other = (Psf) obj;
		if (coeffs == null) {
			if (other.coeffs != null)
				return false;
		} else if (!coeffs.equals(other.coeffs))
			return false;
		if (Double.doubleToLongBits(endTime) != Double
				.doubleToLongBits(other.endTime))
			return false;
		if (specType == null) {
			if (other.specType != null)
				return false;
		} else if (!specType.equals(other.specType))
			return false;
		if (Double.doubleToLongBits(startTime) != Double
				.doubleToLongBits(other.startTime))
			return false;
		if (targetId != other.targetId)
			return false;
		return true;
	}
}
