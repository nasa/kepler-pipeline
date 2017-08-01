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

package gov.nasa.kepler.mc.fs;

import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.pi.PipelineTask;

/**
 * {@link FsId} factory for MR.
 * 
 * @author Bill Wohler
 */
public class MrFsIdFactory {
    public static final String MR_PATH = "/mr";

    /**
     * No instances.
     */
    private MrFsIdFactory() {
    }

    /**
     * Generates an {@link FsId} for an MR report. The {@code pipelineTask} must
     * have a valid {@code pipelineDefinitionNode} and {@code pipelineInstance}.
     * 
     * @param pipelineTask the pipelineTask
     * @return an {@link FsId} for an MR report
     * @throws NullPointerException if {@code pipelineTask} is {@code null} or
     * the pipeline task doesn't have a valid {@code pipelineDefinitionNode} or
     * {@code pipelineInstance}.
     */
    public static FsId getReportId(PipelineTask pipelineTask) {
        return getReportIdIntern(pipelineTask, null);
    }

    /**
     * Generates an {@link FsId} for an MR report. The {@code pipelineTask} must
     * have a valid {@code pipelineDefinitionNode} and {@code pipelineInstance}.
     * 
     * @param pipelineTask the pipelineTask
     * @param identifier the report's distinguishing identifier
     * @return an {@link FsId} for an MR report
     * @throws NullPointerException if {@code identifier} is {@code null} or
     * pipelineTask} is {@code null} or the pipeline task doesn't have a valid
     * {@code pipelineDefinitionNode} or {@code pipelineInstance}.
     */
    public static FsId getReportId(PipelineTask pipelineTask, String identifier) {
        if (identifier == null) {
            throw new NullPointerException("identifier can't be null");
        }

        return getReportIdIntern(pipelineTask, identifier);
    }

    /**
     * Generates an {@link FsId} for an MR report. The {@code pipelineTask} must
     * have a valid {@code pipelineDefinitionNode} and {@code pipelineInstance}.
     * 
     * @param pipelineTask the pipelineTask
     * @param identifier the report's distinguishing identifier; if {@code null}
     * , the identifier is not appended to the fsid
     * @return an {@link FsId} for an MR report
     * @throws NullPointerException if pipelineTask} is {@code null} or the
     * pipeline task doesn't have a valid {@code pipelineDefinitionNode} or
     * {@code pipelineInstance}.
     */
    private static FsId getReportIdIntern(PipelineTask pipelineTask,
        String identifier) {

        if (pipelineTask == null) {
            throw new NullPointerException("pipelineTask can't be null");
        }
        if (pipelineTask.getPipelineDefinitionNode() == null) {
            throw new NullPointerException(
                "pipelineTask.pipelineDefinitionNode can't be null");
        }
        if (pipelineTask.getPipelineDefinitionNode()
            .getModuleName() == null) {
            throw new NullPointerException(
                "pipelineTask.pipelineDefinitionNode.moduleName can't be null");
        }
        if (pipelineTask.getPipelineInstance() == null) {
            throw new NullPointerException(
                "pipelineTask.pipelineInstance can't be null");
        }

        String moduleName = pipelineTask.getPipelineDefinitionNode()
            .getModuleName()
            .toString();
        long pipelineInstanceId = pipelineTask.getPipelineInstance()
            .getId();
        StringBuilder s = new StringBuilder().append(MR_PATH)
            .append("/")
            .append(moduleName)
            .append("/")
            .append(pipelineInstanceId);
        if (identifier != null) {
            s.append("/")
                .append(pipelineTask.getId());
        }

        String path = s.toString();
        String name = identifier != null ? identifier
            : Long.toString(pipelineTask.getId());

        return new FsId(path, name);
    }
}
