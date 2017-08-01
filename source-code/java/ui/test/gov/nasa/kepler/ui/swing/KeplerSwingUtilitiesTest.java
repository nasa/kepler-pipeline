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

import static org.junit.Assert.assertEquals;

import org.junit.Test;

public class KeplerSwingUtilitiesTest {

    @Test(expected = NullPointerException.class)
    public void fillNullTest() {
        KeplerSwingUtilities.fill(null, 1);
    }

    @Test(expected = IllegalArgumentException.class)
    public void fillBadColumnTest1() {
        KeplerSwingUtilities.fill("foo", 0);
    }

    @Test(expected = IllegalArgumentException.class)
    public void fillBadColumnTest2() {
        KeplerSwingUtilities.fill("foo", -1);
    }

    @Test
    public void fillTest() {
        String in = "The quick brown fox jumped over the lazy dogs";
        String out1 = "The\nquick\nbrown\nfox\njumped\nover\nthe\nlazy\ndogs";
        String out3 = "The\nquick\nbrown\nfox\njumped\nover\nthe\nlazy\ndogs";
        String out4 = "The\nquick\nbrown\nfox\njumped\nover\nthe\nlazy\ndogs";
        String out5 = "The\nquick\nbrown\nfox\njumped\nover\nthe\nlazy\ndogs";
        String out10 = "The quick\nbrown fox\njumped\nover the\nlazy dogs";
        String out20 = "The quick brown fox\njumped over the lazy\ndogs";
        assertEquals("Filling 1 column", out1, KeplerSwingUtilities.fill(in, 1));
        assertEquals("Filling 3 columns", out3,
            KeplerSwingUtilities.fill(in, 3));
        assertEquals("Filling 4 columns", out4,
            KeplerSwingUtilities.fill(in, 4));
        assertEquals("Filling 5 columns", out5,
            KeplerSwingUtilities.fill(in, 5));
        assertEquals("Filling 10 columns", out10,
            KeplerSwingUtilities.fill(in, 10));
        assertEquals("Filling 20 columns", out20,
            KeplerSwingUtilities.fill(in, 20));

        in = "Thequickbrownfoxjumpedoverthelazydogs";
        out10 = "Thequickbrownfoxjumpedoverthelazydogs";
        assertEquals(out10, KeplerSwingUtilities.fill(in, 10));
    }

    //@edu.umd.cs.findbugs.annotations.SuppressWarnings("NP")
    @Test(expected = NullPointerException.class)
    public void toHtmlNullTest() {
        KeplerSwingUtilities.toHtml(null);
    }

    @Test
    public void toHtmlTest() {
        assertEquals("<html></html>", KeplerSwingUtilities.toHtml(""));
        assertEquals("<html> </html>", KeplerSwingUtilities.toHtml(" "));
        assertEquals("<html>a</html>", KeplerSwingUtilities.toHtml("a"));
        assertEquals("<html>a<br>b</html>", KeplerSwingUtilities.toHtml("a\nb"));
    }
}
