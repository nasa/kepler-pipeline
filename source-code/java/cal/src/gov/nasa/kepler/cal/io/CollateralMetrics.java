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

package gov.nasa.kepler.cal.io;

import gov.nasa.spiffy.common.persistable.Persistable;

/**
 * @author Sean McCauliff
 *
 */
public class CollateralMetrics implements Persistable {

    /**
     * Calculated for black levels.
     */
    private CalMetricsTimeSeries blackLevelMetrics = new CalMetricsTimeSeries();

    /**
     * Calculated for smear levels.
     */
    private CalMetricsTimeSeries smearLevelMetrics = new CalMetricsTimeSeries();

    /**
     * Calculated for dark current.
     */
    private CalMetricsTimeSeries darkCurrentMetrics = new CalMetricsTimeSeries();

    public CollateralMetrics() {
    }
    
    public CollateralMetrics(CalMetricsTimeSeries blackLevelMetrics,
        CalMetricsTimeSeries smearLevelMetrics,
        CalMetricsTimeSeries darkCurrentMetrics) {
        this.blackLevelMetrics = blackLevelMetrics;
        this.smearLevelMetrics = smearLevelMetrics;
        this.darkCurrentMetrics = darkCurrentMetrics;
    }


    public CalMetricsTimeSeries getBlackLevelMetrics() {
        return blackLevelMetrics;
    }

    public CalMetricsTimeSeries getSmearLevelMetrics() {
        return smearLevelMetrics;
    }

    public CalMetricsTimeSeries getDarkCurrentMetrics() {
        return darkCurrentMetrics;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + ((blackLevelMetrics == null) ? 0 : blackLevelMetrics.hashCode());
        result = prime
            * result
            + ((darkCurrentMetrics == null) ? 0 : darkCurrentMetrics.hashCode());
        result = prime * result
            + ((smearLevelMetrics == null) ? 0 : smearLevelMetrics.hashCode());
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
        CollateralMetrics other = (CollateralMetrics) obj;
        if (blackLevelMetrics == null) {
            if (other.blackLevelMetrics != null)
                return false;
        } else if (!blackLevelMetrics.equals(other.blackLevelMetrics))
            return false;
        if (darkCurrentMetrics == null) {
            if (other.darkCurrentMetrics != null)
                return false;
        } else if (!darkCurrentMetrics.equals(other.darkCurrentMetrics))
            return false;
        if (smearLevelMetrics == null) {
            if (other.smearLevelMetrics != null)
                return false;
        } else if (!smearLevelMetrics.equals(other.smearLevelMetrics))
            return false;
        return true;
    }

}
