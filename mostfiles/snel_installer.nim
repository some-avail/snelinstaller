
# status: working
# source-machine: ndell-mint19
# source-scripts: none
# author: joris bollen
# script-type: nim
#	birth-date      prog.name				version   update-machine
#	2020-02-13      snel_installer.nim  see var   ndell-mint19


# script-operation:
# simple installer of files
# uses installation-definition-file in which sources and targets are placed
# ---------------------------------------------------
# Format of the installation-definition-file (def-file):
# it contains multiple blocks starting with specific tasks:
# DIRECTORIES TO CREATE
# TARGET-LOCATION AND SOURCE-FILES TO COPY
# EDIT FILE (ADD, DELETE, REPLACE LINES)
# EXECUTE SHELL-COMMANDS - IN ORDER


# Please consult the def-file for addional info.
# ----------------------------------------------------

# ADAP HIS
# implement exception-handling
# substitute another separator-line between blocks instead of empty line
  # like >----------------------------------<
  # so that empty lines can be added to config files
# add command-section
# add an arguments-line,for:
  # linux:set_exe
# add one comment-line per block
# extend EDIT-block with additional options:
  # remove a line
  # prepend a string before a line (like commenting)
  # replace a line


# ADAP NOW


# ADAP FUT
# naming of entries in the defile, like:
  # dir===/somdir
  # line_orientatien==="after"
# functionalize main-code
# implement a dry run mode (instead of def-file-validation)
  # dry run means testing the def-file without making changes.
  # it is not a full validation but it can find some definition-faults.
# create a higher loop in which multiple packages can be installed.
  # use a higer folder for:
    # executable 
    # and higher install-order-config.txt
# add permissions-section
# reverse order = removal of installation
# add def-file validation
# conditional operations
  # create a block for test-variables which can 
  # later be used for conditional operations

#=============================================


var versionfl:float = 2.01
var def_filenamest: string = "install-definition-si.txt"

import os
import strutils
import jo_file_ops


proc yes(question: string): bool =
  echo question, " (y/n)"
  while true:
    case readLine(stdin)
    of "y", "Y", "yes", "Yes": return true
    of "n", "N", "no", "No": return false
    else: echo "Please be clear: yes or no"
  
  
# report status and ask followup-action
echo "\n==============================="
echo "Program Snel_Installer " & $(versionfl) & " is running..."     
echo "Make sure to run snel_installer with sufficient rights."

if yes("Do you want to continue?"):
  echo "continuing..."

else:
  echo "aborting Snel_Installer...goodbye!"
  quit(QuitSuccess)

echo "Opening file: " & def_filenamest

var 
  myfile: File
  blockheadar: array[4, string] = [
      "DIRECTORIES TO CREATE",
      "TARGET-LOCATION AND SOURCE-FILES TO COPY",
      "EDIT FILE (ADD, DELETE, REPLACE LINES)",
      "EXECUTE SHELL-COMMANDS - IN ORDER"]
  blockphasest: string = ""
  blocklineit: int
  blockseparatorst = ">----------------------------------<"
  targetdirpathst: string
  targetfilepathst: string
  sourcefilest: string
  editfileprops:array[6,string]
  ops_paramsq:seq[string] = @[]
  lastline: string
  all_argst: string
  argumentsq: seq[string] = @[]
  linux_setexe: bool= false
  linux_use_sudo: bool = false
  

