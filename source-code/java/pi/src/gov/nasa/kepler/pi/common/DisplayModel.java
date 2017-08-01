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

package gov.nasa.kepler.pi.common;

import gov.nasa.spiffy.common.lang.StringUtils;

import java.io.PrintStream;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Superclass for all DisplayModel classes.
 * Contains abstract methods and print logic
 * 
 * @author tklaus
 *
 */
public abstract class DisplayModel {

    private static final int COLUMN_SPACING = 2;

    private static SimpleDateFormat dateFormat = new SimpleDateFormat();

    public abstract int getRowCount();
    public abstract int getColumnCount();
    public abstract Object getValueAt(int rowIndex, int columnIndex);
    public abstract String getColumnName(int column);

    public void print(PrintStream ps) {
        print(ps, null);
    }
    
    public void print(PrintStream ps, String title) {
        // print title if specified
        if(title != null && title.length() > 0){
            ps.println();
            ps.println(title);
            ps.println();
        }
        
        // determine column widths
        int[] columnWidths = new int[getColumnCount()];
        for (int column = 0; column < getColumnCount(); column++) {
            columnWidths[column] = Math.max(0, getColumnName(column).length() + COLUMN_SPACING);
            for (int row = 0; row < getRowCount(); row++) {
                columnWidths[column] = Math.max(columnWidths[column], getValueAt(row, column).toString()
                    .length() + COLUMN_SPACING);
            }
        }

        // print column headers
        for (int column = 0; column < getColumnCount(); column++) {
            ps.print(StringUtils.pad(getColumnName(column), columnWidths[column]));
        }
        ps.println();
        
        for (int column = 0; column < getColumnCount(); column++) {
            for (int i = 0; i < columnWidths[column]; i++) {
                ps.print("-");
            }
        }
        ps.println();

        // print table data
        for (int row = 0; row < getRowCount(); row++) {
            for (int column = 0; column < getColumnCount(); column++) {
                ps.print(StringUtils.pad(getValueAt(row, column).toString(), columnWidths[column]));
            }
            ps.println();
        }
    }
    
    public static double getProcessingMillis(Date start, Date end) {
        double processingMillis = 0.0;
        long startMillis = start.getTime();
        long endMillis = end.getTime();

        if(endMillis == 0){
            endMillis = System.currentTimeMillis();
        }

        if(startMillis == 0){
            startMillis = System.currentTimeMillis();
        }
        
        processingMillis = endMillis - startMillis;

        return processingMillis;
    }
    
    public static double getProcessingHours(Date start, Date end) {
        double processingMillis = getProcessingMillis(start, end);
        double processingHours = processingMillis / (1000.0 * 60.0 * 60.0);

        return processingHours;
    }
    
    protected String formatDouble(double d){
        if(new Double(d).isNaN()){
            return "-";
        }else{
            return String.format("%.3f", d);
        }
    }

    public static String formatDate(Date d){
        if(d.getTime() == 0){
            return "-";
        }else{
            return dateFormat.format(d);
        }
    }    
}
