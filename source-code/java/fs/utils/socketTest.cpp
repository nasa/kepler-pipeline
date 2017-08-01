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

#include <iostream>
#include <pthread.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <sys/socket.h>

using namespace std;

class Semaphore {
private:
  int count;
  pthread_mutex_t mutex;
  pthread_cond_t cond;
public:
  Semaphore(int initialValue) : 
    count(initialValue) {
    pthread_mutex_init(&mutex, 0);
    pthread_cond_init(&cond, 0);
  }

  void up() {
    pthread_mutex_lock(&mutex);
    count++;
    pthread_cond_signal(&cond);
    pthread_mutex_unlock(&mutex);
  }

  void down() {
    pthread_mutex_lock(&mutex);
    while (count <= 0) {
      //cout << "Waiting." << endl;
      pthread_cond_wait(&cond, &mutex);
    }
    count--;
    pthread_mutex_unlock(&mutex);
  }

  int currentCount() const {
    return count;
  }

  ~Semaphore() {
    pthread_mutex_destroy(&mutex);
  }
};

class ConnectorParams {
private:
  int runCount;
  struct sockaddr_in& addr;
  Semaphore& sem;
public:
  ConnectorParams(int runCount_p, struct sockaddr_in& addr_p, Semaphore& sem_p) : 
    runCount(runCount_p), addr(addr_p), sem(sem_p) {}

  int getRunCount() { return runCount; }
  struct sockaddr_in& getAddr() { return addr; }
  void complete() {
    sem.up();
  }
};


void *run(void *voidParams) {
  ConnectorParams * params = reinterpret_cast<ConnectorParams *>(voidParams);

  int sockfd = socket(AF_INET, SOCK_STREAM, 0);
  //cout << "Socket created on fd " << sockfd << endl;
  if (sockfd < 0) {
    cout << "Error" << endl;
    perror("");
    params->complete();
    return 0;
  }

  struct sockaddr_in& addr = params->getAddr();

  int isError = 
    connect(sockfd, reinterpret_cast<struct sockaddr*>(&addr), sizeof(struct sockaddr_in));
  if (isError) {
    perror("");
    cout << "Error." << endl;
    params->complete();
    return 0;
  }
  //cout << "Connected." << endl;

  shutdown(sockfd, SHUT_RDWR);
  //cout << "Shutdown." << endl;
  close(sockfd);
  //cout << "Closed." << endl;  
  params->complete();
}

#define NTHREADS 100

int main(int argc, char** argv) {
  struct sockaddr_in addr;
  addr.sin_family = AF_INET;
  addr.sin_port = htons(46231);
  //143.232.108.198
  addr.sin_addr.s_addr =  (143 ) | ( 232 << 8) | (108 << 16) | ( 198 << 24);

  Semaphore sem(-NTHREADS+1);
  ConnectorParams params(10, addr, sem);

  pthread_t threads[NTHREADS];
  for (int i=0; i < NTHREADS; i++) {
    pthread_create(&threads[i], 0, &run, &params);
  }
  sem.down();
}


