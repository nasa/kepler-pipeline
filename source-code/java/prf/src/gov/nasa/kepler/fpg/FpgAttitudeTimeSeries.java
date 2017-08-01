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

package gov.nasa.kepler.fpg;

import gov.nasa.kepler.hibernate.mc.DoubleDbTimeSeries;
import gov.nasa.kepler.hibernate.mc.DoubleTimeSeriesType;
import gov.nasa.spiffy.common.persistable.OracleDouble;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * @author Sean McCauliff
 *
 */
public class FpgAttitudeTimeSeries implements Persistable {

    @OracleDouble
    private double[] values;
    @OracleDouble
    private double[] uncertainties;
    private int[] gapIndices;
    
    /**
     * Don't use this.
     */
    public FpgAttitudeTimeSeries() {
        
    }
    
    public FpgAttitudeTimeSeries(double[] values, double[] uncertainties, 
        int[] gapIndices) {
        this.values = values;
        this.uncertainties = uncertainties;
        this.gapIndices = gapIndices;
    }
    
    List<DoubleDbTimeSeries> toDoubleDbTimeSeries(DoubleTimeSeriesType dataType, 
        DoubleTimeSeriesType uncertType, int startCadence, int endCadence,
        long originator) {
        
        List<DoubleDbTimeSeries> rv = new ArrayList<DoubleDbTimeSeries>(2);
        rv.add( new DoubleDbTimeSeries(values, 
            startCadence, endCadence, gapIndices, originator, dataType) );
        rv.add(new DoubleDbTimeSeries(uncertainties, startCadence, 
            endCadence, gapIndices, originator, uncertType));
        
        return rv;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + Arrays.hashCode(gapIndices);
        result = prime * result + Arrays.hashCode(uncertainties);
        result = prime * result + Arrays.hashCode(values);
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
        final FpgAttitudeTimeSeries other = (FpgAttitudeTimeSeries) obj;
        if (!Arrays.equals(gapIndices, other.gapIndices))
            return false;
        if (!Arrays.equals(uncertainties, other.uncertainties))
            return false;
        if (!Arrays.equals(values, other.values))
            return false;
        return true;
    }
    
    
}
