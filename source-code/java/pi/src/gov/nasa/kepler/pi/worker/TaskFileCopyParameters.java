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

package gov.nasa.kepler.pi.worker;

import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.spiffy.common.pi.Parameters;

/**
 * Parameters for copying task files from the worker to
 * another directory, typically a shared volume.
 * 
 * These parameters are used by {@link TaskFileCopy}
 * 
 * @author tklaus
 *
 */
public class TaskFileCopyParameters implements Parameters {

    private boolean enabled = false;

    /**
     * Absolute path to the destination directory.
     */
    private String destinationPath;
    
    /**
     * Files with any of the specified suffixes will be
     * excluded from the copy. Wildcards should not be used
     * ('.txt' not '*.txt').
     */
    private String[] excludeWildcards = new String[0];

    /**
     * If true, an exception is thrown if the copy fails
     */
    private boolean failTaskOnError = false;
    
    /** 
     * Delete the source after the copy is complete (without errors).
     */
    private boolean deleteAfterCopy = false;
    
    /** 
     * Delete the source without copying. This option destroys the task
     * files so it should only be used in testing scenarios where that
     * is acceptable */
    private boolean deleteWithoutCopy = false;
    
    /**
     * When enabled, generate UOW symlinks to the copied task directories
     * using {@link UnitOfWorkTask.makeUowSymlinks}.
     */
    private boolean uowSymlinksEnabled = false;
    
    /**
     * Directory where the symlinks will be created.
     */
    private String uowSymlinkPath;
    
    /**
     * Specifies whether to include month name in UOW string
     */
    private boolean uowSymlinksIncludeMonths = false;
    
    /**
     * Specifies whether to include cadence range in UOW string
     */
    private boolean uowSymlinksIncludeCadenceRange = false;
    
    public TaskFileCopyParameters() {
    }

    public boolean isEnabled() {
        return enabled;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public String getDestinationPath() {
        return destinationPath;
    }

    public void setDestinationPath(String destinationPath) {
        this.destinationPath = destinationPath;
    }

    public String[] getExcludeWildcards() {
        return excludeWildcards;
    }

    public void setExcludeWildcards(String[] excludeSuffixes) {
        this.excludeWildcards = excludeSuffixes;
    }

    public boolean isFailTaskOnError() {
        return failTaskOnError;
    }

    public void setFailTaskOnError(boolean failTaskOnError) {
        this.failTaskOnError = failTaskOnError;
    }

    public boolean isDeleteAfterCopy() {
        return deleteAfterCopy;
    }

    public void setDeleteAfterCopy(boolean deleteAfterCopy) {
        this.deleteAfterCopy = deleteAfterCopy;
    }

	public boolean isDeleteWithoutCopy() {
		return deleteWithoutCopy;
	}

	public void setDeleteWithoutCopy(boolean deleteWithoutCopy) {
		this.deleteWithoutCopy = deleteWithoutCopy;
	}

    public boolean isUowSymlinksEnabled() {
        return uowSymlinksEnabled;
    }

    public void setUowSymlinksEnabled(boolean uowSymlinksEnabled) {
        this.uowSymlinksEnabled = uowSymlinksEnabled;
    }

    public String getUowSymlinkPath() {
        return uowSymlinkPath;
    }

    public void setUowSymlinkPath(String uowSymlinkPath) {
        this.uowSymlinkPath = uowSymlinkPath;
    }

    public boolean isUowSymlinksIncludeMonths() {
        return uowSymlinksIncludeMonths;
    }

    public void setUowSymlinksIncludeMonths(boolean uowSymlinksIncludeMonths) {
        this.uowSymlinksIncludeMonths = uowSymlinksIncludeMonths;
    }

    public boolean isUowSymlinksIncludeCadenceRange() {
        return uowSymlinksIncludeCadenceRange;
    }

    public void setUowSymlinksIncludeCadenceRange(
        boolean uowSymlinksIncludeCadenceRange) {
        this.uowSymlinksIncludeCadenceRange = uowSymlinksIncludeCadenceRange;
    }
    
}
