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

package gov.nasa.kepler.dv;

import gov.nasa.spiffy.common.jmock.JMockTest;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.api.Action;
import org.jmock.integration.junit4.JMock;
import org.jmock.integration.junit4.JUnit4Mockery;
import org.jmock.lib.legacy.ClassImposteriser;
import org.jmock.syntax.ReceiverClause;
import org.junit.runner.RunWith;

/**
 * Extended by tests that use {@link JMock}.
 * 
 * @author Forrest Girouard
 * 
 */
@RunWith(JMock.class)
public abstract class DvJMockTest extends JMockTest {

    private final Mockery mockery = new JUnit4Mockery() {
        {
            setImposteriser(ClassImposteriser.INSTANCE);
        }
    };

    private Expectations expectations = new Expectations();
    private boolean allowingWasPreviousMethodCalled = false;
    
    public Mockery getMockery() {
        return mockery;
    }
    
    public Expectations getExpectations() {
        return expectations;
    }

    public <T> T mock(Class<T> typeToMock) {
        return mockery.mock(typeToMock);
    }

    public <T> T mock(Class<T> typeToMock, String name) {
        return mockery.mock(typeToMock, name);
    }

    public <T> T allowing(T mockObject) {
        checkThatAllowingWasNotThePreviousMethodCalled();

        T allowing = expectations.allowing(mockObject);
        allowingWasPreviousMethodCalled = true;

        return allowing;
    }

    public void will(Action action) {
        checkThatAllowingWasThePreviousMethodCalled();

        expectations.will(action);
        allowingWasPreviousMethodCalled = false;
        checking();
    }

    public <T> T oneOf(T mockObject) {
        checkThatAllowingWasNotThePreviousMethodCalled();

        T oneOf = expectations.oneOf(mockObject);
        allowingWasPreviousMethodCalled = false;
        checking();

        return oneOf;
    }

    public ReceiverClause atLeast(int count) {
        checkThatAllowingWasNotThePreviousMethodCalled();

        ReceiverClause rc = expectations.atLeast(count);
        allowingWasPreviousMethodCalled = false;

        return rc;
    }

    public static Action returnValue(Object result) {
        return Expectations.returnValue(result);
    }

    private void checking() {
        checkThatAllowingWasNotThePreviousMethodCalled();

        mockery.checking(expectations);
        expectations = new Expectations();
        allowingWasPreviousMethodCalled = false;
    }

    private void checkThatAllowingWasNotThePreviousMethodCalled() {
        if (allowingWasPreviousMethodCalled) {
            throw new IllegalArgumentException(
                "\n  The will() method must be called immediately following the allowing() method."
                    + "\n  This enforces the principle 'stub queries and expect commands'.");
        }
    }

    private void checkThatAllowingWasThePreviousMethodCalled() {
        if (!allowingWasPreviousMethodCalled) {
            throw new IllegalArgumentException(
                "\n  The will() method can only be called immediately following the allowing() method."
                    + "\n  This enforces the principle 'stub queries and expect commands'.");
        }
    }

}