if open(myfile, def_filenamest):    # try to open the def-file
  try:
    # validate the def-file (skip for now)

    # walk thru the lines of the file
    echo "\n=====Begin processing===="
    for line in myfile.lines:
      lastline = line
      
      # check for block-header
      if line in blockheadar:
        blockphasest = line
        echo "\p" & blockphasest
        blocklineit = 0
      elif blockphasest != "":
      
        blocklineit += 1
        if line != blockseparatorst:   # block-separating string

          if blockphasest == "DIRECTORIES TO CREATE":
            if blocklineit == 1:  # comment-line
              discard
            elif blocklineit == 2:
              # handle arguments
              discard
            else:
              if not existsOrCreateDir(expandTilde(line)):   # proc creates only when non-existent
                echo "creating directory: " & line

          elif blockphasest == "TARGET-LOCATION AND SOURCE-FILES TO COPY":
            if blocklineit == 1:  # comment-line
              discard
            elif blocklineit == 2:
              # handle arguments
              if line != "arguments---none":
                all_argst = line.split("---")[1]
                argumentsq = all_argst.split(",,")
                #echo repr argumentsq
                if jo_file_ops.getValueFromKey(argumentsq, "=", "linux_set_exe") == "1":
                  echo "linux_set_exe = true"
                  linux_setexe = true
                if jo_file_ops.getValueFromKey(argumentsq, "=", "linux_use_sudo") == "1":
                  echo "linux_use_sudo = true"
                  linux_use_sudo = true

            elif blocklineit == 3:
              targetdirpathst = expandTilde(line)
            else:
              sourcefilest = expandTilde(line)
              echo "copying: " & sourcefilest & "   to:   " & targetdirpathst
              targetfilepathst = joinPath(targetdirpathst,sourcefilest)
              copyfile(sourcefilest,targetfilepathst)
              if linux_setexe:
                var prependst:string = ""
                if linux_use_sudo: prependst = "sudo "
                discard execShellCmd(prependst & "chmod +x " & targetfilepathst)

          elif blockphasest == "EDIT FILE (ADD, DELETE, REPLACE LINES)":
            #echo "----edit-test----"
            #echo blocklineit
            
            echo line
            if blocklineit == 1:  # comment-line
              discard
            elif blocklineit == 2:
              # handle arguments
              discard      
            elif blocklineit in 3..8:
              editfileprops[blocklineit - 3]=line
            elif blocklineit > 8:
              if line == "end-of-edit-block-here":
                jo_file_ops.alterTextFile(
                      operationst = editfileprops[0],
                      targetfilepathst = expandTilde(editfileprops[1]), 
                      line_orientationst = editfileprops[5], 
                      locating_stringst = editfileprops[4], 
                      occurit = parseint(editfileprops[3]),
                      directionst = editfileprops[2],
                      operationparamsq = ops_paramsq)
                echo "\p" & editfileprops[0] & " performed on: " & editfileprops[1] & "\p"

              else:
                ops_paramsq.add(line)
          elif blockphasest == "EXECUTE SHELL-COMMANDS - IN ORDER":
            if blocklineit == 1:  # comment-line
              discard
            elif blocklineit == 2:
              # handle arguments
              discard
            else:
              echo "Running command: " & line
              discard execShellCmd(line)

        else:
          # then the former block is completed
          blockphasest = ""
          # set arguments to none:
          linux_setexe = false
          linux_use_sudo = false
          
      
    echo "===End of processing===="
    
  except IOError:
    echo "IO error!"
  
  except RangeDefect:
    echo "\p\p+++++++ search-config not found +++++++++++\p"
    echo "You have probably entered a search-config that could not be found. \p" &
        "Re-examine you search-config. \p" &
        "The problem originated probably in the above EDIT FILE-block"
    let errob = getCurrentException()
    echo "\p******* Technical error-information ******* \p" 
    echo "block-phase: " & blockphasest & "\p"
    echo "Last def-file-line read: " & lastline & "\p"
    echo repr(errob) & "\p****End exception****\p"

  
  except:
    let errob = getCurrentException()
    echo "\p******* Unanticipated error ******* \p" 
    echo "block-phase: " & blockphasest & "\p"
    echo "Last def-file-line read: " & lastline & "\p"
    echo repr(errob) & "\p****End exception****\p"
      
  finally:
    close(myfile)
else:
  echo "Could not open file!"

