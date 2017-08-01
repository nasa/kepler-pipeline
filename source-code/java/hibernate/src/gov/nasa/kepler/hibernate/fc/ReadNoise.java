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
@Table(name = "FC_READNOISE")
public class ReadNoise {

    @Id
    @GeneratedValue(strategy=GenerationType.AUTO, generator="sg")
    @SequenceGenerator(name="sg", sequenceName="FC_READNOISE_SEQ")
    private long id;
    
    private double mjd;
    private int ccdModule;
    private int ccdOutput;
    private double readNoise;

    ReadNoise() {
    }

    /**
     * @param ccdModule
     * @param ccdOutput
     * @param readNoise
     * @param mjd
     */
    public ReadNoise(double mjd, int ccdModule, int ccdOutput, double readNoise) {
        super();
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.readNoise = readNoise;
        this.mjd = mjd;
    }


    public int getCcdModule() {
        return this.ccdModule;
    }


    public void setCcdModule(int ccdModule) {
        this.ccdModule = ccdModule;
    }


    public int getCcdOutput() {
        return this.ccdOutput;
    }


    public void setCcdOutput(int ccdOutput) {
        this.ccdOutput = ccdOutput;
    }


    public double getReadNoise() {
        return this.readNoise;
    }


    public void setReadNoise(double readNoise) {
        this.readNoise = readNoise;
    }


    public double getMjd() {
        return this.mjd;
    }


    public void setMjd(double mjd) {
        this.mjd = mjd;
    }


    public int compareTo(ReadNoise readNoise) {
        Double mjdComp = new Double(this.mjd);
        Double mjdCompOther = new Double(readNoise.getMjd());
        return mjdComp.compareTo(mjdCompOther);
    }
    
    public String toString() {
        return "mod " + getCcdModule() + " out " + getCcdOutput() + " readNoiseVal "
            + getReadNoise() + " mjd " + getMjd();
    }
}
