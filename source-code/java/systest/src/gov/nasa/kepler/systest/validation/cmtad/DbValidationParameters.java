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

package gov.nasa.kepler.systest.validation.cmtad;

import gov.nasa.kepler.common.UsageException;
import gov.nasa.spiffy.common.lang.StringUtils;

import org.apache.commons.lang.ArrayUtils;

/**
 * Parameters for database validator.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public class DbValidationParameters {

    public static final int MAX_ERRORS_DISPLAYED_DEFAULT = 20;

    public enum Command {
        VALIDATE_CM_TAD;

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

    private boolean ignoreBackgroundTargetTableType;
    private boolean ignoreIndexInModuleOutput;
    private int maxErrorsDisplayed = MAX_ERRORS_DISPLAYED_DEFAULT;
    private String[] urls = ArrayUtils.EMPTY_STRING_ARRAY;

    public Command getCommand() {
        return command;
    }

    public void setCommand(Command command) {
        this.command = command;
    }

    public void setCommand(String command) {
        this.command = Command.valueOfHyphenatedLowercase(command);
    }

    public boolean isIgnoreBackgroundTargetTableType() {
        return ignoreBackgroundTargetTableType;
    }

    public void setIgnoreBackgroundTargetTableType(
        boolean ignoreBackgroundTargetTableType) {
        this.ignoreBackgroundTargetTableType = ignoreBackgroundTargetTableType;
    }

    public boolean isIgnoreIndexInModuleOutput() {
        return ignoreIndexInModuleOutput;
    }

    public void setIgnoreIndexInModuleOutput(boolean ignoreIndexInModuleOutput) {
        this.ignoreIndexInModuleOutput = ignoreIndexInModuleOutput;
    }

    public int getMaxErrorsDisplayed() {
        return maxErrorsDisplayed;
    }

    public void setMaxErrorsDisplayed(int maxErrorsDisplayed) {
        this.maxErrorsDisplayed = maxErrorsDisplayed == 0 ? Integer.MAX_VALUE
            : maxErrorsDisplayed;
    }

    public String[] getUrls() {
        return urls;
    }

    public void setUrls(String[] strings) {
        urls = strings;
    }
}
