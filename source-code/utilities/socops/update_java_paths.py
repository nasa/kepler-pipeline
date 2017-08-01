#!/usr/bin/python
# 
# Copyright 2017 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration.
# All Rights Reserved.
# 
# This file is available under the terms of the NASA Open Source Agreement
# (NOSA). You should have received a copy of this agreement with the
# Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
# 
# No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
# WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
# INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
# WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
# INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
# FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
# TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
# CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
# OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
# OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
# FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
# REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
# AND DISTRIBUTES IT "AS IS."
#
# Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
# AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
# SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
# THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
# EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
# PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
# SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
# STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
# PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
# REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
# TERMINATION OF THIS AGREEMENT.
#


################################################################################
# SCRIPT NAME: update_java_paths.hpy 
#
# PURPOSE: Updates java executables in ~/.bashrc, ~/.modulesbeginenv, and 
#          /path/to/dist/bin/nas-build.sh
#
# RUNS ON: host
# 
# USAGE: ./set_java_paths.py -c [cluster_abbreviation] -j [java_version] -u [user_name] -h
#
# Author: Jean-Pierre Harrison jean-pierre.harrison@nasa.gov
#
################################################################################


import sys, getopt, re, io, time, os, pdb

from datetime import date


# START set constants
#
SUCCESS = 0

FAIL = 1
#
# END set constants


# START script parameters
#
p_userName = ''

p_javaVersion = ''

p_clusterAbbreviation = ''
#
# END script_parameters


# START declare global variables
# These are variables used as needed for assignment and use. 
# The values contained therein vary as the script executes and defined immediately before use.
#
g_optionsList = [] 

g_argumentsList = []

g_option = ''

g_argument = ''


g_directoryPath = ''


g_homeDirectoryPath = ''


g_bashRcFilePath = ''

g_modulesBeginEnvFilePath = ''

g_nasBuildFilePath = ''

g_string = ''

i = 0;
#
# END declare global variables


################################################################################
# PURPOSE:    Prints message and terminates script with FAIL value.
# PARAMETERS: p_string: Message to print.
# RETURNS:    Nothing.

def print_message_and_exit_script(p_string):

   print p_string

   sys.exit(FAIL)

# END def print_message_and_exit_script(p_string)
################################################################################
 


################################################################################
# PURPOSE:    Updates ~/.bashrc file with java version parameter.
# PARAMETERS: p_bashRcFilePath: Path to .bashrc file.
#             p_versionJava:    Java version.
# RETURNS:    Nothing.

def updateBashRcFile(p_bashRcFilePath, p_versionJava):


   l_fileContentsList = []

   l_line = ''

   l_regExp = "^module\s+add\s+jvm\/.*" 

   l_jvmRegExp = re.compile(l_regExp)

   l_splitStringList = []


   l_string = ''


   i = 0

   j = 0


   l_fileContentsList = \
   [l_line.strip() for l_line in open(p_bashRcFilePath, 'r')]


   while i < len(l_fileContentsList):

      if l_jvmRegExp.search(l_fileContentsList[i]):

         l_splitStringList = l_fileContentsList[i].split('/')

         l_splitStringList[1] = p_versionJava 

         l_fileContentsList[i] = '/'.join(l_splitStringList) 

      i = i + 1


   l_outputFile = open(p_bashRcFilePath, 'w')

   for l_line in l_fileContentsList:

      l_outputFile.write(l_line + "\n")

   l_outputFile.close()


   l_string = 'File [' + p_bashRcFilePath + "] updated.\n\n"

   print l_string


# END def updateBashRcFile(p_bashRcFilePath, p_versionJava)
################################################################################



################################################################################
# PURPOSE:    Updates ~/.modulesbeginenv file with java version parameter.
# PARAMETERS: p_modulesBeginEnvFilePath: Path to .modulesbeginenv file.
#             p_versionJava:             Java version.
# RETURNS:    Nothing.

def updateModulesBeginEnvFile(p_modulesBeginEnvFilePath, p_versionJava):


   l_fileContentsList = []

   l_line = ''


   l_regExp = ".*jdk\d+\.(\d+)\.\d+_\d+$"

   l_regexpMatch = \
   re.search(l_regExp, p_versionJava)

   l_version_number = l_regexpMatch.group(1)


   l_regExp = "^\#?JAVA_HOME\=.*$"

   l_javaHomeRegExp = re.compile(l_regExp)


   l_regExp = "^\#?JAVA_HOME\=\/nasa\/sun\/jvm\/" + l_version_number + "[a-z]+\d+\/.*$"

   l_javaHomeFullPathRegExp = re.compile(l_regExp)


   l_regExp = "^" + l_version_number + "[a-z]\d+$"

   l_alphaNumRegExp = re.compile(l_regExp)


   l_splitStringList = []


   l_string = ''


   i = 0

   j = 0


   l_fileContentsList = \
   [l_line.strip() for l_line in open(p_modulesBeginEnvFilePath, 'r')]


   while i < len(l_fileContentsList):

      if l_javaHomeRegExp.search(l_fileContentsList[i]):
      
         if l_javaHomeFullPathRegExp.search(l_fileContentsList[i]):
 
            while l_fileContentsList[i][:1] == '#':

               l_fileContentsList[i] = l_fileContentsList[i][1:] 

            l_splitStringList = l_fileContentsList[i].split('/')

            j = 0

            while j < len(l_splitStringList):

               if ((j > 0) \
                   and     \
                   l_alphaNumRegExp.search(l_splitStringList[j - 1])):
                

                  l_splitStringList[j] = p_versionJava   

                  while (l_splitStringList[-1] == ''):

                     l_splitStringList.pop()

                  j = len(l_splitStringList)

                  l_fileContentsList[i] = '/'.join(l_splitStringList)

               j = j + 1

         elif l_fileContentsList[i][:1] != '#':       

            l_fileContentsList[i] = '#' + l_fileContentsList[i]

      i = i + 1   


   l_outputFile = open(p_modulesBeginEnvFilePath, 'w')

   for l_line in l_fileContentsList:

      l_outputFile.write(l_line + "\n")

   l_outputFile.close()


   l_string = 'File [' + p_modulesBeginEnvFilePath + "] updated.\n\n"

   print l_string


