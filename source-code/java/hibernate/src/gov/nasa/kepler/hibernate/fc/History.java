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

import gov.nasa.kepler.common.ModifiedJulianDate;

import java.util.Date;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

/**
 * This class encapsulates the history information for when a model is valid
 * for.
 * 
 * @author kester allen
 * 
 */

@Entity
@Table(name = "FC_HISTORY")
public class History {

    @Id
	@GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
	@SequenceGenerator(name = "sg", sequenceName = "FC_HISTORY_TEST_SEQ")
	private long id; // required by Hibernate

	private double ingestTime;
	private int version;
	private HistoryModelName modelType;
	private String description;

	/**
	 * No-op default constructor (package-level to avoid being run) for
	 * hibernate
	 */
	History() {
		;
	}

	/**
	 * @param changeTime
	 * @param modelType
	 * @param description
	 */
	public History(double changeTime, HistoryModelName modelType,
			String description, int version) {
		super();
		this.ingestTime = changeTime;
		this.modelType = modelType;
		this.description = description;
		this.version = version;
	}

	/**
	 * Construct a History object with a change time and a model type.
	 * 
	 * @param changeTime (MJD double)
	 * @param modelType (String)
	 */
	public History(double changeTime, HistoryModelName modelType, int version) {
		this.ingestTime = changeTime;
		this.modelType = modelType;
		this.version = version;
	}

	/**
	 * Construct a History object with a change time of NOW and a model type.
	 * 
	 * @param ingestTime (MJD double)
	 * @param modelType (String)
	 */
	public History(HistoryModelName modelType, int version) {
		double mjdNow = ModifiedJulianDate.dateToMjd(new Date());
		this.ingestTime = mjdNow;
		this.modelType = modelType;
		this.version = version;
	}

	public History(HistoryModelName modelType, String description, int version) {
		double mjdNow = ModifiedJulianDate.dateToMjd(new Date());
		this.ingestTime = mjdNow;
		this.description = description;
		this.modelType = modelType;
		this.version = version;
	}

	public double getIngestTime() {
		return ingestTime;
	}

	public void setIngestTime(double ingestTime) {
		this.ingestTime = ingestTime;
	}

	public int getVersion() {
		return version;
	}

	public void setVersion(int version) {
		this.version = version;
	}

	public HistoryModelName getModelType() {
		return this.modelType;
	}

	public void setModelType(HistoryModelName modelType) {
		this.modelType = modelType;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

    public String toString() {
        return "changeTime="      + ingestTime + 
               ", modelType="     + modelType + 
               ", description=\"" + description + "\"" +
               ", oracle ID="     + id;
    }
}
