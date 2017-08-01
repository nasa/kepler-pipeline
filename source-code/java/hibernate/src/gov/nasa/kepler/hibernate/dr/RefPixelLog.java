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

package gov.nasa.kepler.hibernate.dr;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.OneToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

/**
 * JDO class for the table that contains a log of all received reference pixels
 * 
 * @author tklaus
 * 
 */
@Entity
@Table(name = "DR_REF_PIXEL_LOG")
public class RefPixelLog implements Comparable<RefPixelLog> {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "DR_RPL_SEQ")
    // required by Hibernate
    private int id;

    @OneToOne
    private FileLog fileLog;

    private long timestamp;
    private double mjd;

    private int targetTableId;
    private int numberOfReferencePixels;

    /**
     * Compression table ID. The same ID is used for all of the compression
     * tables: requant, Huffman, mean black.
     */
    private int compressionTableId;

    private boolean processed;

    public RefPixelLog() {
    }

    public RefPixelLog(FileLog fileLog, long timestamp, int targetTableId,
        int numberOfReferencePixels, int compressionTableId, double mjd) {
        this.fileLog = fileLog;
        this.timestamp = timestamp;
        this.targetTableId = targetTableId;
        this.numberOfReferencePixels = numberOfReferencePixels;
        this.compressionTableId = compressionTableId;
        this.mjd = mjd;
    }

    public RefPixelLog(long timestamp, int targetTableId,
        int numberOfReferencePixels, int compressionTableId, double mjd) {
        this(null, timestamp, targetTableId, numberOfReferencePixels,
            compressionTableId, mjd);
    }

    public int getCompressionTableId() {
        return compressionTableId;
    }

    public void setCompressionTableId(int compressionTableId) {
        this.compressionTableId = compressionTableId;
    }

    public long getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(long timestamp) {
        this.timestamp = timestamp;
    }

    public double getMjd() {
        return mjd;
    }

    public void setMjd(double mjd) {
        this.mjd = mjd;
    }

    public int getTargetTableId() {
        return targetTableId;
    }

    public void setTargetTableId(int targetTableId) {
        this.targetTableId = targetTableId;
    }

    public int getNumberOfReferencePixels() {
        return numberOfReferencePixels;
    }

    public void setNumberOfReferencePixels(int numberOfReferencePixels) {
        this.numberOfReferencePixels = numberOfReferencePixels;
    }

    public boolean isProcessed() {
        return processed;
    }

    public void setProcessed(boolean processed) {
        this.processed = processed;
    }

    public int compareTo(RefPixelLog other) {
        return (int) (this.timestamp - other.timestamp);
    }

    public long getId() {
        return id;
    }

    public FileLog getFileLog() {
        return fileLog;
    }

    public void setFileLog(FileLog fileLog) {
        this.fileLog = fileLog;
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + numberOfReferencePixels;
        result = PRIME * result + targetTableId;
        result = PRIME * result + (int) (timestamp ^ (timestamp >>> 32));
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
        final RefPixelLog other = (RefPixelLog) obj;
        if (numberOfReferencePixels != other.numberOfReferencePixels)
            return false;
        if (targetTableId != other.targetTableId)
            return false;
        if (timestamp != other.timestamp)
            return false;
        return true;
    }
}
