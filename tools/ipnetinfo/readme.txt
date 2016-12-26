


IPNetInfo v1.74
Copyright (c) 2004 - 2016 Nir Sofer
Web site: http://www.nirsoft.net



Description
===========

IPNetInfo is a small utility that allows you to easily find all available
information about an IP address: The owner of the IP address, the
country/state name, IP addresses range, contact information (address,
phone, fax, and email), and more.

This utility can be very useful for finding the origin of unsolicited
mail. You can simply copy the message headers from your email software
and paste them into IPNetInfo utility. IPNetInfo automatically extracts
all IP addresses from the message headers, and displays the information
about these IP addresses.



How does it work ?
==================

The IP address information is retrieved by sending a request to the whois
server of ARIN. If ARIN doesn't maintain the information about the
requested IP address, a second request is sent to the whois server of
RIPE, APNIC, LACNIC or AfriNIC.
After the IP address information is retrieved, IPNetInfo analyzes the
Whois record and displays it in a table.

Notice: From time to time, the WHOIS server of ARIN is down and doesn't
respond to WHOIS requests from IPNetInfo, and thus IPNetinfo fails to
retrieve the IP address. When such a thing occurs, simply try again later.



Retrieving the message headers from your email client
=====================================================

If you don't know how to get the message headers from your email client,
this web site can help you - it provides detailed explanation about how
to get the message headers in each email client.



Versions History
================


* Version 1.74:
  o Fixed to detect the country of whois.registro.br records as
    Brazil.

* Version 1.73:
  o Updated to detect the 'org-name' field as owner name in RIPE
    queries.

* Version 1.72:
  o Fixed the IP addresses text-box in 'Choose IP Addresses' window
    to handle Ctrl+A (Select All).

* Version 1.71:
  o Added new option: 'Add -B to RIPE and AFRINIC queries, for
    showing email addresses'. In previous versions, IPNetInfo added the
    -B flag only to the RIPE queries, now it's added to both RIPE and
    AFRINIC, and you have an option to turn it off.

* Version 1.70:
  o Added option to choose the WHOIS server that IPNetInfo will use.

* Version 1.66:
  o IPNetInfo now displays the result as failed if 'access denied
    for' message is detected (For RIPE queries).

* Version 1.65:
  o Added 'Auto Size Columns On Update' option.

* Version 1.63:
  o Added 'Postal Code' column (For ARIN IP addresses).

* Version 1.62:
  o Fixed bug: IPNetInfo failed to display the 'Resolved Name' column
    when 'Resolve IP addresses' option was turned on.

* Version 1.61:
  o Empty WHOIS responses are now considered as failed.
  o Fixed IPNetInfo to detect RIPE IP addresses blocks reassigned
    back to ARIN.

* Version 1.60:
  o Added support for SOCKS4 and SOCKS5 proxy (Options -> Proxy
    Settings). Be aware that user/password authentication is currently
    not supported.

* Version 1.56:
  o The 'IP Address' column is now sorted numerically.

* Version 1.55:
  o Added 'Automatically retry failed queries' option.

* Version 1.53:
  o Added 'Show Choose IP Window On Start' option. You can turn off
    this option if you don't want that the 'Choose IP Address' window
    will be opened every time that you start IPNetInfo.

* Version 1.52:
  o Updated the internal countries file (The original countries file
    was generated on 2004, and some countries were missing...)

* Version 1.51:
  o Added new option to the 'Choose IP Addresses' window: Don't
    filter duplicate IP addresses.

* Version 1.50:
  o Added 'CIDR' column.

* Version 1.45:
  o IPNetInfo now displays the result as failed if 'Query rate limit
    exceeded' message is detected.
  o Added 'Mark Odd/Even Rows' option, under the View menu. When it's
    turned on, the odd and even rows are displayed in different color, to
    make it easier to read a single line.
  o Added 'Auto Size Columns+Headers' option, which allows you to
    automatically resize the columns according to the row values and
    column headers.

* Version 1.40:
  o IPNetInfo now remembers that last size and position of the
    'Choose IP Addresses' window.
  o Fixed the 'Detect IPv6 addresses' check-box to move with all
    other fields when resizing the 'Choose IP Addresses' window.

* Version 1.37:
  o Updated the internal IANA IP assignment table, for using the
    correct WHOIS server, according to the first byte of the IP address.

