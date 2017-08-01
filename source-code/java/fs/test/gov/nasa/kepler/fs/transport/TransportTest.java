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

package gov.nasa.kepler.fs.transport;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.ClientSideException;
import gov.nasa.kepler.fs.client.util.PersistableXid;
import gov.nasa.kepler.io.DataInputStream;
import gov.nasa.kepler.io.DataOutputStream;

import static org.junit.Assert.*;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.persistable.BinaryPersistableInputStream;
import gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream;

import java.io.*;
import java.net.*;
import java.nio.channels.*;
import java.util.Arrays;
import java.util.Random;
import java.util.concurrent.*;
import java.util.concurrent.atomic.*;

import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Sean McCauliff
 * 
 */
public class TransportTest {

    private static final Log log = LogFactory.getLog(TransportTest.class);

    private static final int LISTEN_PORT_NO = 12345;

    private Server server;

    private InetSocketAddress localAddress;

    private File testDir = new File(Filenames.BUILD_TEST
        + "/TransportTest");
    
    private final Random fileContents = new Random(234324);

    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {

        server = new Server();
        localAddress = new InetSocketAddress("localhost", LISTEN_PORT_NO);
        testDir.mkdirs();
    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        if (server != null) {
            if (server.serverChannel != null) {
                server.serverChannel.close();

            }
        }

        FileUtil.removeAll(testDir);
    }

    @Test
    public void reproducePersistableBug() throws Exception {
        final AtomicReference<PersistableXid> xidRef = new AtomicReference<PersistableXid>();
        final CountDownLatch done = new CountDownLatch(1);
        final AtomicReference<String> methodNameRef = new AtomicReference<String>();
        
        server.testCode = new TestCode() {

            public void serverSide(SocketChannel s) throws Exception {
                try {
                    TransportServerV2 fsTransportServer = new TransportServerV2(s, true);
                    InputStream in = fsTransportServer.inputStream();
                    DataInputStream din = new DataInputStream(new BufferedInputStream(in));
                    String methodName = din.readUTF();
                    methodNameRef.set(methodName);
                    BinaryPersistableInputStream bpin = new BinaryPersistableInputStream(din);
                    PersistableXid xid = new PersistableXid();
                    bpin.load(xid);
                    System.out.println(xid);
                    xidRef.set(xid);
                    FsId readId = new FsId();
                    bpin.load(readId);
                    din.readLong();
                    din.readLong();
                } finally {
                    done.countDown();
                }
            }
        };
        
        Thread t = new Thread(server, "singleByte");
        t.setDaemon(true);
        t.start();

        server.waitForServerStart();
        
        Random rand = new Random(8675309);
        byte[] global = new byte[16];
        rand.nextBytes(global);
        byte[] branch = new byte[16];
        rand.nextBytes(branch);
        PersistableXid xid = new PersistableXid(global, branch, 233);
        String methodName = "method-name";
        
        TransportClientV2 transportClient = null;
        try {
            transportClient = new TransportClientV2(this.localAddress);
            transportClient.startMethod();

            OutputStream out = transportClient.outputStream();
            BufferedOutputStream bufOut = new BufferedOutputStream(out);
            DataOutputStream dout = new DataOutputStream(bufOut);
            BinaryPersistableOutputStream pout = new BinaryPersistableOutputStream(dout);
            
            dout.writeUTF(methodName);
            pout.save(xid);
            FsId id = new FsId("/jskjf/kjsdfkj");
            pout.save(id);
            dout.writeLong(7);
            dout.writeLong(8);
            dout.write(new byte[0]);
            bufOut.flush();
            done.await();
        } finally {
            transportClient.close();
        }
        
        assertEquals( xid, xidRef.get());
        assertEquals(methodName, methodNameRef.get());
    }
    
