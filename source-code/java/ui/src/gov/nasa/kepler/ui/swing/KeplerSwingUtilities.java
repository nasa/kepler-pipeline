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

package gov.nasa.kepler.ui.swing;

import java.awt.Component;
import java.awt.Container;
import java.awt.Dialog;
import java.awt.FontMetrics;
import java.awt.Image;
import java.awt.TextComponent;

import javax.swing.ImageIcon;
import javax.swing.JComponent;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.SwingUtilities;
import javax.swing.text.JTextComponent;

/**
 * General Swing utility methods.
 * 
 * @see SwingUtilities
 * @author Bill Wohler
 */
public class KeplerSwingUtilities {

    /**
     * Returns the dialog for the given component
     * 
     * @param component the component
     * @return the component's dialog, or null if the component isn't a
     * descendent of a dialog
     */
    public static Dialog getDialog(Component component) {
        for (Container c = component.getParent(); c != null; c = c.getParent()) {
            if (c instanceof JDialog) {
                return (JDialog) c;
            }
        }
        return null;
    }

    /**
     * Get the width of the given string for the given component in pixels.
     * 
     * @param component a {@link JComponent}
     * @param s the string
     * @return the width of the string, in pixels, or 0 if
     * <code>component</code> is <code>null</code> or its string is empty
     */
    public static int textWidth(JComponent component, String s) {
        if (component == null || s == null || s.length() == 0) {
            return 0;
        }

        FontMetrics metrics = component.getFontMetrics(component.getFont());

        return metrics.stringWidth(s);
    }

    /**
     * Get the width of the string of the given text component in pixels.
     * 
     * @param component a {@link JLabel} or {@link TextComponent}
     * @return the width of the string, in pixels, or 0 if
     * <code>component</code> is <code>null</code> or its string is empty
     * @throws ClassCastException if the <code>component</code> is neither a
     * {@link JLabel} nor a {@link TextComponent}
     */
    public static int textWidth(JComponent component) {
        if (component == null) {
            return 0;
        }

        String s = null;
        if (component instanceof JLabel) {
            s = ((JLabel) component).getText();
        } else {
            s = ((JTextComponent) component).getText();
        }

        return textWidth(component, s);
    }

    /**
     * Fill the given string by replacing spaces with newlines so that it does
     * not exceed the given number of columns. Note that if a line doesn't have
     * any spaces, it will not be broken.
     * 
     * @param s a non-null string
     * @param columns a positive number of columns
     * @throws NullPointerException if s is <code>null</code>
     * @throws IllegalArgumentException if columns is not positive
     * @return a filled string
     */
    public static String fill(String s, int columns) {
        if (columns <= 0) {
            throw new IllegalArgumentException("columns must be positive");
        }

        StringBuilder filledString = new StringBuilder(s);
        int lastSpace = -1;
        int column = 0;
        for (int i = 0, n = filledString.length(); i < n; i++) {
            if (filledString.charAt(i) == ' ') {
                lastSpace = i;
            } else if (filledString.charAt(i) == '\n') {
                lastSpace = -1;
                column = 0;
                continue;
            }
            if (++column > columns && lastSpace >= 0) {
                filledString.replace(lastSpace, lastSpace + 1, "\n");
                column = i - lastSpace;
                lastSpace = -1;
            }
        }

        return filledString.toString();
    }

    /**
     * Converts string to HTML. Newlines are converted to br tags, and html tags
     * are inserted and appended. These strings are appropriate for text
     * components.
     * 
     * @param s the input string
     * @return the string, converted to HTML
     */
    public static String toHtml(String s) {
        StringBuilder html = new StringBuilder(s);

        for (int i = 0, n = html.length(); i < n; i++) {
            if (html.charAt(i) == '\n') {
                html.replace(i, i + 1, "<br>");
                i += "<br>".length() - 1;
                n += "<br>".length() - 1;
            }
        }
        html.insert(0, "<html>");
        html.append("</html>");

        return html.toString();
    }

    /**
     * Scales the given icon to the given size.
     * 
     * @param icon the icon to scale
     * @param width the desired width
     * @param height the desired height
     */
    public static ImageIcon scaleIcon(ImageIcon icon, int width, int height) {
        Image image = icon.getImage();
        image = image.getScaledInstance(width, height, Image.SCALE_SMOOTH);
        ImageIcon imageIcon = new ImageIcon(image);

        return imageIcon;
    }
}
