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

package gov.nasa.kepler.fs.server;


import static gov.nasa.kepler.fs.FileStoreConstants.*;
import gov.nasa.kepler.common.os.IOChecker;
import gov.nasa.kepler.common.os.IOChecker.Report;
import gov.nasa.kepler.fs.api.MaintenanceInterface;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.fs.perf.PerformanceCounterMBean;
import gov.nasa.kepler.fs.perf.StackDumperPoller;
import gov.nasa.kepler.fs.server.jmx.BTreeMonitoring;
import gov.nasa.kepler.fs.server.jmx.ThrottleMonitoring;
import gov.nasa.kepler.fs.server.jmx.TransactionMonitoring;
import gov.nasa.kepler.fs.server.xfiles.FileTransactionManager;
import gov.nasa.kepler.fs.storage.UserConfigurableFsIdFileSystemLocator;
import gov.nasa.kepler.fs.transport.TransportFactory;
import gov.nasa.kepler.fs.transport.TransportServer;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.services.process.AbstractPipelineProcess;
import gov.nasa.kepler.services.process.ProcessStatusReporter;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.lang.SystemProvider;
import gov.nasa.spiffy.common.metrics.MetricsDumper;
import gov.nasa.spiffy.common.os.OperatingSystemType;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.*;
import java.lang.management.ManagementFactory;
import java.net.BindException;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.MalformedURLException;
import java.net.ServerSocket;
import java.nio.channels.*;
import java.security.NoSuchAlgorithmException;

import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.atomic.*;

import javax.management.MBeanServer;
import javax.management.ObjectName;
import javax.xml.parsers.FactoryConfigurationError;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.jmx.HierarchyDynamicMBean;

/**
 * The file store server.
 * 
 * @author Sean McCauliff
 *
 */
public class Server extends AbstractPipelineProcess implements ShutdownListener {

    public static final String NAME = "File Store";
    private static final Log log = LogFactory.getLog(Server.class);
    private static final int SOCKET_TIMEOUT = 30;
    private static final int THREAD_KEEPALIVE_SEC = 10;

    private final int port;
    private final boolean localonly;


    private final AtomicBoolean isShuttingDown = new AtomicBoolean(false);
       
    private final Map<SocketChannel, FstpHandler> fstpHandlers = 
        Collections.synchronizedMap(new WeakHashMap<SocketChannel, FstpHandler>());
    
    private final Map<SocketChannel, TransportServer> transportServers =
        Collections.synchronizedMap(new WeakHashMap<SocketChannel, TransportServer>());
    
    private Thread mainThread;

    /**
     * Socket channels in this queue are destined to be reregisterd by
     * the listening thread.  This can not be a blocking queue since the
     * listener thread may occasionally put something back on the queue to be
     * processed later.  Making this a blocking queue would cause a deadlock in
     * those cases.
     */
    private Queue<SocketChannel> reregisterQueue = 
        new ConcurrentLinkedQueue<SocketChannel>();
    
    /**
     * When this latch is unlatched then the listening thread has shutdown.
     */
    private final CountDownLatch shutdownReceived = new CountDownLatch(1);

    private final ThreadPoolExecutor clientWorkers;

    private final ThreadGroup serverThreadGroup =
        new ServerThreadGroup();
  
    private final ThrottleInterface throttle;
    private final ServerIdGenerator serverId;
    private StackDumperPoller stackDumper;
    
    private final TransactionalBackend.Factory backendFactory = 
    		new TransactionalBackend.Factory();
    
    
    private final FileTransactionManager.Factory ftmFactory = new FileTransactionManager.Factory();
    
    /**
     * 
     * @param exitOnShutdown When true this will attempt to call system.exit() on
     * shutdown.
     * @param port The listening port.
     * @param localonly Only bind to localhost.
     * @throws NoSuchAlgorithmException 
     * @throws ClassNotFoundException 
     */
    public Server(int port, boolean localonly) 
        throws NoSuchAlgorithmException, ClassNotFoundException {
        super(NAME);

        this.port = port;
        this.localonly = localonly;
        
        this.clientWorkers = setupClientThreadPool();
            
        setupThrottle();
        serverId = new ServerIdGenerator();
        throttle = setupThrottle();
    }


