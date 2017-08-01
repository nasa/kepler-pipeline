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

package gov.nasa.kepler.mc;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * All the background specific configuration information for PA.
 * 
 * @author Forrest Girouard (fgirouard)
 * 
 */
public class BackgroundModuleParameters implements Parameters, Persistable {

    private boolean aicOrderSelectionEnabled;
    private int fitMaxOrder;
    private int fitOrder;

    /**
     * Minimum number of points required to create a valid background
     * polynomial.
     */
    private int fitMinPoints;

    public BackgroundModuleParameters() {
    }

    public boolean isAicOrderSelectionEnabled() {
        return aicOrderSelectionEnabled;
    }

    public void setAicOrderSelectionEnabled(boolean aicOrderSelectionEnabled) {
        this.aicOrderSelectionEnabled = aicOrderSelectionEnabled;
    }

    public int getFitMinPoints() {
        return fitMinPoints;
    }

    public void setFitMinPoints(int fitMinPoints) {
        this.fitMinPoints = fitMinPoints;
    }

    public int getFitOrder() {
        return fitOrder;
    }

    public void setFitOrder(int fitOrder) {
        this.fitOrder = fitOrder;
    }

    public int getFitMaxOrder() {
        return fitMaxOrder;
    }

    public void setFitMaxOrder(int fitMaxOrder) {
        this.fitMaxOrder = fitMaxOrder;
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + (aicOrderSelectionEnabled ? 1231 : 1237);
        result = PRIME * result + fitMinPoints;
        result = PRIME * result + fitOrder;
        result = PRIME * result + fitMaxOrder;
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
        final BackgroundModuleParameters other = (BackgroundModuleParameters) obj;
        if (aicOrderSelectionEnabled != other.aicOrderSelectionEnabled)
            return false;
        if (fitMinPoints != other.fitMinPoints)
            return false;
        if (fitOrder != other.fitOrder)
            return false;
        if (fitMaxOrder != other.fitMaxOrder)
            return false;
        return true;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }

}
