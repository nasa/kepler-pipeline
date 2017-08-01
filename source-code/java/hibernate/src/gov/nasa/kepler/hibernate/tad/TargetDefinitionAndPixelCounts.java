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

package gov.nasa.kepler.hibernate.tad;

import java.util.Map;
import java.util.TreeMap;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinTable;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;
import org.hibernate.annotations.CollectionOfElements;
import org.hibernate.annotations.Fetch;
import org.hibernate.annotations.FetchMode;
import org.hibernate.annotations.IndexColumn;

/**
 * Used to track various target and pixel counts for {@link TadReport} and
 * {@link TadModOutReport}.
 * 
 * @author Miles Cote
 */
@Entity
@Table(name = "TAD_TARG_AND_PIX_COUNTS")
public class TargetDefinitionAndPixelCounts {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "TAD_TAPC_SEQ")
    @Column(nullable = false)
    private long id;

    @CollectionOfElements(fetch = FetchType.EAGER)
    @Fetch(value = FetchMode.SUBSELECT)
    @IndexColumn(name = "IDX")
    @Cascade(CascadeType.ALL)
    @JoinTable(name = "TAD_TPC_LABEL_COUNTS")
    private Map<String, Integer> labelCounts = new TreeMap<String, Integer>();

    @Column(name = "STELLAR_TARGET_DEF_CNT")
    private int stellarTargetDefCount;
    @Column(name = "DYNAMIC_RANGE_TARGET_DEF_CNT")
    private int dynamicRangeTargetDefCount;
    @Column(name = "BACKGROUND_TARGET_DEF_CNT")
    private int backgroundTargetDefCount;
    @Column(name = "LEADING_BLACK_TARGET_DEF_CNT")
    private int leadingBlackTargetDefCount;
    @Column(name = "TRAILING_BLACK_TARGET_DEF_CNT")
    private int trailingBlackTargetDefCount;
    @Column(name = "MASKED_SMEAR_TARGET_DEF_CNT")
    private int maskedSmearTargetDefCount;
    @Column(name = "VIRTUAL_SMEAR_TARGET_DEF_CNT")
    private int virtualSmearTargetDefCount;
    @Column(name = "TOTAL_TARGET_DEF_CNT")
    private int totalTargetDefCount;

    private int stellarPixelCount;
    private int dynamicRangePixelCount;
    private int backgroundPixelCount;
    private int leadingBlackPixelCount;
    private int trailingBlackPixelCount;
    private int maskedSmearPixelCount;
    private int virtualSmearPixelCount;
    private int excessPixelCount;
    private int totalPixelCount;
    private int uniquePixelCount;

    public TargetDefinitionAndPixelCounts() {
    }

    public int getLeadingBlackPixelCount() {
        return leadingBlackPixelCount;
    }

    public void setLeadingBlackPixelCount(int leadingBlackPixelCount) {
        this.leadingBlackPixelCount = leadingBlackPixelCount;
    }

    public int getMaskedSmearPixelCount() {
        return maskedSmearPixelCount;
    }

    public void setMaskedSmearPixelCount(int maskedSmearPixelCount) {
        this.maskedSmearPixelCount = maskedSmearPixelCount;
    }

    public int getTrailingBlackPixelCount() {
        return trailingBlackPixelCount;
    }

    public void setTrailingBlackPixelCount(int trailingBlackPixelCount) {
        this.trailingBlackPixelCount = trailingBlackPixelCount;
    }

    public int getVirtualSmearPixelCount() {
        return virtualSmearPixelCount;
    }

    public void setVirtualSmearPixelCount(int virtualSmearPixelCount) {
        this.virtualSmearPixelCount = virtualSmearPixelCount;
    }

    public int getStellarPixelCount() {
        return stellarPixelCount;
    }

    public void setStellarPixelCount(int visiblePixelCount) {
        this.stellarPixelCount = visiblePixelCount;
    }

    public int getBackgroundPixelCount() {
        return backgroundPixelCount;
    }

    public void setBackgroundPixelCount(int backgroundPixelCount) {
        this.backgroundPixelCount = backgroundPixelCount;
    }

    public int getBackgroundTargetDefCount() {
        return backgroundTargetDefCount;
    }

    public void setBackgroundTargetDefCount(int backgroundTargetCount) {
        this.backgroundTargetDefCount = backgroundTargetCount;
    }

    public int getDynamicRangePixelCount() {
        return dynamicRangePixelCount;
    }

    public void setDynamicRangePixelCount(int dynamicRangePixelCount) {
        this.dynamicRangePixelCount = dynamicRangePixelCount;
    }

    public int getDynamicRangeTargetDefCount() {
        return dynamicRangeTargetDefCount;
    }

    public void setDynamicRangeTargetDefCount(int dynamicRangeTargetCount) {
        this.dynamicRangeTargetDefCount = dynamicRangeTargetCount;
    }

    public int getLeadingBlackTargetDefCount() {
        return leadingBlackTargetDefCount;
    }

    public void setLeadingBlackTargetDefCount(int leadingBlackTargetCount) {
        this.leadingBlackTargetDefCount = leadingBlackTargetCount;
    }

    public int getMaskedSmearTargetDefCount() {
        return maskedSmearTargetDefCount;
    }

    public void setMaskedSmearTargetDefCount(int maskedSmearTargetCount) {
        this.maskedSmearTargetDefCount = maskedSmearTargetCount;
    }

    public int getStellarTargetDefCount() {
        return stellarTargetDefCount;
    }

    public void setStellarTargetDefCount(int stellarTargetCount) {
        this.stellarTargetDefCount = stellarTargetCount;
    }

    public int getTotalPixelCount() {
        return totalPixelCount;
    }

    public void setTotalPixelCount(int totalPixelCount) {
        this.totalPixelCount = totalPixelCount;
    }

    public int getUniquePixelCount() {
        return uniquePixelCount;
    }

    public void setUniquePixelCount(int uniquePixelCount) {
        this.uniquePixelCount = uniquePixelCount;
    }

    public int getTotalTargetDefCount() {
        return totalTargetDefCount;
    }

    public void setTotalTargetDefCount(int totalTargetCount) {
        this.totalTargetDefCount = totalTargetCount;
    }

    public int getTrailingBlackTargetDefCount() {
        return trailingBlackTargetDefCount;
    }

    public void setTrailingBlackTargetDefCount(int trailingBlackTargetCount) {
        this.trailingBlackTargetDefCount = trailingBlackTargetCount;
    }

    public int getVirtualSmearTargetDefCount() {
        return virtualSmearTargetDefCount;
    }

    public void setVirtualSmearTargetDefCount(int virtualSmearTargetCount) {
        this.virtualSmearTargetDefCount = virtualSmearTargetCount;
    }

    public int getExcessPixelCount() {
        return excessPixelCount;
    }

    public void setExcessPixelCount(int excessPixelCount) {
        this.excessPixelCount = excessPixelCount;
    }

    public Map<String, Integer> getLabelCounts() {
        return labelCounts;
    }

    public void setLabelCounts(Map<String, Integer> labelCounts) {
        this.labelCounts = labelCounts;
    }

}