    private static ThrottleInterface setupThrottle() {
        Configuration config = ConfigurationServiceFactory.getInstance();
        int concurrentReadersWriters = 
            config.getInt(FS_SERVER_MAX_CONCURRENT_READ_WRITE, 
                FS_SERVER_MAX_CONCURRENT_READ_WRITE_DEFAULT);
        
        int writeCost = config.getInt(FS_SERVER_PERMITS_PER_WRITE,
                                                     FS_SERVER_PERMITS_PER_WRITE_DEFAULT);
        int readCost = config.getInt(FS_SERVER_PERMITS_PER_READ,
                                                     FS_SERVER_PERMITS_PER_READ_DEFAULT);
        int maxWriters = concurrentReadersWriters / writeCost;
        int maxReaders = concurrentReadersWriters / readCost;
        log.info("Setting max concurrent read/writes permits to " + concurrentReadersWriters);
        log.info("Write cost/max writers " + writeCost + "/" + maxWriters +  
            " read cost/max readers " + readCost + "/" + maxReaders + ".");
        
        return new Throttle(concurrentReadersWriters, readCost, writeCost);
    }


    private static ThreadPoolExecutor setupClientThreadPool() {
        int maxClients = getConfiguredMaxClients();
        BlockingQueue<Runnable> clientQueue = 
            new ArrayBlockingQueue<Runnable>(maxClients, true);

        ThreadFactory threadFactory = new DaemonThreadFactory();

        //Throw an exception if work can not be performed.
        RejectedExecutionHandler rejectPolicy =
            new ThreadPoolExecutor.AbortPolicy();


        ThreadPoolExecutor threadPool =  
            new ThreadPoolExecutor(maxClients, maxClients, THREAD_KEEPALIVE_SEC, 
                TimeUnit.SECONDS, clientQueue, threadFactory, rejectPolicy);
        threadPool.allowCoreThreadTimeOut(true);
        
        return threadPool;
    }
    
    private static int getConfiguredMaxClients() {
        Configuration config = ConfigurationServiceFactory.getInstance();
        return config.getInt(FS_SERVER_MAX_CLIENTS, FS_SERVER_MAX_CLIENTS_DEFAULT);
    }
    
    /**
     * Note that the OS may have decided the the backlog is too large and truncate
     * it to SOMAXCONN which is usually 128 for Linux.
     * @return
     */
    private static int getConfiguredMaxBacklog() {
        Configuration config = ConfigurationServiceFactory.getInstance();
        return config.getInt(FS_SERVER_MAX_SOCKET_BACKLOG, getConfiguredMaxClients() * 2);
    }

    private void checkAopXml() throws IOException {
        InputStream resourceIn = getClass().getResourceAsStream("/META-INF/aop.xml");
        if (resourceIn == null) {
            throw new IllegalStateException("Can't find /META-INF/aop.xml on classpath.");
        }
        resourceIn.close();
    }

