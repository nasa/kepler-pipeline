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
# SCRIPT NAME: update_nas_code.py 
#
# PURPOSE: Updates/verifies code link, matlab link; updates/verifies ~/.bashrc 
#          KEPLER_ROOT and ANT_HOME paths; updates/verifies ~/.modulesbeginenv 
#          ANT_HOME and PATH paths; updates/verifies pleiades-XXX.template user and
#          NFS location; updates/verifies kepler.properties user and NFS location.
#
# USAGE: ./setup_nas_user.py -c [cluster_abbr] -u [user_name] -v [code_version] -h 
#
# RUNS ON: host
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


# START store script parameters
#
p_clusterAbbreviation = ''

p_userName = ''

p_codeVersion = ''
#
# END store script_parameters


# START declare global variables
# These variables are reused in main as needed. They maye be passed as a parameter to a function.
# The values contained therein vary as the script executes and are defined immediately before use.
#
g_optionsList = [] 

g_argumentsList = []

g_option = ''

g_argument = ''


g_codeVersionDir = ''


g_directoryPath = ''

g_matlabLinkPath = ''

g_matlabExecutable = ''

g_codeLinkPath = ''


g_bashRcFilePath = ''

g_modulesBeginEnvFilePath = ''

g_pleiadesClusterTemplateFilePath = ''


g_return_value = None


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
# PURPOSE:    Updates ~/.bashrc file with cluster abbreviation parameter.
# PARAMETERS: p_bashRcFilePath: Path to .bashrc file.
#             p_clusterAbbr:    Cluster abbreviation.
# RETURNS:    Nothing.

def updateBashRcFile(p_bashRcFilePath, p_clusterAbbr):


   l_fileContentsList = []

   l_line = ''


   l_keplerRootRegExp = re.compile(".*KEPLER_ROOT\=.*")

   l_antHomeRegExp = re.compile(".*ANT_HOME\=.*")


   l_clusterAbbrRegExp = re.compile(".*\/" + p_clusterAbbr + "\/.*")


   l_splitStringList = []


   l_string = ''


   i = 0

   j = 0


   l_fileContentsList = \
   [l_line.strip() for l_line in open(p_bashRcFilePath, 'r')]


   for i in range(0, len(l_fileContentsList) - 1):


      if l_keplerRootRegExp.search(l_fileContentsList[i]) \
         or \
         l_antHomeRegExp.search(l_fileContentsList[i]):


         if not l_clusterAbbrRegExp.search(l_fileContentsList[i]):

            l_splitStringList = l_fileContentsList[i].split('/')

            j = 0

            while j < len(l_splitStringList):

               if (j > 0) \
                  and   \
                  (l_splitStringList[j - 1] == 'kepler-soc'):

                  l_splitStringList[j] = p_clusterAbbr

                  j = len(l_splitStringList)

                  l_fileContentsList[i] = '/'.join(l_splitStringList) 

               j = j + 1


   l_outputFile = open(p_bashRcFilePath, 'w')

   for l_line in l_fileContentsList:

      l_outputFile.write(l_line + "\n")

   l_outputFile.close()


   l_string = 'File [' + p_bashRcFilePath + "] updated.\n\n"

   print l_string


# END def updateBashRcFile(p_bashRcFilePath, p_clusterAbbr)
################################################################################



################################################################################
# PURPOSE:    Updates ~/.modulesbeginenv file with cluster abbreviation parameter.
# PARAMETERS: p_modulesBeginEnvFilePath: Path to .modulesbeginenv file.
#             p_clusterAbbr:             Cluster abbreviation.
# RETURNS:    Nothing.

