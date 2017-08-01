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

package gov.nasa.kepler.ppa.pag;

import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppDuration;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppMagnitude;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.EnergyDistribution;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType;

import java.util.HashSet;
import java.util.Set;

/**
 * A class that is used as a key to look up
 * {@link gov.nasa.kepler.hibernate.ppa.PmdMetricReport} objects. Use a flavor
 * of {@link #PmdMetricReportKey(gov.nasa.kepler.hibernate.ppa.PmdMetricReport)}
 * to create the key when placing the report in a map; use a flavor of
 * {@code PmdMetricReportKey(int, int, ReportType, String...)} to create the key
 * which retrieving the report from a map. There are no accessors since the
 * fields are not intended to be retrieved (except for index, so that another
 * key can be generated with a incremented index).
 * 
 * @author Bill Wohler
 */
public class PmdMetricReportKey {

    /**
     * The CCD module, or
     * {@link gov.nasa.kepler.hibernate.ppa.PmdMetricReport#CCD_MOD_OUT_ALL} if
     * this report represents the entire focal plane
     */
    private int ccdModule;

    /**
     * The CCD output, or
     * {@link gov.nasa.kepler.hibernate.ppa.PmdMetricReport#CCD_MOD_OUT_ALL} if
     * this report represents the entire focal plane
     */
    private int ccdOutput;

    /**
     * The report type.
     */
    private ReportType type;

    /**
     * The report subtype.
     */
    private Set<String> subTypes;

    /**
     * If there is an array of reports for a particular type, use {code index}
     * to distinguish them.
     */
    private int index;

    /**
     * Creates a {@link PmdMetricReportKey} with the given report.
     */
    public PmdMetricReportKey(
        gov.nasa.kepler.hibernate.ppa.PmdMetricReport report) {
        this(report, 0);
    }

    /**
     * Creates a {@link PmdMetricReportKey} with the given report.
     * 
     * @param index the index of the report, in case there is an array of
     * reports for the particular type
     */
    public PmdMetricReportKey(
        gov.nasa.kepler.hibernate.ppa.PmdMetricReport report, int index) {
        ccdModule = report.getCcdModule();
        ccdOutput = report.getCcdOutput();
        type = report.getType();
        subTypes = report.getSubTypes();
        this.index = index;
    }

    /**
     * Creates a {@link PmdMetricReportKey}.
     * 
     * @param ccdModule the CCD module
     * @param ccdOutput the CCD output
     * @param type the report type
     * @param subTypes string representations of the {@link EnergyDistribution},
     * {@link CdppMagnitude}, and {@link CdppDuration}
     */
    public PmdMetricReportKey(int ccdModule, int ccdOutput, ReportType type,
        String... subTypes) {
        this(ccdModule, ccdOutput, 0, type, subTypes);
    }

    /**
     * Creates a {@link PmdMetricReportKey}.
     * 
     * @param ccdModule the CCD module
     * @param ccdOutput the CCD output
     * @param index the index of the report, in case there is an array of
     * reports for the particular type
     * @param type the report type
     * @param subTypes string representations of the {@link EnergyDistribution},
     * {@link CdppMagnitude}, and {@link CdppDuration}
     */
    public PmdMetricReportKey(int ccdModule, int ccdOutput, int index,
        ReportType type, String... subTypes) {

        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.index = index;
        this.type = type;

        this.subTypes = new HashSet<String>();
        for (String subType : subTypes) {
            this.subTypes.add(subType);
        }
    }

    public int getIndex() {
        return index;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ccdModule;
        result = prime * result + ccdOutput;
        result = prime * result + index;
        result = prime * result + (subTypes == null ? 0 : subTypes.hashCode());
        result = prime * result + (type == null ? 0 : type.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (!(obj instanceof PmdMetricReportKey)) {
            return false;
        }
        final PmdMetricReportKey other = (PmdMetricReportKey) obj;
        if (ccdModule != other.ccdModule) {
            return false;
        }
        if (ccdOutput != other.ccdOutput) {
            return false;
        }
        if (index != other.index) {
            return false;
        }
        if (subTypes == null) {
            if (other.subTypes != null) {
                return false;
            }
        } else if (!subTypes.equals(other.subTypes)) {
            return false;
        }
        if (type == null) {
            if (other.type != null) {
                return false;
            }
        } else if (!type.equals(other.type)) {
            return false;
        }
        return true;
    }
}
