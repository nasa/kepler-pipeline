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

package gov.nasa.kepler.fs.server.xfiles;

import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.server.FakeXid;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import javax.transaction.xa.Xid;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import static org.junit.Assert.*;

/**
 * @author Sean McCauliff
 *
 */
@RunWith(JMock.class)
public class TransactionalFileOpenerTest {

    
    private Mockery mockery;
    
    private Map<FsId, TransactionalFile> openedFiles;
    private TransactionalRandomAccessFile traf;
    private Map<Xid, FTMContext> allTransactions;

    @Before
    public void setUp() {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
        openedFiles = new HashMap<FsId, TransactionalFile>();
        traf = mockery.mock(TransactionalRandomAccessFile.class);
        allTransactions = mockery.mock(Map.class, "allTransactions");
    }
    
    
    @Test
    public void openNewFile() throws Exception {
        
        final AtomicInteger beginTransactionCount =  new AtomicInteger();
        TransactionalFileOpener<TransactionalRandomAccessFile> opener =
            new TransactionalFileOpener<TransactionalRandomAccessFile>() {
        
                
                @Override
                protected Map<FsId, TransactionalFile> openFileMap(FsId id) {
                    return openedFiles;
                }
                
                @Override
                protected TransactionalRandomAccessFile loadFile(FsId id) {
                    return traf;
                }
                
                @Override
                protected void beginTransaction(TransactionalRandomAccessFile xFile) {
                    assertSame(xFile, traf);
                    beginTransactionCount.getAndIncrement();
                }
            };
        
        FakeXid xid = new FakeXid(0, 1);
        FsId id = new FsId("/i/m");
        TransactionalRandomAccessFile returned = opener.openFile(xid, id, 1, allTransactions);
        assertSame(traf, returned);
        assertEquals(1, beginTransactionCount.get());
    }
    
    
    /**
     * File is already opened, but not not locked.
     * 
     * @throws Exception
     */
    @Test
    public void openOpenedFile() throws Exception {

        final FakeXid xid = new FakeXid(0, 1);
        
        FsId id = new FsId("/i/m");
        openedFiles.put(id, traf);
        
        mockery.checking(new Expectations() {{
            one(traf).acquireReadLock(xid, 1, false);
            will(returnValue(true));
            one(traf).releaseReadLock(xid);
        }});
        
        final AtomicInteger beginTransactionCount =  new AtomicInteger();
        TransactionalFileOpener<TransactionalRandomAccessFile> opener =
            new TransactionalFileOpener<TransactionalRandomAccessFile>() {
        
                
                @Override
                protected Map<FsId, TransactionalFile> openFileMap(FsId id) {
                    return openedFiles;
                }
                
                @Override
                protected TransactionalRandomAccessFile loadFile(FsId id) {
                    assertTrue(false);
                    return null;
                }
                
                @Override
                protected void beginTransaction(TransactionalRandomAccessFile xFile) {
                    assertSame(xFile, traf);
                    beginTransactionCount.getAndIncrement();
                }
            };
        
 

        TransactionalRandomAccessFile returned = 
            opener.openFile(xid, id, 1, allTransactions);
        assertSame(traf, returned);
        assertEquals(1, beginTransactionCount.get());
    }
    
    /**
     * File is already opened, but locked.  Will wait for transaction to finish.
     * Has an existing transaction so transaction count is not zero.
     * 
     * @throws Exception
     */
    @Test
    public void openOpenedLockedFile() throws Exception {
        final FakeXid xid = new FakeXid(0, 1);
        final FakeXid otherXid = new FakeXid(2, 2);
        final FTMContext otherTransactionContext = 
            mockery.mock(FTMContext.class);
        
        mockery.checking(new Expectations() {{
            one(allTransactions).get(otherXid);
            will(returnValue(otherTransactionContext));
            
            one(traf).transactionLockHolder();
            will(returnValue(otherXid));
            
            one(otherTransactionContext).acclerateCommit();
        }});
        
        FsId id = new FsId("/i/m");
        openedFiles.put(id, traf);
        
        mockery.checking(new Expectations() {{
            one(traf).acquireReadLock(xid, 1, false);
            will(returnValue(false));
            one(traf).acquireReadLock(xid, 1, false);
            will(returnValue(false));
            one(traf).acquireReadLock(xid, 1, false);
            will(returnValue(true));
            one(traf).releaseReadLock(xid);
            one(traf).hasTransactions();
            will(returnValue(true));
        }});
        
        final AtomicInteger beginTransactionCount =  new AtomicInteger();
        TransactionalFileOpener<TransactionalRandomAccessFile> opener =
            new TransactionalFileOpener<TransactionalRandomAccessFile>() {
        
                
                @Override
                protected Map<FsId, TransactionalFile> openFileMap(FsId id) {
                    return openedFiles;
                }
                
                @Override
                protected TransactionalRandomAccessFile loadFile(FsId id) {
                    assertTrue(false);
                    return null;
                }
                
                @Override
                protected void beginTransaction(TransactionalRandomAccessFile xFile) {
                    assertSame(xFile, traf);
                    beginTransactionCount.getAndIncrement();
                }
            };
        
 

        TransactionalRandomAccessFile returned = opener.openFile(xid, id, 1, allTransactions);
        assertSame(traf, returned);
        assertEquals(1, beginTransactionCount.get());
    }
    
    /**
     * File is already opened, but locked.  Will wait for transaction to finish.
     * But the transaction count is zero so it should attempt to get the
     * transactional file again.
     * 
     * @throws Exception
     */
    @Test
    public void openOpenedLockedAgainFile() throws Exception {
        final FakeXid xid = new FakeXid(0, 1);

        FsId id = new FsId("/i/m");
        openedFiles.put(id, traf);
        
        
        mockery.checking(new Expectations() {{
            one(traf).acquireReadLock(xid, 1, false);
            will(returnValue(false));
            
            one(traf).acquireReadLock(xid, 1, false);
            will(returnValue(true));
            
            one(traf).releaseReadLock(xid);
            one(traf).hasTransactions();
            will(returnValue(false));
            
            one(traf).acquireReadLock(xid, 1, false);
            will(returnValue(true));
            
            one(traf).releaseReadLock(xid);
        }});
        
        final AtomicInteger beginTransactionCount =  new AtomicInteger();
        TransactionalFileOpener<TransactionalRandomAccessFile> opener =
            new TransactionalFileOpener<TransactionalRandomAccessFile>() {
        
                
                @Override
                protected Map<FsId, TransactionalFile> openFileMap(FsId id) {
                    return openedFiles;
                }
                
                @Override
                protected TransactionalRandomAccessFile loadFile(FsId id) {
                    assertTrue(false);
                    return null;
                }
                
                @Override
                protected void beginTransaction(TransactionalRandomAccessFile xFile) {
                    assertSame(xFile, traf);
                    beginTransactionCount.getAndIncrement();
                }
            };
        
 

        TransactionalRandomAccessFile returned = 
            opener.openFile(xid, id, 1, allTransactions);
        assertSame(traf, returned);
        assertEquals(1, beginTransactionCount.get());
    }
}