    @Test
    public void singleByte() throws Exception {
        final int MAX_BYTES = 4;
        final BlockingQueue<Byte> received = new ArrayBlockingQueue<Byte>(1);

        server.testCode = new TestCode() {

            public void serverSide(SocketChannel s) throws Exception {
                TransportServerV2 fsTransportServer = new TransportServerV2(s, true);
                InputStream in = fsTransportServer.inputStream();

                for (int i = 0; i < MAX_BYTES; i++) {
                    byte b = (byte) in.read();
                    received.add(b);
                }
                fsTransportServer.doneWithMethod();
            }
        };

        Thread t = new Thread(server, "singleByte");
        t.setDaemon(true);
        t.start();

        server.waitForServerStart();

        TransportClientV2 transportClient = null;
        try {
            transportClient = new TransportClientV2(this.localAddress);

            OutputStream out = transportClient.outputStream();
            transportClient.startMethod();
            byte byteValue = -1;
            for (int i = 0; i < MAX_BYTES; i++) {
                out.write(byteValue);
                byte serverByte = received.poll(2, TimeUnit.SECONDS);
                assertTrue("Bytes must be equals", byteValue == serverByte);
                byteValue--;
            }

        } finally {
            transportClient.close();
        }

    }

    @Test
    public void multipleBytes() throws Exception {
         final int MAX_BYTE_ARRAYS = 2;
         final int BYTE_ARRAY_SIZE = 1024;
         final BlockingQueue<byte[]> received = new ArrayBlockingQueue<byte[]>(1);

         server.testCode = new TestCode() {

             public void serverSide(SocketChannel s) throws Exception {
                 TransportServerV2 fsTransportServer = new TransportServerV2(s, true);
                 InputStream in = fsTransportServer.inputStream();

                 for (int i = 0; i < MAX_BYTE_ARRAYS; i++) {
                     byte[] b = new byte[BYTE_ARRAY_SIZE];
                     int nRead = in.read(b);
                     //This is actually an implementation side effect.  This need not read BYTE_ARRAY_SIZE
                     assertEquals("did not read expected number of bytes", BYTE_ARRAY_SIZE, nRead);
                     received.add(b);
                 }
                 
                 fsTransportServer.doneWithMethod();

             }
         };

         Thread t = new Thread(server, "singleByte");
         t.setDaemon(true);
         t.start();

         server.waitForServerStart();

         Random rand = new Random(8989);
         TransportClientV2 transportClient = null;
         try {
             transportClient = new TransportClientV2(this.localAddress);
             transportClient.startMethod();
             OutputStream out = transportClient.outputStream();

             for (int i = 0; i < MAX_BYTE_ARRAYS; i++) {
                 byte[] buf = new byte[BYTE_ARRAY_SIZE];
                 rand.nextBytes(buf);
                 out.write(buf);
                 byte[] serverByteArray = received.poll(2000, TimeUnit.SECONDS);
                 assertTrue("Byte arrays are not equal.", Arrays.equals(serverByteArray, buf));
             }

         } finally {
             transportClient.close();
         }
    }

    
    @Test
    public void sendClientToServerException() throws Exception {
        final int TEST_SIZE = 5;

        final AtomicBoolean gotSSE = new AtomicBoolean(false);

        server.testCode = new TestCode() {

            public void serverSide(SocketChannel s) throws Exception {
                TransportServerV2 fsTransportServer = new TransportServerV2(s, true);
                DataInputStream din = new DataInputStream(
                    fsTransportServer.inputStream());

                byte[] buf = new byte[TEST_SIZE];
                din.readFully(buf);

                try {
                    din.read();
                    assertTrue("Should not have reached here.", false);
                } catch (ServerSideException sse) {
                    // Good.
                    gotSSE.set(true);
                } finally {
                    fsTransportServer.doneWithMethod();
                }
            }
        };

        Thread t = new Thread(server, "singleByte");
        t.setDaemon(true);
        t.start();

        server.waitForServerStart();

        TransportClientV2 transportClient = null;
        try {
            transportClient = new TransportClientV2(this.localAddress);
            transportClient.startMethod();
            OutputStream out = transportClient.outputStream();

            for (int i = 0; i < TEST_SIZE; i++) {
                out.write(1);
            }

            out.flush();

            transportClient.sendThrowable(new Exception("Blah"));
        } finally {
            transportClient.close();
        }

        server.waitForServerDone();
        assertTrue("Did not get correct exception.", gotSSE.get());
    }

