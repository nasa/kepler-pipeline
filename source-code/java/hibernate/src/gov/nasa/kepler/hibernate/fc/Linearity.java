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

import gov.nasa.spiffy.common.pi.PipelineException;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinTable;
import javax.persistence.ManyToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.hibernate.annotations.CollectionOfElements;
import org.hibernate.annotations.IndexColumn;

@Entity
@Table(name = "FC_LINEARITY")
public class Linearity {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "FC_LINEARITY_SEQ")
    private long id;

    private int ccdModule;
    private int ccdOutput;
    private double startMjd;
    private double offsetX;
    private double scaleX;
    private double originX;
    private String type;
    private int xIndex;
    private int maxDomain;

    
    // A Linearity can be associated with only one History,
    // but an History can refer to many Linearity.
    //
    @ManyToOne
    private History history;
    
    @CollectionOfElements
    @JoinTable(name = "FC_LINEARITY_COEFFS")
    @IndexColumn(name="IDX")
    private double[] coefficients;

    @CollectionOfElements
    @JoinTable(name = "FC_LINEARITY_UNCERT")
    @IndexColumn(name="IDX2")
    private double[] uncertainties;

    Linearity() {
        ;
    }

    /**
     * @param ccdModule
     * @param ccdOutput
     * @param startMjd
     * @param history
     * @param coefficients
     * @param uncertainties
     * @throws PipelineException 
     */
    public Linearity(int ccdModule, int ccdOutput, double startMjd,
        double[] coefficients, double[] uncertainties) {
        super();
        
        // uncertainties.length=(coefficients.length^2)
        if (uncertainties.length !=  coefficients.length * coefficients.length) {
            throw new PipelineException(
                "The size of the uncertainty covariance matrix must be the " +
                "square of the size of the coefficients array");
        }
        
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.startMjd = startMjd;
        this.coefficients = coefficients;
        this.uncertainties = uncertainties;
        
        this.offsetX = 0.0;
        this.scaleX =  0.0;
        this.originX = 0.0;
        this.type = "";
        this.xIndex = -1;
        this.maxDomain = 10000;
    }
    
    /**
     * 
     * @param ccdModule
     * @param ccdOutput
     * @param startMjd
     * @param offsetX
     * @param scaleX
     * @param originX
     * @param type
     * @param xIndex
     * @param maxDomain
     * @param coefficients
     * @param uncertainties
     * @throws PipelineException
     */
    public Linearity(int ccdModule, int ccdOutput, double startMjd,
        double offsetX, double scaleX, double originX, 
        String type, int xIndex, int maxDomain, 
        double[] coefficients, double[] uncertainties) 
    {
        this(ccdModule, ccdOutput, startMjd, coefficients, uncertainties);
        this.offsetX = offsetX;
        this.scaleX = scaleX;
        this.originX = originX;
        this.type = type;
        this.xIndex = xIndex;
        this.maxDomain = maxDomain;
    }

    public void setCoefficients(double[] coefficients) {
        this.coefficients = coefficients;
    }

    public void setCcdModule(int ccdModule) {
        this.ccdModule = ccdModule;
    }

    public void setCcdOutput(int ccdOutput) {
        this.ccdOutput = ccdOutput;
    }

    public void setStartMjd(double startMjd) {
        this.startMjd = startMjd;
    }

    public double[] getCoefficients() {
        return coefficients;
    }

    public int getCcdModule() {
        return ccdModule;
    }

    public int getCcdOutput() {
        return ccdOutput;
    }

    public double getStartMjd() {
        return startMjd;
    }

	public History getHistory() {
		return history;
	}

	public void setHistory(History history) {
		this.history = history;
	}

    public double[] getUncertainties() {
        return this.uncertainties;
    }

    public void setUncertainties(double[] uncertainties) {
        this.uncertainties = uncertainties;
    }

    public double getOffsetX() {
        return this.offsetX;
    }

    public void setOffsetX(double offsetX) {
        this.offsetX = offsetX;
    }

    public double getScaleX() {
        return this.scaleX;
    }

    public void setScaleX(double scaleX) {
        this.scaleX = scaleX;
    }

    public double getOriginX() {
        return this.originX;
    }

    public void setOriginX(double originX) {
        this.originX = originX;
    }

    public String getType() {
        return this.type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public int getXIndex() {
        return this.xIndex;
    }

    public void setXIndex(int index) {
        this.xIndex = index;
    }

    public int getMaxDomain() {
        return this.maxDomain;
    }

    public void setMaxDomain(int maxDomain) {
        this.maxDomain = maxDomain;
    }
}
