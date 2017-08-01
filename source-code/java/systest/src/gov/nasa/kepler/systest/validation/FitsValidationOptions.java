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

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.common.UsageException;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.lang.StringUtils;

import java.io.File;

/**
 * Options for FITS validator.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public class FitsValidationOptions {

    public static final int MAX_ERRORS_DISPLAYED_DEFAULT = 20;

    // To maximize testing of UOW, use large prime < 150 (number of cadences in
    // dev pipeline).
    public static final int CHUNK_SIZE_DEFAULT = 139;

    public enum Command {
        VALIDATE_ARP_PIXELS,
        VALIDATE_BACKGROUND_PIXELS,
        VALIDATE_COLLATERAL_PIXELS,
        VALIDATE_DV,
        VALIDATE_FLUX,
        VALIDATE_GAPS,
        VALIDATE_PIXELS_IN,
        VALIDATE_PIXELS_OUT,
        VALIDATE_TARGET_PIXELS,
        VALIDATE_TPS;

        private String name;

        private Command() {
            name = StringUtils.constantToHyphenSeparatedLowercase(toString())
                .intern();
        }

        public String getName() {
            return name;
        }

        public static Command valueOfHyphenatedLowercase(String name) {
            if (name == null) {
                throw new NullPointerException("name can't be null");
            }

            for (Command command : values()) {
                if (command.getName()
                    .equals(name)) {
                    return command;
                }
            }

            throw new UsageException("Unknown command " + name);
        }
    }

    private Command command;
    private long arId = -1;
    private long calId = -1;
    private long paId = -1;
    private long pdcId = -1;
    private long dvId = -1;
    private long tpsId = -1;
    private Pair<Integer, Integer> cadenceRange;
    private CadenceType cadenceType;
    private int skipCount = 0;
    private int targetSkipCount = 100;
    private int chunkSize = CHUNK_SIZE_DEFAULT;
    private int timeLimit;
    private int ccdModule = -1;
    private int ccdOutput = -1;
    private int keplerId = -1;
    private String pmrfDirectory;
    private String dvFitsDirectory;
    private String dvXmlDirectory;
    private String fluxDirectory;
    private String pixelsInputDirectory;
    private String pixelsOutputDirectory;
    private String arpPixelsDirectory;
    private String backgroundPixelsDirectory;
    private String collateralPixelsDirectory;
    private String targetPixelsDirectory;
    private String tpsTextDirectory;
    private String tpsCdppDirectory;
    private String tasksRootDirectory;
    private int maxErrorsDisplayed = MAX_ERRORS_DISPLAYED_DEFAULT;
    private boolean cacheEnabled;

    public Command getCommand() {
        return command;
    }

    public void setCommand(Command command) {
        this.command = command;
    }

    public void setCommand(String command) {
        this.command = Command.valueOfHyphenatedLowercase(command);
    }

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

    public Pair<Integer, Integer> getCadenceRange() {
        return cadenceRange;
    }

    public void setCadenceRange(Pair<Integer, Integer> cadenceRange) {
        this.cadenceRange = cadenceRange;
    }

    public void setCadenceRange(int startCadence, int endCadence) {
        cadenceRange = Pair.of(startCadence, endCadence);
    }

    public void setCadenceRange(String cadenceRange) {
        String[] values = cadenceRange.split("-");
        if (values.length != 2) {
            throw new UsageException("Invalid cadence range " + cadenceRange);
        }
        try {
            Pair<Integer, Integer> range = Pair.of(Integer.parseInt(values[0]),
                Integer.parseInt(values[1]));
            if (range.left > range.right) {
                throw new UsageException(
                    "The starting cadence must be less than or "
                        + "equal to the ending cadence in the given range "
                        + cadenceRange);
            }
            this.cadenceRange = range;
        } catch (NumberFormatException e) {
            throw new UsageException("Invalid cadence range " + cadenceRange);
        }
    }

    public CadenceType getCadenceType() {
        return cadenceType;
    }

    public void setCadenceType(CadenceType cadenceType) {
        this.cadenceType = cadenceType;
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

    public int getCcdModule() {
        return ccdModule;
    }

    public void setCcdModule(int ccdModule) {
        if (!FcConstants.validCcdModule(ccdModule)) {
            throw new UsageException(ccdModule
                + " is not a valid CCD module value");
        }
        this.ccdModule = ccdModule;
    }

    public int getCcdOutput() {
        return ccdOutput;
    }

    public void setCcdOutput(int ccdOutput) {
        if (!FcConstants.validCcdOutput(ccdOutput)) {
            throw new UsageException(ccdOutput
                + " is not a valid CCD output value");
        }
        this.ccdOutput = ccdOutput;
    }

    public int getKeplerId() {
        return keplerId;
    }

    public void setKeplerId(int keplerId) {
        this.keplerId = keplerId;
    }

    public String getPmrfDirectory() {
        return pmrfDirectory;
    }

    public void setPmrfDirectory(String pmrfDirectory) {
        this.pmrfDirectory = pmrfDirectory;
    }

    public String getDvFitsDirectory() {
        return dvFitsDirectory;
    }

    public void setDvFitsDirectory(String dvFitsDirectory) {
        this.dvFitsDirectory = dvFitsDirectory;
    }

    public String getDvXmlDirectory() {
        return dvXmlDirectory;
    }

    public void setDvXmlDirectory(String dvXmlDirectory) {
        this.dvXmlDirectory = dvXmlDirectory;
    }

    public String getFluxDirectory() {
        return fluxDirectory;
    }

    public void setFluxDirectory(String fluxDirectory) {
        this.fluxDirectory = fluxDirectory;
    }

    public String getPixelsInputDirectory() {
        return pixelsInputDirectory;
    }

    public void setPixelsInputDirectory(String pixelsInputDirectory) {
        this.pixelsInputDirectory = pixelsInputDirectory;
    }

    public String getPixelsOutputDirectory() {
        return pixelsOutputDirectory;
    }

    public void setPixelsOutputDirectory(String pixelsOutputDirectory) {
        this.pixelsOutputDirectory = pixelsOutputDirectory;
    }

    public String getArpPixelsDirectory() {
        return arpPixelsDirectory;
    }

    public void setArpPixelsDirectory(String arpPixelsDirectory) {
        this.arpPixelsDirectory = arpPixelsDirectory;
    }

    public String getBackgroundPixelsDirectory() {
        return backgroundPixelsDirectory;
    }

    public void setBackgroundPixelsDirectory(String backgroundPixelsDirectory) {
        this.backgroundPixelsDirectory = backgroundPixelsDirectory;
    }

    public String getCollateralPixelsDirectory() {
        return collateralPixelsDirectory;
    }

    public void setCollateralPixelsDirectory(String collateralPixelsDirectory) {
        this.collateralPixelsDirectory = collateralPixelsDirectory;
    }

    public String getTargetPixelsDirectory() {
        return targetPixelsDirectory;
    }

    public void setTargetPixelsDirectory(String targetPixelsDirectory) {
        this.targetPixelsDirectory = targetPixelsDirectory;
    }

    public String getTpsTextDirectory() {
        return tpsTextDirectory;
    }

    public void setTpsTextDirectory(String tpsTextDirectory) {
        this.tpsTextDirectory = tpsTextDirectory;
    }

    public String getTpsCdppDirectory() {
        return tpsCdppDirectory;
    }

    public void setTpsCdppDirectory(String tpsCdppDirectory) {
        this.tpsCdppDirectory = tpsCdppDirectory;
    }

    /**
     * Returns the task root directory. This is guaranteed to be an absolute
     * path.
     * 
     * @see #setTasksRootDirectory(String)
     * @return the task root directory
     */
    public String getTasksRootDirectory() {
        return tasksRootDirectory;
    }

    /**
     * Sets the task root directory. If the path is relative, then
     * $SOC_CODE_ROOT/dist or {@code /path/to/dist} will be prepended in
     * later calls to {@link #getTasksRootDirectory()}.
     * 
     * @see #getTasksRootDirectory()
     * @param tasksRootDirectory the task root directory
     */
    public void setTasksRootDirectory(String tasksRootDirectory) {
        if (tasksRootDirectory.startsWith(File.separator)) {
            this.tasksRootDirectory = tasksRootDirectory;
        } else {
            this.tasksRootDirectory = new File(SocEnvVars.getLocalDistDir(),
                tasksRootDirectory).getAbsolutePath();
        }
    }

    public int getMaxErrorsDisplayed() {
        return maxErrorsDisplayed;
    }

    public void setMaxErrorsDisplayed(int maxErrorsDisplayed) {
        this.maxErrorsDisplayed = maxErrorsDisplayed == 0 ? Integer.MAX_VALUE
            : maxErrorsDisplayed;
    }

    public boolean isCacheEnabled() {
        return cacheEnabled;
    }

    public void setCacheEnabled(boolean cacheEnabled) {
        this.cacheEnabled = cacheEnabled;
    }
}
