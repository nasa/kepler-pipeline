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

package gov.nasa.kepler.ui.common;

/**
 * A general status event which is generally consumed by progress monitors. This
 * object uses the builder pattern, which means that setter methods return
 * <code>this</code> so that they may be chained to create the desired status
 * event. For example, most events will look like one of the following:
 * 
 * <pre>
 * new StatusEvent(this).message(resourceMap.getString(&quot;resource&quot;));
 * new StatusEvent(this).done();
 * </pre>
 * 
 * <p>
 * However, failure messages will look more like the following:
 * 
 * <pre>
 * new StatusEvent(this).failed()
 *     .message(e.getCause()
 *         .getMessage());
 * </pre>
 * 
 * @author Bill Wohler
 */
public class StatusEvent {

    private Object source;
    private String message;
    private boolean started;
    private float progress = -1;
    private boolean done;
    private boolean failed;

    /**
     * Use {@link StatusEvent#StatusEvent(Object)}.
     */
    @SuppressWarnings("unused")
    private StatusEvent() {
    }

    /**
     * Creates a {@link StatusEvent} with the given source.
     * 
     * @param source the source, usually <code>this</code>.
     */
    public StatusEvent(Object source) {
        this.source = source;
    }

    /**
     * Returns the source of this status event.
     * 
     * @return the source.
     */
    public Object getSource() {
        return source;
    }

    /**
     * Returns the message property for this event object. It may be
     * <code>null</code> unless {@link #failed()} has been called on this object
     * in which case it must not be null.
     * 
     * @return the message property.
     */
    public String getMessage() {
        return message;
    }

    /**
     * Sets the message property on this event object. This method must be
     * called with a non-null message if {@link #failed()} has been called on
     * this object.
     * 
     * @param message the message.
     * @return this status event object to enable method chaining.
     */
    public StatusEvent message(String message) {
        this.message = message;
        return this;
    }

    /**
     * Returns the progress property for this event object. This is a number
     * between 0 and 1 inclusive. The {@link #started()} method sets this
     * property to 0 and {@link #done} sets it to 1.
     * 
     * @return the progress property.
     */
    public float getProgress() {
        return progress;
    }

    /**
     * Sets the progress property on this event object.
     * 
     * @return this status event object to enable method chaining.
     */
    public StatusEvent progress(float progress) {
        this.progress = progress;
        return this;
    }

    /**
     * Returns the started property for this event object.
     * 
     * @return the started property.
     */
    public boolean isStarted() {
        return started;
    }

    /**
     * Sets the started property on this event object to <code>true</code>. Also
     * sets the progress property to 0.0.
     * 
     * @return this status event object to enable method chaining.
     */
    public StatusEvent started() {
        started = true;
        progress = 0.0F;
        return this;
    }

    /**
     * Returns the done property for this event object.
     * 
     * @return the done property.
     */
    public boolean isDone() {
        return done;
    }

    /**
     * Sets the done property on this event object to <code>true</code>. Also
     * sets the progress property to 1.0.
     * 
     * @return this status event object to enable method chaining.
     */
    public StatusEvent done() {
        done = true;
        progress = 1.0F;
        return this;
    }

    /**
     * Returns the failed property for this event object. If <code>true</code>,
     * then {@link #getMessage()} should return non-null strings.
     * 
     * @return the failed property.
     */
    public boolean isFailed() {
        return failed;
    }

    /**
     * Sets the failed property on this event object. If this method is called,
     * then the {@link #message(String)} methods must be called with non-
     * <code>null</code> arguments.
     * 
     * @return this status event object to enable method chaining.
     */
    public StatusEvent failed() {
        failed = true;
        return this;
    }

    @Override
    public String toString() {
        StringBuilder s = new StringBuilder();

        s.append(source != null ? source.getClass()
            .getSimpleName() : "Unknown");
        s.append("(");
        boolean addComma = false;
        if (started) {
            s.append("started");
            addComma = true;
        }
        // Avoid showing progress of 0 or 100 if we're going to be printing
        // "done" or "started" already.
        if (progress >= 0 && !done && !started) {
            if (addComma) {
                s.append(",");
            }
            s.append((int) (100 * progress));
            s.append("%");
            addComma = true;
        }
        if (done) {
            if (addComma) {
                s.append(",");
            }
            s.append("done");
            addComma = true;
        }
        if (failed) {
            if (addComma) {
                s.append(",");
            }
            s.append("failed");
            addComma = true;
        }
        s.append("): ");
        if (message != null) {
            s.append(message);
        }

        return s.toString();
    }
}
