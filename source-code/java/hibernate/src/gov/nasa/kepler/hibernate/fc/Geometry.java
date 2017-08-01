/**
 * Geometry.java.
 * 
 * A class that maintains the persistence of the Focal Plane Geometry Model, the
 * set of angles that defines the spatial orientation of the Kepler CCDs.
 * 
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
@Table(name = "FC_GEOMETRY")
public class Geometry {
    public static final int ELEMENT_COUNT_NO_PLATESCALE = 252;
    public static final int ELEMENT_COUNT = ELEMENT_COUNT_NO_PLATESCALE + FcConstants.nModules * FcConstants.nOutputsPerModule;

    
    @Id
    @GeneratedValue(strategy=GenerationType.AUTO, generator="sg")
    @SequenceGenerator(name="sg", sequenceName="FC_GEOMETRY_SEQ")
    // required by Hibernate
    private long id;
    
    private double startTime;
    
    @CollectionOfElements
    @JoinTable(name="FC_GEOMETRY_CONSTANTS")
    @IndexColumn(name="IDX")
    private List<Double> constants;

    @CollectionOfElements
    @JoinTable(name="FC_GEOMETRY_UNCERTAINTY")
    @IndexColumn(name="IDX2")
    private List<Double> uncertainty;

    public Geometry() {
        setStartTime(-100.0);
        constants = new ArrayList<Double>(ELEMENT_COUNT_NO_PLATESCALE);
        uncertainty = new ArrayList<Double>(ELEMENT_COUNT_NO_PLATESCALE);
        for (int ii = 0; ii < uncertainty.size(); ++ii) {
            constants.add(-1.0);
            uncertainty.add(-1.0);
        }
    }

    public Geometry(List<Double> constants) {
        this();
        this.constants = constants;
    }

    public Geometry(double[] constants) {
        this();
        for (double constant : constants) {
            this.constants.add(constant);
        }
    }

    public Geometry(double start, List<Double> constants) {
        this();
        setStartTime(start);
        setConstants(constants);
    }
    
    public Geometry(double start, List<Double> constants, List<Double> uncertainty) {
        this();
        setStartTime(start);
        setConstants(constants);
        setUncertainty(uncertainty);
    }

    public Geometry(double startTime, double[] constants) {
        this();
        setStartTime(startTime);
        this.constants.clear();
        for (double val : constants) {
            this.constants.add(val);
        }
    }

    public Geometry(double mjd) {
        this();
        this.startTime = mjd; 
    }

    public String toStringForLoader() {
        String out = "";
        out += startTime + "\n";
        for (Object obj : constants) {
            out += obj + "\n";
        }
        return out;
    }

    public String toString() {
        String out = startTime + " ---- " + constants.size() + " elements ----";
        for (Object obj : constants) {
            out += "|" + obj;
        }
        out += "\n";
        return out;
    }

    public double[] getConstantsArray() {
        double[] arr = new double[constants.size()];
        for (int ii = 0; ii < constants.size(); ++ii) {
            arr[ii] = constants.get(ii);
        }
        return arr;
    }

    public double[] getUncertaintyArray() {
        double[] arr = new double[constants.size()];
        for (int ii = 0; ii < uncertainty.size(); ++ii) {
            arr[ii] = uncertainty.get(ii);
        }
        return arr;
    }
    
    public double getStartTime() {
        return startTime;
    }

    public void setStartTime(double startTime) {
        this.startTime = startTime;
    }

    public List<Double> getConstants() {
        return constants;
    }

    public void setConstants(List<Double> constants) {
        this.constants = constants;
    }
    
    public double getTime() {
        return getStartTime();
    }

    public void setTime(double time) {
        setStartTime(time);
    }

    public List<Double> getUncertainty() {
        return this.uncertainty;
    }

    public void setUncertainty(List<Double> uncertainty) {
        this.uncertainty = uncertainty;
    }

    public long getId() {
        return id;
    }
}
