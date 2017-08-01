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
# SCRIPT NAME: calculate_total_sbus_used.py 
#
# RUNS ON: host
#
# PURPOSE: CalculatesKepler/K2 SBUs used by task number(s) and/or start/end dates. 
#          
# USAGE: calculate_totalSBUs_used.py -b [startDate in format MM/DD/YY] -e [endDate in format MM/DD/YY] -m [startTaskNumber] -n [endTaskNumber] -u [userName] -h
#        All options use default values if not provided. 
#
# Author: Jean-Pierre Harrison jean-pierre.harrison@nasa.gov
#
################################################################################


import sys, getopt, re, io, time, os, getpass, pdb

from datetime import date


# START set constants
#
DELIMITER = '|'

DATE_INDEX = 4

SBU_INDEX = 8

JOB_NAME_INDEX = 9

DAY = 'DAY'

MONTH = 'MONTH'

YEAR = 'YEAR'

SUCCESS = 0

FAIL = 1
#
# END set constants


# START store script parameters
#
p_endDate = ''

p_endTask = ''

p_inputFilePath = None

p_startDate = ''

p_startTaskNumber = 0

p_endTaskNumber = 0

p_agencyID = ''
#
# END store script_parameters


# START declare global variables
# These are used in the main routine, but 
# may be passed as parameters to a function.
#
g_acctQueryFilePath = ''

g_optionsList = [] 

g_argumentsList = []

g_option = ''

g_argument = ''

g_command = ''

g_startDateComponentsHash = {}

g_endDateComponentsHash = {}

g_startDateNumber = ''

g_endDateNumber = ''

g_acctQueryOutput = ''

g_fileContentsList = []

g_line = ''

g_delimitedRecordsList = []

g_totalSBUs = 0


g_numberOfDaysPerMonthHash = {  1 : 31,
                                2 : 28,
                                3 : 31,
                                4 : 30,
                                5 : 31,
                                6 : 30,
                                7 : 31,
                                8 : 31,
                                9 : 30,
                               10 : 31,
                               11 : 30,
                               12 : 31 }


g_string = ''


i = 0

j = 0
#
# END declare global variables



################################################################################
# PURPOSE:    Terminates script if correct date format of MM/DD/YY not found.
# PARAMETERS: p_date: Date.
# RETURNS:    Correct date format.

def checkDateFormat(p_date):


   l_string = ''

   l_dateRegExp = re.compile("^\d{2}\/\d{2}\/\d{2}$")


   if not l_dateRegExp.search(p_date):

      l_string = \
      "Date must be in MM/DD/YY format.\n\n" + \
      sys.argv[0] + " terminated on error.\n\n"

      print l_string

      sys.exit(FAIL) 


   return p_date


# END def checkDateFormat(p_date)
################################################################################



################################################################################
# PURPOSE:     Creates hash containing DAY:digit, MONTH:digit, YEAR:digit.
# PARAMETERS:  p_date: Date in MM/DD/YY format.
# RETURNS:     Returns hash containing DAY:digit, MONTH:digit, YEAR:digit.

def getDateComponents(p_date):


   l_regexpMatch = \
   re.search("^(\d{2})\/(\d{2})\/(\d{2})$", p_date)

   l_month = l_regexpMatch.group(1)

   l_day = l_regexpMatch.group(2)

   l_year = l_regexpMatch.group(3)

   l_return_hash = \
   {DAY : int(l_day), MONTH : int(l_month), YEAR : int(l_year)}


   return l_return_hash


# END def getDateComponents(p_date)
################################################################################



################################################################################
# PURPOSE:    Checks if start date is less than/equal to end date.
# PARAMETERS: p_dateStart: Start date.
#             p_dateEnd: End date.
# RETURNS:    True if start date is less than/equal to end date, else False. 

def isValidDateRange(p_dateStart, p_dateEnd):


   l_dateStartHash = {} 

   l_dateEndHash = {}

   l_isValidDates = True


   if p_dateStart and p_dateEnd:


      l_dateStartHash = \
      getDateComponents(p_dateStart)

      l_dateEndHash = \
      getDateComponents(p_dateEnd) 


      if ((l_dateStartHash[MONTH] > l_dateEndHash[MONTH]) \
          or \
          ((l_dateStartHash[MONTH] == l_dateEndHash[MONTH]) \
           and \
           (l_dateStartHash[DAY] > l_dateEndHash[DAY])) \
          or \
          (l_dateStartHash[YEAR] > l_dateEndHash[YEAR])):

         l_isValidDates = False


   return l_isValidDates