* Version 1.36:
  o Fixed issue with ARIN queries: For query result containing more
    than one IP range, IPNetInfo displayed the wrong network details in
    the upper table.

* Version 1.35:
  o Added 'Detect IPv6 addresses' option. When it's turned on, you
    can type valid IPv6 addresses, and IPNetInfo will display the
    information about these IPv6 address blocks.

* Version 1.30:
  o Added 'Retry Failed Queries' (F7) option, which allows you to
    send WHOIS queries again for the items with 'failed' status. You can
    also use this option to continue the session that you stopped with
    'Stop Retrieving Data' option.

* Version 1.27:
  o Added Alt+O Accelerator Key (Ok button) on the 'Choose IP
    Addresses' dialog-box.

* Version 1.26:
  o Fixed issue: The text-box of IP addresses was limited to 32 KB.

* Version 1.25:
  o When you select multiple items in the upper pane, the lower pane
    will now display the raw text returned from the WHOIS servers of all
    selected items. (In previous versions, the lower pane was empty when
    multiple items were selected in the upper pane)

* Version 1.24:
  o Fixed issue: IPNetInfo now automatically scrolls the text of the
    bottom pane to the top when a new WHOIS record is retrieved.

* Version 1.23:
  o Fixed IPNetInfo to work with the changes made in ARIN WHOIS
    server.

* Version 1.22:
  o Fixed issue: for some networks, IPNetInfo displayed the wrong IP
    address owner name.

* Version 1.21:
  o Fixed bug: IPNetInfo displayed an empty owner name when the first
    'desc' line of the WHOIS record was empty.

* Version 1.20:
  o Fixed a problem with 151.*.*.* addresses.

* Version 1.19:
  o Fixed bug: IPNetInfo created the .cfg file in the wrong folder
    when one of the parent folders contained a dot character.

* Version 1.18:
  o The 'Choose IP Addresses' dialog-box is now resizable.

* Version 1.17:
  o Fixed bug: IPNetInfo crashed in some systems.

* Version 1.16:
  o Added support for launching IPNetInfo from CurrPorts without
    displaying the main dialog-box.

* Version 1.15:
  o New option: Automatically use the right server according to IP
    address. If this option is selected, IPNetInfo automatically detect
    the right WHOIS server according to the IP address. In previous
    versions, IPNetInfo always sent the first query to ARIN, and if it
    was a non-US address, it sent a second query to the right WHOIS
    server. This means that getting information for non-US IP address
    will work faster than before. For example, if the IP address begins
    with 194 (194.x.x.x), IPNetInfo will automatically send the query to
    the RIPE WHOIS server.

* Version 1.11:
  o Fixed bug: The main window lost the focus when the user switched
    to another application and then returned back to IPNetInfo.

* Version 1.10:
  o Added 'Show Tooltips' option.
  o Added 'Show My Current IP Address' option - it automatically
    opens a Web page from NirSoft Web site that displays your current IP
    address. You can copy this address and paste it into IPNetInfo
    utility, and get all information about your IP address.
  o The configuration of IPNetInfo is now saved into a cfg file
    instead of the Registry.

* Version 1.09:
  o Added -B option in ripe.net queries, to avoid the default data
    filtering.

* Version 1.08:
  o New option: Resolve IP Addresses.

* Version 1.07:
  o New option: pause for X seocnds after retrieving Y IP addresses.

* Version 1.06:
  o Added command-line support.
  o Integration with CurrPorts utility.

* Version 1.05: Added support for AfriNIC IP Addresses.
* Version 1.04: Added support for Windows XP visual styles.
* Version 1.03: Fixed bug: garbage characters appeared in the 'Host
  Name' column.
* Version 1.02:
  o Ability to extract the host name from a Web address. For example:
    If you type 'http://www.nirsoft.net/utils', IPNetInfo will extract
    the information about the IP address of www.nirsoft.net (Only when
    'Convert host names to IP addresses' is checked)
  o When the host name that you typed is converted to IP address, the
    original host name will be displayed under the 'Host Name' column
    (Only when 'Convert host names to IP addresses' is checked)

* Version 1.01: Fixed small bug: IP addresses appears in email format
  (email@IPAddress) are now parsed properly.
* Version 1.00: First Release.



System Requirements
===================


* Windows operating system: Any version of Windows, starting from
  Windows 98 and up to Windows 10
* Internet connection.
* On a firewall, you should allow outgoing connections to port 43.



Using IPNetInfo
===============

