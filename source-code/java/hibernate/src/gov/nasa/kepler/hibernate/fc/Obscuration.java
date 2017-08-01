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

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

@Entity
@Table(name = "FC_OBSCURATION")
public class Obscuration {
    
    @Id
    @GeneratedValue(strategy=GenerationType.AUTO, generator="sg")
    @SequenceGenerator(name="sg", sequenceName="FC_OBSCURATION_SEQ")
    private long id;
    
    private int ccdModule;
    private int ccdOutput;
    private int ccdRow;
    private int ccdColumn;
    private double startTime;
    private double endTime;
    private double obscurationValue;

    public Obscuration() {
        setCcdModule(-1);
        setCcdOutput(-1);
        setCcdRow(-1);
        setCcdColumn(-1);
        setStartTime(-200);
        setEndTime(-100);
    }

    public Obscuration(int module, int output, int row, int column,
        double value, double start, double stop) {
        this();
        setCcdModule(module);
        setCcdOutput(output);
        setCcdRow(row);
        setCcdColumn(column);
        setObscurationValue(value);
        setStartTime(start);
        setEndTime(stop);
    }

    public Obscuration(double time) {
        this();
        setStartTime(time);
    }

    // public Obscuration( Pixel pix ) {
    // this( pix.getModule(), pix.getOutput(), (int) pix.getRow(), (int)
    // pix.getColumn() );
    // }
    //    
    public String queryString() {
        return "select from gov.nasa.kepler.hibernate.fc.Obscuration where " +
        // " ccdModule == " + getModule() + " && " +
            // " ccdOutput == " + getOutput() + " && " +
            // " ccdRow == " + getRow( ) + " && " +
            // " ccdColumn == " + getColumn() + " && " +
            " startTime  <  parameterizedValue";
    }

    public double getCcdColumn() {
        return ccdColumn;
    }

    public void setCcdColumn(int column) {
        this.ccdColumn = column;
    }

    public int getCcdModule() {
        return ccdModule;
    }

    public void setCcdModule(int module) {
        this.ccdModule = module;
    }

    public int getCcdOutput() {
        return ccdOutput;
    }

    public void setCcdOutput(int output) {
        this.ccdOutput = output;
    }

    public double getCcdRow() {
        return ccdRow;
    }

    public void setCcdRow(int row) {
        this.ccdRow = row;
    }

    public double getStartTime() {
        return startTime;
    }

    public void setStartTime(double start) {
        this.startTime = start;
    }

    public double getEndTime() {
        return endTime;
    }

    public void setEndTime(double end) {
        this.endTime = end;
    }

    public double getObscurationValue() {
        return obscurationValue;
    }

    public void setObscurationValue(double value) {
        this.obscurationValue = value;
    }
}
