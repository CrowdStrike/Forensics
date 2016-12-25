' This script parses the W3C log files for the default web site, finds the ip addresses
'  of all the clients sending NIMDA requests and adds these ip addresses to the list 
'  of denied IP addresses for the web site.

DIM nSiteID     : nSiteID = 1

DIM IPs         : IPs = ARRAY(0)

DIM objLogQuery : SET objLogQuery = WScript.CreateObject("MSUtil.LogQuery")

DIM recordSet

DIM SelectStr 


 
' Get the distinct IP addresses sending NIMDA requests and store them in an array

SelectStr = "SELECT DISTINCT c-ip FROM <" & nSiteID & "> WHERE "

SelectStr = SelectStr & "cs-uri-stem LIKE '%cmd.exe%' OR cs-uri-stem LIKE '%root.exe%'"

SET recordSet=objLogQuery.Execute(SelectStr)

DO WHILE NOT recordset.atEnd

      IF recordSet.GetRecord().isNull(0) = FALSE THEN

            REDIM PRESERVE IPs(UBOUND(IPs)+1)

            IPs(UBOUND(IPs)-1) = recordSet.GetRecord().getValue(0)

      END IF

      recordset.MoveNext

LOOP

recordSet.close




IF UBOUND(IPs) > 0 THEN 

      WScript.Echo("Blocking the following IP addresses:")

      FOR t=0 TO UBOUND(IPs)-1

            WScript.Echo "IP: " & IPs(t)

      NEXT


      'Get the already blocked IP addresses

      DIM BlockedIPs : BlockedIPs = GetBlockedIPs

 

      'Block the non-blocked IP addresses

      FOR t=0 TO UBOUND(IPs)-1

        IF IsIn(IPs(t), BlockedIPs) = FALSE THEN

            REDIM PRESERVE BlockedIPs(UBOUND(BlockedIPs)+1)

            BlockedIPs(UBOUND(BlockedIPs))=IPs(t) & ", 255.255.255.255"
         
        END IF 

      NEXT 

      IF UBOUND(BlockedIPs) > 0 THEN

          BlockIPs(BlockedIPs)

      END IF

ELSE

      WScript.Echo("No IP addresses to block")

END IF

WScript.Quit

 

' This function returns an array of all the IP addresses currently denied 

FUNCTION GetBlockedIPs()

      DIM rootObj : SET rootObj = GetObject("IIS://localhost/W3SVC/" & nSiteID & "/Root")

      DIM ipSecObj : SET ipSecObj = rootObj.IPSecurity

      GetBlockedIPs = ipSecObj.IPDeny

END FUNCTION

 

' This function adds each IP address in the argument array to the list of IP addresses to deny access from

FUNCTION BlockIPs(IPAddresses)

      DIM rootObj : SET rootObj =  GetObject("IIS://localhost/W3SVC/1/Root")

      DIM ipSecObj : SET ipSecObj = rootObj.IPSecurity

      ipSecObj.GrantByDefault = TRUE

      ipSecObj.IPDeny = IPAddresses

      rootObj.IPSecurity = ipSecObj

      rootObj.SetInfo

END FUNCTION

 


' This function returns TRUE if the specified element is in the specified array

FUNCTION IsIn(element, arrayObj)

      if UBOUND(arrayObj) = -1 THEN

            IsIn = FALSE

      END IF

      FOR i=0 TO UBOUND(arrayObj)

            DIM IPs 

            IPs = Split(arrayObj(i),",")

            IF IPs(0)=element THEN

                  IsIn = TRUE

                  EXIT FUNCTION

            END IF

      NEXT

      IsIn = FALSE

END FUNCTION


 

