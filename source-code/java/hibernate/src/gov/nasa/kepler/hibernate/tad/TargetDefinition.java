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

import gov.nasa.kepler.hibernate.pi.PipelineTask;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.ManyToOne;
import javax.persistence.OneToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;

/**
 * This class represents target definitions that are sent to the MOC. An
 * {@link ObservedTarget} can have multiple {@link TargetDefinition}s if it
 * requires multiple {@link Mask}s to cover its {@link Aperture}.
 * 
 * @author Miles Cote
 */
@Entity
@Table(name = "TAD_TARGET_DEFINITION")
public class TargetDefinition {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "TAD_TARGET_DEFINITION_SEQ")
    @Column(nullable = false)
    private long id;

    @OneToOne(fetch = FetchType.LAZY)
    private PipelineTask pipelineTask;

    @ManyToOne(optional = false)
    @Cascade(CascadeType.EVICT)
    private TargetTable targetTable;

    @Column(nullable = false)
    private int ccdModule;

    @Column(nullable = false)
    private int ccdOutput;

    @Column(nullable = false)
    private int keplerId;

    // The index of this object in the target table. Restarts for each
    // module/output.
    @Column(nullable = false)
    private int indexInModuleOutput;

    @Column(nullable = false)
    private int referenceRow;

    @Column(nullable = false)
    private int referenceColumn;

    @Column(nullable = false)
    private int excessPixels;

    private int status;

    @ManyToOne(optional = true)
    @Cascade(CascadeType.EVICT)
    private Mask mask;

    public TargetDefinition() {
    }

    public TargetDefinition(ObservedTarget observedTarget) {
        this.targetTable = observedTarget.getTargetTable();
        setModOut(observedTarget.getModOut());
        this.keplerId = observedTarget.getKeplerId();
    }

    public TargetDefinition(int referenceRow, int referenceColumn,
        int amaExcessPixels, Mask mask) {
        this.referenceRow = referenceRow;
        this.referenceColumn = referenceColumn;
        this.excessPixels = amaExcessPixels;
        this.mask = mask;
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + ccdModule;
        result = PRIME * result + ccdOutput;
        result = PRIME * result + indexInModuleOutput;
        result = PRIME * result
            + ((targetTable == null) ? 0 : targetTable.hashCode());
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
        final TargetDefinition other = (TargetDefinition) obj;
        if (ccdModule != other.ccdModule)
            return false;
        if (ccdOutput != other.ccdOutput)
            return false;
        if (indexInModuleOutput != other.indexInModuleOutput)
            return false;
        if (targetTable == null) {
            if (other.targetTable != null)
                return false;
        } else if (!targetTable.equals(other.targetTable))
            return false;
        return true;
    }

    public int getExcessPixels() {
        return excessPixels;
    }

    public int getIndexInModuleOutput() {
        return indexInModuleOutput;
    }

    public void setIndexInModuleOutput(int index) {
        this.indexInModuleOutput = index;
    }

    public Mask getMask() {
        return mask;
    }

    public int getReferenceColumn() {
        return referenceColumn;
    }

    public int getReferenceRow() {
        return referenceRow;
    }

    public void setExcessPixels(int excessPixels) {
        this.excessPixels = excessPixels;
    }

    public void setMask(Mask mask) {
        this.mask = mask;
    }

    public void setReferenceColumn(int referenceColumn) {
        this.referenceColumn = referenceColumn;
    }

    public void setReferenceRow(int referenceRow) {
        this.referenceRow = referenceRow;
    }

    public int getCcdModule() {
        return ccdModule;
    }

    public void setCcdModule(int ccdModule) {
        this.ccdModule = ccdModule;
    }

    public int getCcdOutput() {
        return ccdOutput;
    }

    public void setCcdOutput(int ccdOutput) {
        this.ccdOutput = ccdOutput;
    }

    public ModOut getModOut() {
        return ModOut.of(ccdModule, ccdOutput);
    }

    public void setModOut(ModOut modOut) {
        this.ccdModule = modOut.getCcdModule();
        this.ccdOutput = modOut.getCcdOutput();
    }

    public TargetTable getTargetTable() {
        return targetTable;
    }

    public void setTargetTable(TargetTable targetTable) {
        this.targetTable = targetTable;
    }

    public int getKeplerId() {
        return keplerId;
    }

    public void setKeplerId(int keplerId) {
        this.keplerId = keplerId;
    }

    public PipelineTask getPipelineTask() {
        return pipelineTask;
    }

    public void setPipelineTask(PipelineTask pipelineTask) {
        this.pipelineTask = pipelineTask;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public long getId() {
        return id;
    }

}