    @Test
    public void sendServerToClientException() throws Exception {
        server.testCode = new TestCode() {

            public void serverSide(SocketChannel s) throws Exception {
                TransportServerV2 fsTransportServer = new TransportServerV2(s, true);
                OutputStream out = fsTransportServer.outputStream();
                
                out.write(0);
                fsTransportServer.sendThrowable(new SpecialTestException("Yea!"));
            }
        };
        
        Thread t = new Thread(server, "sendServerToClientException");
        t.setDaemon(true);
        t.start();

        server.waitForServerStart();

        TransportClientV2 transportClient = null;
        try {
            transportClient = new TransportClientV2(this.localAddress);
            transportClient.startMethod();
           
            DataInputStream in = new DataInputStream(transportClient.inputStream());
            byte[] buffer = new byte[2];
            in.readFully(buffer);
            assertFalse("Should not have reached here.", true);
        } catch (ServerSideException sse) {
            assertTrue(sse.getCause() instanceof SpecialTestException);
        } finally {
            transportClient.close();
        }
    }
    
    
    public static final class SpecialTestException extends RuntimeException {
        /**
         * 
         */
        private static final long serialVersionUID = 1L;

        public SpecialTestException() {
            
        }
        
        public SpecialTestException(String msg) {
            super(msg);
        }
    }
    
    @Test
    public void serverLosesSynchronizationWithClient() throws Exception {
        server.testCode = new TestCode() {

            public void serverSide(SocketChannel s) throws Exception {
                TransportServerV2 fsTransportServer = new TransportServerV2(s, true);
                OutputStream out = fsTransportServer.outputStream();
                
                out.write(0);
                fsTransportServer.doneWithMethod();
                out.write(0);
            }
        };
        
        Thread t = new Thread(server, "serverLosesSynchronizationWithClient");
        t.setDaemon(true);
        t.start();

        server.waitForServerStart();
        
        TransportClientV2 transportClient = null;
        try {
            transportClient = new TransportClientV2(this.localAddress);
            transportClient.startMethod();
           
            InputStream in = transportClient.inputStream();
            in.read();
            assertTrue(true);
            in.read();
            assertTrue("should not have reached here", false);
        } catch (ClientSideException ex) {
            //OK
        }
    }
    
    @Test
    public void clientLosesSyncrhonizationWithServer() throws Exception {
        server.testCode = new TestCode() {

            public void serverSide(SocketChannel s) throws Exception {
                TransportServerV2 fsTransportServer = new TransportServerV2(s, true);
                OutputStream out = fsTransportServer.outputStream();
                
                out.write(0);
                fsTransportServer.doneWithMethod();
                out.write(0);
            }
        };
        
        Thread t = new Thread(server, "serverLosesSynchronizationWithClient");
        t.setDaemon(true);
        t.start();

        server.waitForServerStart();
        
        TransportClientV2 transportClient = null;
        try {
            transportClient = new TransportClientV2(this.localAddress);
            transportClient.startMethod();
            
            InputStream in = transportClient.inputStream();
            in.read();
            assertTrue(true);
            transportClient.startMethod();
            transportClient.startMethod();
            in.read();
            assertTrue("should not have reached here", false);
        } catch (IOException e) {
            //OK
        }
    }
    @Test
    public void sendFile() throws Exception {
        final int FILE_BYTES = 1024 * 1024;
        final File testFile = createFile(FILE_BYTES);
        
        server.testCode = new TestCode() {

            public void serverSide(SocketChannel s) throws Exception {
                TransportServerV2 fsTransportServer = new TransportServerV2(s, true);
                fsTransportServer.initConnection();
                InputStream in = fsTransportServer.inputStream();
                if (in.read() == -1) {
                    throw new IOException("disconnected");
                }
                
                RandomAccessFile raf = new RandomAccessFile(testFile, "r");
                fsTransportServer.sendFile(raf.getChannel(), 0, raf.length());
                raf.close();
                fsTransportServer.doneWithMethod();
            }

        };

        Thread t = new Thread(server, "singleByte");
        t.setDaemon(true);
        t.start();

        server.waitForServerStart();
        File outputFile = new File(testDir, "out");
        TransportClientV2 transportClient = null;
        try {
            transportClient = new TransportClientV2(this.localAddress);
            transportClient.startMethod();
            transportClient.outputStream().write(42);
            RandomAccessFile raf = new RandomAccessFile(outputFile, "rw");
            transportClient.receiveFile(raf.getChannel(), 0, FILE_BYTES);
            raf.close();
        } finally {
            transportClient.close();
        }

        byte[] expectedBytes = FileUtils.readFileToByteArray(testFile);
        byte[] actualBytes = FileUtils.readFileToByteArray(outputFile);
        
        assertTrue(Arrays.equals(expectedBytes, actualBytes));
    }

