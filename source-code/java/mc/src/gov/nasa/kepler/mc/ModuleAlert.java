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

import static gov.nasa.kepler.services.alert.AlertService.Severity.ERROR;
import static gov.nasa.kepler.services.alert.AlertService.Severity.WARNING;
import gov.nasa.kepler.services.alert.AlertService.Severity;
import gov.nasa.spiffy.common.persistable.OracleDouble;
import gov.nasa.spiffy.common.persistable.Persistable;

/**
 * Pipeline module alert.
 * 
 * @author Forrest Girouard
 * 
 */
public class ModuleAlert implements Persistable {

    /**
     * The time in MJD of this alert.
     */
    @OracleDouble
    private double time;

    /**
     * The severity of this alert (see {@link org.apache.log4j.lf5.LogLevel}).
     */
    private String severity = Severity.ERROR.toString();

    /**
     * A detailed explanation.
     */
    private String message;

    public ModuleAlert() {
    }

    public ModuleAlert(String message) {
        this.message = message;
    }

    public ModuleAlert(String severity, String message) {

        if (Severity.valueOf(severity.toUpperCase()) != null) {
            this.severity = severity.toUpperCase();
            this.message = message;
        } else {
            throw new IllegalArgumentException("invalid severity: " + severity);
        }
    }

    public ModuleAlert(double time, String severity, String message) {

        this(severity, message);
        this.time = time;
    }

    public ModuleAlert(Severity severity, String message) {
        this(severity.toString(), message);
    }

    public ModuleAlert(double time, Severity severity, String message) {
        this(time, severity.toString(), message);
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + ((message == null) ? 0 : message.hashCode());
        result = PRIME * result
            + ((getSeverity() == null) ? 0 : getSeverity().hashCode());
        long temp;
        temp = Double.doubleToLongBits(time);
        result = PRIME * result + (int) (temp ^ (temp >>> 32));
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
        final ModuleAlert other = (ModuleAlert) obj;
        if (message == null) {
            if (other.message != null)
                return false;
        } else if (!message.equals(other.message))
            return false;
        if (getSeverity() == null) {
            if (other.getSeverity() != null)
                return false;
        } else if (!getSeverity().equals(other.getSeverity()))
            return false;
        if (Double.doubleToLongBits(time) != Double.doubleToLongBits(other.time))
            return false;
        return true;
    }

    public String getMessage() {
        return message;
    }

    public String getSeverity() {
        return severity.toUpperCase();
    }

    public double getTime() {
        return time;
    }

    public boolean isError() {
        return Severity.valueOf(getSeverity()) == ERROR;
    }

    public boolean isWarning() {
        return Severity.valueOf(getSeverity()) == WARNING;
    }
}
