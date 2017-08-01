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

package gov.nasa.kepler.ar.exporter;


import gov.nasa.spiffy.common.pi.Parameters;

/**
 * Classes common to most pipeline exporters.
 * 
 * @author Sean McCauliff
 *
 */
public final class ExporterParameters implements Parameters {

    public static final int AUTOMATIC_CADENCE = -1;
    public static final long AUTOMATIC_FRONT_END_PIPELINE_INSTANCE = 0;
    
    private String nfsExportDirectory; // = "/tmp";
    private int startCadence; // = AUTOMATIC_CADENCE;
    private int endCadence; // = AUTOMATIC_CADENCE;
    private int quarter; //= -1;
    private int dataReleaseNumber; // = -1;
    private String fileTimestamp;
    private String module3FileTimestamp;
    private long frontEndPipelineInstance;
    private int k2Campaign = -1;
    private boolean ignoreZeroCrossingsForReferenceCadence;
    
    public ExporterParameters() {
        
    }
    public ExporterParameters(String nfsExportDirectory, int startCadence,
        int endCadence, int quarter, int dataReleaseNumber,
        long tpsPipelineInstanceId, String fileTimestamp,
        String module3FileTimestamp, 
        long useFrontEndPipelineInstance,
        int k2Campaign) {

        this.nfsExportDirectory = nfsExportDirectory;
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.quarter = quarter;
        this.dataReleaseNumber = dataReleaseNumber;
        this.fileTimestamp = fileTimestamp;
        this.module3FileTimestamp = module3FileTimestamp;
        this.frontEndPipelineInstance = useFrontEndPipelineInstance;
        this.k2Campaign = k2Campaign;
    }
    
    /**
     * Selects a fileTimestamp.
     * 
     * @author Miles Cote
     * 
     */
    public String selectTimestamp(int ccdModule, String defaultFileTimestamp) {
        if (module3FileTimestamp != null && module3FileTimestamp.length() != 0
            && ccdModule == 3) {
            return module3FileTimestamp;
        } else if (fileTimestamp != null && fileTimestamp.length() != 0) {
            return fileTimestamp;
        } else {
            return defaultFileTimestamp;
        }
    }
    
    public String getNfsExportDirectory() {
        return nfsExportDirectory;
    }
    public void setNfsExportDirectory(String nfsExportDirectory) {
        this.nfsExportDirectory = nfsExportDirectory;
    }
    public int getStartCadence() {
        return startCadence;
    }
    public void setStartCadence(int startCadence) {
        this.startCadence = startCadence;
    }
    public int getEndCadence() {
        return endCadence;
    }
    public void setEndCadence(int endCadence) {
        this.endCadence = endCadence;
    }
    public int getQuarter() {
        return quarter;
    }
    public void setQuarter(int quarter) {
        this.quarter = quarter;
    }
    public int getK2Campaign() {
        return k2Campaign;
    }
    public void setK2Campaign(int c) {
        this.k2Campaign = c;
    }
    public int getDataReleaseNumber() {
        return dataReleaseNumber;
    }
    public void setDataReleaseNumber(int dataReleaseNumber) {
        this.dataReleaseNumber = dataReleaseNumber;
    }
    public String getFileTimestamp() {
        if (fileTimestamp != null) {
            return fileTimestamp.trim();
        }
        return null;
    }
    
    public void setFileTimestamp(String fileTimestamp) {
        this.fileTimestamp = fileTimestamp;
    }
    public String getModule3FileTimestamp() {
        return module3FileTimestamp;
    }
    public void setModule3FileTimestamp(String module3FileTimestamp) {
        this.module3FileTimestamp = module3FileTimestamp;
    }
    public long getFrontEndPipelineInstance() {
        return frontEndPipelineInstance;
    }
    public void setFrontEndPipelineInstance(long useFrontEndPipelineInstance) {
        this.frontEndPipelineInstance = useFrontEndPipelineInstance;
    }
    public boolean isIgnoreZeroCrossingsForReferenceCadence() {
        return ignoreZeroCrossingsForReferenceCadence;
    }
    public void setIgnoreZeroCrossingsForReferenceCadence(
            boolean ignoreZeroCrossingsForReferenceCadence) {
        this.ignoreZeroCrossingsForReferenceCadence = ignoreZeroCrossingsForReferenceCadence;
    }
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + dataReleaseNumber;
        result = prime * result + endCadence;
        result = prime * result
                + ((fileTimestamp == null) ? 0 : fileTimestamp.hashCode());
        result = prime
                * result
                + (int) (frontEndPipelineInstance ^ (frontEndPipelineInstance >>> 32));
        result = prime * result
                + (ignoreZeroCrossingsForReferenceCadence ? 1231 : 1237);
        result = prime * result + k2Campaign;
        result = prime
                * result
                + ((module3FileTimestamp == null) ? 0 : module3FileTimestamp
                        .hashCode());
        result = prime
                * result
                + ((nfsExportDirectory == null) ? 0 : nfsExportDirectory
                        .hashCode());
        result = prime * result + quarter;
        result = prime * result + startCadence;
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
        ExporterParameters other = (ExporterParameters) obj;
        if (dataReleaseNumber != other.dataReleaseNumber)
            return false;
        if (endCadence != other.endCadence)
            return false;
        if (fileTimestamp == null) {
            if (other.fileTimestamp != null)
                return false;
        } else if (!fileTimestamp.equals(other.fileTimestamp))
            return false;
        if (frontEndPipelineInstance != other.frontEndPipelineInstance)
            return false;
        if (ignoreZeroCrossingsForReferenceCadence != other.ignoreZeroCrossingsForReferenceCadence)
            return false;
        if (k2Campaign != other.k2Campaign)
            return false;
        if (module3FileTimestamp == null) {
            if (other.module3FileTimestamp != null)
                return false;
        } else if (!module3FileTimestamp.equals(other.module3FileTimestamp))
            return false;
        if (nfsExportDirectory == null) {
            if (other.nfsExportDirectory != null)
                return false;
        } else if (!nfsExportDirectory.equals(other.nfsExportDirectory))
            return false;
        if (quarter != other.quarter)
            return false;
        if (startCadence != other.startCadence)
            return false;
        return true;
    }
   
    
}