    private File createFile(final int FILE_BYTES) throws FileNotFoundException,
            IOException {
        final File testFile = new File(testDir, "test");
        BufferedOutputStream bout = new BufferedOutputStream(
            new FileOutputStream(testFile));

        for (int i = 1; i <= FILE_BYTES; i++) {
            bout.write(fileContents.nextInt());
        }
        bout.close();
        return testFile;
    }

    @Test
    public void transportRandomReadWrite() throws Exception {
        final int NMESSAGES = 200;

        final BlockingQueue<Integer> messageSizeQueue = new ArrayBlockingQueue<Integer>(
            2);
        final BlockingQueue<byte[]> received = new ArrayBlockingQueue<byte[]>(2);
        final AtomicInteger messageCount = new AtomicInteger(0);

        server.testCode = new TestCode() {

            public void serverSide(SocketChannel s) throws Exception {
                TransportServerV2 fsTransport = new TransportServerV2(s, true);
                DataInputStream din = new DataInputStream(
                    fsTransport.inputStream());

                while (true) {
                    int nextSize = messageSizeQueue.take();
                    if (nextSize == -1) {
                        break;
                    }

                    messageCount.incrementAndGet();

                    byte[] buf = new byte[nextSize];
                    din.readFully(buf);
                    received.add(buf);
                }
            }
        };

        Thread t = new Thread(server, "transportRandomReadWrite");
        t.setDaemon(true);
        t.start();

        server.waitForServerStart();

        TransportClientV2 client = new TransportClientV2(new InetSocketAddress(
            "localhost", LISTEN_PORT_NO));
        client.startMethod();
        OutputStream ostr = client.outputStream();

        byte sendMessageValue = 0;
        Random random = new Random(0);
        for (int i = 0; i < NMESSAGES; i++) {
            if (server.serverError.get() != null) {
                AssertionError ae = new AssertionError();
                ae.initCause(server.serverError.get());
                throw ae;
            }
            int nBytes = random.nextInt(ProtocolVersion.PROTOCOL_V2.maxMessageSize() * 2) + 1;
            byte[] buf = new byte[nBytes];
            Arrays.fill(buf, sendMessageValue);
            messageSizeQueue.put(buf.length);
            ostr.write(buf);
            ostr.flush();

            byte[] fromServer = received.poll(2, TimeUnit.SECONDS);
            assertTrue("Server timedout.", fromServer != null);
            assertTrue("Bytes must be equal.", Arrays.equals(buf, fromServer));
        }

        messageSizeQueue.add(-1);

    }