def updateModulesBeginEnvFile(p_modulesBeginEnvFilePath, p_clusterAbbr):


   l_fileContentsList = []

   l_line = ''


   l_clusterRegExp = re.compile("^CLUSTER\=\w+$")


   l_splitStringList = []


   l_string = ''


   i = 0


   l_fileContentsList = \
   [l_line.strip() for l_line in open(p_modulesBeginEnvFilePath, 'r')]


   while i < len(l_fileContentsList):

      if l_clusterRegExp.search(l_fileContentsList[i]):

         l_splitStringList = l_fileContentsList[i].split('=')

         l_splitStringList[1] = p_clusterAbbr;

         l_fileContentsList[i] = '='.join(l_splitStringList)            

         i = len(l_fileContentsList)

      i = i + 1   


   l_outputFile = open(p_modulesBeginEnvFilePath, 'w')

   for l_line in l_fileContentsList:

      l_outputFile.write(l_line + "\n")

   l_outputFile.close()


   l_string = 'File [' + p_modulesBeginEnvFilePath + "] updated.\n\n"

   print l_string


# END def updateModulesBeginEnvFile(p_modulesBeginEnvFilePath, p_clusterAbbr) 
################################################################################



################################################################################
# PURPOSE:    Updates pleiades-XXX.template file with cluster abbreviation parameter.
# PARAMETERS: p_pleiadesClusterTemplateFilePath: Path to pleiades-XXX.template file.
#             p_clusterAbbr:                     Cluster abbreviation.
# RETURNS:    Nothing.

def updatePleiadesClusterTemplateFile(p_pleiadesClusterTemplateFilePath, p_clusterAbbr):


   l_fileContentsList = []

   l_line = ''


   l_piRemoteDistDirRegExp = re.compile("^pi\.remote\.dist\.dir\=.*")

   l_piRemoteStatefileDirRegExp = re.compile("^pi\.remote\.statefile\.dir\=.*")

   l_piRemoteTaskfileDirRegExp = re.compile("^pi\.remote\.taskfile\.dir\=.*")

   l_piWorkerModuleExeMcrRootRegExp = re.compile("^pi\.worker\.moduleExe\.mcrRoot\=.*")


   l_clusterAbbrRegExp = re.compile(".*\/" + p_clusterAbbr + "\/.*")


   l_splitStringList = []


   l_string = ''


   i = 0

   j = 0 


   l_fileContentsList = \
   [l_line.strip() for l_line in open(p_pleiadesClusterTemplateFilePath, 'r')]


   for i in range(0, len(l_fileContentsList) - 1):


      if l_piRemoteDistDirRegExp.search(l_fileContentsList[i])  \
         or \
         l_piRemoteStatefileDirRegExp.search(l_fileContentsList[i])  \
         or \
         l_piRemoteTaskfileDirRegExp.search(l_fileContentsList[i])  \
         or \
         l_piWorkerModuleExeMcrRootRegExp.search(l_fileContentsList[i]): 


         if not l_clusterAbbrRegExp.search(l_fileContentsList[i]):

            l_splitStringList = l_fileContentsList[i].split('/')

            j = 0

            while j < len(l_splitStringList):

               if (j > 0) \
                  and     \
                  (l_splitStringList[j - 1] == 'kepler-soc'):

                  l_splitStringList[j] = p_clusterAbbr

                  j = len(l_splitStringList)

                  l_fileContentsList[i] = '/'.join(l_splitStringList)

               j = j + 1


   l_outputFile = open(p_pleiadesClusterTemplateFilePath, 'w')

   for l_line in l_fileContentsList:

      l_outputFile.write(l_line + "\n")

   l_outputFile.close()
                        

   l_string = 'File [' + p_pleiadesClusterTemplateFilePath + "] updated.\n\n"

   print l_string


# END def updatePleiadesClusterTemplateFile(p_pleiadesClusterTemplateFilePath, p_clusterAbbr)
################################################################################



################################################################################
# PURPOSE:    Updates kepler.properties file with cluster abbreviation parameter.
# PARAMETERS: p_keplerPropertiesFilePath: Path to kepler.properties file.
#             p_clusterAbbr:              Cluster abbreviation.
# RETURNS:    Nothing.

