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

package gov.nasa.kepler.systest.ops;

import gov.nasa.kepler.common.UsageException;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.lang.StringUtils;

import java.util.ArrayList;
import java.util.List;

/**
 * Options for OPS report generator.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public class ReportGenerationOptions {

    public enum Command {
        DATA_PROCESSING_REPORT, DATA_PROCESSING_SUMMARY;

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
    private String clusterName;
    private String dataName;
    private List<Pair<String, String>> fields = new ArrayList<Pair<String, String>>();
    private String jiraTicket;
    private List<Long> pipelineInstanceIds = new ArrayList<Long>();
    private String releaseToSt;
    private String releaseToPublic;
    private TextRenderer textRenderer = new PlainTextRenderer();

    public Command getCommand() {
        return command;
    }

    public void setCommand(Command command) {
        this.command = command;
    }

    public void setCommand(String command) {
        this.command = Command.valueOfHyphenatedLowercase(command);
    }

    public String getClusterName() {
        return clusterName;
    }

    public void setClusterName(String clusterName) {
        this.clusterName = clusterName;
    }

    public String getDataName() {
        return dataName;
    }

    public void setDataName(String dataName) {
        this.dataName = dataName;
    }

    public List<Pair<String, String>> getFields() {
        return fields;
    }

    public void addField(String fieldValue) {
        String[] field = fieldValue.split("=");
        fields.add(Pair.of(field[0], field[1]));
    }

    public void addFields(String[] fieldValues) {
        for (String fieldValue : fieldValues) {
            addField(fieldValue);
        }
    }

    public String getJiraTicket() {
        return jiraTicket;
    }

    public void setJiraTicket(String jiraTicket) {
        this.jiraTicket = jiraTicket;
    }

    public List<Long> getPipelineInstanceIds() {
        return pipelineInstanceIds;
    }

    public void addPipelineInstanceIds(String[] pipelineInstanceIds) {
        for (String pipelineInstanceId : pipelineInstanceIds) {
            try {
                addPipelineInstanceId(Long.valueOf(pipelineInstanceId));
            } catch (NumberFormatException e) {
                throw new UsageException(String.format(
                    "Could not determine pipeline instance ID from %s",
                    pipelineInstanceId));
            }
        }
    }

    private void addPipelineInstanceId(Long pipelineInstanceId) {
        pipelineInstanceIds.add(pipelineInstanceId);
    }

    public String getReleaseToSt() {
        return releaseToSt;
    }

    public void setReleaseToSt(String releaseToSt) {
        this.releaseToSt = releaseToSt;
    }

    public String getReleaseToPublic() {
        return releaseToPublic;
    }

    public void setReleaseToPublic(String releaseToPublic) {
        this.releaseToPublic = releaseToPublic;
    }

    public TextRenderer getTextRenderer() {
        return textRenderer;
    }

    public void setPlainTextRenderer() {
        textRenderer = new PlainTextRenderer();
    }

    public void setMediaWikiTextRenderer() {
        textRenderer = new MediaWikiTextRenderer();
    }
}