    private void checkOsIoScheduler() throws Exception {
        OperatingSystemType osType = OperatingSystemType.getInstance();
        if (osType != OperatingSystemType.LINUX) {
            log.warn("Operating system type is not Linux.  Skipping I/O scheduler check.");
            return;
        }
        final Configuration config = ConfigurationServiceFactory.getInstance();
        boolean ioSchedulerCheckEnabled = config.getBoolean(FS_SERVER_CHECK_IO_SCHEDULERS,
            FS_SERVER_CHECK_IO_SCHEDULERS_DEFAULT);
            
        if (!ioSchedulerCheckEnabled) {
            log.warn("Operating system I/O scheduler check is not enabled." +
                    "  To enable this check set the property " + 
                    FS_SERVER_CHECK_IO_SCHEDULERS + " to true.");
            return;
        }
        
        String internalScheduler = config.getString(FS_SERVER_IO_SCHEDULERS_INTERNAL_SCHEDULER,
            FS_SERVER_IO_SCHEDULERS_INTERNAL_SCHEDULER_DEFAULT);
        int internalReadAheadKb = config.getInt(FS_SERVER_IO_SCHEDULERS_INTERNAL_READ_AHEAD_KB,
            FS_SERVER_IO_SCHEDULERS_INTERNAL_READ_AHEAD_KB_DEFAULT);
        String leafScheduler = config.getString(FS_SERVER_IO_SCHEDULERS_LEAF_SCHEDULER,
            FS_SERVER_IO_SCHEDULERS_LEAF_SCHEDULER_DEFAULT);
        int leafReadAheadKb = config.getInt(FS_SERVER_IO_SCHEDULERS_LEAF_READ_AHEAD_KB,
            FS_SERVER_IO_SCHEDULERS_LEAF_READ_AHEAD_KB_DEFAULT);
        
        File fsDataDir =new File(config.getString(FS_DATA_DIR_PROPERTY, FS_DATA_DIR_DEFAULT));
        final AtomicInteger returnCode = new AtomicInteger(Integer.MAX_VALUE);
        SystemProvider system = new SystemProvider() {
            
            @Override
            public PrintStream out() {
                return System.out;
            }
            
            @Override
            public InputStream in() {
                return null;
            }
            
            @Override
            public String getProperty(String propName) {
                return config.getString(propName);
            }
            
            @Override
            public void exit(int rc) {
                returnCode.set(rc);
            }
            
            @Override
            public PrintStream err() {
                return System.err;
            }
        };
        
        File fileSystemConfigFile =
            new File(fsDataDir, FileTransactionManager.FILE_SYSTEM_ROOT_CONF_FILE_NAME);
        UserConfigurableFsIdFileSystemLocator fileSystemLocator = 
            new UserConfigurableFsIdFileSystemLocator(fileSystemConfigFile, fsDataDir.getCanonicalPath());
        //check all file system where data is stored.
        for (File fileSystemRoot : fileSystemLocator.fileSystemRoots()) {
            IOChecker ioChecker = new IOChecker(system, 
                fileSystemRoot, internalReadAheadKb, leafReadAheadKb, 
                internalScheduler, leafScheduler, true /* dry run */);
            Report report = ioChecker.topDownCheck();
            if (!report.ok) {
                log.fatal("The I/O schedulers that the file system for " + fsDataDir 
                    + " uses are not configured correctly.  The file store server" +
                     " will not perform correctly.  To disable this check set the " +
                     "property \"" + FS_SERVER_CHECK_IO_SCHEDULERS + "\" to false." +
                             "Exiting.");
                log.info("Current configuration (use graphviz's \"dot\" program to visualize).");
                log.info(report.report);
                System.exit(2);
            }
        }
    }
    
    
    /**
     * Starts a server running on the configured port.  This method creates
     * a daemon thread to listen on the incoming socket.
     * @throws Exception 
     *
     */
    public void start() throws Exception {
        checkAopXml();
        
        checkOsIoScheduler();
        
        Configuration config = ConfigurationServiceFactory.getInstance();
        //This has some interesting side effects like running the recovery.
        backendFactory.instance(config, ftmFactory);
        FileTransactionManagerInterface fileTransactionManager = 
            ftmFactory.instance(config);
        
        ServerSocketChannel serverChannel = ServerSocketChannel.open();
        ServerSocket serverSocket= serverChannel.socket();
        serverSocket.setSoTimeout(SOCKET_TIMEOUT);
        serverSocket.setReuseAddress(true);
        serverSocket.setReceiveBufferSize(512*1024);
        serverChannel.configureBlocking(false);
        InetSocketAddress listenAddress = null;
  
        if (localonly) {
            //Not using InetAddress.getLocalAddress() here because it may not
            //return 127.0.0.1, but rather the IP of one of the machine's interfaces.
            InetAddress localAddress = 
                InetAddress.getByAddress(new byte[] {(byte)127, (byte)0, (byte)0, (byte)1 });
            listenAddress = new InetSocketAddress(localAddress, port);
        } else {
            //Bind to all addresses.
            listenAddress = new InetSocketAddress(port);
        }
        
        try {
            serverSocket.bind(listenAddress, getConfiguredMaxBacklog());
        } catch (BindException bindException) {
            throw new BindException("Address \"" + listenAddress + "\" already in use.");
        }
        log.info("File store server bound to address \"" + listenAddress + "\".");
        
        updateProcessState(ProcessStatusReporter.State.RUNNING);
        
        Runtime.getRuntime().addShutdownHook(new ShutdownHook());
        mainThread = 
            new Thread(serverThreadGroup, new ServerListener(serverChannel), "FstpListener");
        mainThread.setDaemon(true);
        mainThread.start();
        
        log.info("Starting File Store MBeans.");
        MBeanServer mbeanServer = ManagementFactory.getPlatformMBeanServer();
        TransactionMonitoring xMonitoring = new TransactionMonitoring(fileTransactionManager);
        ThrottleMonitoring throttleMonitoring = new ThrottleMonitoring(throttle);
        HierarchyDynamicMBean hdmbean = new HierarchyDynamicMBean();
        BTreeMonitoring btreebean = new BTreeMonitoring();
        btreebean.runMetricsPoller();
        PerformanceCounterMBean perfMBean = PerformanceCounterMBean.instance();
        
        ObjectName monitoringName = 
            new ObjectName("gov.nasa.kepler.fs.server.xfiles:type=TransactionMonitoring");
        ObjectName throttleMonitoringName =
            new ObjectName("gov.nasa.kepler.fs.server:type=ThrottleMonitoring");
        ObjectName hdmbeanName = new ObjectName("log4j:type=HierarchyDynamicMBean");
        ObjectName btreeName = 
            new ObjectName("gov.nasa.kepler.fs.server.index.btree:type=BTreeMonitoring");
        ObjectName perfName = 
            new ObjectName("gov.nasa.kepler.fs.server.perf:type=PerformanceCounterMBean");

        mbeanServer.registerMBean(xMonitoring, monitoringName);
        mbeanServer.registerMBean(hdmbean, hdmbeanName);
        mbeanServer.registerMBean(throttleMonitoring, throttleMonitoringName);
        mbeanServer.registerMBean(btreebean, btreeName);
        mbeanServer.registerMBean(perfMBean, perfName);

        long stackDumperPollIntervalMs = 
            config.getInt(FS_SERVER_STACK_DUMPER_POLL_INTERVAL, 
                FS_SERVER_STACK_DUMPER_POLL_INTERVAL_DEFAULT);
        stackDumperPollIntervalMs *= 1000;
       
        String dirName = 
            config.getString(FS_SERVER_STACK_DUMPER_DIR,
            config.getString(FS_DATA_DIR_PROPERTY, FS_DATA_DIR_DEFAULT));
        File outputDir = new File(dirName);
        FileUtil.mkdirs(outputDir);
        
        //Performance monitoring
        stackDumper = new StackDumperPoller(outputDir, stackDumperPollIntervalMs);
        stackDumper.start();
        //TODO:  get the pid from somewhere.
        Thread metricsDumper = new Thread(new MetricsDumper(-1, outputDir));
        metricsDumper.setDaemon(true);
        metricsDumper.setName("Metrics Dumper");
        metricsDumper.start();
    }


