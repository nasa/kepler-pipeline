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

package gov.nasa.kepler.ar.exporter.ktc.verifier;

import java.util.*;

import gov.nasa.kepler.common.Cadence.CadenceType;

/**
 * This represents an entry that has been parsed out of a KTC for verification
 * purposes.
 * 
 * @author Sean McCauliff
 *
 */
class ParsedKtcEntry implements ActualAndPlannedTimes {

    public final CadenceType cadenceType;
    public final Set<String> categories;
    public final int keplerId;
    public final double plannedStartMjd;
    public final double plannedEndMjd;
    public final Double actualStartMjd;
    public final Double actualEndMjd;
    public final String investigationId;
    
    private ParsedKtcEntry(CadenceType cadenceType, Set<String> categories,
        int keplerId, double startExpectedMjd, double endExpectedMjd,
        Double startActualMjd, Double endActualMjd, String investigationId) {
        super();
        this.cadenceType = cadenceType;
        this.categories = categories;
        this.keplerId = keplerId;
        this.plannedStartMjd = startExpectedMjd;
        this.plannedEndMjd = endExpectedMjd;
        this.actualStartMjd = startActualMjd;
        this.actualEndMjd = endActualMjd;
        this.investigationId = investigationId;
    }
    
    public static ParsedKtcEntry valueOf(String line) {
        String[] parts = line.split("\\|");
        String keplerIdStr =     parts[0];
        String cadenceTypeStr =  parts[1];
        String categoriesStr =   parts[2];
        String expectedStartStr = parts[3];
        String expectedEndStr =  parts[4];
        String actualStartStr =  parts[5];
        String actualEndStr =    parts[6];
        String investigationIdStr = parts[7];
        
        int keplerId = Integer.parseInt(keplerIdStr);
        
        CadenceType cadenceType = null;
        if (cadenceTypeStr.equals("LC")) {
            cadenceType = CadenceType.LONG;
        } else if (cadenceTypeStr.equals("SC")) {
            cadenceType = CadenceType.SHORT;
        } else {
            throw new IllegalArgumentException("Bad cadence type \\" + cadenceTypeStr + "\".");
        }
        
        String[] categories_a = categoriesStr.split(",");
        Set<String> categories = 
            Collections.unmodifiableSet(new HashSet<String>(Arrays.asList(categories_a)));
        double expectedStart = Double.parseDouble(expectedStartStr);
        double expectedEnd = Double.parseDouble(expectedEndStr);
        Double actualStart = (actualStartStr.length() == 0) ? null : Double.valueOf(actualStartStr);
        Double actualEnd = (actualEndStr.length() == 0) ? null : Double.valueOf(actualEndStr);
        
        return new ParsedKtcEntry(cadenceType, categories, keplerId, 
            expectedStart, expectedEnd, actualStart, actualEnd, 
            investigationIdStr);
    }

    @Override
    public Double actualEndMjd() {
        return actualEndMjd;
    }

    @Override
    public Double actualStartMjd() {
        return actualStartMjd;
    }

    @Override
    public double plannedEndMjd() {
        return plannedEndMjd;
    }

    @Override
    public double plannedStartMjd() {
        return plannedStartMjd;
    }

    @Override
    public String toString() {
        StringBuilder builder = new StringBuilder();
        builder.append("ParsedKtcEntry [actualEndMjd=")
            .append(actualEndMjd)
            .append(", actualStartMjd=")
            .append(actualStartMjd)
            .append(", cadenceType=")
            .append(cadenceType)
            .append(", categories=")
            .append(categories)
            .append(", investigationId=")
            .append(investigationId)
            .append(", keplerId=")
            .append(keplerId)
            .append(", plannedEndMjd=")
            .append(plannedEndMjd)
            .append(", plannedStartMjd=")
            .append(plannedStartMjd)
            .append("]");
        return builder.toString();
    }

    
}