# END def isValidDateRange(p_dateStart, p_dateEnd)
################################################################################



################################################################################
# PURPOSE:    Checks if two dates are equal.
# PARAMETERS: p_date1: Date in MM/DD/YY format.
#             p_date2: Date in MM/DD/YY format.
# RETURNS:    True if dates match, otherwise False.

def isMatchingDates(p_date1, p_date2):


   l_dateHash1 = getDateComponents(p_date1)

   l_dateHash2 = getDateComponents(p_date2)


   l_isMatchingDates = False


   if ((l_dateHash1[MONTH] == l_dateHash2[MONTH]) \
        and \
       (l_dateHash1[DAY] == l_dateHash2[DAY]) \
        and \
       (l_dateHash1[YEAR] == l_dateHash2[YEAR])):

      l_isMatchingDates = True


   return l_isMatchingDates


# END def isMatchingDates(p_date1, p_date2)
################################################################################



################################################################################
# PURPOSE:    Coverts date to number of day of a year.
# PARAMETERS: p_date: date in MM/DD/YY format.
# RETURNS:    Number representing day of a year.

def convertDateToNumber(p_date):


   l_dateComponentsHash = getDateComponents(p_date)

   l_numberDays = 0   

   i = 0
   

   l_numberDays = l_dateComponentsHash[DAY] 

   
   for i in range(1, l_dateComponentsHash[MONTH]):

      l_numberDays = \
      l_numberDays + g_numberOfDaysPerMonthHash[i]


   if (((l_dateComponentsHash[YEAR] % 4) == 0) \
        and \
        (l_dateComponentsHash[MONTH] >= 2)):

      l_numberDays = l_numberDays + 1


   return l_numberDays


# END def convertDateToNumber(p_date)
################################################################################



################################################################################
# PURPOSE:    Checks that a record date is between a start date and end date.
# PARAMETERS: p_startDateNumber:  Number representing day of a year.
#             p_endDateNumber:    Number representing day of a year.
#             p_recordDateNumber: Number representing day of a year.
# RETURNS:    True if record date is between start date and end date, else False.

def isInDateRange(p_startDateNumber, p_endDateNumber, p_recordDateNumber):


   l_isValidDate = False


   if ((p_startDateNumber and p_endDateNumber) \
       and \
       (p_startDateNumber != 0) \
       and \
       (p_endDateNumber != 0)):

      if ((p_recordDateNumber >= p_startDateNumber) \
          and \
          (p_recordDateNumber <= p_endDateNumber)):

         l_isValidDate = True


   elif ((p_startDateNumber and not p_endDateNumber) \
          and \
         (p_startDateNumber != 0)):

      if (p_recordDateNumber >= p_startDateNumber):

         l_isValidDate = True


   elif ((p_endDateNumber and not p_startDateNumber) \
         and \
         (p_endDateNumber != 0)):

      if (p_recordDateNumber <= p_endDateNumber):

         l_isValidDate = True


   return l_isValidDate


# END def isInDateRange(p_startDateNumber, p_endDateNumber, p_recordDateNumber)
################################################################################



################################################################################
# PURPOSE:    Retrieves structured SBU data from list containing file data. 
# PARAMETERS: p_fileContentsList: File data,
# RETURNS:    List containing delimited file sbu data.

