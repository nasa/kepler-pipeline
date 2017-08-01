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

package gov.nasa.kepler.services.cmdrunner;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import org.apache.commons.exec.ExecuteStreamHandler;
import org.apache.commons.exec.InputStreamPumper;
import org.apache.commons.exec.StreamPumper;
import org.apache.commons.exec.util.DebugUtils;

public class NamedPumpStreamHandler implements ExecuteStreamHandler {

    private String threadLabel = "???";
    private Thread outputThread;
    private Thread errorThread;
    private Thread inputThread;
    private final OutputStream out;
    private final OutputStream err;
    private final InputStream input;
    private InputStreamPumper inputStreamPumper;

    /**
     * Construct a new <CODE>NamedPumpStreamHandler</CODE>.
     */
    public NamedPumpStreamHandler() {
        this(System.out, System.err);
    }

    /**
     * Construct a new <CODE>NamedPumpStreamHandler</CODE>.
     * 
     * @param outAndErr the output/error <CODE>OutputStream</CODE>.
     */
    public NamedPumpStreamHandler(final OutputStream outAndErr) {
        this(outAndErr, outAndErr);
    }

    /**
     * Construct a new <CODE>NamedPumpStreamHandler</CODE>.
     * 
     * @param out the output <CODE>OutputStream</CODE>.
     * @param err the error <CODE>OutputStream</CODE>.
     */
    public NamedPumpStreamHandler(final OutputStream out, final OutputStream err) {
        this(out, err, null);
    }

    /**
     * Construct a new <CODE>NamedPumpStreamHandler</CODE>.
     * 
     * @param out the output <CODE>OutputStream</CODE>.
     * @param err the error <CODE>OutputStream</CODE>.
     * @param input the input <CODE>InputStream</CODE>.
     */
    public NamedPumpStreamHandler(final OutputStream out, final OutputStream err, final InputStream input) {

        this.out = out;
        this.err = err;
        this.input = input;
    }

    /**
     * Set the <CODE>InputStream</CODE> from which to read the standard output
     * of the process.
     * 
     * @param is the <CODE>InputStream</CODE>.
     */
    @Override
    public void setProcessOutputStream(final InputStream is) {
        if (out != null) {
            createProcessOutputPump(is, out);
        }
    }

    /**
     * Set the <CODE>InputStream</CODE> from which to read the standard error of
     * the process.
     * 
     * @param is the <CODE>InputStream</CODE>.
     */
    @Override
    public void setProcessErrorStream(final InputStream is) {
        if (err != null) {
            createProcessErrorPump(is, err);
        }
    }

    /**
     * Set the <CODE>OutputStream</CODE> by means of which input can be sent to
     * the process.
     * 
     * @param os the <CODE>OutputStream</CODE>.
     */
    @Override
    public void setProcessInputStream(final OutputStream os) {
        if (input != null) {
            if (input == System.in) {
                inputThread = createSystemInPump(input, os);
            } else {
                inputThread = createPump(threadLabel + ":IN", input, os, true);
            }
        } else {
            try {
                os.close();
            } catch (IOException e) {
                String msg = "Got exception while closing output stream";
                DebugUtils.handleException(msg, e);
            }
        }
    }

    /**
     * Start the <CODE>Thread</CODE>s.
     */
    @Override
    public void start() {
        if (outputThread != null) {
            outputThread.start();
        }
        if (errorThread != null) {
            errorThread.start();
        }
        if (inputThread != null) {
            inputThread.start();
        }
    }

    /**
     * Stop pumping the streams.
     */
    @Override
    public void stop() {

        if (inputStreamPumper != null) {
            inputStreamPumper.stopProcessing();
        }

        if (outputThread != null) {
            try {
                outputThread.join();
                outputThread = null;
            } catch (InterruptedException e) {
                // ignore
            }
        }

        if (errorThread != null) {
            try {
                errorThread.join();
                errorThread = null;
            } catch (InterruptedException e) {
                // ignore
            }
        }

        if (inputThread != null) {
            try {
                inputThread.join();
                inputThread = null;
            } catch (InterruptedException e) {
                // ignore
            }
        }

        if (err != null && err != out) {
            try {
                err.flush();
            } catch (IOException e) {
                String msg = "Got exception while flushing the error stream : " + e.getMessage();
                DebugUtils.handleException(msg, e);
            }
        }

        if (out != null) {
            try {
                out.flush();
            } catch (IOException e) {
                String msg = "Got exception while flushing the output stream";
                DebugUtils.handleException(msg, e);
            }
        }
    }

    /**
     * Get the error stream.
     * 
     * @return <CODE>OutputStream</CODE>.
     */
    protected OutputStream getErr() {
        return err;
    }

    /**
     * Get the output stream.
     * 
     * @return <CODE>OutputStream</CODE>.
     */
    protected OutputStream getOut() {
        return out;
    }

    /**
     * Create the pump to handle process output.
     * 
     * @param is the <CODE>InputStream</CODE>.
     * @param os the <CODE>OutputStream</CODE>.
     */
    protected void createProcessOutputPump(final InputStream is, final OutputStream os) {
        outputThread = createPump(threadLabel + ":SO", is, os);
    }

    /**
     * Create the pump to handle error output.
     * 
     * @param is the <CODE>InputStream</CODE>.
     * @param os the <CODE>OutputStream</CODE>.
     */
    protected void createProcessErrorPump(final InputStream is, final OutputStream os) {
        errorThread = createPump(threadLabel + ":SE", is, os);
    }

    /**
     * Creates a stream pumper to copy the given input stream to the given
     * output stream.
     * 
     * @param is the input stream to copy from
     * @param os the output stream to copy into
     * @return the stream pumper thread
     */
    protected Thread createPump(String threadName, final InputStream is, final OutputStream os) {
        return createPump(threadName, is, os, false);
    }

    /**
     * Creates a stream pumper to copy the given input stream to the given
     * output stream.
     * 
     * @param is the input stream to copy from
     * @param os the output stream to copy into
     * @param closeWhenExhausted close the output stream when the input stream
     * is exhausted
     * @return the stream pumper thread
     */
    protected Thread createPump(String threadName, final InputStream is, final OutputStream os, final boolean closeWhenExhausted) {
        final Thread result = new Thread(new StreamPumper(is, os, closeWhenExhausted), threadName);
        result.setDaemon(true);
        return result;
    }

    /**
     * Creates a stream pumper to copy the given input stream to the given
     * output stream.
     * 
     * @param is the System.in input stream to copy from
     * @param os the output stream to copy into
     * @return the stream pumper thread
     */
    private Thread createSystemInPump(InputStream is, OutputStream os) {
        inputStreamPumper = new InputStreamPumper(is, os);
        final Thread result = new Thread(inputStreamPumper, threadLabel + ":IN");
        result.setDaemon(true);
        return result;
    }

    public String getThreadLabel() {
        return threadLabel;
    }

    public void setThreadLabel(String threadLabel) {
        this.threadLabel = threadLabel;
    }
}
