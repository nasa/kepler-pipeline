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

/**
 * Render input into MediaWiki format.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class MediaWikiTextRenderer implements TextRenderer {

    private String cellStyle;

    @Override
    public void renderLine(String line) {

        System.out.println(line.substring(renderLeadingWhitespace(line))
            + "<br>");
    }

    private int renderLeadingWhitespace(String input) {

        int offset = 0;
        for (char c : input.toCharArray()) {
            if (Character.isWhitespace(c)) {
                // Convert leading spaces to non-breaking space entities.
                System.out.print("&nbsp;");
                offset++;
            } else {
                break;
            }
        }

        return offset;
    }

    @Override
    public void renderLine(String format, Object... args) {
        renderLine(String.format(format, args));
    }

    @Override
    public void renderTableBegin(String tableAttributes, String cellStyle) {
        System.out.println("{| " + tableAttributes);
        this.cellStyle = cellStyle;
    }

    @Override
    public void renderTableEnd() {
        System.out.println("|}");
    }

    @Override
    public void renderTableRow(Object... args) {
        StringBuilder line = new StringBuilder();
        line.append("|-\n");
        boolean oneline = true; // make it easier to change behavior
        for (Object arg : args) {
            if (oneline) {
                line.append("|");
            }
            line.append("|");
            line.append(" ");
            line.append(cellStyle != null ? "style=\"" + cellStyle + "\" | "
                : "");
            line.append(arg.toString()
                .trim()
                .replace("\n", "<br>"));
            line.append(oneline ? " " : "\n");
        }
        if (oneline) {
            // In this case, we need to add a newline and remove the extra pipe
            // at the beginning of the line.
            line.append("\n");
            line.deleteCharAt(line.indexOf("|", line.indexOf("|") + 1));
        }

        System.out.print(line.toString());
    }
}