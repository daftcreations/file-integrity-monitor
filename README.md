# File Integriy Monitor
This is a simple powershell script which continuously monitor the changes in your file or a directory and shows alert when it detects any changes.

# Usage
<img src="/uploads/filemonitor.gif" width="90%" alt="file monitor"/>

# Installation
Execution Policy is on Restricted by default in Powershell, to change it enter the below command in Powershell
<pre>
<code># Start powershell in administrator mode
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
</code></pre>
Clone the respository and run the script
<pre><code>
git clone https://github.com/mmbverse/file-integrity-monitor
cd file-integrity-monitor
.\file-monitor.ps1
</code></pre>
