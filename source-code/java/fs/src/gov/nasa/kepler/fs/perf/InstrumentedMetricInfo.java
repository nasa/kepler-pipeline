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

package gov.nasa.kepler.fs.perf;

import java.io.Serializable;

import javax.management.openmbean.CompositeData;
import javax.management.openmbean.OpenDataException;

import gov.nasa.spiffy.common.jmx.AbstractCompositeData;
import gov.nasa.spiffy.common.jmx.CompositeTypeDescription;
import gov.nasa.spiffy.common.jmx.ConstructorDescription;
import gov.nasa.spiffy.common.jmx.ItemDescription;
import gov.nasa.spiffy.common.jmx.TableIndex;

/**
 * A data holder for sending instrumented metric data over JMX.
 * @author Sean McCauliff
 *
 */
@CompositeTypeDescription("Information about a class instrumented with metrics.")
public class InstrumentedMetricInfo extends AbstractCompositeData 
    implements Serializable, CompositeData {
    
    private static final long serialVersionUID = -3429053346196044780L;
    private final String name;
    private final int reportingInterval;
    
    /**
     * 
     * @param name
     * @param reportingInterval
     * @throws OpenDataException
     */
    @ConstructorDescription("Initialize all values constructor.")
    public InstrumentedMetricInfo(String name, int reportingInterval)
        throws OpenDataException {
        this.name = name;
        this.reportingInterval = reportingInterval;
    }
    
    @TableIndex(0)
    @ItemDescription("The name of the instrumented class.")
    public String getName() {
        return name;
    }
    
    @ItemDescription("The number of method calls before generating a metric.")
    public int getReportingInterval() {
        return reportingInterval;
    }
    
    @Override
    public String toString() {
        StringBuilder builder = new StringBuilder();
        builder.append("InstrumentedMetricInfo [name=")
            .append(name)
            .append(", reportingInterval=")
            .append(reportingInterval)
            .append("]");
        return builder.toString();
    } 

}
