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

package gov.nasa.kepler.ui.cm;

import gov.nasa.kepler.common.Iso8601Formatter;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.hibernate.fc.RollTime;
import gov.nasa.kepler.ui.common.DatabaseTask;
import gov.nasa.kepler.ui.common.DatabaseTaskService;

import java.text.DateFormat;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.swing.AbstractListModel;
import javax.swing.ComboBoxModel;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.jdesktop.application.Application;
import org.jdesktop.application.ResourceMap;

/**
 * A combobox model for start and stop dates. This model obtains the quarterly
 * roll dates from the database and inserts interpolated monthly dates.
 * <p>
 * N.B. This class is not thread-safe, but since it should only be constructed
 * on the EDT, this shouldn't be a problem.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
public class QuarterlyRollDateModel extends AbstractListModel implements
    ComboBoxModel {

    private static final Log log = LogFactory.getLog(QuarterlyRollDateModel.class);
    private ResourceMap resourceMap = Application.getInstance()
        .getContext()
        .getResourceMap(QuarterlyRollDateModel.class);

    /**
     * This is the number of segments per quarterly roll. It is currently
     * defined as three, as there are three months in a quarter, but it could go
     * higher if the segments are re-defined as every four-day contact. That
     * would be unfortunate, as it would make this the combobox that uses this
     * model rather cumbersome to use.
     */
    private static final int SEGMENTS_PER_ROLL = 3;

    /**
     * This is the number of milliseconds in a segment. It is defined as the
     * number of milliseconds in a year, divided by four (number of quarters in
     * a year), divided by {@link #SEGMENTS_PER_ROLL}.
     */
    // The use of 365L promotes the entire expression to long, which is
    // definitely necessary here.
    private static final long MILLISECONDS_PER_SEGMENT = 365L * 24 * 60 * 60
        * 1000 / 4 / SEGMENTS_PER_ROLL;

    /** A string used to indent segments between quarterly dates. */
    private static final String SEGMENT_INDENT = "    ";

    private DateFormat iso8601DateFormat = Iso8601Formatter.dateTimeFormatter();

    private List<String> dates = new ArrayList<String>();
    private Object selectedItem;

    /**
     * Creates a {@link QuarterlyRollDateModel}. The first date that falls after
     * today will be selected.
     */
    public QuarterlyRollDateModel() {
        this(null);
    }

    /**
     * Creates a {@link QuarterlyRollDateModel} which displays the given date.
     * If it is an exact match of an existing roll time, then that roll time is
     * initially selected; otherwise, the date is displayed in the combobox, but
     * will be lost if another date in the list is chosen by the user. If the
     * date is {@code null}, then the first date that falls after today will be
     * selected.
     */
    public QuarterlyRollDateModel(Date displayedDate) {
        // Add a dummy value if date is null so that drop-down combination box
        // size will be correct.
        dates.add(displayedDate != null ? displayedDate.toString()
            : new Date().toString());

        Application.getInstance()
            .getContext()
            .getTaskService(DatabaseTaskService.NAME)
            .execute(new RollTimesLoadTask(displayedDate));
    }

    /**
     * Returns the first item in the {@code dates} list that represents a date
     * that falls after today. In the case that today is after all of the dates
     * in the list, just return the last item. The last item is also returned
     * (and a warning logged) in the unlikely case that a date (created with the
     * same formatter used here) can't be parsed.
     * 
     * @return a date string which matches one of those in the {@code dates}
     * list.
     */
    private String nextDate() {
        try {
            Date today = new Date();
            for (String dateString : dates) {
                Date date = iso8601DateFormat.parse(dateString);
                if (date.after(today)) {
                    return dateString;
                }
            }
        } catch (ParseException e) {
            log.warn(resourceMap.getString("nextDate", e.getMessage()), e);
        }

        return dates.get(dates.size() - 1);
    }

    @Override
    public Object getElementAt(int index) {
        return dates.get(index);
    }

    @Override
    public int getSize() {
        return dates.size();
    }

    @Override
    public Object getSelectedItem() {
        return selectedItem;
    }

    @Override
    public void setSelectedItem(Object item) {

        // If item is date, convert it to string that is in list.
        Object requestedSelection = item;
        if (requestedSelection instanceof Date) {
            String dateString = iso8601DateFormat.format((Date) requestedSelection);
            boolean inList = false;
            for (String date : dates) {
                if (date.equals(dateString)
                    || date.equals(SEGMENT_INDENT + dateString)) {
                    requestedSelection = date;
                    inList = true;
                    break;
                }
            }
            if (!inList) {
                // Format item; it will be added to (probably empty) list.
                requestedSelection = dateString;
            }
        }

        // Update selection if it's changed.
        if (selectedItem != null && !selectedItem.equals(requestedSelection)
            || selectedItem == null && requestedSelection != null) {
            selectedItem = requestedSelection;
            fireContentsChanged(this, -1, -1);
        }
    }

    /**
     * A task for loading roll dates.
     * 
     * @author Bill Wohler
     */
    private class RollTimesLoadTask extends DatabaseTask<List<String>, Void> {
        private static final String NAME = "RollTimesLoadTask";
        private Date displayedDate;

        public RollTimesLoadTask(Date displayedDate) {
            this.displayedDate = displayedDate;
        }

        @Override
        protected List<String> doInBackground() throws Exception {
            RollTimeOperations rtOps = new RollTimeOperations();
            List<String> dates = new ArrayList<String>();

            for (RollTime rollTime : rtOps.retrieveAllRollTimes()) {
                // Convert RollTime to Date
                Date date = ModifiedJulianDate.mjdToDate(rollTime.getMjd());

                // Add the current roll date to the list.
                dates.add(iso8601DateFormat.format(date));

                // Now interpolate the monthly contacts.
                for (int i = 1; i < SEGMENTS_PER_ROLL; i++) {
                    date = new Date(date.getTime() + MILLISECONDS_PER_SEGMENT);
                    dates.add(SEGMENT_INDENT + iso8601DateFormat.format(date));
                }
            }

            return dates;
        }

        @Override
        protected void handleFatalError(Throwable e) {
            log.error(resourceMap.getString(NAME + ".failed"));
            log.error(resourceMap.getString(NAME + ".failed.secondary",
                e.getMessage()));
            // TODO Display dialog a la handleError(e, NAME)
        }

        @Override
        protected void succeeded(List<String> dates) {
            QuarterlyRollDateModel.this.dates = dates;
            if (displayedDate != null) {
                setSelectedItem(displayedDate);
            } else if (dates.size() > 0) {
                setSelectedItem(nextDate());
            }
        }
    }
}
