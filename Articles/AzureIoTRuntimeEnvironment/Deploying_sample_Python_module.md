# Deploying a sample Python module on an Edge Device installed with Azure IoT Edge Runtime

## Introduction

Azure IoT Runtime enables you to collect information and execute commands on Edge devices remotely. When installed on e-RT3 Plus, the features of both e-RT3 Plus and Azure Runtime Environment can be utilized to perform various operations.

This is part one of a five-part series that demonstrates how to use Azure Runtime Environment with e-RT3 Plus. In this article, we explore how to deploy a sample Python module on e-RT3 Plus and Raspberry Pi 4 Model B and update the values from Azure Portal.

We deploy two IoT Modules; a Simulated Temperature Sensor module that generates sample temperature values, and a Python module that uploads the temperature values to the IoT Hub whenever the temperature value crosses a threshold. We can view the uploaded temperature values on Visual Studio Code.

This demonstration is based on two Microsoft tutorials:

- [Develop IoT Edge modules with Linux containers](https://learn.microsoft.com/en-us/azure/iot-edge/tutorial-develop-for-linux?view=iotedge-1.4)
- [Develop and deploy a Python IoT Edge module using Linux containers](https://learn.microsoft.com/en-us/azure/iot-edge/tutorial-python-module?view=iotedge-1.4)

However, it is customized to show the procedure for the ARM 32-bit device.

## Environment

**Supported devices（OS)**

- e-RT3 Plus F3RP70-2L（Ubuntu 18.04 32-bit）
- Raspberry Pi 4 Model B （Ubuntu Server 18.04 32-bit）

The `armhf` architecture package runs on these devices.
The modules are developed on a computer installed with Windows 10.

## Workflow

The following figure shows the workflow for deploying a sample python module on e-RT3 Plus using Azure IoT runtime.

![workflow](assets/workflow.jpg)

## Prerequisites

Azure Runtime environment must be installed on the e-RT3 Plus or the Edge device that you are using. For more information about deploying Azure Runtime Environment on e-RT3 Plus, refer to [Deploying Azure Runtime Environment on e-RT3 Plus](https://github.com/Yokogawa-Technologies-Solutions-India/e-RT3-docs/blob/master/Articles/Local_blob_storage/Installing_Azure_Runtime_on_e-RT3.md).

The following software must be installed and configured before you start creating the sample Python module.

1. [Container Engine (Docker Desktop)](#setting-up-the-container-engine)
2. [Python](#installing-python)
3. [Visual Studio Code](#setting-up-visual-studio-code)

### Setting up the Container Engine

You must set up a container engine on the computer in which you want to develop the Python module. In this demonstration, we install the Docker Desktop container engine.

> **Note**: If your computer is in an environment that requires proxies to connect to the internet, you must configure the [Proxy settings](#docker).

Follow these steps to set up Docker Desktop on your computer:

1. Download [Docker Desktop](https://hub.docker.com/editions/community/docker-ce-desktop-windows/). For Windows Home and other operating systems, select the corresponding OS from the menu on the left and continue the installation. Ensure that you enable Hyper-V backend during installation.

    For more information on how to install Docker Desktop, refer to [Install Docker Desktop on Windows](https://docs.docker.com/desktop/install/windows-install/).

    >**Note**: Ensure that your computer meets the system requirements specified on [Install Docker Desktop on Windows](https://docs.docker.com/desktop/install/windows-install/) before installing Docker Desktop.

2. After the installation is complete, launch Docker Desktop from the Start menu.
   A notification appears, indicating that Docker Desktop is running and the container engine setup is complete. Ensure that Docker Desktop is successfully launched before proceeding.

    > **Note**:
    >
    >1. As we are using a Linux container, ensure that the notification "Linux Containers Hyper-V backend is launching..." is displayed.
    >2. Docker Desktop may fail to launch if the computer load is high. In this case, retry launching.

### Installing Python

Follow these steps to install Python on your computer:

1. Download the [Python installer](https://www.python.org/downloads/).

    >**Note**: To maintain compatibility with the Python module template, download Python 3.7.

2. Open the installer and click **Install Now**.
    Python is installed on your computer.
   > **Note**: In the installer dialog box, select the **Add Python 3.7 to PATH** check box.

### Setting up Visual Studio Code

Visual Studio Code is used for developing the IoT Edge module.

Follow these steps to install and configure Visual Studio Code:

1. Download the installer for Visual Studio Code from the [official website](https://code.visualstudio.com/).
   > **Note**: Ensure that you select a version that is compatible with your computer.
2. Start the installer and follow the steps in the installation wizard to complete the installation.
   If the installation is completed successfully, a message is displayed indicating the same.
3. To install Azure IoT Tools and Python extension features, on the left pane, click **Extensions** and perform the following operations:
   1. In the search bar, type `Azure IoT Tools` and click **Install** on the corresponding search result.

        Azure IoT Tools extension is downloaded and installed on Visual Studio Code.

        ![01_IntsallAzureExtension](assets/01_IntsallAzureExtension.png)

   2. In the search bar, type `Python` and click **Install** on the corresponding search result.

        Python extension is downloaded and installed on Visual Studio Code.

        ![02_InstallPythonExtension](assets/02_InstallPythonExtension.png)

4. To sign in to Azure, in the Command Palette, type `Azure: Sign In` and select the corresponding search result.

   ![03_SignIn](assets/03_SignIn.png)

5. Follow the instructions displayed to sign in.

    If you have successfully signed in, your account information is displayed at the bottom of the Visual Studio Code window.

   ![04_Accountdetails](assets/04_Accountdetails.png)

6. To select the IoT Hub, in the Command Palette, type `Azure IoT Hub: Select IoT Hub` and select the corresponding search result.

   ![05_SelectIoTHub](assets/05_SelectIoTHub.png)

7. Follow the instructions displayed and select **Azure subscription** and **IoT Hub**.

   ![06_SelectSubscription](assets/06_SelectSubscription.png)

   ![07_iotHub](assets/07_iotHub.png)

8. To view the IoT Hub and connected devices, on the left pane, select the file explorer and expand **AZURE IOT HUB**.

   The IoT Hub is displayed and the connected devices are listed under the Devices section.

   ![08_viewDevices](assets/08_viewDevices.png)

## Creating and deploying a module

To create, deploy and test an IoT Edge module, you must complete the following steps:

   1. [Create container registry](#creating-container-registry)
   2. [Create project](#creating-a-new-project)
   3. [Add registry credentials](#adding-registry-credentials)
   4. [Select target architecture](#selecting-target-architecture)
   5. [Update module with custom code](#updating-module-with-custom-code)
   6. [Build and push module](#building-and-pushing-the-module)
   7. [Deploy Simulated Temperature Sensor module](#deploying-simulated-temperature-sensor-module)
   8. [Deploy Python module](#deploying-python-module)
   9. [Verify the module operation](#verifying-module-operation)

### Creating container registry

To store the docker images, any registry that is compatible with docker can be used. In this demonstration, we use the Azure Container Registry.

> **Note**: Azure Container Registry is a paid service. For the pricing details, click [here](https://azure.microsoft.com/en-us/pricing/details/container-registry/).

Follow these steps to create a container registry:

1. Sign-in to [Azure Portal](https://portal.azure.com/).
2. In the upper-left corner of the page, click **+ Create a resource**.
3. From the left panel, select **Containers**.

   ![09_ContainerRegistry](assets/09_ContainerRegistry.png)

4. From the list of displayed services, select **Container Registry**.
5. In the **Information** tab, specify the following settings information:
      1. Subscription
      2. Resource group
      3. Registry name
      4. Location
      5. SKU
      >**Note**: SKU must be set to `Basic`.
6. Click the **Review + create** tab, and verify the setting information.
7. If the settings are configured correctly, click **Create**.

### Creating a new project

Follow these steps to create a new Edge IoT solution in Visual Studio Code:

1. Open Visual Studio Code.
2. In the Command Palette, type `Azure IoT Edge: New IoT Edge solution` and select the same from the search results.

    The folder selection box appears.
3. Specify the location where you want to save the project.
4. In the **Provide a Solution Name** box that appears in the Command Palette, specify a solution name.
5. From the Select Module Template drop-down list that appears in the Command Palette, specify **Python Module**.
6. In the **Provide a Module Name** box that appears in the Command Palette, specify a name for the module.

    The module name specified is reflected within the template and is considered as the module name in IoT Edge. Here, we have specified the name `PythonModule`.

    > **Note**: The module name of IoT Edge can also be modified individually before building the images.
7. In the **Provide Docker Image Repository** box that appears in the Command Palette, specify the address of the Container Registry login server.

    By default `localhost:5000` appears.

    To obtain the login server information, open Azure Portal and navigate to the Container registry that you created in [previous step](#creating-container-registry). On the left pane, under the **Settings** section, select **Access keys**. The login server information is displayed on the right.

    > **Note**: Ensure to save this information as it is required at a later stage.

    ![10_AccessKeys](assets/10_AccessKeys.png)
    ![13_AccessKeys](assets/13_AccessKeys.png)

8. Copy the Login server information `<registry_name>.azurecr.io` and paste it in the Command Palette in the format `<registry_name>.azurecr.io/<module_name>`.

    ![11_ModuleName](assets/11_ModuleName.png)

    The project template is created with the folder structure as shown below.

    ![12_ProjectFolderStructure](assets/12_ProjectFolderStructure.png)

### Adding registry credentials

Follow these steps to add the registry credentials:

1. To add the registry credentials, on the left pane, select the file explorer and open the `.env` file under the PythonModule folder.

    ```bash
    .env
    CONTAINER_REGISTRY_USERNAME_<registry name>=
    CONTAINER_REGISTRY_PASSWORD_<registry name>=
    ```

2. In the `CONTAINER_REGISTRY_USERNAME_<registry name>` and `CONTAINER_REGISTRY_PASSWORD_<registry name>` fields, specify the username and password, i.e.: the Access keys of the Container Registry.

    ```bash
    .env

    CONTAINER_REGISTRY_USERNAME_<registry name>=<username>
    CONTAINER_REGISTRY_PASSWORD_<registry name>=<password or password2>
    ```

    ![13_AccessKeys](assets/13_AccessKeys.png)

>**Note**: The password provided can be either password or password2.

### Selecting target architecture

Follow these steps to select the target architecture:

1. Click the current architecture at the bottom of the Visual Studio Code window.

    The **Select Azure IoT Edge Solution Default Platform** box appears in the Command Palette.

    ![14_targetArchitecture](assets/14_targetArchitecture.png)

2. Since we are using the `armhf` architecture, select `arm32v7`.

   The current architecture changes to `arm32v7`.

    > **Note**: If the current architecture is not displayed at the bottom of the window, type `Azure IoT Edge: Set Default Target Platform for Edge Solution` and select the same.
    ![14_1_targetArchitecture](assets/14_1_targetArchitecture.png)

### Updating module with custom code

Rewrite the contents of `main.py` and `deployment.template.json` by following the steps in [Update Modules with Custom Code](https://learn.microsoft.com/en-us/azure/iot-edge/tutorial-python-module?view=iotedge-1.4#update-the-module-with-custom-code), and save the file.

The Python module routes temperature values to the IoT Hub only if the value exceeds the defined threshold.

### Building and pushing the module

Follow these steps to build the created module and push the image to Container Registry:

1. From the menu bar, select **View** > **Terminal** to display the terminal pane.

    ![15_Terminal](assets/15_Terminal.png)

2. Run the following command in the terminal to log in to the Container Registry.

    ```bash
    docker login -u <username> -p <password or password2> <login server>
    ```

    > **Note**: If the required proxy settings are not configured then you will not be able to log into the Container Registry.
    For details about proxy settings, refer to [Proxy settings](#proxy-settings).

3. On the left pane, select File Explorer, right-click `deployment.template.json`, and select **Build and Push IoT Edge Solution**.

   The module is built and if there are no errors the image is pushed to the Container Registry.

    ![16_BuildandPush](assets/16_BuildandPush.png)

4. To verify that the images are pushed to the Container Registry, perform these steps:

   1. Open Azure Portal.
   2. Navigate to the Container Registry.
   3. On the left pane, click **Repositories**.

       The repositories page appears, displaying a list of images.
   4. Verify that your image is present in this list.
    ![17_imageList](assets/17_imageList.png)

### Deploying Simulated Temperature Sensor module

The Simulated Temperature Sensor module generates sample temperature readings periodically which increase in value over time. This module is readily available for deployment in Azure Marketplace.

We will deploy this module and route the generated temperature values as input to the Python module.

Follow these steps to deploy the Simulated Temperature Sensor:

1. Open [Azure Portal](https://portal.azure.com/).
2. Navigate to the IoT Hub that you created.
3. From the left pane, under the **Device management** section, click **IoT Edge**.
4. On the right pane, click the device ID of the target device on which you want to deploy the module.

    ![SetModules](assets/samplemod-1.png)
5. Click **Set modules** tab.

    The *Set modules on device* page appears.

    ![addmoduleMarketplace](assets/samplemod-2.png)
6. In the **IoT Edge Modules** section, click the **Add** drop-down menu, and select **Marketplace Module**.

    The *IoT Edge Module Marketplace* page appears.

   ![marketplace](assets/samplemod-3.png)

7. In the search box, type `simulated temperature sensor` and select the same from the search results.

    The module is added to the IoT Edge Modules section with the Desired Status as `running`.

   ![modulerunning](assets/samplemod-4.png)

8. Click the **Review + create** tab.

   The deployment settings in the standard JSON format is displayed.

9. In the upper-left corner of the page, ensure that the message `Validation passed` is displayed and then click **Create**.

   ![SetModules](assets/samplemod-5.png)

The device details page appears, displaying the deployment status of the Simulated Temperature Sensor on the **Modules** tab.

> **Note**: If the Edge device is in an environment that requires proxies to connect to the internet, the telemetry sent to IoT Hub may be blocked and not delivered even when the module is correctly deployed and working.
In such cases, you must configure the Proxy settings for `$edgeHub` module. For more information about the proxy settings refer to [Configure proxy support](https://learn.microsoft.com/en-us/azure/iot-edge/how-to-configure-proxy-support?view=iotedge-2018-06#azure-portal).

### Deploying Python module

After pushing the images to the Container Registry, we must deploy it on the Edge device.

Follow these steps to deploy the images from Azure Portal:

1. Open [Azure Portal](https://portal.azure.com/).
2. Navigate to the IoT Hub that you created.
3. From the left pane, under the **Device management** section, click **IoT Edge**.
4. On the right pane, click the device ID of the target device on which you want to deploy the module.
5. Click **Set modules** tab.

    ![18_SetModules](assets/18_SetModules.png)

6. In the **Modules** tab, specify the details mentioned in the following table.

    |Setting items of module |Information to be entered|
    |---|---|
    |NAME| Registry name|
    |ADDRESS|Login server|
    |USERNAME|User name|
    |PASSWORD|Password or password2|

    ![19_Modules](assets/19_Modules.png)

    To obtain the Registry name, Login Server details, username and password, refer to step 7 in [Creating a new project](#creating-a-new-project).

7. To configure the settings of the IoT Edge module, click **+Add** and then select **IoT Edge Module** from the drop-down list.

   ![20_IoTEdgeModule](assets/20_IoTEdgeModule.png)

8. Configure the parameters of the IoT Edge module as described in the following table and click **Add**.

    | Setting item of module |Information to be entered|
    |---|---|
    |IoT Edge Module Name|The module name|
    |Image URI|Image URI  obtained from the repository of Container Registry. For information about how to obtain the image URI, refer to [Image URI](#image-uri).|
    |Restart Policy| Always (retain default settings)|
    |Desired Status| Running (retain default settings)|

9. Click the **Routes** tab and configure the details as described in the following table.

    |NAME|VALUE|
    |---|---|
    |PythonModuleToIoTHub|FROM /messages/modules/PythonModule/outputs/* INTO $upstream|
    |sensorToPythonModule|FROM /messages/modules/SimulatedTemperatureSensor/outputs/temperatureOutput INTO BrokeredEndpoint(‘/modules/PythonModule/inputs/input1’)|

    ![22_SetModules](assets/22_SetModules.png)

10. Click **Review + create** and verify the configuration information.

    In the upper-left corner of the screen, the message "Validation passed" is displayed.

    ![23_reviewCreate1](assets/23_reviewCreate1.png)
    ![24_reviewCreate2](assets/24_reviewCreate2.png)
    ![25_reviewCreate3](assets/25_reviewCreate3.png)

11. After verifying the configuration information, in the lower-left corner of the page, click **Create**.

    The *Device settings* page appears, and the module list is displayed. It usually takes some time to complete the deployment.

    ![26_ModuleList](assets/26_ModuleList.png)

12. Click **Refresh**.

    The Module list is updated and you can see the module that you deployed to the Edge device is added to the Modules list and the status details are displayed.

### Verifying module operation

After viewing the telemetry messages received from the Edge device in the IoT Hub, we can confirm that the deployed module is working.

In this section, we describe how you can verify module operation by using **Visual Studio Code**.

Follow these steps to verify the reception of telemetry messages at the IoT Hub:

1. Open the project created in [Creating a new project](#creating-a-new-project) in Visual Studio Code.

    ![27_StartMonitoring](assets/27_StartMonitoring.png)

2. On the left pane, right-click your Azure IoT Device, and select `Start Monitoring Built-in Event Endpoint`

   The messages received at the IoT Hub are displayed in the **OUTPUT** tab.

    ![28_receivedOutput](assets/28_receivedOutput.png)

3. To stop receiving messages, in the lower-left corner of the window, click **Stop Monitoring built-in event endpoint**.

    ![27_StartMonitoring](assets/29_StopMonitoring.png)

> **Note**: The maximum number of messages that can be sent in the case of the Simulated Temperature Sensor is 500. If you want to send more messages, you must restart the module by running the following command in the terminal:
>
>    ```bash
>    sudo iotedge restart SimulatedTemperatureSensor
>    ```
>
> You can restart the other module by replacing `SimulatedTemperatureSensor` with the required module ID.
>
>    ```bash
>    sudo iotedge restart <Module ID>

## Editing Module Twin

By editing the module twin, the features of the sample module used can be edited without having to build or deploy the module again.
In this example, let us edit the module twin of the deployed Python module to change the threshold value of the temperature of the machine that notifies IoT Hub.

Follow these steps to edit the module twin from Azure Portal:

1. Open [Azure Portal](https://portal.azure.com/) and navigate to the IoT Hub that you created.
2. From the **Device management** category, display the IoT Edge device.
3. Click the device ID of the target device.
4. Click **Set modules**.
5. From the list of IoT Edge modules, select the Python module that you deployed.

    The *Update IoT Edge Module*  page appears.
6. Click the **Module Twin Settings** tab.
7. In the editor, enter the `TemperatureThreshold` details in JSON format.
8. In the lower-left corner of the screen, click **Apply**.

    The following example shows how to set the threshold value of the machine temperature to 40 degrees.

    ![33_editTwin](assets/33_editTwin.png)

9. Click **Review + Create**.

    The verification page appears, displaying the configured deployment in standard JSON format. You can view the updated temperature threshold here.

    After confirming the deployment configuration and checking for the "Validation passed" message in the upper-left corner of the screen, click **Create**.

    ![34_ReviewEditModule](assets/34_ReviewEditModule.png)

When you view the data generated by following the same procedure as [Verifying module operation](#verifying-module-operation), you can see that the new threshold value has come into effect.

For example, if you changed the temperature threshold from 30 to 40, you will see that the Python module stops sending messages until the generated temperature values start exceeding 40℃. Subsequently, on the **OUTPUT** tab of Visual Studio Code, the messages are displayed only when the temperature values exceed 40℃.

## Conclusion

As you have seen, the messages sent by the Edge device are received at the IoT Hub. Additionally, updates to the Twin Module in Azure Portal are reflected in the Edge device.

In our future articles, we will explore how to collect data using a Python module in Azure IoT Edge and send it to an IoT Hub.

## Appendix

### Image URI

To obtain the image URI, follow these steps:

1. Navigate to the images stored in the container registry as shown in step 4 of [Build and Push modules](#building-and-pushing-the-module).
2. Select the ID of the module you want to deploy.

    The repository details are displayed.
3. From the Docker pull command box, the content displayed after `docker pull` is the image URI.
    ![34_DockerPull](assets/34_DockerPull.png)

    The image URI is in the format  `<registry name>.azurecr.io/<module name>:<tag>`.

    For example in the following image, the URI is `<registry name>.azurecr.io/pythonmodule:0.0.1-arm32v7`.

    ![21_AddIoTEdgeModule](assets/21_AddIoTEdgeModule.png)

### Proxy settings

If you are using a proxy server in your environment then you must configure the proxy settings for Visual Studio Code and Docker Desktop.

The proxy settings described in this section are an example of what was used for this demonstration. Depending on your environment, you must configure the proxy settings as necessary.

#### Visual Studio Code

Proxy settings for Visual Studio Code are required when logging in from Visual Studio Code to Azure.

Follow these steps to configure the proxy settings in Visual Studio Code.

1. Open Visual Studio Code.
2. From the menu bar, select **File > User settings > Settings**.

   The *Settings* page is displayed.
3. To display the proxy settings, in the search box, type `proxy`.

    The `Http:Proxy` search result is displayed.

     ![35_VSCodeProxy](assets/35_VSCodeProxy.png)

4. In the **Http:Proxy** box, specify the proxy URL based on your environment. For example, `http://username:password@example.com:port/`

    The proxy information is saved in the settings file in the following location.
    `C:\Users\username\AppData\Roaming\Code\User\settings.json`

    For environment details, contact your network administrator.

#### Docker

Proxy settings for Docker are required when logging in to Container Registry from the Visual Studio Code Terminal and pushing images.

For more information about configuring proxy settings in Docker, refer to the [Docker official document](https://docs.docker.com/network/proxy/).

Follow these steps to configure the proxy settings:

1. Use any editor to open the `config.json` file from the following folder location. `C:\Users\username\.docker`.

    >**Note**: If the file does not exist, create it.

2. Specify the proxy information in `config.json` by following the procedure mentioned in [Configure the Docker Client](https://docs.docker.com/network/proxy/#configure-the-docker-client).

3. If `config.json` is already created, there is a possibility that settings other than Proxy settings are specified in the file. In such cases, specify the configuration such that the label name is the same as the already existing labels.

    The following shows the `httpProxy` and `httpsProxy` configurations used in this demonstration.

    ```JSON
    {
        "HttpHeaders":
        {
            "User-Agent":"Docker-Client/19.03.13 (windows)"
        },
        "auths":
        {
            "<registry name 1>.azurecr.io":{},
            "https://index.docker.io/v1/":{},
            "<registry name 2>.azurecr.io":{}
        },
        "credStore":"desktop",
        "credsStore":"desktop",
        "proxies":
        {
            "default":     
            {
                "httpProxy":"http://username:password@example.com:port/",
                "httpsProxy":"http://username:password@example.com:port/"
            }
        },
        "stackOrchestrator":"swarm"
    }
    ```

    As you can see, some of the configurations already existed. Here, we have added the `proxies` configuration.

4. To configure the proxy settings in Docker Desktop, perform these steps:
     ![36_docker](assets/36_docker.png)
   1. On the toolbar, click the arrow to open the tool tray.
   2. Right-click the Docker Desktop icon and select **Settings**.
   3. Expand **Resources** and select **PROXIES**.
   4. In the **Web Server (HTTP)** box, specify the proxy URL.
   5. In the **Secure Web Server (HTTPS)** box, specify the proxy URL.
   6. Click **Apply & Restart**.

## References

1. [Real-time OS controller e-RT3 Plus F3RP70-2L](https://www.yokogawa.com/solutions/products-and-services/control/control-devices/real-time-os-based-machine-controllers/#Overview)
2. [Azure Certified Device catalog](https://devicecatalog.azure.com/)
3. [Tutorial: Develop IoT Edge module for Linux device](https://learn.microsoft.com/en-us/azure/iot-edge/tutorial-develop-for-linux?view=iotedge-1.4)
4. [Tutorial: Develop and deploy Python IoT Edge module for Linux device](https://learn.microsoft.com/en-us/azure/iot-edge/tutorial-python-module?view=iotedge-1.4)
5. [Configure Docker to use a proxy server](https://docs.docker.com/network/proxy/)
