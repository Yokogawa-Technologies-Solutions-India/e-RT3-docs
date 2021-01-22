# Communication with e-RT3 Plus (remote)

## Introduction

### What is e-RT3 Plus?

<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The e-RT3 Plus is an industrial AI platform that runs on a Linux OS. With Ubuntu as its operating system, the e-RT3 Plus is designed with AI applications in mind. This industrial AI platform enables you to develop applications using the Python machine learning libraries. With a wealth of I/O modules, e-RT3 Plus could be used for data acquisitions or analysis and control.

<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;e-RT3 Plus can seamlessly connect from the local equipment to the higher level system and help you realize application development exceeding the boundary between IT and OT.

Follow the links to check out [Applications](https://www.yokogawa.com/solutions/products-platforms/data-acquisition/ai-product-solutions/) and [Features](https://www.yokogawa.com/solutions/products-platforms/control-system/ert3-embedded-controller/ert3-ai-platform/).

![Overview](assets/intro_v2.png)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;![alt text](assets/ert3.PNG)
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;As e-RT3 Plus is an edge device, the user cannot connect to it with physical connections every time. Sometimes the user needs to connect to it remotely. Therefore, e-RT3 Plus provides connection through a browser and SSH connection with the help of PuTTY. </p>

---

## Connecting to e-RT3 Plus from browser
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The browser based connection allows the user to perform limited tasks like monitoring the device and CPU settings.</p>

---

### Establishing browser based connection by e-RT3 Plus

<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;In order to establish a browser based connection, the user must be aware of the IP address and should belong to same network. </p>

### Steps
1. Make sure you belong to the same network as the device.
2. Type in the IP address of e-RT3. (By default, 192.168.3.72). It opens the website which looks like the following image.
3. Now the user can perform tasks like monitoring the device and CPU setting<br><br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;![alt text](assets/Home_new.PNG)<br>
This is how the user can access the device through a browser

---

## Communicating  with e-RT3 Plus by SSH
<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;With the help of SSH connection, user can perform many tasks. But in order to connect by SSH, user needs to have PuTTY installed in their system and should be aware of the IP address and the login credentials of the device. </p>

---

### Establishing SSH connection to e-RT3 Plus
### Steps

1. Make sure you belong to same network as device.
2. Open PuTTY and type in the IP address of e-RT3. (By default, 192.168.3.72) and hit enter. <br><br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;![alt text](assets/ip_new.png)<br><br>
3. When establishing connection for the first time, the PuTTY Security Alert dialog is displayed. Click “Yes” to continue. <br><br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;![alt text](assets/security.PNG)<br><br>
4. Now it will ask for user id and password. Enter the user id and password. But only normal user can access e-RT3 Plus with SSH with the default settings. <br><br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;![alt text](assets/login_new.png)<br><br>
5. Now the user is good to perform different tasks. <br><br>

   User can perform tasks like 
   1. adding new user (only with root access),
   2. deleting user (only with root access),
   3. changing password (only with root access),
   4. installing applications (only with root access),
   5. updating the applications (only with root access),
   6. create new folders,
   7. deleting the folders,
   8. copying a file,
   9. moving a file, etc. 

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The SSH connection provides the safest communication between the user and the device and it is most preferred by developers. The browser based connection has limited tasks that can be performed. But both connections let the user to connect to e-RT3 Plus easily.</p>

---
