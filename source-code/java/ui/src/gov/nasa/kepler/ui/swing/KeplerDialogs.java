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

import static gov.nasa.kepler.ui.swing.KeplerSwingUtilities.fill;
import static gov.nasa.kepler.ui.swing.KeplerSwingUtilities.toHtml;

import java.awt.Container;
import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.util.HashMap;
import java.util.Map;

import javax.swing.Icon;
import javax.swing.JButton;
import javax.swing.JComponent;
import javax.swing.JDialog;
import javax.swing.JEditorPane;
import javax.swing.JFileChooser;
import javax.swing.JOptionPane;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.UIManager;
import javax.swing.filechooser.FileFilter;

import org.jdesktop.application.Application;
import org.jdesktop.application.ResourceMap;

import sun.swing.DefaultLookup;

/**
 * A class containing helpful dialogs. The methods in this class move the
 * boilerplate of a dialog out of the caller's code.
 * 
 * @author Bill Wohler
 */
public class KeplerDialogs {

    private static Map<Integer, JFileChooser> fileChoosers = new HashMap<Integer, JFileChooser>();
    private static File currentDirectory;

    /**
     * Displays an information dialog from the given parent component with the
     * given message. The primary string is emboldened. According to the HIG,
     * alert windows do not carry titles.
     * 
     * @param parent the parent component.
     * @param primary the primary message. It should use sentence
     * capitalization, but not end in a period.
     * @throws NullPointerException if any of the arguments are {@code null}.
     */
    public static void showInformationDialog(Container parent, String primary) {
        showInformationDialog(parent, primary, null);
    }

    /**
     * Displays an information dialog from the given parent component with the
     * given message. The primary string is emboldened. According to the HIG,
     * alert windows do not carry titles.
     * 
     * @param parent the parent component.
     * @param primary the primary message. It should use sentence
     * capitalization, but not end in a period.
     * @param secondary the secondary message. It should use sentence
     * capitalization and end with a period. It may be {@code null}.
     * @throws NullPointerException if any of the arguments (other than
     * secondary) are {@code null}.
     */
    public static void showInformationDialog(Container parent, String primary,
        String secondary) {

        JComponent label = createTextComponent(primary, secondary);
        JOptionPane.showMessageDialog(parent, label, "",
            JOptionPane.INFORMATION_MESSAGE);
    }

    /**
     * Displays an error dialog from the given parent component whose messages
     * are derived from the given resource map. The primary message resource
     * comes from the {@code primary} parameter and the secondary message
     * resource comes the resource {@code <i>primary</i>.secondary}. The
     * property for the primary resource should use sentence capitalization, but
     * not end in a period. It will be emboldened. The secondary property should
     * use sentence capitalization and end with a period. According to the HIG,
     * alert windows do not carry titles.
     * 
     * @param parent the parent component.
     * @param resourceMap the resource map to use.
     * @param primaryResource the primary resource.
     * @throws NullPointerException if any of the arguments are {@code null}.
     */
    public static void showErrorDialog(Container parent,
        ResourceMap resourceMap, String primaryResource) {

        String primary = resourceMap.getString(primaryResource);
        String secondary = resourceMap.getString(primaryResource + ".secondary");
        showErrorDialog(parent, primary, secondary);
    }

    /**
     * Displays an error dialog from the given parent component with the given
     * message. The primary string is emboldened. According to the HIG, alert
     * windows do not carry titles.
     * 
     * @param parent the parent component.
     * @param primary the primary message. It should use sentence
     * capitalization, but not end in a period.
     * @throws NullPointerException if any of the arguments are {@code null}.
     */
    public static void showErrorDialog(Container parent, String primary) {
        showErrorDialog(parent, primary, null);
    }

    /**
     * Displays an error dialog from the given parent component with the given
     * message. The primary string is emboldened. According to the HIG, alert
     * windows do not carry titles.
     * 
     * @param parent the parent component.
     * @param primary the primary message. It should use sentence
     * capitalization, but not end in a period.
     * @param secondary the secondary message. It should use sentence
     * capitalization and end with a period. It may be {@code null}.
     * @throws NullPointerException if any of the arguments (other than
     * secondary) are {@code null}.
     */
    public static void showErrorDialog(Container parent, String primary,
        String secondary) {

        JComponent label = createTextComponent(primary, secondary);
        JOptionPane.showMessageDialog(parent, label, "",
            JOptionPane.ERROR_MESSAGE);
    }