    protected ShutdownExecutor shutdownExecutor() {
        return DefaultShutdownExecutor.INSTANCE;
    }
    
    /**
     * Part of ShutdownListener
     */
    public void shutdownStarted() {
        if (this.isShuttingDown.get()) {
            return;
        }
        this.isShuttingDown.set(true);
        for (FstpHandler fstpHandler : fstpHandlers.values()) {
            fstpHandler.shutdown();
        }
        mainThread.interrupt();
        try {
            shutdownReceived.await();
        } catch (InterruptedException e) {
            log.warn("Interrupt while waiting for listening thread to shutdown.", e);
        }
    }

    public static void main(String[] argv) throws Exception {
        if (argv.length != 1) {
            printUsage();
        }

        String command = argv[0];
        if (command.equals("startup")) {
            startupServer();
        } else if (command.equals("shutdown")){
            shutdownServer();
        } else {
            System.err.println("Unrecognized command \"" + command + "\".");
            printUsage();
        }
    }

    private static void printUsage() {
        System.out.println("java gov.nasa.kepler.fs.server.Server <startup | shutdown>");
    }

    private static void startupServer()  throws Exception {

        Configuration configuration = ConfigurationServiceFactory.getInstance();
        int port = configuration.getInt(FS_LISTEN_PORT);
        Server server = new Server( port, false);

        try {
            server.setInitDatabaseService(false);
            server.initialize();
        } catch (PipelineException px) {
            log.warn("Unable to initialize the StatusMessageBroadcaster.");
        } 

        server.start();
        try {
            server.mainThread.join();
        } catch (InterruptedException ie) {
            //ok.
        }
    }

    private static void shutdownServer() 
        throws MalformedURLException,
                      FactoryConfigurationError {
        
        Configuration configuration = ConfigurationServiceFactory.getInstance();
        int port = configuration.getInt(FS_LISTEN_PORT);
        configuration.addProperty(FS_FSTP_URL, "fstp://host:"+port);
        configuration.addProperty(FS_DRIVER_NAME_PROPERTY, "fstp");
        MaintenanceInterface maintence = 
            (MaintenanceInterface) FileStoreClientFactory.getInstance();

        maintence.shutdown();
        System.out.println("File store shutting down.");
    }

