%% Microscopy Image Browser Installation
% 
% *Back to* <im_browser_product_page.html *Index*>
%% Run Microscopy Image Browser under Matlab environment
% 
% # Download Matlab distribution of the program (<http://mib.helsinki.fi/web-update/im_browser.zip im_browser.zip>)
% # Unzip and copy im_browser files to |im_browser| directory in your
% |Scripts| folder. For example, |c:\Matlab\Scripts\im_browser\|
% # Start Matlab
% # Add |im_browser| starting directory (for example, |c:\Matlab\Scripts\im_browser\|) into Matlab path
% |Matlab->Home tab->Set path...->Add folder...->Save|, or alternatively use the |pathtool| function from Matlab command window
% # Type |im_browser| in the matlab command window and hit the enter button to start the program
% # Check <im_browser_system_requirements.html System Requirements> for further details about optional
% steps, such as use of <http://fiji.sc/Fiji Fiji>, <http://www.openmicroscopy.org/site OMERO> or use of <http://www.diplib.org DIPlib filters>.
% # Access help and tutorials from the menu of |im_browser|: |im_browser->Menu->Help->Help| 
%
%% Run Microscopy Image Browser as standalone (Windows, x64 bit)
% 
% # Download standalone distribution of the program (<http://mib.helsinki.fi/web-update/im_browser_distrib.zip im_browser_distrib.zip>). 
% Please note the version of Matlab (*Matlab 8.4 (R2014b)* for MIB version 0.998 and newer, or *Matlab 8.1 (R2013a)* for MIB version 0.997 and older) for which it was compiled
% # Download and install <http://www.mathworks.com/products/compiler/mcr/
% MATLAB Compiler Runtime (MCR)> *that is compatible* with the downloaded release of |MIB|
% # Unzip |im_browser_distrib.zip|
% # Start the file browser (Computer) and navigate to the directory where |im_browser| was unzipped (_see image below_). Type |cmd.exe| in
% the command line of the file browser to start the command prompt. Now the command prompt should start in the |im_browser| directory
% # Start |im_browser| by typing |MIB.exe|
% # It may take a while for program to start in this mode
% # Access help and tutorials from the menu of |MIB|: |im_browser->Menu->Help->Help|
% 
%
% <<images\standalone_starting.jpg>>
% 
%
% *Note!* If you want to use Fiji or Omero with the deployed version of |im_browser| you need to check _java_path.txt_ file
% in the directory of _im_browser.exe_. Please modify this file and set correct path to your Fiji application and Omero Java libraries.
% See more about Fiji in the <im_browser_system_requirements.html Fiji: Volume rendering and connection section>
%
%% Run Microscopy Image Browser as standalone (MacOS, x64 bit)
% _Tested with Mac OS X (Yosemite), version 10.10.3 and Matlab version 8.4 (R2014b)._
% 
% # Download standalone distribution of the program for Mac OS (<http://mib.helsinki.fi/web-update/im_browser_distrib_mac.zip im_browser_distrib_mac.zip>). 
% Please note the version of Matlab (*Matlab 8.4 (R2014b)* for MIB version 0.998 and newer) for which it was compiled
% # Download and install <http://www.mathworks.com/products/compiler/mcr/
% MATLAB Compiler Runtime (MCR)> *that is compatible* with the downloaded release of |MIB|
% # Unzip |im_browser_distrib_mac.zip| to
% *|./Users/[YourUserName]/Documents/MIB|*. *Note!* MIB will only work
% from this directory!
% # Start |im_browser| by double click on |./Users/[YourUserName]/Documents/MIB/MIB_Mac.app| using the Finder
% application
% # It may take a while for program to start in this mode
% # Access help and tutorials from the menu of |MIB|: |im_browser->Menu->Help->Help|
% 
%
% *Note!* If you want to use Fiji or Omero with the deployed version of |im_browser| you need to check _java_path.txt_ file
% in the directory of _im_browser.exe_. Please modify this file and set correct path to your Fiji application and Omero Java libraries.
% See more about Fiji in the <im_browser_system_requirements.html Fiji: Volume rendering and connection section>
%
%% Additional info
% |im_browser| stores its configuration parameters:
%
% * *Windows* in _c:\temp\im_browser.mat_ or when _c:\temp_ is not available then the configuration parameters can be found in
% _C:\Users\User-name\AppData\Local\Temp\im_browser.mat_
% * *Linux* in the script directory or in the local tmp directory (_/tmp_)
%
% The configuration file is automatically created after closing of |im_browser|.
%
% If |im_browser| does not start check Matlab path
% and/or delete _c:\tmp\im_browser.mat_ file.
%
%
% *Back to* <im_browser_product_page.html *Index*>