    /**
     * Displays a confirmation dialog from the given parent component whose
     * messages are derived from the given resource map. The primary message
     * resource comes from the {@code primary} parameter and the secondary
     * message resource comes the resource {@code <i>primary</i>.secondary}. The
     * property for the primary resource should use sentence capitalization, but
     * not end in a period. It will be emboldened. The secondary property should
     * use sentence capitalization and end with a period. According to the HIG,
     * alert windows do not carry titles.
     * 
     * @param parent the parent component.
     * @param resourceMap the resource map to use.
     * @param primaryResource the primary resource.
     * @throws NullPointerException if any of the arguments are {@code null}.
     */
    public static int showConfirmDialog(Container parent,
        ResourceMap resourceMap, String primaryResource) {

        String primary = resourceMap.getString(primaryResource);
        String secondary = resourceMap.getString(primaryResource + ".secondary");

        return showConfirmDialog(parent, primary, secondary, false);
    }

    /**
     * Displays a confirmation dialog from the given parent component with the
     * given message. The primary string is emboldened. According to the HIG,
     * alert windows do not carry titles.
     * 
     * @param parent the parent component.
     * @param primary the primary message. It should use sentence
     * capitalization, but not end in a period.
     * @throws NullPointerException if any of the arguments (other than
     * secondary) are {@code null}.
     */
    public static int showConfirmDialog(Container parent, String primary) {
        return showConfirmDialog(parent, primary, null, false);
    }

    /**
     * Displays a confirmation dialog from the given parent component with the
     * given message. The primary string is emboldened. According to the HIG,
     * alert windows do not carry titles.
     * 
     * @param parent the parent component.
     * @param primary the primary message. It should use sentence
     * capitalization, but not end in a period.
     * @param secondary the secondary message. It should use sentence
     * capitalization and end with a period. It may be {@code null}.
     * @throws NullPointerException if any of the arguments (other than
     * secondary) are {@code null}.
     */
    public static int showConfirmDialog(Container parent, String primary,
        String secondary) {

        return showConfirmDialog(parent, primary, secondary, false);
    }