def retrieveStructuredData(p_fileContentsList):


   l_line = ''

   l_regexpMatch = None


   l_endeavourRegExp = re.compile("^endeavour_\w+\s+.*")

   l_meropeRegExp = re.compile("^merope_\w+\s+.*")

   l_pleiadesRegExp = re.compile("^pleiades_\w+\s+.*")

   l_jobRecordRegExp = re.compile("^JOB\s+Record:.*")

   l_stringRegExp = re.compile("^\w+.*$")

   l_jobRecordDate = ''


   l_client = ''

   l_user = ''

   l_project = ''

   l_queue = ''

   l_date = ''

   l_wall_time = ''

   l_num_cpus = ''

   l_sbu = ''

   l_hours = ''

   l_job_name = ''


   l_string = ''


   l_return_list = []

   for l_line in p_fileContentsList:

      l_string = ''

      if (l_endeavourRegExp.search(l_line) \
          or \
          l_meropeRegExp.search(l_line) \
          or \
          l_pleiadesRegExp.search(l_line) \
          or \
          l_jobRecordRegExp.search(l_line)):
     

         l_regexpMatch = \
         re.search("^JOB\s+Record:\s+(\d{2})\/(\d{2})\/(\d{2})\s*$", l_line)

         if l_regexpMatch:

            l_jobRecordDate = \
            l_regexpMatch.group(1) + '/' + \
            l_regexpMatch.group(2) + '/' + \
            l_regexpMatch.group(3)

         else:

            l_regexpMatch = \
            re.search("^(.+?)\s+(\w+)\s+(.+?)\s+(.+?)\s+(\d+\/\d+)\s+(\d+\:\d+)\s+(\d+\.\d+)\s+(\d+)\s+(\d+\.\d+)\s+(.+?)$", l_line)

            if l_regexpMatch:

               l_client = l_regexpMatch.group(1)

               l_user = l_regexpMatch.group(2)

               l_project = l_regexpMatch.group(3)

               l_queue = l_regexpMatch.group(4) 

               l_date = l_jobRecordDate

               l_wall_time = l_regexpMatch.group(6)

               l_num_cpus = l_regexpMatch.group(7)

               l_sbu = l_regexpMatch.group(8) 

               l_hours = l_regexpMatch.group(9) 

               l_job_name = l_regexpMatch.group(10)


               l_string = l_client + DELIMITER + \
                          l_user + DELIMITER + \
                          l_project + DELIMITER + \
                          l_queue + DELIMITER + \
                          l_date + DELIMITER + \
                          l_wall_time + DELIMITER + \
                          l_num_cpus + DELIMITER + \
                          l_sbu + DELIMITER + \
                          l_hours + DELIMITER + \
                          l_job_name

            l_regexpMatch = \
            l_stringRegExp.search(l_string)

            if l_regexpMatch:

               l_return_list.append(l_string)


   return l_return_list


# END retrieveStructuredData(p_fileContentsList)
################################################################################



################################################################################
# PURPOSE:    Calculates SBUs used corresponding to start/end task numbers and/or start/end dates.
# PARAMETERS: p_delimitedRecordsList: List containing delimited SBU usage records.
#             p_taskStart:            Start task number.
#             p_taskEnd:              End task number.
#             p_dateStart:            Start date.
#             p_dateEnd:              End date.
# RETURNS:    Total SBUs used.

def calculateSBUs(p_delimitedRecordsList, p_taskStart, p_taskEnd, p_dateStart, p_dateEnd):

 
   l_digitsRegExp = re.compile("^\d+$")

   l_startTaskRegExp = None

   l_endTaskRegExp = None

   l_dateRegExp = re.compile("^\d{2}\/\d{2}\/\d{2}$")

   l_regexpMatch = None


   l_record = ''

   l_recordList = []

   l_jobNameSplitList = []

   l_sbuTotal = 0

   l_record_date = ''
   
   l_dateStartHash = {}

   l_dateEndHash = {}

   l_recordDateHash = {}

   l_dateStartNumber = 0

   l_dateEndNumber = 0

   l_recordDateNumber = 0

   l_jobTaskNumber = 0


   l_isValidDate = False


   l_string = ''


   if p_dateStart:

      l_dateStartHash = getDateComponents(p_dateStart)

      l_dateStartNumber = convertDateToNumber(p_dateStart)


   if p_dateEnd:

      l_dateEndHash = getDateComponents(p_dateEnd)

      l_dateEndNumber = convertDateToNumber(p_dateEnd)


   if ((l_dateStartHash and l_dateEndHash) \
       and \
       (l_dateStartHash[YEAR] < l_dateEndHash[YEAR])):

      l_dateEndNumber = \
      l_dateEndNumber + 365


   try:

      if p_taskStart:

         l_string = '.*' + str(p_taskStart) + '$'

         l_startTaskRegExp = re.compile(l_string) 

   except TypeError:

      None


   try:

      if p_taskEnd:

         l_string = '.*' + str(p_taskEnd) + '$'

         l_endTaskRegExp = re.compile(l_string) 

   except TypeError:

      None


   for l_record in p_delimitedRecordsList:
 
      l_recordList = l_record.split(DELIMITER)

      l_jobNameSplitList = \
      l_recordList[JOB_NAME_INDEX].split('-')

      if l_digitsRegExp.search(l_jobNameSplitList[-1]):

         l_jobTaskNumber = \
         int(l_jobNameSplitList[-1]) 

         l_recordDateNumber = \
         convertDateToNumber(l_recordList[DATE_INDEX])

         l_recordDateHash = \
         getDateComponents(l_recordList[DATE_INDEX])


         if (l_dateEndHash \
             and \
             (l_recordDateHash[YEAR] > l_dateStartHash[YEAR]) \
             and \
             (l_recordDateHash[YEAR] == l_dateEndHash[YEAR])):

            l_recordDateNumber = \
            l_recordDateNumber + 365


         l_isValidDate = \
         isInDateRange(l_dateStartNumber, l_dateEndNumber, l_recordDateNumber)     


         if ((l_isValidDate == True) \
             or \
             ((not l_dateRegExp.search(p_dateStart)) \
              and \
              (not l_dateRegExp.search(p_dateEnd)))):


            if ((p_taskStart > 0) \
                 and \
                (p_taskEnd > 0)):
          
               if ((l_jobTaskNumber >= p_taskStart) \
                    and \
                   (l_jobTaskNumber <= p_taskEnd)):

                  l_sbuTotal = \
                  l_sbuTotal + float(l_recordList[SBU_INDEX])


            elif ((p_taskStart > 0) \
                   and \
                  (p_taskEnd == 0)):

               if (l_jobTaskNumber >= p_taskStart):

                  l_sbuTotal = \
                  l_sbuTotal + float(l_recordList[SBU_INDEX])


            elif ((p_taskStart == 0) \
                   and \
                  (p_taskEnd > 0)):

               if (l_jobTaskNumber <= p_taskEnd):

                  l_sbuTotal = \
                  l_sbuTotal + float(l_recordList[SBU_INDEX])


            elif ((p_taskStart == 0) \
                   and \
                  (p_taskEnd == 0)):

               l_sbuTotal = \
               l_sbuTotal + float(l_recordList[SBU_INDEX])



   return l_sbuTotal