IPNetInfo is standalone program, so it doesn't require any installation
process or additional DLLs. In order to start using it, simply copy the
executable file (ipnetinfo.exe) to any folder you like, and run it.

When you run IPNetInfo, the "Choose IP Addresses" window appears. You
have to type one or more IP addresses separated by comma, space, or CRLF
characters. If you want to find the origin of email message that you
received, copy the entire message header to the clipboard, and then click
the "Paste" button.
You can also use the following advanced options:
* Resolve IP addresses: If you select this option, all IP addresses are
  converted back to the host name. The resolved host name is displayed in
  'Resolved Name' column.
* Convert host names to IP addresses: If you select this option, all
  host names that you type will be converted to IP addresses. You can use
  this option if you want to know who owns the IP address of specific Web
  site (For example: If you type 'www.yahoo.com', you'll get the
  information about the IP address of Yahoo Web site)
  You should not select this option for message headers.
* Load only the last IP address: In most email messages, the last IP
  address in the message headers is the address of the computer that sent
  the message. So if you select this option for message headers, you'll
  get the desired IP address in most cases (but not in all of them !).
  However, for finding the origin of unsolicited mail, it's not
  recommended to use this option, because many spammers add fake headers
  and IP addresses in order to deceive the user who tries to trace them.
  When you try to trace the origin of unsolicited mail, you should
  examine all IP addresses that appears in the message headers.

After choosing the desired options and IP addresses, click the 'OK'
button in order to start retrieving the IP addresses information.
After the data is retrieved, the upper pane displays a nice summary of
all IP addresses that you requested, including the owner name, country,
network name, IP addresses range, contact information, and more. You can
view this summary in your browser as HTML report, copy it to the
clipboard, or save it as text/HTML/XML file.
When you click a particular item in the upper pane, the lower pane
displays the original WHOIS record. You can copy the original WHOIS
records to the clipboard, or save them to text file by using "Save Whois
Records" option.

Notice: The IP addresses summary in the upper pane displays only partial
information, If you want to contact the owner of IP address for reporting
about spam/abuse problems, you should also look at the full Whois record
in the lower pane.



Non-Public IP Addresses
=======================

IPNetInfo always ignores the following special IP address blocks, because
they are not used as public Internet addresses:
* 10.0.0.0 - 10.255.255.255
* 127.0.0.0 - 127.255.255.255
* 169.254.0.0 - 169.254.255.255
* 172.16.0.0 - 172.31.255.255
* 192.168.0.0 - 192.168.255.255
* 224.0.0.0 - 239.255.255.255



Command-Line Options
====================



/ipfile <Filename>
Load IP addresses from the specified file.
For example:
ipnetinfo.exe /ipfile "c:\temp\ip-list.txt"

/ip <IP Address>
Load IPNetInfo with the specified IP address.
For example:
ipnetinfo.exe /ip 216.239.59.103



Translating IPNetInfo to other languages
========================================

IPNetInfo allows you to easily translate all menus, dialog-boxes, and
other strings to other languages.
In order to do that, follow the instructions below:
1. Run IPNetInfo with /savelangfile parameter:
   ipnetinfo.exe /savelangfile
   A file named ipnetinfo_lng.ini will be created in the folder of
   IPNetInfo utility.
2. Open the created language file in Notepad or in any other text
   editor.
3. Translate all menus, dialog-boxes, and string entries to the
   desired language. Optionally, you can also add your name and/or a link
   to your Web site. (TranslatorName and TranslatorURL values) If you add
   this information, it'll be used in the 'About' window.
4. After you finish the translation, Run IPNetInfo, and all translated
   strings will be loaded from the language file.
   If you want to run IPNetInfo without the translation, simply rename
   the language file, or move it to another folder.


License
=======

This utility is released as freeware. You are allowed to freely
distribute this utility via floppy disk, CD-ROM, Internet, or in any
other way, as long as you don't charge anything for this. If you
distribute this utility, you must include all files in the distribution
package, without any modification !



Disclaimer
==========

The software is provided "AS IS" without any warranty, either expressed
or implied, including, but not limited to, the implied warranties of
merchantability and fitness for a particular purpose. The author will not
be liable for any special, incidental, consequential or indirect damages
due to loss of data or any other reason.



Feedback
========

If you have any problem, suggestion, comment, or you found a bug in my
utility, you can send a message to nirsofer@yahoo.com