    protected Thread getMainThread() {
        return mainThread;
    }

    private static class DaemonThreadFactory implements ThreadFactory {
        private final AtomicInteger threadId = new AtomicInteger(0);

        public Thread newThread(Runnable r) {
            String threadName =  "ClientThread-" + threadId.getAndIncrement(); 
            Thread t = new Thread(r, threadName);
            t.setDaemon(true);
            return t;
        }

    }

    private class ClientTask implements Runnable {
        private final SocketChannel clientChannel;
        private final Selector selector;

        ClientTask(SocketChannel clientChannel, Selector selector) throws IOException {
            this.clientChannel = clientChannel;
            this.selector = selector;
        }

        public InetAddress clientAddress() {
            return clientChannel.socket().getInetAddress();
        }

        public void run() {
            FstpHandler fstpHandler = null;
            try {
                if (fstpHandlers.containsKey(clientChannel)) {
                   fstpHandler = fstpHandlers.get(clientChannel);
                } else {
                    TransportServer transportServer = 
                            TransportFactory.newTransportServer(clientChannel, true);
                    transportServers.put(clientChannel, transportServer);
                    //TODO:  this probably increases the client response time.
                    Configuration configuration = ConfigurationServiceFactory.getInstance();
                    
                    fstpHandler = new FstpHandler(Server.this, shutdownExecutor(), 
                        throttle, serverId, clientAddress(), configuration,
                        backendFactory.instance(configuration, ftmFactory));
                    fstpHandlers.put(clientChannel, fstpHandler);
                }
                
                InetAddress clientAddress = clientAddress();
                String clientName = clientAddress.getCanonicalHostName();
                Thread.currentThread().setName("ST-"+clientName);
                
                TransportServer transportServer = transportServers.get(clientChannel);
                
                boolean anotherMethod = false;
                try {
                    anotherMethod = fstpHandler.processMethod(transportServer, clientAddress);
                } catch (Exception e) {
                    try {
                        transportServer.sendThrowable(e);
                    } catch (Throwable t) {
                        log.error("Failed to send throwable " + e + ".", t);
                    }
                }
                
                if (! anotherMethod) {
                    if (log.isDebugEnabled()) {
                        log.debug("Client \"" + clientAddress + "\" disconnected.");
                    }
                    try {
                        transportServer.close();
                    } catch (Exception e) {
                        //ignore.
                    }
                } else if (clientChannel.isOpen()) {
                    //client is still live.
                    reregisterQueue.add(clientChannel);
                    selector.wakeup();
                    if (log.isDebugEnabled()) {
                        log.debug("Queue client for reregistration with selector.");
                    }
                }
            } catch (Exception e) {
                if (!isShuttingDown.get()) {
                    log.error("Received exception at file store server top level.", e);
                }
            } catch (Throwable t) {
                if (!isShuttingDown.get()) {
                    log.fatal("Received throwable error (not exception)" +
                            " at file store server top level.  Shutting down.", t);
                    fstpHandler.shutdown();
                }
            } finally {
                fstpHandlers.remove(fstpHandler);
            }
        }
    }

    private class ServerListener implements Runnable {

        private final ServerSocketChannel serverChannel;
        /**
         * The selector is used by this thread to choose among all the 
         * connected, but idle clients.  It is also used to wait for accepts.
         */
        private final Selector selector;

        ServerListener(ServerSocketChannel serverChannel) throws IOException {
            this.serverChannel = serverChannel;
            this.selector = Selector.open();
            serverChannel.register(selector, SelectionKey.OP_ACCEPT);
        }