# END def calculateSBUs(p_delimitedRecordsList, p_taskStart, p_taskEnd, p_dateStart, p_dateEnd)
################################################################################



################################################################################
# PURPOSE:    Displays total SBUs used corresponding to task number and date parameters. 
# PARAMETERS: p_sbuTotal:  Total SBUs.
#             p_taskStart: Start task number. 
#             p_taskEnd:   End task number.
#             p_dateStart: Start date.
#             p_dateEnd:   End date.
# RETURNS:    Nothing. 

def displaySBUs(p_sbuTotal, p_taskStart, p_taskEnd, p_dateStart, p_dateEnd):


   l_string = ''

   l_sbuTotal = str(p_sbuTotal)

   l_taskStart = str(p_taskStart)

   l_taskEnd = str(p_taskEnd)

 
   if ((p_taskStart > 0) \
       and \
       (p_taskEnd > 0)):

      l_string = \
      "\n\nTotal SBUs [" + l_sbuTotal + \
      '] : start task [' + l_taskStart + \
      '] : end task [' + l_taskEnd + "]"


   if ((p_taskStart > 0) \
       and \
       (p_taskEnd == 0)):

      l_string = \
      "\n\nTotal SBUs [" + l_sbuTotal + \
      '] : start task [' + l_taskStart + "]"


   if ((p_taskStart == 0) \
       and \
       (p_taskEnd > 0)):

      l_string = \
      "\n\nTotal SBUs [" + l_sbuTotal + \
      '] : end task [' + l_taskEnd + "]"


   if ((p_taskStart == 0) \
       and \
       (p_taskEnd == 0)):

      l_string = \
      "\n\nTotal SBUs [" + l_sbuTotal + "] : all tasks"


   if ((p_dateStart and p_dateEnd) \
        and \
       (p_dateStart != 0) \
        and \
       (p_dateEnd != 0)):

      l_string = \
      l_string + ' : start date [' + p_dateStart + \
      '] : end date [' + p_dateEnd + ']'


   elif ((p_dateStart and not p_dateEnd) \
          and \
         (p_dateStart != 0)):
         
      l_string = \
      l_string + ' : start date [' + p_dateStart + ']'


   elif ((not p_dateStart and p_dateEnd) \
          and \
         (p_dateEnd != 0)):

      l_string = \
      l_string + ' : end date [' + p_dateEnd + ']'


   l_string = l_string + ".\n\n"


   print l_string


