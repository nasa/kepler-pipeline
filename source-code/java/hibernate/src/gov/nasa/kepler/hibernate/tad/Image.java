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
import javax.persistence.Lob;
import javax.persistence.ManyToOne;
import javax.persistence.OneToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;

/**
 * Contains an {@link Image}.
 * 
 * @author Miles Cote
 */
@Entity
@Table(name = "TAD_IMAGE")
public final class Image {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "TAD_IMAGE_SEQ")
    @Column(nullable = false)
    private long id;

    @ManyToOne(optional = false)
    @Cascade(CascadeType.EVICT)
    private TargetTable targetTable;

    @Column(nullable = false)
    private int ccdModule;

    @Column(nullable = false)
    private int ccdOutput;

    @OneToOne(fetch = FetchType.LAZY)
    private PipelineTask pipelineTask;

    @Lob
    private double[][] moduleOutputImage;
    private int minRow;
    private int maxRow;
    private int minCol;
    private int maxCol;

    private transient Image supplementalImage;

    Image() {
    }

    Image(TargetTable targetTable, int ccdModule, int ccdOutput,
        PipelineTask pipelineTask, double[][] moduleOutputImage, int minRow,
        int maxRow, int minCol, int maxCol) {
        this.targetTable = targetTable;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.pipelineTask = pipelineTask;
        this.moduleOutputImage = moduleOutputImage;
        this.minRow = minRow;
        this.maxRow = maxRow;
        this.minCol = minCol;
        this.maxCol = maxCol;
    }

    public TargetTable getTargetTable() {
        return targetTable;
    }

    public int getCcdModule() {
        return ccdModule;
    }

    public int getCcdOutput() {
        return ccdOutput;
    }

    public PipelineTask getPipelineTask() {
        return pipelineTask;
    }

    public double[][] getModuleOutputImage() {
        if (supplementalImage != null) {
            return supplementalImage.getModuleOutputImage();
        } else {
            return moduleOutputImage;
        }
    }

    public int getMinRow() {
        if (supplementalImage != null) {
            return supplementalImage.getMinRow();
        } else {
            return minRow;
        }
    }

    public int getMaxRow() {
        if (supplementalImage != null) {
            return supplementalImage.getMaxRow();
        } else {
            return maxRow;
        }
    }

    public int getMinCol() {
        if (supplementalImage != null) {
            return supplementalImage.getMinCol();
        } else {
            return minCol;
        }
    }

    public int getMaxCol() {
        if (supplementalImage != null) {
            return supplementalImage.getMaxCol();
        } else {
            return maxCol;
        }
    }

    Image getSupplementalImage() {
        return supplementalImage;
    }

    public void setSupplementalImage(Image supplementalImage) {
        this.supplementalImage = supplementalImage;
    }

}
