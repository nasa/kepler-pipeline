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

import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.spiffy.common.persistable.ProxyIgnore;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.ManyToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.hibernate.annotations.Index;

/**
 * Contains an rclc pixel log.
 * 
 * @author Miles Cote
 * 
 */
@Entity
@Table(name = "DR_RCLC_PIXEL_LOG")
public class RclcPixelLog {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "DR_RCLC_PIXEL_LOG_SEQ")
    private long id;

    @ManyToOne
    @ProxyIgnore
    private DispatchLog dispatchLog;

    private DataSetType dataSetType;

    private int cadenceNumber;
    private int cadenceType;
    private String fitsFilename;
    private String datasetName; // like kplr2009001013000 - everything in the
    // filename before the first _

    private double mjdStartTime; // MJD start time of data
    private double mjdMidTime;
    private double mjdEndTime; // MJD end time of data

    private int spacecraftConfigId;

    @Index(name = "DR_RCLC_PIXEL_LOG_LCTTID_IDX")
    private short lcTargetTableId;

    @Index(name = "DR_RCLC_PIXEL_LOG_SCTTID_IDX")
    private short scTargetTableId;

    private short backTargetTableId;
    private short targetApertureTableId;
    private short backApertureTableId;

    /**
     * Compression table ID. The same ID is used for all of the compression
     * tables: requant, Huffman, mean black.
     */
    private short compressionTableId;

    /**
     * Data requantized for downlink (Tf).
     */
    @Column(name = "REQUANT")
    private boolean dataRequantizedForDownlink;

    /**
     * Data entropic compressed for downlink (Tf).
     */
    @Column(name = "HUFFMAN")
    private boolean dataEntropicCompressedForDownlink;

    /**
     * Data originated as baseline image (Tf).
     */
    @Column(name = "BASELINE")
    private boolean dataOriginatedAsBaselineImage;

    /**
     * Root name of baseline image.
     */
    @Column(name = "BASENAME")
    private String baselineImageRootname;

    /**
     * Baseline created from residual baseline image (tF).
     */
    @Column(name = "BASERCON")
    private boolean baselineCreatedFromResidualBaselineImage;

    /**
     * Root name of residual baseline image.
     */
    @Column(name = "RBASNAME")
    private String residualBaselineImageRootname;

    /**
     * Reverse clocking in effect (T/F).
     */
    @Column(name = "REV_CLCK")
    private boolean reverseClockingInEffect;

    /**
     * Single Event Funtional Interrupt in accum memor
     */
    @Column(name = "SEFI_ACC")
    private boolean sefiAcc;

    /**
     * Single Event Funtional Interrupt in cadence mem
     */
    @Column(name = "SEFI_CAD")
    private boolean sefiCad;

    /**
     * Local Detector Electronics OutOfSynch reported
     */
    @Column(name = "LDE_OOS")
    private boolean ldeOos;

    /**
     * Fine Point pointing status during accumulation
     */
    @Column(name = "FINE_PNT")
    private boolean finePnt;

    /**
     * Momentum dump occurred during accumulation
     */
    @Column(name = "MMNTMDMP")
    private boolean mmntmDmp;

    /**
     * Local Detector Electronics parity error occurre
     */
    @Column(name = "LDEPARER")
    private boolean ldeParEr;

    /**
     * SDRAM Controller memory pixel error occurred
     */
    @Column(name = "SCRC_ERR")
    private boolean scrcErr;

    public RclcPixelLog() {
    }

    /**
     * 
     * @param dispatchLog
     * @param cadenceNumber A number from Cadence.
     * @param cadenceType
     * @param fitsFilename
     * @param datasetName
     * @param mjdStartTime
     * @param mjdEndTime
     * @param lcTargetTableId
     * @param scTargetTableId
     * @param backTargetTableId
     * @param targetApertureTableId
     * @param backApertureTableId
     * @param compressionTableId
     */
    public RclcPixelLog(DispatchLog dispatchLog, int cadenceNumber,
        int cadenceType, String fitsFilename, String datasetName,
        double mjdStartTime, double mjdEndTime, short lcTargetTableId,
        short scTargetTableId, short backTargetTableId,
        short targetApertureTableId, short backApertureTableId,
        short compressionTableId) {
        this.dispatchLog = dispatchLog;
        this.cadenceNumber = cadenceNumber;
        this.cadenceType = cadenceType;
        this.fitsFilename = fitsFilename;
        this.datasetName = datasetName;
        this.mjdStartTime = mjdStartTime;
        this.mjdEndTime = mjdEndTime;
        this.lcTargetTableId = lcTargetTableId;
        this.scTargetTableId = scTargetTableId;
        this.backTargetTableId = backTargetTableId;
        this.targetApertureTableId = targetApertureTableId;
        this.backApertureTableId = backApertureTableId;
        this.mjdMidTime = (mjdStartTime + mjdEndTime) / 2;
        this.compressionTableId = compressionTableId;
    }

    RclcPixelLog(PixelLog pixelLog) {
        dispatchLog = pixelLog.getDispatchLog();
        dataSetType = pixelLog.getDataSetType();
        cadenceNumber = pixelLog.getCadenceNumber();
        cadenceType = pixelLog.getCadenceType();
        fitsFilename = pixelLog.getFitsFilename();
        datasetName = pixelLog.getDatasetName();
        mjdStartTime = pixelLog.getMjdStartTime();
        mjdMidTime = pixelLog.getMjdMidTime();
        mjdEndTime = pixelLog.getMjdEndTime();
        spacecraftConfigId = pixelLog.getSpacecraftConfigId();
        lcTargetTableId = pixelLog.getLcTargetTableId();
        scTargetTableId = pixelLog.getScTargetTableId();
        backTargetTableId = pixelLog.getBackTargetTableId();
        targetApertureTableId = pixelLog.getTargetApertureTableId();
        backApertureTableId = pixelLog.getBackApertureTableId();
        compressionTableId = pixelLog.getCompressionTableId();
        dataRequantizedForDownlink = pixelLog.isDataRequantizedForDownlink();
        dataEntropicCompressedForDownlink = pixelLog.isDataEntropicCompressedForDownlink();
        dataOriginatedAsBaselineImage = pixelLog.isDataOriginatedAsBaselineImage();
        baselineImageRootname = pixelLog.getBaselineImageRootname();
        baselineCreatedFromResidualBaselineImage = pixelLog.isBaselineCreatedFromResidualBaselineImage();
        residualBaselineImageRootname = pixelLog.getResidualBaselineImageRootname();
        reverseClockingInEffect = pixelLog.isReverseClockingInEffect();
        sefiAcc = pixelLog.isSefiAcc();
        sefiCad = pixelLog.isSefiCad();
        ldeOos = pixelLog.isLdeOos();
        finePnt = pixelLog.isFinePnt();
        mmntmDmp = pixelLog.isMmntmDmp();
        ldeParEr = pixelLog.isLdeParEr();
        scrcErr = pixelLog.isScrcErr();
    }

    PixelLog getPixelLog() {
        PixelLog pixelLog = new PixelLog();
        pixelLog.setDispatchLog(dispatchLog);
        pixelLog.setDataSetType(dataSetType);
        pixelLog.setCadenceNumber(cadenceNumber);
        pixelLog.setCadenceType(cadenceType);
        pixelLog.setFitsFilename(fitsFilename);
        pixelLog.setDatasetName(datasetName);
        pixelLog.setMjdStartTime(mjdStartTime);
        pixelLog.setMjdMidTime(mjdMidTime);
        pixelLog.setMjdEndTime(mjdEndTime);
        pixelLog.setSpacecraftConfigId(spacecraftConfigId);
        pixelLog.setLcTargetTableId(lcTargetTableId);
        pixelLog.setScTargetTableId(scTargetTableId);
        pixelLog.setBackTargetTableId(backTargetTableId);
        pixelLog.setTargetApertureTableId(targetApertureTableId);
        pixelLog.setBackApertureTableId(backApertureTableId);
        pixelLog.setCompressionTableId(compressionTableId);
        pixelLog.setDataRequantizedForDownlink(dataRequantizedForDownlink);
        pixelLog.setDataEntropicCompressedForDownlink(dataEntropicCompressedForDownlink);
        pixelLog.setDataOriginatedAsBaselineImage(dataOriginatedAsBaselineImage);
        pixelLog.setBaselineImageRootname(baselineImageRootname);
        pixelLog.setBaselineCreatedFromResidualBaselineImage(baselineCreatedFromResidualBaselineImage);
        pixelLog.setResidualBaselineImageRootname(residualBaselineImageRootname);
        pixelLog.setReverseClockingInEffect(reverseClockingInEffect);
        pixelLog.setSefiAcc(sefiAcc);
        pixelLog.setSefiCad(sefiCad);
        pixelLog.setLdeOos(ldeOos);
        pixelLog.setFinePnt(finePnt);
        pixelLog.setMmntmDmp(mmntmDmp);
        pixelLog.setLdeParEr(ldeParEr);
        pixelLog.setScrcErr(scrcErr);

        return pixelLog;
    }

    /**
     * @return the mid-point between the start and end time of this cadence
     */
    public double getMjdMidTime() {
        return mjdMidTime;
    }

    /**
     * @return the backApertureTableId
     */
    public short getBackApertureTableId() {
        return backApertureTableId;
    }

    /**
     * @param backApertureTableId the backApertureTableId to set
     */
    public void setBackApertureTableId(short backApertureTableId) {
        this.backApertureTableId = backApertureTableId;
    }

    /**
     * @return the backTargetTableId
     */
    public short getBackTargetTableId() {
        return backTargetTableId;
    }

    /**
     * @param backTargetTableId the backTargetTableId to set
     */
    public void setBackTargetTableId(short backTargetTableId) {
        this.backTargetTableId = backTargetTableId;
    }

    /**
     * @return the cadenceNumber
     */
    public int getCadenceNumber() {
        return cadenceNumber;
    }

    /**
     * @param cadenceNumber the cadenceNumber to set
     */
    public void setCadenceNumber(int cadenceNumber) {
        this.cadenceNumber = cadenceNumber;
    }

    /**
     * @return the cadenceString
     */
    public String getFitsFilename() {
        return fitsFilename;
    }

    /**
     * @param cadenceString the cadenceString to set
     */
    public void setFitsFilename(String cadenceString) {
        this.fitsFilename = cadenceString;
    }

    /**
     * @return the cadenceType
     */
    public int getCadenceType() {
        return cadenceType;
    }

    /**
     * @param cadenceType the cadenceType to set
     */
    public void setCadenceType(int cadenceType) {
        this.cadenceType = cadenceType;
    }

    public void setCompressionTableId(short compressionTableId) {
        this.compressionTableId = compressionTableId;
    }

    public short getCompressionTableId() {
        return compressionTableId;
    }

    /**
     * @return the lcTargetTableId
     */
    public short getLcTargetTableId() {
        return lcTargetTableId;
    }

    /**
     * @param lcTargetTableId the lcTargetTableId to set
     */
    public void setLcTargetTableId(short lcTargetTableId) {
        this.lcTargetTableId = lcTargetTableId;
    }

    /**
     * @return the mjdStartTime
     */
    public double getMjdStartTime() {
        return mjdStartTime;
    }

    /**
     * @param mjdStartTime the mjdStartTime to set
     */
    public void setMjdStartTime(double mjdStartTime) {
        this.mjdStartTime = mjdStartTime;
    }

    /**
     * @return the scTargetTableId
     */
    public short getScTargetTableId() {
        return scTargetTableId;
    }

    /**
     * @param scTargetTableId the scTargetTableId to set
     */
    public void setScTargetTableId(short scTargetTableId) {
        this.scTargetTableId = scTargetTableId;
    }

    /**
     * @return the targetApertureTableId
     */
    public short getTargetApertureTableId() {
        return targetApertureTableId;
    }

    /**
     * @param targetApertureTableId the targetApertureTableId to set
     */
    public void setTargetApertureTableId(short targetApertureTableId) {
        this.targetApertureTableId = targetApertureTableId;
    }

    /**
     * @return the id
     */
    public long getId() {
        return id;
    }

    /**
     * @return the mjdEndTime
     */
    public double getMjdEndTime() {
        return mjdEndTime;
    }

    public String getDatasetName() {
        return datasetName;
    }

    public void setDatasetName(String datasetName) {
        this.datasetName = datasetName;
    }

    public void setMjdEndTime(double mjdEndTime) {
        this.mjdEndTime = mjdEndTime;
    }

    public void setMjdMidTime(double mjdMidTime) {
        this.mjdMidTime = mjdMidTime;
    }

    public DispatchLog getDispatchLog() {
        return dispatchLog;
    }

    public void setDispatchLog(DispatchLog dispatchLog) {
        this.dispatchLog = dispatchLog;
    }

    public int getSpacecraftConfigId() {
        return spacecraftConfigId;
    }

    public void setSpacecraftConfigId(int spacecraftConfigId) {
        this.spacecraftConfigId = spacecraftConfigId;
    }

    public DataSetType getDataSetType() {
        return dataSetType;
    }

    public void setDataSetType(DataSetType dataSetType) {
        this.dataSetType = dataSetType;
    }

    public boolean isDataRequantizedForDownlink() {
        return dataRequantizedForDownlink;
    }

    public void setDataRequantizedForDownlink(boolean dataRequantizedForDownlink) {
        this.dataRequantizedForDownlink = dataRequantizedForDownlink;
    }

    public boolean isDataEntropicCompressedForDownlink() {
        return dataEntropicCompressedForDownlink;
    }

    public void setDataEntropicCompressedForDownlink(
        boolean dataEntropicCompressedForDownlink) {
        this.dataEntropicCompressedForDownlink = dataEntropicCompressedForDownlink;
    }

    public boolean isDataOriginatedAsBaselineImage() {
        return dataOriginatedAsBaselineImage;
    }

    public void setDataOriginatedAsBaselineImage(
        boolean dataOriginatedAsBaselineImage) {
        this.dataOriginatedAsBaselineImage = dataOriginatedAsBaselineImage;
    }

    public String getBaselineImageRootname() {
        return baselineImageRootname;
    }

    public void setBaselineImageRootname(String baselineImageRootname) {
        this.baselineImageRootname = baselineImageRootname;
    }

    public boolean isBaselineCreatedFromResidualBaselineImage() {
        return baselineCreatedFromResidualBaselineImage;
    }

    public void setBaselineCreatedFromResidualBaselineImage(
        boolean baselineCreatedFromResidualBaselineImage) {
        this.baselineCreatedFromResidualBaselineImage = baselineCreatedFromResidualBaselineImage;
    }

    public String getResidualBaselineImageRootname() {
        return residualBaselineImageRootname;
    }

    public void setResidualBaselineImageRootname(
        String residualBaselineImageRootname) {
        this.residualBaselineImageRootname = residualBaselineImageRootname;
    }

    public boolean isReverseClockingInEffect() {
        return reverseClockingInEffect;
    }

    public void setReverseClockingInEffect(boolean reverseClockingInEffect) {
        this.reverseClockingInEffect = reverseClockingInEffect;
    }

    public boolean isSefiAcc() {
        return sefiAcc;
    }

    public void setSefiAcc(boolean sefiAcc) {
        this.sefiAcc = sefiAcc;
    }

    public boolean isSefiCad() {
        return sefiCad;
    }

    public void setSefiCad(boolean sefiCad) {
        this.sefiCad = sefiCad;
    }

    public boolean isLdeOos() {
        return ldeOos;
    }

    public void setLdeOos(boolean ldeOos) {
        this.ldeOos = ldeOos;
    }

    public boolean isFinePnt() {
        return finePnt;
    }

    public void setFinePnt(boolean finePnt) {
        this.finePnt = finePnt;
    }

    public boolean isMmntmDmp() {
        return mmntmDmp;
    }

    public void setMmntmDmp(boolean mmntmDmp) {
        this.mmntmDmp = mmntmDmp;
    }

    public boolean isLdeParEr() {
        return ldeParEr;
    }

    public void setLdeParEr(boolean ldeParEr) {
        this.ldeParEr = ldeParEr;
    }

    public boolean isScrcErr() {
        return scrcErr;
    }

    public void setScrcErr(boolean scrcErr) {
        this.scrcErr = scrcErr;
    }

    /*
     * (non-Javadoc)
     * 
     * @see java.lang.Object#hashCode()
     */
    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + backApertureTableId;
        result = PRIME * result + backTargetTableId;
        result = PRIME * result + cadenceNumber;
        result = PRIME * result + cadenceType;
        result = PRIME * result + compressionTableId;
        result = PRIME * result
            + ((datasetName == null) ? 0 : datasetName.hashCode());
        result = PRIME * result
            + ((fitsFilename == null) ? 0 : fitsFilename.hashCode());
        result = PRIME * result + lcTargetTableId;
        long temp;
        temp = Double.doubleToLongBits(mjdEndTime);
        result = PRIME * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(mjdStartTime);
        result = PRIME * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(mjdMidTime);
        result = PRIME * result + (int) (temp ^ (temp >>> 32));
        result = PRIME * result + scTargetTableId;
        result = PRIME * result + targetApertureTableId;
        return result;
    }

    /*
     * (non-Javadoc)
     * 
     * @see java.lang.Object#equals(java.lang.Object)
     */
    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        final RclcPixelLog other = (RclcPixelLog) obj;
        if (backApertureTableId != other.backApertureTableId)
            return false;
        if (backTargetTableId != other.backTargetTableId)
            return false;
        if (cadenceNumber != other.cadenceNumber)
            return false;
        if (cadenceType != other.cadenceType)
            return false;
        if (compressionTableId != other.compressionTableId)
            return false;
        if (datasetName == null) {
            if (other.datasetName != null)
                return false;
        } else if (!datasetName.equals(other.datasetName))
            return false;
        if (fitsFilename == null) {
            if (other.fitsFilename != null)
                return false;
        } else if (!fitsFilename.equals(other.fitsFilename))
            return false;
        if (lcTargetTableId != other.lcTargetTableId)
            return false;
        if (Double.doubleToLongBits(mjdEndTime) != Double.doubleToLongBits(other.mjdEndTime))
            return false;
        if (Double.doubleToLongBits(mjdStartTime) != Double.doubleToLongBits(other.mjdStartTime))
            return false;
        if (Double.doubleToLongBits(mjdMidTime) != Double.doubleToLongBits(other.mjdMidTime))
            return false;
        if (scTargetTableId != other.scTargetTableId)
            return false;
        if (targetApertureTableId != other.targetApertureTableId)
            return false;
        return true;
    }
}