    /**
     * Displays a confirmation dialog from the given parent component with the
     * given message. The primary string is emboldened. According to the HIG,
     * alert windows do not carry titles.
     * <p>
     * This variant adds an additional parameter {@code dangerous}, which when
     * {@code true}, sets the default button to Cancel. This should be used when
     * deleting objects and for other operations that cannot be easily undone.
     * 
     * @param parent the parent component.
     * @param primary the primary message. It should use sentence
     * capitalization, but not end in a period.
     * @param secondary the secondary message. It should use sentence
     * capitalization and end with a period. It may be {@code null}.
     * @param dangerous if {@code true}, the Cancel button is the default
     * button.
     * @throws NullPointerException if any of the arguments (other than
     * secondary) are {@code null}.
     */
    public static int showConfirmDialog(Container parent, String primary,
        String secondary, boolean dangerous) {

        JComponent label = createTextComponent(primary, secondary);

        // The following is the equivalent of
        // JOptionPane.showConfirmDialog(parent, label, "",
        // JOptionPane.OK_CANCEL_OPTION) adding the ability to set the Cancel
        // button as the default. If showConfirmDialog ever adds this flag, then
        // this method can be retired.

        // Create OK/Cancel buttons manually so that we can set Cancel button as
        // the default button.
        JButton[] buttons = new JButton[2];
        buttons[0] = createButton("OptionPane.okButtonText",
            "OptionPane.okButtonMnemonic", "OptionPane.okIcon",
            JOptionPane.OK_OPTION);
        buttons[1] = createButton("OptionPane.cancelButtonText",
            "OptionPane.cancelButtonMnemonic", "OptionPane.cancelIcon",

            JOptionPane.CANCEL_OPTION);

        // Make them the same size.
        Dimension b0size = buttons[0].getPreferredSize();
        Dimension b1size = buttons[1].getPreferredSize();
        Dimension size = new Dimension(Math.max(b0size.width, b1size.width),
            b0size.height);
        buttons[0].setPreferredSize(size);
        buttons[1].setPreferredSize(size);

        // Create the pane.
        final JOptionPane pane = new JOptionPane(label,
            JOptionPane.QUESTION_MESSAGE, JOptionPane.OK_CANCEL_OPTION, null,
            buttons, dangerous ? buttons[1] : buttons[0]);

        // Now that we have the pane, we can set up the buttons.
        buttons[0].addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                pane.setValue(JOptionPane.OK_OPTION);
            }
        });
        buttons[1].addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                pane.setValue(JOptionPane.CANCEL_OPTION);
            }
        });

        // Create, display, and dispose dialog.
        JDialog dialog = pane.createDialog(parent, "");
        dialog.setVisible(true);
        dialog.dispose();

        // What did the user choose?
        Object selectedValue = pane.getValue();
        if (selectedValue == null) {
            return JOptionPane.CLOSED_OPTION;
        }

        return (Integer) selectedValue;
    }

    /**
     * Creates a button from the given UIManager <b>keys</b>.
     * 
     * @param text the text key.
     * @param mnemonic the mnemonic key.
     * @param icon the icon key.
     * @return a button.
     */
    private static JButton createButton(String text, String mnemonic,
        String icon, final int value) {

        JButton tokenButton = new JButton();
        JButton button = new JButton(UIManager.getString(text),
            (Icon) DefaultLookup.get(tokenButton, tokenButton.getUI(), icon));
        try {
            button.setMnemonic(Integer.parseInt((String) UIManager.get(mnemonic)));
        } catch (NumberFormatException e) {
        }

        return button;
    }

    /**
     * Creates a text component with the given primary and secondary text. The
     * primary string is emboldened.
     * 
     * @param primary the primary text.
     * @param secondary the secondary text.
     * @return a text component.
     */
    private static JComponent createTextComponent(String primary,
        String secondary) {
        ResourceMap resourceMap = Application.getInstance()
            .getContext()
            .getResourceMap(KeplerDialogs.class);
        int width = resourceMap.getInteger("dialogWidth")
            .intValue();
        // Make the primary text slightly larger (125%) than the secondary text.
        // Adjust width of secondary text accordingly so that it is as wide as
        // the primary text. The number 1.6 was determined empirically.
        String message = "<span style=\"font-size:125%;font-weight:bold\">"
            + fill(primary, width)
            + "</span>"
            + (secondary != null && secondary.trim()
                .length() > 0 ? "\n\n" + fill(secondary, (int) (width * 1.6))
                : "");
        message = toHtml(message);

        JEditorPane pane = new JEditorPane("text/html", message);
        pane.setEditable(false);

        return pane;
    }

    /**
     * Displays a message dialog from the given parent component with the given
     * title and strings(s).
     * 
     * @param parent the parent component.
     * @param title the title.
     * @param strings the strings that should appear.
     * @throws NullPointerException if any of the arguments are {@code null}.
     */
    public static void showMessageDialog(Container parent, String title,
        String... strings) {
        JTextArea textArea = new JTextArea(33, 60);
        for (String s : strings) {
            textArea.append(s);
        }
        textArea.setCaretPosition(0);
        textArea.setEditable(false);

        JScrollPane pane = new JScrollPane(textArea);
        JOptionPane panel = new JOptionPane(pane, JOptionPane.PLAIN_MESSAGE,
            JOptionPane.DEFAULT_OPTION, null);

        JDialog dialog = panel.createDialog(parent, title);
        dialog.setResizable(true);
        dialog.setVisible(true);
        dialog.dispose();
    }

    /**
     * Shows a simple input dialog from the given parent component with the
     * given title, prompt string, and choices.
     * 
     * @param parent the parent component.
     * @param title the title.
     * @param prompt the prompt.
     * @param selectionValues if non-{@code null}, a drop-down combination box
     * with the given choices is created; if {@code null}, a text field is
     * created.
     * @param initialSelectionValue the initial value.
     * @return user's input, or {@code null} meaning the user cancelled the
     * input.
     */
    public static Object showInputDialog(Container parent, String title,
        String prompt, Object[] selectionValues, Object initialSelectionValue) {

        return JOptionPane.showInputDialog(parent, prompt, title,
            JOptionPane.PLAIN_MESSAGE, null, selectionValues,
            initialSelectionValue);
    }

    /**
     * Displays a file chooser dialog to user and returns chosen file.
     * 
     * @param parent the parent component.
     * @return the desired file, or {@code null} if the user cancelled.
     */
    public static File showFileChooserDialog(JComponent parent) {
        return showFileChooserDialogInternal(parent, JFileChooser.FILES_ONLY,
            false, null, null);
    }

    /**
     * Displays a file chooser dialog to user with the given filename initially
     * selected and returns chosen file.
     * 
     * @param parent the parent component.
     * @param filename the filename that should be initially selected.
     * @return the desired file, or {@code null} if the user cancelled.
     */
    public static File showFileChooserDialog(JComponent parent, String filename) {
        return showFileChooserDialogInternal(parent, JFileChooser.FILES_ONLY,
            false, filename, null);
    }

    /**
     * Displays a file chooser dialog with the given filter to user and return
     * chosen file.
     * 
     * @param parent the parent component.
     * @param filter the filter to apply to the chooser.
     * @return the desired file, or {@code null} if the user cancelled.
     */
    public static File showFileChooserDialog(JComponent parent,
        FileFilter filter) {
        return showFileChooserDialogInternal(parent, JFileChooser.FILES_ONLY,
            false, null, filter);
    }

    /**
     * Displays a file chooser dialog with the given filename initially selected
     * and the given filter to user and returns chosen file.
     * 
     * @param parent the parent component.
     * @param filename the filename that should be initially selected.
     * @param filter the filter to apply to the chooser.
     * @return the desired file, or {@code null} if the user cancelled.
     */
    public static File showFileChooserDialog(JComponent parent,
        String filename, FileFilter filter) {
        return showFileChooserDialogInternal(parent, JFileChooser.FILES_ONLY,
            false, filename, filter);
    }

    /**
     * Displays a file chooser dialog with a Save button to user and returns
     * chosen file.
     * 
     * @param parent the parent component.
     * @return the desired file, or {@code null} if the user cancelled.
     */
    public static File showSaveFileChooserDialog(JComponent parent) {
        return showFileChooserDialogInternal(parent, JFileChooser.FILES_ONLY,
            true, null, null);
    }

    /**
     * Displays a file chooser dialog with the given filter with a Save button
     * to user and return chosen file.
     * 
     * @param parent the parent component.
     * @param filter the filter to apply to the chooser.
     * @return the desired file, or {@code null} if the user cancelled.
     */
    public static File showSaveFileChooserDialog(JComponent parent,
        FileFilter filter) {
        return showFileChooserDialogInternal(parent, JFileChooser.FILES_ONLY,
            true, null, filter);
    }

    /**
     * Displays a file chooser dialog to user and returns chosen directory.
     * 
     * @param parent the parent component.
     * @return the desired directory, or {@code null} if the user cancelled.
     */
    public static File showDirectoryChooserDialog(JComponent parent) {
        return showFileChooserDialogInternal(parent,
            JFileChooser.DIRECTORIES_ONLY, false, null, null);
    }

    /**
     * Displays a file chooser dialog with a Save button to user and returns
     * chosen directory.
     * 
     * @param parent the parent component.
     * @return the desired directory, or {@code null} if the user cancelled.
     */
    public static File showSaveDirectoryChooserDialog(JComponent parent) {
        return showFileChooserDialogInternal(parent,
            JFileChooser.DIRECTORIES_ONLY, true, null, null);
    }

    /**
     * Displays a file chooser dialog with the given mode and filter to user and
     * returns chosen file or directory.
     * 
     * @param parent the parent component.
     * @param mode the type of files to be displayed.
     * @param filename the filename that should be initially selected.
     * @param filter the filter to apply to the chooser.
     * @return the desired file or directory, or {@code null} if the user
     * cancelled.
     * @see JFileChooser#setFileSelectionMode(int)
     * @see JFileChooser#setFileFilter(FileFilter)
     */
    private static File showFileChooserDialogInternal(JComponent parent,
        int mode, boolean save, String filename, FileFilter filter) {

        JFileChooser fileChooser = fileChoosers.get(mode);

        if (fileChooser == null) {
            fileChooser = new JFileChooser();
            // Keep a separate file chooser for each mode. This is to work
            // around a problem where once the file chooser has been set to
            // JFileChooser.DIRECTORIES_ONLY mode, it won't go back to
            // JFileChooser.FILES_ONLY mode.
            fileChooser.setFileSelectionMode(mode);
            fileChoosers.put(mode, fileChooser);
        }

        if (currentDirectory != null) {
            fileChooser.setCurrentDirectory(currentDirectory);
        }

        if (filename != null && filename.trim()
            .length() > 0) {
            fileChooser.setSelectedFile(new File(filename));
        }

        fileChooser.resetChoosableFileFilters();
        fileChooser.addChoosableFileFilter(filter);

        File file = null;
        int result = save ? fileChooser.showSaveDialog(parent)
            : fileChooser.showOpenDialog(parent);
        if (result == JFileChooser.APPROVE_OPTION) {
            file = fileChooser.getSelectedFile();
        }

        if (file != null) {
            currentDirectory = fileChooser.getCurrentDirectory();
        }

        return file;
    }
}
