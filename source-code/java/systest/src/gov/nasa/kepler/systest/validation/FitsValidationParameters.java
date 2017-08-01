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

package gov.nasa.kepler.systest.validation;

import gov.nasa.kepler.common.UsageException;
import gov.nasa.spiffy.common.pi.Parameters;

/**
 * Parameters for FITS validator pipeline modules.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public class FitsValidationParameters implements Parameters {

    private long arId;
    private long calId;
    private long paId;
    private long pdcId;
    private long dvId;
    private long tpsId;
    private int skipCount;
    private int targetSkipCount;
    private int chunkSize;
    private int timeLimit;
    private int maxErrorsDisplayed;
    private String tasksRootDirectory = "";

    public long getArId() {
        return arId;
    }

    public void setArId(long arId) {
        this.arId = arId;
    }

    public long getCalId() {
        return calId;
    }

    public void setCalId(long calId) {
        this.calId = calId;
    }

    public long getPaId() {
        return paId;
    }

    public void setPaId(long paId) {
        this.paId = paId;
    }

    public long getPdcId() {
        return pdcId;
    }

    public void setPdcId(long pdcId) {
        this.pdcId = pdcId;
    }

    public long getDvId() {
        return dvId;
    }

    public void setDvId(long dvId) {
        this.dvId = dvId;
    }

    public long getTpsId() {
        return tpsId;
    }

    public void setTpsId(long tpsId) {
        this.tpsId = tpsId;
    }

    public int getSkipCount() {
        return skipCount;
    }

    public void setSkipCount(int skipCount) {
        if (skipCount < 0) {
            throw new UsageException(
                "skip count must but be greater than or equal to zero");
        }
        this.skipCount = skipCount;
    }

    public int getTargetSkipCount() {
        return targetSkipCount;
    }

    public void setTargetSkipCount(int targetSkipCount) {
        this.targetSkipCount = targetSkipCount;
    }

    public int getChunkSize() {
        return chunkSize;
    }

    public void setChunkSize(int chunkSize) {
        if (chunkSize < 0) {
            throw new UsageException(
                "chunk size must but be greater than or equal to zero");
        }
        this.chunkSize = chunkSize;
    }

    public int getTimeLimit() {
        return timeLimit;
    }

    public void setTimeLimit(int timeLimit) {
        if (timeLimit < 0) {
            throw new UsageException(
                "time limit must be greater than or equal to zero");
        }
        this.timeLimit = timeLimit;
    }

    public int getMaxErrorsDisplayed() {
        return maxErrorsDisplayed;
    }

    public void setMaxErrorsDisplayed(int maxErrorsDisplayed) {
        this.maxErrorsDisplayed = maxErrorsDisplayed == 0 ? Integer.MAX_VALUE
            : maxErrorsDisplayed;
    }

    public String getTasksRootDirectory() {
        return tasksRootDirectory;
    }

    public void setTasksRootDirectory(String tasksRootDirectory) {
        this.tasksRootDirectory = tasksRootDirectory;
    }
}