# END def displaySBUs(p_sbuTotal, p_taskStart, p_taskEnd, p_dateStart, p_dateEnd)
################################################################################



################################################################################
# START main

g_string = "\n\n" + sys.argv[0] + " started.\n"

print g_string


try:

   g_optionsList, g_argumentsList = \
   getopt.getopt(sys.argv[1:],"b:e:hm:n:u:")

except getopt.GetoptError:

   g_string = "Unknown option found.\n"   + \
              str(sys.argv[0:]) + "\n\n"  + \
              sys.argv[0] + " terminated on error.\n\n"

   print(g_string)

   sys.exit(FAIL)


for g_option, g_argument in g_optionsList:
 
   if g_option == '-b':

      p_startDate = checkDateFormat(g_argument)

   elif g_option == '-e':

      p_endDate = checkDateFormat(g_argument)

   elif g_option == '-h':

      g_string =    \
      sys.argv[0] + \
      ' -i [input_file] -b [startDate MM/DD/YY] -e [endDate MM/DD/YY]' + \
      " -m [startTaskNumber] -n [endTaskNumber] -h\n\n" + \
      "Start date and end date options are required; all other options use default values if not provided.\n\n"

      print g_string

      sys.exit(SUCCESS)

   elif g_option == '-m':

      p_startTaskNumber = int(g_argument)

   elif g_option == '-n':

      p_endTaskNumber = int(g_argument)

   elif g_option == '-u':

      p_agencyID = str(g_argument)


g_acctQueryFilePath = '/u/' + getpass.getuser() + '/acct_query.' + str(time.time())


if ((p_endTaskNumber > 0) \
    and \
    (p_startTaskNumber > p_endTaskNumber)):

   p_startTaskNumber = \
   p_startTaskNumber + p_endTaskNumber

   p_endTaskNumber = \
   p_startTaskNumber - p_endTaskNumber

   p_startTaskNumber = \
   p_startTaskNumber - p_endTaskNumber


if not p_startDate or not p_endDate:

   g_string = \
   "Start date and end date are required.\n\n" + \
   sys.argv[0] + " terminated on error.\n\n" 

   print g_string

   sys.exit(FAIL)


if (p_startDate and p_endDate):

   g_startDateComponentsHash = \
   getDateComponents(p_startDate)

   g_endDateComponentsHash = \
   getDateComponents(p_endDate)


   g_startDateNumber = \
   convertDateToNumber(p_startDate)

   g_endDateNumber = \
   convertDateToNumber(p_endDate)


   if (g_endDateComponentsHash[YEAR] > g_startDateComponentsHash[YEAR]):

      g_endDateNumber = \
      g_endDateNumber + 365


   if (g_startDateNumber > g_endDateNumber):

      g_string = \
      'Start date [' + str(p_startDate) + \
      '] and end date [' + str(p_endDate) + "] are invalid.\n\n" + \
      sys.argv[0] + " terminated on error.\n\n"

      print g_string

      sys.exit(FAIL)


   if p_agencyID:

      g_command = "/usr/local/bin/acct_query -b " + \
                  str(p_startDate) + \
                  " -e " + str(p_endDate) + \
                  " -u " + p_agencyID + \
                  " -o med > " + g_acctQueryFilePath
   else:

      g_command = "/usr/local/bin/acct_query -b " + \
                  str(p_startDate) + \
                  " -e " + str(p_endDate) + \
                  " -u all -p s1089 " + \
                  " -o med > " + g_acctQueryFilePath


else:

   g_command = "/usr/local/bin/acct_query " + \
               " -u " + p_agencyID + \
               " -o med > " + g_acctQueryFilePath


os.system(g_command)


g_fileContentsList = \
[g_line.strip() for g_line in open(g_acctQueryFilePath, 'r')]


g_delimitedRecordsList = \
retrieveStructuredData(g_fileContentsList)


g_totalSBUs = \
calculateSBUs(g_delimitedRecordsList, p_startTaskNumber, p_endTaskNumber, p_startDate, p_endDate)


displaySBUs(g_totalSBUs, p_startTaskNumber, p_endTaskNumber, p_startDate, p_endDate)


g_command = "rm -f " + g_acctQueryFilePath

os.system(g_command)


g_string = sys.argv[0] + " terminated on SUCCESS.\n\n"

print g_string


sys.exit(SUCCESS)


# END main
################################################################################