    private void compatibityTest(final TransportWrapper client,
            final TransportServerWrapperFactory serverFactory) throws Exception {
        
        final byte EXPECTED_BYTE = (byte) 0xa2;
        final byte[] EXPECTED_BYTE_ARRAY = new byte[1024*1024*5];
        final int FILE_LEN = ProtocolVersion.PROTOCOL_V1.maxMessageSize() * 2;
        final File destFile = new File(testDir, "dest");
        Random rand = new Random(434543);
        rand.nextBytes(EXPECTED_BYTE_ARRAY);
        
        server.testCode = new TestCode() {

            public void serverSide(SocketChannel s) throws Exception {
                TransportWrapper transportServer = serverFactory.makeServer(s);
                DataInputStream in = new DataInputStream(transportServer.inputStream());
                int gotByte = in.read();
                OutputStream out = transportServer.outputStream();
                out.write(gotByte);
                byte[] gotBytes = new byte[EXPECTED_BYTE_ARRAY.length];
                in.readFully(gotBytes);
                out.write(gotBytes);
                try {
                    in.read();
                    out.write(0);
                } catch (ServerSideException sse) {
                    out.write(34);
                }
                RandomAccessFile dest = new RandomAccessFile(destFile, "rw");
                transportServer.receiveFile(dest.getChannel(), 0, FILE_LEN);
                dest.close();
            }
        };
        
        Thread t = new Thread(server, "compatibility v2 server");
        t.setDaemon(true);
        t.start();

        server.waitForServerStart();

        
        OutputStream ostr = client.outputStream();
        DataInputStream istr = new DataInputStream(client.inputStream());
        ostr.write(EXPECTED_BYTE);
        byte roundTripByte = (byte) istr.read();
        assertEquals(EXPECTED_BYTE, roundTripByte);
        ostr.write(EXPECTED_BYTE_ARRAY);
        byte[] roundTripByteArray = new byte[EXPECTED_BYTE_ARRAY.length];
        istr.readFully(roundTripByteArray);
        assertTrue("Arrays must be equals.", Arrays.equals(roundTripByteArray, EXPECTED_BYTE_ARRAY));
        client.sendThrowable(new Exception("X"));
        assertEquals(34, istr.read());
        final File testFile = createFile(FILE_LEN);
        RandomAccessFile clientRaf = new RandomAccessFile(testFile, "rw");
        client.sendFile(clientRaf.getChannel(), 0, testFile.length());
        clientRaf.close();
        Thread.sleep(1000);
        assertTrue("File contents must be equals.", FileUtils.contentEquals(testFile, destFile));
        
    }
    
    @Test
    public void compatibilityV1ClientWithV2Server() throws Exception {
        TransportServerWrapperFactory serverFactory = 
            new TransportServerWrapperFactory() {

                @Override
                public TransportWrapper makeServer(SocketChannel s) throws IOException {
                    final TransportServerV2 serverv2 = new TransportServerV2(s, true);
                    return new TransportWrapper() {
                        
                        @Override
                        public void sendThrowable(Throwable t) throws IOException {
                            serverv2.sendThrowable(t);
                        }
                        
                        @Override
                        public void sendFile(FileChannel src, long startPos, long count)
                                throws IOException {
                            serverv2.sendFile(src, startPos, count);
                            
                        }
                        
                        @Override
                        public void receiveFile(FileChannel dest, long destStart, long count)
                                throws IOException {
                            serverv2.receiveFile(dest, destStart, count);
                        }
                        
                        @Override
                        public OutputStream outputStream() throws IOException, TransportException {
                            return serverv2.outputStream();
                        }
                        
                        @Override
                        public InputStream inputStream() throws IOException, TransportException {
                            return serverv2.inputStream();
                        }
                    };
                }
        };
        
        final TransportClientV1 clientv1 = 
        		new TransportClientV1(new InetSocketAddress(
                "localhost", LISTEN_PORT_NO));
        
        TransportWrapper clientv1Wrapper = new TransportWrapper() {
            
            @Override
            public void sendThrowable(Throwable t) throws IOException {
                clientv1.sendThrowable(t);
            }
            
            @Override
            public void sendFile(FileChannel src, long startPos, long count)
                    throws IOException {
                clientv1.sendFile(src, startPos, count);
            }
            
            @Override
            public void receiveFile(FileChannel dest, long destStart, long count)
                    throws IOException {
                clientv1.receiveFile(dest, destStart, count);
            }
            
            @Override
            public OutputStream outputStream() throws IOException, TransportException {
                return clientv1.outputStream();
            }
            
            @Override
            public InputStream inputStream() throws IOException, TransportException {
                return clientv1.inputStream();
            }
        };
        compatibityTest(clientv1Wrapper, serverFactory);
    }
    
    
    @Test
    public void compatibilityV2ClientWithV1Server() throws Exception {
        TransportServerWrapperFactory serverFactory = 
            new TransportServerWrapperFactory() {

                @Override
                public TransportWrapper makeServer(SocketChannel s) throws IOException {
                    final TransportServerV1 serverv1 = new TransportServerV1(s, true);
                    return new TransportWrapper() {
                        
                        @Override
                        public void sendThrowable(Throwable t) throws IOException {
                            serverv1.sendThrowable(t);
                        }
                        
                        @Override
                        public void sendFile(FileChannel src, long startPos, long count)
                                throws IOException {
                            serverv1.sendFile(src, startPos, count);
                            
                        }
                        
                        @Override
                        public void receiveFile(FileChannel dest, long destStart, long count)
                                throws IOException {
                            serverv1.receiveFile(dest, destStart, count);
                        }
                        
                        @Override
                        public OutputStream outputStream() throws IOException, TransportException {
                            return serverv1.outputStream();
                        }
                        
                        @Override
                        public InputStream inputStream() throws IOException, TransportException {
                            return serverv1.inputStream();
                        }
                    };
                }
        };
        
        final TransportClientV2 clientv2 =
            new TransportClientV2(new InetSocketAddress("localhost", LISTEN_PORT_NO));
        
        TransportWrapper clientv2Wrapper = new TransportWrapper() {
            
            @Override
            public void sendThrowable(Throwable t) throws IOException {
                clientv2.sendThrowable(t);
            }
            
            @Override
            public void sendFile(FileChannel src, long startPos, long count)
                    throws IOException {
                clientv2.sendFile(src, startPos, count);
            }
            
            @Override
            public void receiveFile(FileChannel dest, long destStart, long count)
                    throws IOException {
                clientv2.receiveFile(dest, destStart, count);
            }
            
            @Override
            public OutputStream outputStream() throws IOException, TransportException {
                return clientv2.outputStream();
            }
            
            @Override
            public InputStream inputStream() throws IOException, TransportException {
                return clientv2.inputStream();
            }
        };
        compatibityTest(clientv2Wrapper, serverFactory);
    }
    
   
    