def updateKeplerPropertiesFile(p_keplerPropertiesFilePath, p_clusterAbbr):


   l_fileContentsList = []

   l_line = ''


   l_amcRegExp = re.compile(".*\/AMC\/.*")

   l_labRegExp = re.compile(".*\/LAB\/.*")

   l_spmRegExp = re.compile(".*\/SPM\/.*")

   l_spqRegExp = re.compile(".*\/SPQ\/.*")

   l_testRegExp = re.compile(".*\/TEST\/.*")


   l_splitStringList = []


   l_string = ''


   i = 0

   j = 0


   l_fileContentsList = \
   [l_line.strip() for l_line in open(p_keplerPropertiesFilePath, 'r')]

 
   for i in range(0, len(l_fileContentsList) - 1):

      if l_amcRegExp.search(l_fileContentsList[i]) \
         or \
         l_labRegExp.search(l_fileContentsList[i]) \
         or \
         l_spmRegExp.search(l_fileContentsList[i]) \
         or \
         l_spqRegExp.search(l_fileContentsList[i]) \
         or \
         l_testRegExp.search(l_fileContentsList[i]):


         l_splitStringList = l_fileContentsList[i].split('/')

         j = 0

         while j < len(l_splitStringList):

            if (j > 0) \
               and     \
               ((l_splitStringList[j - 1] == 'kepler-soc') \
                or \
                (l_splitStringList[j - 1] == 'remote-exec')):

               l_splitStringList[j] = p_clusterAbbr

               j = len(l_splitStringList)

               l_fileContentsList[i] = '/'.join(l_splitStringList)

            j = j + 1


   l_outputFile = open(p_keplerPropertiesFilePath, 'w')

   for l_line in l_fileContentsList:

      l_outputFile.write(l_line + "\n")

   l_outputFile.close()


   l_string = 'File [' + p_keplerPropertiesFilePath + "] updated.\n\n"

   print l_string


# END def updateKeplerPropertiesFile(p_keplerPropertiesFilePath, p_clusterAbbr)
################################################################################



################################################################################
# START main


g_string = "\n\n" + sys.argv[0] + " started.\n"

print g_string


try:

   g_optionsList, g_argumentsList = \
   getopt.getopt(sys.argv[1:],"c:hu:v:")

except getopt.GetoptError:

   g_string = "Unknown option found.\n"   + \
              str(sys.argv[0:]) + "\n\n"  + \
              sys.argv[0] + " terminated on error.\n\n"

   print(g_string)

   sys.exit(1)


for g_option, g_argument in g_optionsList:

   if g_option == '-h':

      g_string =    \
      sys.argv[0] + \
      " -c [cluster_abbr] -u [user_name] -v [code_version] -h\n\n" 

      print g_string

      sys.exit(SUCCESS)

   elif g_option == '-c':

      p_clusterAbbreviation = str(g_argument).upper()

   elif g_option == '-u':

      p_userName = g_argument

   elif g_option == '-v':

      p_codeVersion = g_argument

      g_codeVersionDir = 'release-' + p_codeVersion + '-code'

if not p_clusterAbbreviation:

   g_string = \
   "Cluster abbreviation parameter is required.\n\n" + \
   sys.argv[0] + " terminated on error.\n\n"

   print_message_and_exit_script(g_string)


if not p_codeVersion:

   g_string = \
   "Code version parameter is required.\n\n" + \
   sys.argv[0] + " terminated on error.\n\n"

   print_message_and_exit_script(g_string)


if not p_userName:

   g_string = \
   "User name parameter is required.\n\n" + \
   sys.argv[0] + " terminated on error.\n\n"

   print_message_and_exit_script(g_string)


g_directoryPath = '/path/to/' + p_userName + '/kepler-soc'

if not os.path.isdir(g_directoryPath):

   g_string = \
   'Directory path [' + g_directoryPath   + "] does not exist.\n\n" + \
   sys.argv[0] + " terminated on error.\n\n"

   print_message_and_exit_script(g_string)


g_directoryPath = g_directoryPath + '/' + p_clusterAbbreviation + '/'

if not os.path.isdir(g_directoryPath):

   g_string = \
   'Directory path [' + g_directoryPath + "] does not exist.\n\n" + \
   sys.argv[0] + " terminated on error.\n\n"

   print_message_and_exit_script(g_string)


