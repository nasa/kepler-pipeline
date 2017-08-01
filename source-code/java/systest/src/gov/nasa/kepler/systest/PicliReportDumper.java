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

package gov.nasa.kepler.systest;

import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.pi.cli.PipelineConsoleCli;

import java.io.File;
import java.io.FileOutputStream;
import java.io.PrintStream;
import java.util.List;

import com.google.common.collect.ImmutableList;

/**
 * Dumps picli reports.
 * 
 * @author Miles Cote
 * 
 */
public class PicliReportDumper {

    public void dump(File outputDir, long startPipelineInstanceId,
        long endPipelineInstanceId) throws Exception {
        for (long pipelineInstanceId = startPipelineInstanceId; pipelineInstanceId <= endPipelineInstanceId; pipelineInstanceId++) {
            dumpReports(outputDir, pipelineInstanceId);
        }
    }

    private void dumpReports(File outputDir, long pipelineInstanceId)
        throws Exception {
        PipelineInstanceCrud pipelineInstanceCrud = new PipelineInstanceCrud();
        PipelineInstance pipelineInstance = pipelineInstanceCrud.retrieve(pipelineInstanceId);
        if (pipelineInstance != null) {
            List<String> reportTypes = ImmutableList.of("f", "r", "s");
            for (String reportType : reportTypes) {
                File outputFile = new File(outputDir, "i" + pipelineInstanceId
                    + "-instance-" + reportType + ".txt");
                PrintStream out = new PrintStream(new FileOutputStream(
                    outputFile));
                System.setOut(out);

                PipelineConsoleCli pipelineConsoleCli = new PipelineConsoleCli();
                pipelineConsoleCli.processCommand(new String[] { "i",
                    String.valueOf(pipelineInstanceId), reportType });

                out.close();
            }
        }
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 3) {
            System.err.println("USAGE: dump-picli-reports OUTPUT_DIR START_PIPELINE_INSTANCE_ID END_PIPELINE_INSTANCE_ID");
            System.err.println("EXAMPLE: dump-picli-reports /path/to/reports 4000 4100");
            System.exit(-1);
        }

        File outputDir = new File(args[0]);
        long startPipelineInstanceId = Long.parseLong(args[1]);
        long endPipelineInstanceId = Long.parseLong(args[2]);

        PicliReportDumper picliReportDumper = new PicliReportDumper();
        picliReportDumper.dump(outputDir, startPipelineInstanceId,
            endPipelineInstanceId);
    }
}