    private interface TestCode {
        void serverSide(SocketChannel s) throws Exception;
    }

    //I'm not having V1 and V2 implement an interface because they should not
    //have such dependencies on each other.  Also I would like the original code
    //to remain the original code.
    private interface TransportWrapper {
        OutputStream outputStream() throws IOException, TransportException;
        InputStream inputStream() throws IOException, TransportException;
        void sendFile(FileChannel src, long startPos, long count)
            throws IOException;
        void receiveFile(FileChannel dest, long destStart, long count)
            throws IOException;
        public void sendThrowable(Throwable t) throws IOException;
        
    }
    
    private interface TransportServerWrapperFactory {
        TransportWrapper makeServer(SocketChannel s) throws IOException;
    }
    
    private final class Server implements Runnable {

        ServerSocketChannel serverChannel;
        TestCode testCode;
        final AtomicReference<Throwable> serverError = new AtomicReference<Throwable>();
        final CountDownLatch started = new CountDownLatch(1);
        final CountDownLatch done = new CountDownLatch(1);

        Server() {
        }

        void waitForServerStart() throws Exception {
            if (!started.await(1, TimeUnit.MINUTES)) {
                throw new Exception("Wait timedout.");
            }
            if (serverError.get() != null) {
                AssertionError ae = new AssertionError("Server error.");
                ae.initCause(serverError.get());
                throw ae;
            }
        }

        void waitForServerDone() throws Exception {
            if (!done.await(5, TimeUnit.MINUTES)) {
                throw new Exception("Wait timedout.");
            }
            if (serverError.get() != null) {
                AssertionError ae = new AssertionError("Server error.");
                ae.initCause(serverError.get());
                throw ae;
            }
        }

        public void run() {

            SocketChannel acceptChannel = null;
            try {
                serverChannel = ServerSocketChannel.open();
                ServerSocket serverSocket = serverChannel.socket();
                serverSocket.setSoTimeout(0);
                serverSocket.setReuseAddress(true);
                serverSocket.bind(localAddress);
                started.countDown();
                acceptChannel = serverChannel.accept();

                testCode.serverSide(acceptChannel);
            } catch (Throwable t) {
                serverError.compareAndSet(null, t);
                log.error("Server side error.", t);
                if (started.getCount() != 0L) {
                    started.countDown();
                }
            } finally {
                try {
                    acceptChannel.close();
                } catch (IOException e) {
                    log.error("kjdfk", e);
                }
                try {
                    serverChannel.close();
                } catch (IOException e) {
                    log.error("3434", e);
                }
                done.countDown();
            }
        }

    }

}
