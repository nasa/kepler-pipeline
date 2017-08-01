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

package gov.nasa.kepler.services.process;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.LineNumberReader;
import java.io.Writer;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Utility class that consumes external process output from a dedicated thread to
 * avoid a buffer full situation and subsequent process blocking. 
 * 
 * Output can be sent to a user-supplied Writer, or can be accumulated in a
 * StringBuffer that the caller can later access, or can just be sent to the
 * logger
 * 
 * @author Todd Klaus
 */
public class OutputConsumerThread extends Thread {
    static final Log log = LogFactory.getLog(OutputConsumerThread.class);
    private boolean shouldLog;
    private LineNumberReader reader;
    private Writer output;
    
    /**
     * 
     * @param label
     * @param input
     * @param output
     * @param shouldLog
     */
    public OutputConsumerThread(String label, InputStream input, Writer output, boolean shouldLog) {
        super(label + ":CT");
        this.reader = new LineNumberReader(new BufferedReader(new InputStreamReader(input)));
        this.output = output;
        this.shouldLog = shouldLog;
    }

    @Override
    public void run() {
        while (true) {
            String oneLine;
            try {
                oneLine = reader.readLine();

            } catch (IOException e) {
                log.warn("caught IOException reading process output, e = " + e);
                try {
                    if (reader != null) {
                        reader.close();
                    }
                } catch (IOException e1) {
                }
                return;
            }

            if (oneLine == null) {
                // by definition, process exited
                try {
                    if (reader != null) {
                        reader.close();
                    }
                } catch (IOException e1) {
                    log.warn("caught IOException closing output writer or reader, e1 = " + e1);
                }
                return;
            }
            if (shouldLog) {
                // don't send to output stream, just log
                log.info(": " + oneLine);
            }
            // send to the user-supplied (or default StringWriter) output
            // stream
            if (output != null) {
                try {
                    output.write(oneLine + "\n");
                } catch (IOException e1) {
                    log.warn("failed to write output, caught e = " + e1);
                }
            }
        }
    }
}