        public void run() {

            log.info("File store server listener thread started.");

            try {
                while (true) {
                    try {
                        if (isShuttingDown.get()) {
                            break;
                        }
                        
                        if (selector.select(10 /* wait ms */) != 0) {

                            Iterator<SelectionKey> it =
                                selector.selectedKeys().iterator();
                            while (it.hasNext()) {
                                SelectionKey readySelectionKey = it.next();
                                it.remove();
                                if (readySelectionKey == null) {
                                    throw new NullPointerException("Ready selection key is null.");
                                }
                                dispatchSelectionKey(readySelectionKey);
                            }
                        }
                        

                        
                        List<SocketChannel> channelsToReregister = new ArrayList<SocketChannel>();
                        while (reregisterQueue.peek() != null) {
                            channelsToReregister.add(reregisterQueue.poll());
                        }
                        for (SocketChannel clientChannel : channelsToReregister) {
                            if (!clientChannel.isOpen()) {
                                continue;
                            }
                            clientChannel.configureBlocking(false);
                            try {
                                clientChannel.register(selector, SelectionKey.OP_READ);
                            } catch (CancelledKeyException cke) {
                               log.warn("Attempt to reregister client failed.", cke);
                               //This can happen if the client request has completed
                               //and before the next select from the selector has happened.
                               //In this case requeue the client connection so
                               //the select can happen.
                               reregisterQueue.add(clientChannel);
                            }
                            if (log.isDebugEnabled()) {
                                log.debug("Reregistered client with selector.");
                            }
                        }

                    } catch (ClosedByInterruptException ie) {
                        if (!isShuttingDown.get()) {
                            log.error("Received interrupted exception at top level.  Shutting down.", ie);
                            break;
                        } else {
                            log.warn("Got interrupted exception on listener thread, but" +
                                    " not shutting down.  Exception will be ignored.");
                        }
                    } catch (Exception e) {
                        log.error("Received exception at file store server top level.", e);
                    } catch (Throwable t) {
                        log.fatal("Received error at file store server top level.  Shutting down.", t);
                        break;
                    } finally {
                        shutdownReceived.countDown();
                    }
                }//while
            } finally {
                clientWorkers.shutdownNow();
                log.info("File store server listener thread exiting.");
            }
        }
        
        private void dispatchSelectionKey(SelectionKey readySelectionKey) throws IOException {
            if (!readySelectionKey.isValid()) {
                return;
            }
            
            if (readySelectionKey.isAcceptable()) {
                log.debug("Found selection key ready for accept.");
                SocketChannel clientChannel = serverChannel.accept();
                clientChannel.socket().setReceiveBufferSize(1024*512);
                clientChannel.socket().setSendBufferSize(1024*512);
                clientChannel.socket().setTcpNoDelay(true);
                clientChannel.socket().setKeepAlive(true);
                clientChannel.configureBlocking(false);
                clientChannel.socket().setSoTimeout(SOCKET_TIMEOUT);
                clientChannel.register(selector, SelectionKey.OP_READ | SelectionKey.OP_WRITE);
            } else if (readySelectionKey.isReadable() || readySelectionKey.isWritable()) {
                //Cancel selection since we are now going to put the
                //socket channel in blocking mode.
                readySelectionKey.cancel();
                log.debug("Found selection key that is readable or writable.");
                SocketChannel clientChannel = 
                    (SocketChannel) readySelectionKey.channel();
                clientChannel.configureBlocking(true);
                ClientTask clientTask = new ClientTask(clientChannel, selector);
                try {
                    clientWorkers.execute(clientTask);
                } catch (RejectedExecutionException full) {
                    log.error("Too many requests to fulfill client : " +
                            clientChannel.socket().getInetAddress(), full);
                    TransportServer transportServer = null;
                    try {
                        transportServer = TransportFactory.newTransportServer(clientChannel, false);
                        transportServer.initConnection();
                    } catch (IOException e) {
                        log.warn("Failed to send exception to client.");
                    } finally {
                        FileUtil.close(clientChannel);
                    }
                }
            }
        }
    }
    
    /**
     * This class is registered as a shutdown hook with the JVM.  In this way
     * we can execute all the shutdown code when the user CTRL-C the
     * application.
     *
     */
    private class ShutdownHook extends Thread {
        ShutdownHook() {
            super("File Store Server Shutdown Hook");
        }
        
        public void run() {
            log.info("Shutdown hook running.");
            shutdownStarted();
            log.info("Waiting for listener thread to exit.");
            try {
                mainThread.join();
            } catch (InterruptedException ie) {
                //ok
            }
            log.info("Shutdown hook thread exiting.");
        }
        
    }
    
    /**
     * This class exists to catch java.lang.Error throwables so that an orderly
     * shutdown can be started.
     */
    private class ServerThreadGroup extends ThreadGroup {

        public ServerThreadGroup() {
            super("File Store Server Thread Group");
        }
        
        public void uncaughtException(Thread t, Throwable e) {
            if (e  instanceof Error) {
                shutdownStarted();
            }
            
            super.uncaughtException(t, e);
        }
    }
}