# END def updateModulesBeginEnvFile(p_modulesBeginEnvFilePath, p_versionJava) 
################################################################################



################################################################################
# PURPOSE:    Updates nas-build.sh file with java version parameter.
# PARAMETERS: p_nasBuildFilePath: Path to nas-build.sh file.
#             p_versionJava:      Java version.
# RETURNS:    Nothing.

def updateNasBuildFile(p_nasBuildFilePath, p_versionJava):

   l_fileContentsList = []

   l_line = ''


   l_regExp = "^module\s+add\s+jvm/.*$"

   l_javaRegExp = re.compile(l_regExp)


   l_splitStringList = []


   l_string = ''


   i = 0

   j = 0


   l_fileContentsList = \
   [l_line.strip() for l_line in open(p_nasBuildFilePath, 'r')]


   while i < len(l_fileContentsList):

      if l_javaRegExp.search(l_fileContentsList[i]): 

         l_splitStringList = l_fileContentsList[i].split('/') 

         j = 0

         while j < len(l_splitStringList):

            if ((j > 0) \
                and     \
                l_splitStringList[j - 1] == 'module add jvm'):

               l_splitStringList[j] = p_versionJava

               while (l_splitStringList[-1] == ''):

                  l_splitStringList.pop()

               j = len(l_splitStringList)

               l_fileContentsList[i] = '/'.join(l_splitStringList)

            j = j + 1

      i = i + 1


   l_outputFile = open(p_nasBuildFilePath, 'w')

   for l_line in l_fileContentsList:

      l_outputFile.write(l_line + "\n")

   l_outputFile.close()


   l_string = 'File [' + p_nasBuildFilePath + "] updated.\n\n"

   print l_string


# END def updateNasBuildFile(p_nasBuildFilePath, p_versionJava) 
################################################################################



################################################################################
# START main


g_string = "\n\n" + sys.argv[0] + " started.\n"

print g_string


try:

   g_optionsList, g_argumentsList = \
   getopt.getopt(sys.argv[1:],"c:hj:u:")

except getopt.GetoptError:

   g_string = "Unknown option found.\n"   + \
              str(sys.argv[0:]) + "\n\n"  + \
              sys.argv[0] + " terminated on error.\n\n"

   print(g_string)

   sys.exit(1)


for g_option, g_argument in g_optionsList:

   if g_option == '-c':

      p_clusterAbbreviation = g_argument   

   elif g_option == '-h':

      g_string =    \
      sys.argv[0] + \
      " -c [cluster_abbreviation] -j [java_version] -u [user_name] -h\n\n" 

      print g_string

      sys.exit(SUCCESS)

   elif g_option == '-j':

      p_javaVersion = g_argument

   elif g_option == '-u':

      p_userName = g_argument



if not p_clusterAbbreviation:

   g_string = \
   "Cluster abbreviation parameter is required.\n\n" + \
   sys.argv[0] + " terminated on error.\n\n"

   print_message_and_exit_script(g_string)


if not p_javaVersion:

   g_string = \
   "Java version parameter is required.\n\n" + \
   sys.argv[0] + " terminated on error.\n\n"

   print_message_and_exit_script(g_string)


if not p_userName:

   g_string = \
   "User name parameter is required.\n\n" + \
   sys.argv[0] + " terminated on error.\n\n"

   print_message_and_exit_script(g_string)


g_homeDirectoryPath = '/u/' + p_userName

if not os.path.isdir(g_homeDirectoryPath):

   g_string = \
   'Home directory path [' + g_homeDirectoryPath  + "] does not exist.\n\n" + \
   sys.argv[0] + " terminated on error.\n\n"

   print_message_and_exit_script(g_string)


g_bashRcFilePath = g_homeDirectoryPath + '/.bashrc'

updateBashRcFile(g_bashRcFilePath, p_javaVersion)


g_modulesBeginEnvFilePath = g_homeDirectoryPath + '/.modulesbeginenv'

updateModulesBeginEnvFile(g_modulesBeginEnvFilePath, p_javaVersion)


g_nasBuildFilePath = '/path/to/' + p_userName + '/kepler-soc/' + p_clusterAbbreviation + '/path/to/dist/bin/nas-build.sh'

updateNasBuildFile(g_nasBuildFilePath, p_javaVersion)


g_string = sys.argv[0] + " terminated on SUCCESS.\n\n"

print g_string


sys.exit(SUCCESS)


# END main
################################################################################