g_svnPath = '/path/to/' + p_userName + '/kepler-soc/' + p_clusterAbbreviation + '/'

g_codeVersionDir = g_svnPath + g_codeVersionDir

g_command = 'svn co svn+ssh://' + p_userName + \
            '@host/path/' + p_codeVersion + ' ' + g_codeVersionDir 

if os.system(g_command) != SUCCESS:

   g_string = \
   'Unable to execute command [' + g_command + "].\n\n" + \
   sys.argv[0] + " terminated on error.\n\n"

   print_message_and_exit_script(g_string)

g_string = 'Code version [' + p_codeVersion + '] downloaded to [' + g_codeVersionDir + "].\n\n"

print g_string


g_codeLinkPath = g_svnPath + 'code'

g_command = 'unlink ' + g_codeLinkPath

if os.path.exists(g_codeLinkPath) \
   and \
   os.system(g_command) != SUCCESS:

   g_string = \
   'Unable to execute command [' + g_command + "].\n\n" + \
   sys.argv[0] + " terminated on error.\n\n"

   print_message_and_exit_script(g_string)

g_string = 'Link [' + g_codeLinkPath + "] deleted.\n\n"

print g_string


g_command = 'ln -s ' + g_codeVersionDir + ' ' + g_codeLinkPath

if os.system(g_command) != SUCCESS:

   g_string = \
   'Unable to execute command [' + g_command + "].\n\n" + \
   sys.argv[0] + " terminated on error.\n\n"

   print_message_and_exit_script(g_string)

g_string = 'Link [' + g_codeLinkPath + '] linked to directory [' + g_codeVersionDir + "].\n\n"

print g_string


g_matlabLinkPath = '/u/' + p_userName + '/matlab/startup.m'

g_command = 'unlink ' + g_matlabLinkPath

if os.path.exists(g_matlabLinkPath) \
   and \
   os.system(g_command) != SUCCESS:

   g_string = \
   'Unable to execute command [' + g_command + "].\n\n" + \
   sys.argv[0] + " terminated on error.\n\n"

   print_message_and_exit_script(g_string)

g_string = 'Link [' + g_matlabLinkPath + "] deleted.\n\n"

print g_string


g_matlabExecutable = '/path/to/' + p_userName + '/kepler-soc/' + \
                     p_clusterAbbreviation + '/matlab/build/matlab-init/soc_startup.m'

g_command = 'ln -s ' + g_matlabExecutable + ' ' + g_matlabLinkPath

g_return_value = os.system(g_command)

if (g_return_value != SUCCESS):

   g_string = \
   'Unable to execute command [' + g_command + "].\n\n" + \
   sys.argv[0] + " terminated on error.\n\n"

   print_message_and_exit_script(g_string)

g_string = 'Link [' + g_matlabLinkPath + '] linked to executable file [' + g_matlabExecutable + "].\n\n"

print g_string 
 

g_bashRcFilePath = '/u/' + p_userName + '/.bashrc'

updateBashRcFile(g_bashRcFilePath, p_clusterAbbreviation)


g_modulesBeginEnvFilePath = '/u/' + p_userName + '/.modulesbeginenv'

updateModulesBeginEnvFile(g_modulesBeginEnvFilePath, p_clusterAbbreviation)


g_pleiadesClusterTemplateFilePath =      \
'/path/to/' + p_userName +          \
'/kepler-soc/' + p_clusterAbbreviation + \
'/skel/etc/pleiades-' + p_clusterAbbreviation + '.template'

updatePleiadesClusterTemplateFile(g_pleiadesClusterTemplateFilePath, p_clusterAbbreviation)


g_keplerPropertiesFilePath =             \
'/path/to/' + p_userName +          \
'/kepler-soc/' + p_clusterAbbreviation + \
'/skel/etc/kepler.properties'

updateKeplerPropertiesFile(g_keplerPropertiesFilePath, p_clusterAbbreviation)


g_string = sys.argv[0] + " terminated on SUCCESS.\n\n"

print g_string


sys.exit(SUCCESS)


# END main
################################################################################
